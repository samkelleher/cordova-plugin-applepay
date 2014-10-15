#import "CDVApplePay.h"

static NSString * const kShippingMethodCarrierPidgeon = @"Carrier Pidgeon";
static NSString * const kShippingMethodUberRush       = @"Uber Rush";
static NSString * const kShippingMethodSentientDrone  = @"Sentient Drone";


@implementation CDVApplePay

@synthesize paymentCallbackId;


- (CDVPlugin*)initWithWebView:(UIWebView*)theWebView
{
    self = (CDVApplePay*)[super initWithWebView:(UIWebView*)theWebView];

    return self;
}

- (void)dealloc
{

}

- (void)onReset
{

}


- (void)setMerchantId:(CDVInvokedUrlCommand*)command
{
    merchantId = [command.arguments objectAtIndex:0];
}


- (NSArray *)itemsFromArguments:(NSArray *)arguments
{
    NSMutableArray *items = [[NSMutableArray alloc] init];

    for (NSDictionary *item in arguments) {
        
        NSString *label = [item objectForKey:@"label"];
        
        NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithDecimal:[[item objectForKey:@"amount"] decimalValue]];
        
        PKPaymentSummaryItem *newItem = [PKPaymentSummaryItem summaryItemWithLabel:label amount:amount];
        
        [items addObject:newItem];
    }
    
    return items;
}


- (void)makePaymentRequest:(CDVInvokedUrlCommand*)command
{
    self.paymentCallbackId = command.callbackId;

    if (merchantId == nil) {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"Please call setMerchantId() with your Apple-given merchant ID."];
        [self.commandDelegate sendPluginResult:result callbackId:self.paymentCallbackId];
        return;
    }

    
    NSLog(@"ApplePay canMakePayments == %@", [PKPaymentAuthorizationViewController canMakePayments]);
    if (![PKPaymentAuthorizationViewController canMakePayments]) {
        
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"This device cannot make payments."];
// Property `canMakePayments` has only reported false so far, but the Apple Pay sheet can be shown anyway.
//        [self.commandDelegate sendPluginResult:result callbackId:self.paymentCallbackId];
//        return;
    }
    
    
    PKPaymentRequest *request = [PKPaymentRequest new];
    
    // Must be configured in Apple Developer Member Center
    request.merchantIdentifier = merchantId;
    
    [request setPaymentSummaryItems:[self itemsFromArguments:command.arguments]];
    
    NSArray *shippingMethods = @[
                                 [self shippingMethodWithIdentifier:kShippingMethodCarrierPidgeon detail:kShippingMethodCarrierPidgeon amount:10.f],
                                 [self shippingMethodWithIdentifier:kShippingMethodUberRush detail:kShippingMethodUberRush amount:15.f],
                                 [self shippingMethodWithIdentifier:kShippingMethodSentientDrone detail:kShippingMethodSentientDrone amount:20.f]
                                 ];
    request.shippingMethods = shippingMethods;
    
    // These appear to be the only 3 supported
    // Sorry, Discover Card
    request.supportedNetworks = @[PKPaymentNetworkAmex, PKPaymentNetworkMasterCard, PKPaymentNetworkVisa];
    
    // What type of info you need (eg email, phone, address, etc);
    request.requiredBillingAddressFields = PKAddressFieldAll;
    request.requiredShippingAddressFields = PKAddressFieldPostalAddress;
    
    // Which payment processing protocol the vendor supports
    // This value depends on the back end, looks like there are two possibilities
    request.merchantCapabilities = PKMerchantCapability3DS;
    
    request.countryCode = @"US";
    request.currencyCode = @"USD";
    
    PKPaymentAuthorizationViewController *authVC = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];

    authVC.delegate = self;
    
    [self.viewController presentViewController:authVC animated:YES completion:nil];
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller
{
    [self.viewController dismissViewControllerAnimated:YES completion:nil];

    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"Payment not completed."];
    [self.commandDelegate sendPluginResult:result callbackId:self.paymentCallbackId];
}

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus status))completion
{
    NSLog(@"CDVApplePay: didAuthorizePayment");
    NSString *data = [payment.token.paymentData base64EncodedStringWithOptions:0];

    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{@"message":data}];
    [self.commandDelegate sendPluginResult:result callbackId:self.paymentCallbackId];
}


- (PKShippingMethod *)shippingMethodWithIdentifier:(NSString *)idenfifier detail:(NSString *)detail amount:(CGFloat)amount
{
    PKShippingMethod *shippingMethod = [PKShippingMethod new];
    shippingMethod.identifier = idenfifier;
    shippingMethod.detail = @"";
    shippingMethod.amount = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithFloat:amount] decimalValue]];
    shippingMethod.label = detail;
    
    return shippingMethod;
}


@end
