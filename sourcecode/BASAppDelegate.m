//
//  BASAppDelegate.m
//  OfigennoParser
//


#import "BASAppDelegate.h"
#import "BASMainViewController.h"
#import "BASMagazineViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "BASChatViewController.h"
#import "BASInfoViewController.h"

@implementation BASAppDelegate

- (BASTabView*) tabView{
    
    if(_tabView == nil){
        CGRect frame = [[UIScreen mainScreen]bounds];
        UIImage * image = [UIImage imageNamed:@"tabbar_bg.png"];
        UINavigationController* nav = [[UINavigationController alloc]initWithRootViewController:nil];
        CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
        hight = nav.navigationBar.frame.size.height + statusBarFrame.size.height;
         self.tabView = [[BASTabView alloc]initWithFrame:CGRectMake(0, frame.size.height  - image.size.height - nav.navigationBar.frame.size.height - statusBarFrame.size.height, image.size.width, image.size.height)];

        
    }
    return _tabView;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
                                                                                             |UIRemoteNotificationTypeSound
                                                                                             |UIRemoteNotificationTypeAlert) categories:nil];
        [application registerUserNotificationSettings:settings];
        
    } else {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:myTypes];
    }
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.isInit = NO;
    self.isShowMessage = NO;
    
    
    
    [[BASManager sharedInstance]initSocket];
    
  
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.isPurchaise = (BOOL)[userDefaults objectForKey:@"isPurchaise"];
    //self.isPurchaise = YES;
    self.login = [userDefaults objectForKey:@"login"];
    self.pass = [userDefaults objectForKey:@"password"];
    self.UID = [[[UIDevice currentDevice] identifierForVendor]UUIDString];
    self.userInfo = [userDefaults objectForKey:@"userInfo"];
    NSNumber* logType = (NSNumber*)[userDefaults objectForKey:@"loginType"];
    self.loginType = (TypeLogin)[logType intValue];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.internetReachable = [Reachability reachabilityForInternetConnection];
    [self.internetReachable startNotifier];
    [self testInternetConnection];

    [self customizeNavBarAppearance];
    
    self.mainController = [BASMainViewController new];
    self.infoController = [BASInfoViewController new];
    self.inputController = [BASInputViewController new];
    self.guestController = [BASGuestInputViewController new];
    self.magazineController = [BASMagazineViewController new];
    
    if(_login == nil ){
       self.chatController = [[BASChatViewController alloc]init];
       self.navigationController = [[UINavigationController alloc]initWithRootViewController:_mainController];
       self.window.rootViewController = _navigationController;
    }


    
    [self performSelector:@selector(openLoginScreen) withObject:nil afterDelay:3.5];
    if(IS_IPHONE_5){
        self.window.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Default-568h@2x.png"]];
    } else if(IS_IPHONE_6){
        self.window.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Default-6@2x.png"]];
    }  else if(IS_IPHONE_6_PLUS){
        self.window.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Default-6+@3x.png"]];
    }
    [self showIndecator:YES withView:self.window];
    
    [self.window makeKeyAndVisible];
    
    
    
    return YES;
}
-(void)openLoginScreen{
    [self showIndecator:NO withView:self.window];
    
    if(_login != nil ){
        [[BASManager sharedInstance] LogIn];
    }
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    return  YES;
}


- (void)showMessage:(NSString*)message{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}
-(void) checkNetworkStatus:(NSNotification *)notice
{
    // called after network status changes
    NetworkStatus internetStatus = [_internetReachable currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable:
        {
            NSLog(@"The internet is down.");
            self.internetActive = NO;
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"The internet is working via WIFI.");
            self.internetActive = YES;
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"The internet is working via WWAN.");
            self.internetActive = YES;
            break;
        }
    }
    
}
- (BOOL)testInternetConnection
{
    NetworkStatus internetStatus = [_internetReachable currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable:
        {
            NSLog(@"The internet is down.");
            self.internetActive = NO;
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"The internet is working via WIFI.");
            self.internetActive = YES;
            self.isWWAN = NO;
            break;
        }
        case ReachableViaWWAN:
        {
            NSLog(@"The internet is working via WWAN.");
            self.internetActive = YES;
            if(!self.isWWAN){
                NSString* mess = @"Для эффективной работы приложения используйте WIFI соединение";
                [self showMessage:mess];
                self.isWWAN = YES;
            }
            
            break;
        }
    }
    
    return self.internetActive;
    
}
- (void) noInternetConnection{
    NSString* mess = @"Интернет-соединение отсутствует. Пожалуйста, проверьте подключение и повторите попытку.";
    [self showMessage:mess];
}


