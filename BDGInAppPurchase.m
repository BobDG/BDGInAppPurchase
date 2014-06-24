//
//  BDGInAppPurchase.m
//
//  Created by Bob de Graaf on 01-02-14.
//  Copyright (c) 2014 GraafICT. All rights reserved.
//

#import <StoreKit/StoreKit.h>

#import "BDGInAppPurchase.h"

@interface BDGInAppPurchase () <SKRequestDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver, SKStoreProductViewControllerDelegate>

@end

@implementation BDGInAppPurchase

#pragma mark Init

-(instancetype)init
{
    self = [super init];
    if(self) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

#pragma mark Public methods

-(void)purchaseIAP
{
    SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:self.productID]];
    request.delegate = self;
    [request start];
}

-(void)restoreIAP
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

-(void)buyApp:(NSString *)appID
{
    NSString *urlStr = [NSString stringWithFormat:@"http://itunes.apple.com/app/id%@", appID];
    [self openURL:urlStr];
}

-(void)reviewApp:(NSString *)appID
{
    NSString *urlStr = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", appID];
    [self openURL:urlStr];
}

-(void)buyAppInApp:(NSString *)appID
{
    SKStoreProductViewController *storeProductViewController = [[SKStoreProductViewController alloc] init];
    [storeProductViewController setDelegate:self];
    [storeProductViewController loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier:appID} completionBlock:^(BOOL result, NSError *error) {
        if(error) {
            NSLog(@"BDGInAppPurchase error: %@, User Info %@", [error description], [error userInfo]);
            if([self.delegate respondsToSelector:@selector(didFailIAS)]) {
                [self.delegate didFailIAS];
            }
        }
        else {
            if([self.delegate respondsToSelector:@selector(presentVC:)]) {
                [self.delegate presentVC:storeProductViewController];
            }
        }
    }];
}

#pragma mark OpenURL

-(void)openURL:(NSString *)urlStr
{
    if(self.affiliateID.length>0) {
        urlStr = [NSString stringWithFormat:@"%@?at=%@", urlStr, self.affiliateID];
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
}

#pragma mark SKStoreProductViewControllerDelegate methods

-(void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    if([self.delegate respondsToSelector:@selector(dismissVC)]) {
        [self.delegate dismissVC];
    }
    if([self.delegate respondsToSelector:@selector(didEndIAS)]) {
        [self.delegate didEndIAS];
    }
}

#pragma mark - SKProductsRequestDelegate methods

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *myProducts = response.products;
    for(SKProduct *product in myProducts) {
        if([product.productIdentifier isEqualToString:self.productID]) {
            SKPayment *payment = [SKPayment paymentWithProduct:product];
            [[SKPaymentQueue defaultQueue] addPayment:payment];
            break;
        }
    }
}

#pragma mark - Updating transaction methods

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for(SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

#pragma mark - Restoring transactions

-(void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    for(SKPaymentTransaction *transaction in queue.transactions) {
        if([self.delegate respondsToSelector:@selector(didRestoreIAP:)]) {
            [self.delegate didRestoreIAP:transaction.payment.productIdentifier];
        }
    }
}

-(void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    NSLog(@"BDGInAppPurchase: Restore completed transactions failed, error: %@", [error description]);
    for(SKPaymentTransaction *transaction in queue.transactions) {
        if([self.delegate respondsToSelector:@selector(didFailToRestoreIAP:)]) {
            [self.delegate didFailToRestoreIAP:transaction.payment.productIdentifier];
        }
    }
}

#pragma mark - Private methods

-(void)completeTransaction:(SKPaymentTransaction *)transaction
{
    if([transaction.payment.productIdentifier isEqualToString:self.productID]) {
        if([self.delegate respondsToSelector:@selector(didPurchaseIAP)]) {
            [self.delegate didPurchaseIAP];
        }
    }
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

-(void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    if([self.delegate respondsToSelector:@selector(didRestoreIAP:)]) {
        [self.delegate didRestoreIAP:transaction.payment.productIdentifier];
    }
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

-(void)failedTransaction:(SKPaymentTransaction *)transaction
{    
    if(transaction.error.code == SKErrorPaymentCancelled) {
        if([self.delegate respondsToSelector:@selector(didCancelIAP)]) {
            [self.delegate didCancelIAP];
        }
    }
    else {
        NSLog(@"BDGInAppPurchase: Failed transaction error: %@", transaction.error.description);
        if([self.delegate respondsToSelector:@selector(didFailIAP)]) {
            [self.delegate didFailIAP];
        }
    }    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

#pragma mark Singleton

+(id)sharedBDGInAppPurchase
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark Dealloc

-(void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

@end














