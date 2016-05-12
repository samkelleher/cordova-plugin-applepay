#import "CDVApplePay.h"

@implementation CDVApplePay

@synthesize paymentCallbackId;


- (void)pluginInitialize
{

    // Set these to the payment cards accepted.
    // They will nearly always be the same.
    supportedPaymentNetworks = @[PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex];

    // Set the capabilities that your merchant supports
    // Adyen for example, only supports the 3DS one.
    merchantCapabilities = PKMerchantCapability3DS;// PKMerchantCapabilityEMV;


}

- (void)canMakePayments:(CDVInvokedUrlCommand*)command
{
        if ([PKPaymentAuthorizationViewController canMakePayments]) {
        if ((floor(NSFoundationVersionNumber) < NSFoundationVersionNumber_iOS_8_0)) {
            CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"This device cannot make payments."];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            return;
        } else if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){9, 0, 0}]) {
            if ([PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:supportedPaymentNetworks capabilities:(merchantCapabilities)]) {
                CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: @"This device can make payments and has a supported card"];
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
                return;
            } else {
                CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"This device can make payments but has no supported cards"];
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
                return;
            }
        } else if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){8, 0, 0}]) {
            if ([PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:supportedPaymentNetworks]) {
                CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: @"This device can make payments and has a supported card"];
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
                return;
            } else {
                CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"This device can make payments but has no supported cards"];
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
                return;
            }
        } else {
            CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"This device cannot make payments."];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            return;
        }
    } else {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"This device cannot make payments."];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }
}

- (void)setMerchantId:(CDVInvokedUrlCommand*)command
{
    merchantId = [command.arguments objectAtIndex:0];
    NSLog(@"ApplePay set merchant id to %@", merchantId);
}

- (NSString *)countryCodeFromArguments:(NSArray *)arguments
{
    NSString *countryCode = [[arguments objectAtIndex:0] objectForKey:@"countryCode"];
    return countryCode;
}

- (NSString *)merchantIdentifierFromArguments:(NSArray *)arguments
{
    NSString *merchantIdentifier = [[arguments objectAtIndex:0] objectForKey:@"merchantIdentifier"];
    return merchantIdentifier;
}

- (NSString *)currencyCodeFromArguments:(NSArray *)arguments
{
    NSString *currencyCode = [[arguments objectAtIndex:0] objectForKey:@"currencyCode"];
    return currencyCode;
}

- (NSArray *)itemsFromArguments:(NSArray *)arguments
{
    NSArray *itemDescriptions = [[arguments objectAtIndex:0] objectForKey:@"items"];

    NSMutableArray *items = [[NSMutableArray alloc] init];

    for (NSDictionary *item in itemDescriptions) {

        NSString *label = [item objectForKey:@"label"];

        NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithDecimal:[[item objectForKey:@"amount"] decimalValue]];

        PKPaymentSummaryItem *newItem = [PKPaymentSummaryItem summaryItemWithLabel:label amount:amount];

        [items addObject:newItem];
    }

    return items;
}

- (NSArray *)shippingMethodsFromArguments:(NSArray *)arguments
{
    NSArray *shippingDescriptions = [[arguments objectAtIndex:0] objectForKey:@"shippingMethods"];

    NSMutableArray *shippingMethods = [[NSMutableArray alloc] init];


     for (NSDictionary *desc in shippingDescriptions) {

         NSString *identifier = [desc objectForKey:@"identifier"];
         NSString *detail = [desc objectForKey:@"detail"];

         NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithDecimal:[[desc objectForKey:@"amount"] decimalValue]];

         PKPaymentSummaryItem *newMethod = [self shippingMethodWithIdentifier:identifier detail:detail amount:amount];

         [shippingMethods addObject:newMethod];
     }

     return shippingMethods;
}

- (void)makePaymentRequest:(CDVInvokedUrlCommand*)command
{
    self.paymentCallbackId = command.callbackId;

    NSLog(@"ApplePay canMakePayments == %s", [PKPaymentAuthorizationViewController canMakePayments]? "true" : "false");
    if ([PKPaymentAuthorizationViewController canMakePayments] == NO) {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"This device cannot make payments."];
        [self.commandDelegate sendPluginResult:result callbackId:self.paymentCallbackId];
        return;
    }

    PKPaymentRequest *request = [PKPaymentRequest new];

    [request setPaymentSummaryItems:[self itemsFromArguments:command.arguments]];

    [request setShippingMethods:[self shippingMethodsFromArguments:command.arguments]];

    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){9, 0, 0}]) {
        request.supportedNetworks = supportedPaymentNetworks;
    } else {
        request.supportedNetworks = supportedPaymentNetworks;
    }

    request.merchantCapabilities = merchantCapabilities;

    // What type of info you need (eg email, phone, address, etc);
    request.requiredBillingAddressFields = PKAddressFieldAll;
    request.requiredShippingAddressFields = PKAddressFieldPostalAddress;

    [request setCurrencyCode:[self currencyCodeFromArguments:command.arguments]];
    [request setCountryCode:[self countryCodeFromArguments:command.arguments]];
    [request setMerchantIdentifier:[self merchantIdentifierFromArguments:command.arguments]];

    NSLog(@"ApplePay request == %@", request);

    PKPaymentAuthorizationViewController *authVC = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];

    authVC.delegate = self;

    if (authVC == nil) {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"PKPaymentAuthorizationViewController was nil."];
        [self.commandDelegate sendPluginResult:result callbackId:self.paymentCallbackId];
        return;
    }

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


- (PKShippingMethod *)shippingMethodWithIdentifier:(NSString *)idenfifier detail:(NSString *)detail amount:(NSDecimalNumber *)amount
{
    PKShippingMethod *shippingMethod = [PKShippingMethod new];
    shippingMethod.identifier = idenfifier;
    shippingMethod.detail = @"";
    shippingMethod.amount = amount;
    shippingMethod.label = detail;

    return shippingMethod;
}


@end