- (void)customizeNavBarAppearance
{

    
   // [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackTranslucent];
  //  [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbar_bg_new.png"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBackgroundImage:[BASAppDelegate imageFromColor:[UIColor colorWithRed:175/255.0 green:218/255.0 blue:174/255.0 alpha:1]] forBarMetrics:UIBarMetricsDefault];
    
   /* [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           UITextAttributeTextColor: [UIColor colorWithRed:255.0/255.0 green:164.0/255.0 blue:65.0/255.0 alpha:1.0],
                                                           UITextAttributeTextShadowColor: [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8],
                                                           UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0, 1)],
                                                           UITextAttributeFont: [UIFont fontWithName:@"Cartonsix NC" size:40.0],
                                                           }];*/
}


- (BOOL) is4InchScreen{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568) {
        return YES;
    }
    return NO;
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    NSLog(@"Received notification: %@", userInfo);
    NSDictionary* dict = (NSDictionary*)[userInfo objectForKey:@"aps"];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Сообщение" message:(NSString*)[dict objectForKey:@"alert"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}
#endif

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken  {
    NSLog(@"My token is: %@", deviceToken);
    NSString* myString = [NSString stringWithFormat:@"%@",deviceToken];
    myString = [myString stringByReplacingOccurrencesOfString:@"<" withString:@""];
    myString = [myString stringByReplacingOccurrencesOfString:@">" withString:@""];
    self.pushToken = myString;
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    
}

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"Received notification: %@", userInfo);
    NSDictionary* dict = (NSDictionary*)[userInfo objectForKey:@"aps"];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Сообщение" message:(NSString*)[dict objectForKey:@"alert"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
}
/*- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    
    if ([[window.rootViewController presentedViewController]
         isKindOfClass:[MPMoviePlayerViewController class]] || [[window.rootViewController presentedViewController] isKindOfClass:NSClassFromString(@"MPInlineVideoFullscreenViewController")] || [[window.rootViewController presentedViewController] isKindOfClass:NSClassFromString(@"AVFullScreenViewController")]) {
        
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }else {
        
        if ([[window.rootViewController presentedViewController]
             isKindOfClass:[UINavigationController class]]) {
            
            // look for it inside UINavigationController
            UINavigationController *nc = (UINavigationController *)[window.rootViewController presentedViewController];
            
            // is at the top?
            if ([nc.topViewController isKindOfClass:[MPMoviePlayerViewController class]]) {
                return UIInterfaceOrientationMaskAllButUpsideDown;
                
                // or it's presented from the top?
            } else if ([[nc.topViewController presentedViewController]
                        isKindOfClass:[MPMoviePlayerViewController class]]) {
                return UIInterfaceOrientationMaskAllButUpsideDown;
            }
        }
    }
    
    return UIInterfaceOrientationMaskPortrait;
}*/
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
   
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if(!self.isInit){
        _isInit = YES;

    }
    [[BASManager sharedInstance] resetWebSocket];
    
    [FBAppEvents activateApp];
    [FBAppCall handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[BASManager sharedInstance]closeSocket];
}
- (void)showIndecator:(BOOL)state withView:(UIView*)view{
    if(state){
        
        CGRect frame = [[UIScreen mainScreen]bounds];
        CGFloat posY = 75.f;
        if(IS_IPHONE_6){
            posY = 85.f;
        }  else if(IS_IPHONE_6_PLUS){
            posY = 95.f;
        }
        UIView *secondaryImage = [[UIView alloc] initWithFrame:CGRectMake(0,0,70,70)];
        secondaryImage.center = CGPointMake(frame.size.width / 2, frame.size.height / 2 - posY);
        secondaryImage.backgroundColor = [UIColor blackColor];
        secondaryImage.alpha = 0.9;
        secondaryImage.layer.cornerRadius = 12;
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        indicator.center = CGPointMake(35, 35);
        [indicator setHidesWhenStopped:NO];
        [secondaryImage addSubview:indicator];
        [indicator startAnimating];
        secondaryImage.tag = 1607;
        
        [view addSubview:secondaryImage];
    }else {
        [[view viewWithTag:1607] removeFromSuperview];
        
    }
    
}

+ (UIImage *)imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
