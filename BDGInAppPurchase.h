//
//  BDGInAppPurchase.h
//
//  Created by Bob de Graaf on 01-02-14.
//  Copyright (c) 2014 GraafICT. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BDGIAPDelegate <NSObject>
-(void)didFailIAP;
-(void)didCancelIAP;
-(void)didPurchaseIAP;
-(void)didRestoreIAP:(NSString *)productID;
@optional
-(void)didFailToRestoreIAP:(NSString *)productID;
@end

@interface BDGInAppPurchase : NSObject
{
    
}

-(void)restoreIAP;
-(void)purchaseIAP;

@property(nonatomic,strong) NSString *productID;
@property(nonatomic,assign) id<BDGIAPDelegate> delegate;

+(BDGInAppPurchase *)sharedBDGInAppPurchase;

@end