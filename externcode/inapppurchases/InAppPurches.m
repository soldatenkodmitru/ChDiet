//
//  InAppPurches.m
//  AvatarCreate
//
//  Created by Sergey on 03.07.14.
//  Copyright (c) 2014 BestAppStudio. All rights reserved.
//

#import "InAppPurches.h"
#import "MKStoreObserver.h"
#import "BASMainViewController.h"


@interface InAppPurches()

@property (strong, nonatomic) SKProduct *product;
@property (strong, nonatomic) SKPayment *payment;
@property (strong, nonatomic) MKStoreObserver *observer;

@end

@implementation InAppPurches

- (id) init
{
    if (self = [super init]){
        self.observer = [[MKStoreObserver alloc] init];
        _observer.delegate = (id<MKStoreObserverDelegate>)self;
        [[SKPaymentQueue defaultQueue] addTransactionObserver:_observer];
    }
    return self;
}

- (void)setProductID:(NSString *)productID{
    _productID = productID;

    if([_productID isEqualToString:restorefeatureId]){
        [[ SKPaymentQueue defaultQueue ] restoreCompletedTransactions ];
    } else {
        [self getProductInfo];
    }
}


- (void)buyProduct{

    //self.payment = [SKPayment paymentWithProductIdentifier:_productID];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Данная услуга платная, желаете купить ее?" delegate:self cancelButtonTitle:@"Отменить" otherButtonTitles:@"Купить", nil];
    //	alertView.tag = kInAppPurchasesAlertViewTag;
    [alertView show];
    
   
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    TheApp;
    if (alertView.cancelButtonIndex != buttonIndex) {
        if (buttonIndex == 1) { //purchase in app
            self.payment = [SKPayment paymentWithProduct:_product];
            [[SKPaymentQueue defaultQueue] addPayment:_payment];
      //  } else { //restore purchases
       //     [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
        }
    }
    else{
        _productID = nil;
        [app showIndecator:NO withView:app.window];
        
        [app.mainController setButtonPressedNO];
    }
}
-(void)getProductInfo
{
 
    if ([SKPaymentQueue canMakePayments]){
        
        SKProductsRequest *request = [[SKProductsRequest alloc]
                                      initWithProductIdentifiers:
                                      [NSSet setWithObject:_productID]];
        request.delegate = (id)self;
        
        [request start];
    }
}

#pragma mark -
#pragma mark SKProductsRequestDelegate

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *products = response.products;
    
    NSLog(@"The product request didReceiveResponse :%@",[response description]);
    NSLog(@"The products are :%@",[response.products description]);
    NSLog(@"The invalidProductIdentifiers are:%@",[response.invalidProductIdentifiers description]);
  
    for(SKProduct *currentProduct in products){
        
        NSLog(@"THE Product price is :%@",currentProduct.price);
        NSLog(@"THE Product description is :%@",currentProduct.localizedDescription);
        NSLog(@"THE Product title is :%@",currentProduct.localizedTitle);
        NSLog(@"THE Product's product identifier is :%@",currentProduct.productIdentifier);
        
    }

    if (products.count != 0){
        _product = (SKProduct*)products[0];
        [self buyProduct];
    }
    
    products = response.invalidProductIdentifiers;
    
    for (SKProduct *product in products)
    {
        NSLog(@"Product not found: %@", product);
    }

}

#pragma mark -
#pragma mark SKPaymentTransactionObserverDelegate
    
- (void) failedTransaction: (SKPaymentTransaction *)transaction{
    TheApp;
    NSLog(@"Error: %@",transaction.error);
    _productID = nil;
    [app showIndecator:NO withView:app.window];
    
    [app.mainController setButtonPressedNO];
}
- (void) completeTransaction: (SKPaymentTransaction *)transaction{
     NSLog(@"Date: %@",transaction.transactionDate);
    if([_delegate respondsToSelector:@selector(unlockFeatureForDate:)])
        [_delegate unlockFeatureForDate:transaction.transactionDate];
}
- (void) restoreTransaction: (SKPaymentTransaction *)transaction{
    
     NSLog(@"Date: %@",transaction.originalTransaction.transactionDate);
   NSLog(@"restore");
    if([_delegate respondsToSelector:@selector(unlockFeatureForDate:)])
        [_delegate unlockFeatureForDate:transaction.originalTransaction.transactionDate];
}
@end
