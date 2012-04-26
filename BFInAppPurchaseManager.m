//
//  BFInAppPurchaseManager.m
//
//  Created by Heiko Dreyer on 26.04.12.
//  Copyright (c) 2012 boxedfolder.com. All rights reserved.
//

#import "BFInAppPurchaseManager.h"

@interface BFInAppPurchaseManager ()

-(void)_finishTransaction: (SKPaymentTransaction *)transaction wasSuccessful: (BOOL)wasSuccessful;
-(void)_requestProductData: (NSSet *)productIdentifiers;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation BFInAppPurchaseManager
{
    NSArray *_products; 
    SKProductsRequest *_productsRequest;
}

@synthesize isProcessingPurchase = _isProcessingPurchase;

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - Init & Purchase

-(void)loadStoreWithProductIdentifiers: (NSSet *)productIdentifiers
{
    [[SKPaymentQueue defaultQueue] addTransactionObserver: self];
    [self _requestProductData: productIdentifiers];
    _isProcessingPurchase = NO;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

-(BOOL)canMakePurchases
{
    return [SKPaymentQueue canMakePayments];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

-(BOOL)purchaseProduct: (SKProduct *)product
{
    if(![self canMakePurchases])
        return NO;
    
    SKPayment *payment = [SKPayment paymentWithProduct: product];
    [[SKPaymentQueue defaultQueue] addPayment: payment];
    
    return YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - Helpers

-(void)_requestProductData: (NSSet *)productIdentifiers
{
    if(!productIdentifiers || [productIdentifiers count] == 0)
        return;
    
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers: productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

-(void)_finishTransaction: (SKPaymentTransaction *)transaction wasSuccessful: (BOOL)wasSuccessful
{
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys: transaction, BFInAppPurchaseManagerProductTransaction, nil];
    
    NSString *name = wasSuccessful ? BFInAppPurchaseManagerProductTransactionSucceededNotification : BFInAppPurchaseManagerProductTransactionFailedNotification;
    [[NSNotificationCenter defaultCenter] postNotificationName: name object: self userInfo: userInfo];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - SKProductsRequestDelegate Methods

-(void)productsRequest: (SKProductsRequest *)request didReceiveResponse: (SKProductsResponse *)response
{
    _products = response.products;
    
    for(NSString *invalidProductID in response.invalidProductIdentifiers)
        NSLog(@"Invalid product id: %@" , invalidProductID);
    
    _productsRequest = nil;
    
    // Seems we recieved our products (or maybe not) - Dispatch notification and append product array
    [[NSNotificationCenter defaultCenter] postNotificationName: BFInAppPurchaseManagerProductsRecievedNotification object: self userInfo: [NSDictionary dictionaryWithObject: _products forKey: BFInAppPurchaseManagerProductArray]];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - SKPaymentTransactionObserver methods

-(void)paymentQueue: (SKPaymentQueue *)queue updatedTransactions: (NSArray *)transactions
{
    _isProcessingPurchase = NO;
    
    for(SKPaymentTransaction *transaction in transactions)
    {
        switch(transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self _finishTransaction: transaction wasSuccessful: YES];
                break;
            case SKPaymentTransactionStateFailed:
                {
                    if(transaction.error.code != SKErrorPaymentCancelled)
                        [self _finishTransaction: transaction wasSuccessful: NO];
                    else
                        [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                }
                break;
            case SKPaymentTransactionStateRestored:
                [self _finishTransaction: transaction wasSuccessful: YES];
                break;
            case SKPaymentTransactionStatePurchasing:
                _isProcessingPurchase = YES;
                break;
            default:
                break;
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - Memory Management & Lifecycle

+(id)alloc
{
	@throw [NSException exceptionWithName: @"Shared Instance alloc called" reason: @"Call Method +sharedInstance and not -alloc" userInfo: nil];
	return nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

+(id)sharedInstance
{
	static dispatch_once_t once;
    static BFInAppPurchaseManager *instance;
	dispatch_once(&once, ^{
		instance = [[super alloc] init];
	});
	
	return instance;
}

@end
