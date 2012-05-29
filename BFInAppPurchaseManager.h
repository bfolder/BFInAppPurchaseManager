//
//  BFInAppPurchaseManager.h
//
//  Created by Heiko Dreyer on 26.04.12.
//  Copyright (c) 2012 boxedfolder.com. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import <Foundation/Foundation.h>

// Notifications
#define BFInAppPurchaseManagerDidRecieveProductsNotification @"BFInAppPurchaseManagerDidRecieveProductsNotification"

#define BFInAppPurchaseManagerProductTransactionDidSucceedNotification @"BFInAppPurchaseManagerProductTransactionDidSucceedNotification"
#define BFInAppPurchaseManagerProductTransactionDidFailNotification @"BFInAppPurchaseManagerProductTransactionDidFailNotification"

// Keys
#define BFInAppPurchaseManagerProductArray @"BFInAppPurchaseManagerProductArray"
#define BFInAppPurchaseManagerProductTransaction @"BFInAppPurchaseManagerProductTransaction"

@interface BFInAppPurchaseManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (nonatomic, readonly)BOOL isProcessingPurchase;

+(id)sharedInstance;

-(void)loadStoreWithProductIdentifiers: (NSSet *)productIdentifiers;
-(BOOL)purchaseProduct: (SKProduct *)product;
-(BOOL)canMakePurchases;

@end
