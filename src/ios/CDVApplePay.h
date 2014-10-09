#import <UIKit/UIKit.h>
#import <Cordova/CDVPlugin.h>

#import <PassKit/PassKit.h>


@interface CDVApplePay : CDVPlugin <PKPaymentAuthorizationViewControllerDelegate>
{

}

@property (nonatomic, strong) NSString* paymentCallbackId;

- (void)initWithPaymentRequest:(CDVInvokedUrlCommand*)command;

@end
