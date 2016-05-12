#import <UIKit/UIKit.h>
#import <Cordova/CDVPlugin.h>

#import <PassKit/PassKit.h>

typedef void (^ARAuthorizationBlock)(PKPaymentAuthorizationStatus);

@interface CDVApplePay : CDVPlugin <PKPaymentAuthorizationViewControllerDelegate>
{
    NSString *merchantId;
    PKMerchantCapability merchantCapabilities;
    NSArray<NSString *>* supportedPaymentNetworks;
}

@property (nonatomic, strong) ARAuthorizationBlock paymentAuthorizationBlock;

@property (nonatomic, strong) NSString* paymentCallbackId;

- (void)setMerchantId:(CDVInvokedUrlCommand*)command;
- (void)makePaymentRequest:(CDVInvokedUrlCommand*)command;
- (void)canMakePayments:(CDVInvokedUrlCommand*)command;
- (void)completeLastTransaction:(CDVInvokedUrlCommand*)command;


@end
