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


- (void)initWithPaymentRequest:(CDVInvokedUrlCommand*)command
{    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (NSDictionary *item in command.arguments) {
        
        NSString *label = [item objectForKey:@"label"];

        NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithDecimal:[[item objectForKey:@"amount"] decimalValue]];
        
        PKPaymentSummaryItem *newItem = [PKPaymentSummaryItem summaryItemWithLabel:label amount:amount];
        
        [items addObject:newItem];
    }

    self.paymentCallbackId = command.callbackId;

    if (![PKPaymentAuthorizationViewController canMakePayments]) {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"This device cannot make payments."];
        [self.commandDelegate sendPluginResult:result callbackId:self.paymentCallbackId];
        return;
    }
 
    PKPaymentRequest *request = [PKPaymentRequest new];
    [request setPaymentSummaryItems:items];
    
    NSArray *shippingMethods = @[
                                 [self shippingMethodWithIdentifier:kShippingMethodCarrierPidgeon detail:kShippingMethodCarrierPidgeon amount:10.f],
                                 [self shippingMethodWithIdentifier:kShippingMethodUberRush detail:kShippingMethodUberRush amount:15.f],
                                 [self shippingMethodWithIdentifier:kShippingMethodSentientDrone detail:kShippingMethodSentientDrone amount:20.f]
                                 ];
    request.shippingMethods = shippingMethods;
    
    // Must be configured in Apple Developer Member Center
    // Doesn't seem like the functionality is there yet
    request.merchantIdentifier = @"com.applepay.test";
    
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
    
    [request setPaymentSummaryItems:items];
    
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
