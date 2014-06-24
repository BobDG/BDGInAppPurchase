//
//  BDGInAppPurchase.h
//
//  Created by Bob de Graaf on 01-02-14.
//  Copyright (c) 2014 GraafICT. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BDGIAPDelegate <NSObject>
-(void)didEndIAS;
-(void)didFailIAS;
-(void)didFailIAP;
-(void)didCancelIAP;
-(void)didPurchaseIAP;
-(void)didRestoreIAP:(NSString *)productID;
-(void)dismissVC;
-(void)presentVC:(UIViewController *)viewController;
@optional
-(void)didFailToRestoreIAP:(NSString *)productID;
@end

@interface BDGInAppPurchase : NSObject
{
    
}

-(void)restoreIAP;
-(void)purchaseIAP;
-(void)buyApp:(NSString *)appID;
-(void)reviewApp:(NSString *)appID;
-(void)buyAppInApp:(NSString *)appID;

@property(nonatomic,strong) NSString *productID;
@property(nonatomic,strong) NSString *affiliateID;
@property(nonatomic,assign) id<BDGIAPDelegate> delegate;

+(BDGInAppPurchase *)sharedBDGInAppPurchase;

@end