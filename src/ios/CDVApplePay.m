#import "CDVApplePay.h"
@import AddressBook;

@implementation CDVApplePay

@synthesize paymentCallbackId;

- (void)canMakePayments:(CDVInvokedUrlCommand*)command
{
    if ([PKPaymentAuthorizationViewController canMakePayments]) {
        if ((floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_8_0)) {
            CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"This device cannot make payments."];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            return;
        } else if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){9, 0, 0}]) {
            if (command.arguments[0] != [NSNull null] && [command.arguments[0] objectForKey:@"supportedNetworks"] != nil) {
                if ([command.arguments[0] objectForKey:@"merchantCapabilities"] != nil) {
                    if ([PKPaymentAuthorizationViewController
                            canMakePaymentsUsingNetworks:[self supportedNetworksFromArguments:command.arguments]
                                            capabilities:[self merchantCapabilitiesFromArguments:command.arguments]]) {
                        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: @"This device can make payments and has a supported card."];
                        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
                        return;
                    } else {
                        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"This device can make payments but has no supported card."];
                        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
                        return;
                    }
                } else { // merchantCapabilities is nil
                    if ([PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:[self supportedNetworksFromArguments:command.arguments]]) {
                        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: @"This device can make payments and has a supported card."];
                        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
                        return;
                    } else {
                        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"This device can make payments but has no supported card."];
                        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
                        return;
                    }
                }
            } else { // supportedNetworks is nil
                CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: @"This device can make payments."];
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

- (PKShippingType)shippingTypeFromArguments:(NSArray *)arguments
{
    NSString *shippingType = [[arguments objectAtIndex:0] objectForKey:@"shippingType"];

    if ([shippingType isEqualToString:@"shipping"]) {
        return PKShippingTypeShipping;
    } else if ([shippingType isEqualToString:@"delivery"]) {
        return PKShippingTypeDelivery;
    } else if ([shippingType isEqualToString:@"store"]) {
        return PKShippingTypeStorePickup;
    } else if ([shippingType isEqualToString:@"service"]) {
        return PKShippingTypeServicePickup;
    }


    return PKShippingTypeShipping;
}

- (PKAddressField)billingAddressRequirementFromArguments:(NSArray *)arguments
{
    NSArray *billingAddressRequirement = [[arguments objectAtIndex:0] objectForKey:@"billingAddressRequirement"];
    PKAddressField requiredFields = PKAddressFieldNone;

    for (id requirement in billingAddressRequirement) {
        if ([requirement isEqualToString:@"all"]) {
            requiredFields = requiredFields | PKAddressFieldAll;
        } else if ([requirement isEqualToString:@"postcode"]) {
            requiredFields = requiredFields | PKAddressFieldPostalAddress;
        } else if ([requirement isEqualToString:@"name"]) {
            requiredFields = requiredFields | PKAddressFieldName;
        } else if ([requirement isEqualToString:@"email"]) {
            requiredFields = requiredFields | PKAddressFieldEmail;
        } else if ([requirement isEqualToString:@"phone"]) {
            requiredFields = requiredFields | PKAddressFieldPhone;
        }
    }

    return requiredFields;
}

- (PKAddressField)shippingAddressRequirementFromArguments:(NSArray *)arguments
{
    NSArray *shippingAddressRequirements = [[arguments objectAtIndex:0] objectForKey:@"shippingAddressRequirement"];
    PKAddressField requiredFields = PKAddressFieldNone;

    for (id requirement in shippingAddressRequirements) {
        if ([requirement isEqualToString:@"all"]) {
            requiredFields = requiredFields | PKAddressFieldAll;
        } else if ([requirement isEqualToString:@"postcode"]) {
            requiredFields = requiredFields | PKAddressFieldPostalAddress;
        } else if ([requirement isEqualToString:@"name"]) {
            requiredFields = requiredFields | PKAddressFieldName;
        } else if ([requirement isEqualToString:@"email"]) {
            requiredFields = requiredFields | PKAddressFieldEmail;
        } else if ([requirement isEqualToString:@"phone"]) {
            requiredFields = requiredFields | PKAddressFieldPhone;
        }
    }

    return requiredFields;
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

- (PKMerchantCapability)merchantCapabilitiesFromArguments:(NSArray *)arguments
{
    NSArray *capabilities = [arguments[0] objectForKey:@"merchantCapabilities"];

    PKMerchantCapability merchantCapability = 0;

    for (NSString *capability in capabilities) {
        if ([capability isEqualToString:@"3ds"]) {
            merchantCapability |= PKMerchantCapability3DS;
        } else if ([capability isEqualToString:@"credit"]) {
            merchantCapability |= PKMerchantCapabilityCredit;
        } else if ([capability isEqualToString:@"debit"]) {
            merchantCapability |= PKMerchantCapabilityDebit;
        } else if ([capability isEqualToString:@"emv"]) {
            merchantCapability |= PKMerchantCapabilityEMV;
        }
    }

    return merchantCapability;
}

- (NSArray<NSString *>*)supportedNetworksFromArguments:(NSArray *)arguments
{
    NSArray *networks = [arguments[0] objectForKey:@"supportedNetworks"];

    NSMutableArray<NSString *>* paymentNetworks = [[NSMutableArray alloc] init];

    for (NSString *network in networks) {
        if ([network isEqualToString:@"visa"]) {
            [paymentNetworks addObject:PKPaymentNetworkVisa];
        } else if ([network isEqualToString:@"discover"]) {
            [paymentNetworks addObject:PKPaymentNetworkDiscover];
        } else if ([network isEqualToString:@"masterCard"]) {
            [paymentNetworks addObject:PKPaymentNetworkMasterCard];
        } else if ([network isEqualToString:@"amex"]) {
            [paymentNetworks addObject:PKPaymentNetworkAmex];
        }
        // TODO: add the rest
    }

    return paymentNetworks;
}

- (NSArray *)shippingMethodsFromArguments:(NSArray *)arguments
{
    NSArray *shippingDescriptions = [[arguments objectAtIndex:0] objectForKey:@"shippingMethods"];

    NSMutableArray *shippingMethods = [[NSMutableArray alloc] init];


    for (NSDictionary *desc in shippingDescriptions) {

        NSString *identifier = [desc objectForKey:@"identifier"];
        NSString *detail = [desc objectForKey:@"detail"];
        NSString *label = [desc objectForKey:@"label"];

        NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithDecimal:[[desc objectForKey:@"amount"] decimalValue]];

        PKPaymentSummaryItem *newMethod = [self shippingMethodWithIdentifier:identifier detail:detail label:label amount:amount];

        [shippingMethods addObject:newMethod];
    }

    return shippingMethods;
}

- (PKPaymentAuthorizationStatus)paymentAuthorizationStatusFromArgument:(NSString *)paymentAuthorizationStatus
{

    if ([paymentAuthorizationStatus isEqualToString:@"success"]) {
        return PKPaymentAuthorizationStatusSuccess;
    } else if ([paymentAuthorizationStatus isEqualToString:@"failure"]) {
        return PKPaymentAuthorizationStatusFailure;
    } else if ([paymentAuthorizationStatus isEqualToString:@"invalid-billing-address"]) {
        return PKPaymentAuthorizationStatusInvalidBillingPostalAddress;
    } else if ([paymentAuthorizationStatus isEqualToString:@"invalid-shipping-address"]) {
        return PKPaymentAuthorizationStatusInvalidShippingPostalAddress;
    } else if ([paymentAuthorizationStatus isEqualToString:@"invalid-shipping-contact"]) {
        return PKPaymentAuthorizationStatusInvalidShippingContact;
    } else if ([paymentAuthorizationStatus isEqualToString:@"require-pin"]) {
        return PKPaymentAuthorizationStatusPINRequired;
    } else if ([paymentAuthorizationStatus isEqualToString:@"incorrect-pin"]) {
        return PKPaymentAuthorizationStatusPINIncorrect;
    } else if ([paymentAuthorizationStatus isEqualToString:@"locked-pin"]) {
        return PKPaymentAuthorizationStatusPINLockout;
    }

    return PKPaymentAuthorizationStatusFailure;
}

- (void)completeLastTransaction:(CDVInvokedUrlCommand*)command
{
    if (self.paymentAuthorizationBlock) {

        NSString *paymentAuthorizationStatusString = [command.arguments objectAtIndex:0];
        NSLog(@"ApplePay completeLastTransaction == %@", paymentAuthorizationStatusString);

        PKPaymentAuthorizationStatus paymentAuthorizationStatus = [self paymentAuthorizationStatusFromArgument:paymentAuthorizationStatusString];
        self.paymentAuthorizationBlock(paymentAuthorizationStatus);

        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: @"Payment status applied."];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

    }
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

    // reset any lingering callbacks, incase the previous payment failed.
    self.paymentAuthorizationBlock = nil;

    PKPaymentRequest *request = [PKPaymentRequest new];

    // All this data is loaded from the Cordova object passed in. See documentation.
    [request setCurrencyCode:[self currencyCodeFromArguments:command.arguments]];
    [request setCountryCode:[self countryCodeFromArguments:command.arguments]];
    [request setMerchantIdentifier:[self merchantIdentifierFromArguments:command.arguments]];
    [request setMerchantCapabilities:[self merchantCapabilitiesFromArguments:command.arguments]];
    [request setSupportedNetworks:[self supportedNetworksFromArguments:command.arguments]];
    [request setRequiredBillingAddressFields:[self billingAddressRequirementFromArguments:command.arguments]];
    [request setRequiredShippingAddressFields:[self shippingAddressRequirementFromArguments:command.arguments]];
    [request setShippingType:[self shippingTypeFromArguments:command.arguments]];
    [request setShippingMethods:[self shippingMethodsFromArguments:command.arguments]];
    [request setPaymentSummaryItems:[self itemsFromArguments:command.arguments]];
    self.shippingMethods = [self shippingMethodsFromArguments:command.arguments];
    self.summaryItems = [self itemsFromArguments:command.arguments];

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

- (void)updateItemsAndShippingMethods:(CDVInvokedUrlCommand*)command
{
    if (self.updateItemsAndShippingMethodsBlock != nil) {
        self.shippingMethods = [self shippingMethodsFromArguments:command.arguments];
        self.summaryItems = [self itemsFromArguments:command.arguments];
        self.updateItemsAndShippingMethodsBlock(PKPaymentAuthorizationStatusSuccess, self.shippingMethods, self.summaryItems);
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: @"Updated List Info"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    } else {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"Did you make a payment request?"];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller
{
    [self.viewController dismissViewControllerAnimated:YES completion:nil];

    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString: @"Payment not completed."];
    [self.commandDelegate sendPluginResult:result callbackId:self.paymentCallbackId];
}

- (NSDictionary*) formatPaymentForApplication:(PKPayment *)payment {
    NSString *paymentData = [payment.token.paymentData base64EncodedStringWithOptions:0];

    //    NSDictionary *response = @{
    //                               @"paymentData":paymentData,
    //                               @"transactionIdentifier":payment.token.transactionIdentifier
    //                               };

    NSMutableDictionary *response = [[NSMutableDictionary alloc] init];

    [response setObject:paymentData  forKey:@"paymentData"];
    [response setObject:payment.token.transactionIdentifier  forKey:@"transactionIdentifier"];

    [response setObject:payment.token.paymentMethod.displayName  forKey:@"paymentMethodDisplayName"];
    [response setObject:payment.token.paymentMethod.network  forKey:@"paymentMethodNetwork"];

    NSString *typeCard = nil;

    switch(payment.token.paymentMethod.type) {
        case PKPaymentMethodTypeUnknown:
            typeCard = @"unknown"; // The card’s type is not known.
            break;
        case PKPaymentMethodTypeDebit:
            typeCard = @"debit"; // A debit card.
            break;
        case PKPaymentMethodTypeCredit:
            typeCard = @"credit";// A credit card.
            break;
        case PKPaymentMethodTypePrepaid:
            typeCard = @"prepaid";// A prepaid card.
            break;
        case PKPaymentMethodTypeStore:
            typeCard = @"store";// A store card.
            break;
        default:
            typeCard = @"error";// A store card.
    }

    [response setObject:typeCard  forKey:@"paymentMethodTypeCard"];

    PKContact *billingContact = payment.billingContact;
    if (billingContact) {
        if (billingContact.emailAddress) {
            [response setObject:billingContact.emailAddress forKey:@"billingEmailAddress"];
        }

        if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){9, 2, 0}]) {
            if (billingContact.supplementarySubLocality) {
                [response setObject:billingContact.supplementarySubLocality forKey:@"billingSupplementarySubLocality"];
            }
        }

        if (billingContact.name) {

            if (billingContact.name.givenName) {
                [response setObject:billingContact.name.givenName forKey:@"billingNameFirst"];
            }

            if (billingContact.name.middleName) {
                [response setObject:billingContact.name.middleName forKey:@"billingNameMiddle"];
            }

            if (billingContact.name.familyName) {
                [response setObject:billingContact.name.familyName forKey:@"billingNameLast"];
            }

        }

        if (billingContact.postalAddress) {

            if (billingContact.postalAddress.street) {
                [response setObject:billingContact.postalAddress.street forKey:@"billingAddressStreet"];
            }

            if (billingContact.postalAddress.city) {
                [response setObject:billingContact.postalAddress.city forKey:@"billingAddressCity"];
            }

            if (billingContact.postalAddress.state) {
                [response setObject:billingContact.postalAddress.state forKey:@"billingAddressState"];
            }


            if (billingContact.postalAddress.postalCode) {
                [response setObject:billingContact.postalAddress.postalCode forKey:@"billingPostalCode"];
            }

            if (billingContact.postalAddress.country) {
                [response setObject:billingContact.postalAddress.country forKey:@"billingCountry"];
            }

            if (billingContact.postalAddress.ISOCountryCode) {
                [response setObject:billingContact.postalAddress.ISOCountryCode forKey:@"billingISOCountryCode"];
            }

        }
    }

    PKContact *shippingContact = payment.shippingContact;
    if (shippingContact) {
        if (shippingContact.emailAddress) {
            [response setObject:shippingContact.emailAddress forKey:@"shippingEmailAddress"];
        }

        if (shippingContact.phoneNumber) {
            [response setObject:shippingContact.phoneNumber.stringValue forKey:@"shippingPhoneNumber"];
        }

        if (shippingContact.name) {

            if (shippingContact.name.givenName) {
                [response setObject:shippingContact.name.givenName forKey:@"shippingNameFirst"];
            }

            if (shippingContact.name.middleName) {
                [response setObject:shippingContact.name.middleName forKey:@"shippingNameMiddle"];
            }

            if (shippingContact.name.familyName) {
                [response setObject:shippingContact.name.familyName forKey:@"shippingNameLast"];
            }

        }
        if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){9, 2, 0}]) {
            if (shippingContact.supplementarySubLocality) {
                [response setObject:shippingContact.supplementarySubLocality forKey:@"shippingSupplementarySubLocality"];
            }
        }

        if (shippingContact.postalAddress) {

            if (shippingContact.postalAddress.street) {
                [response setObject:shippingContact.postalAddress.street forKey:@"shippingAddressStreet"];
            }

            if (shippingContact.postalAddress.city) {
                [response setObject:shippingContact.postalAddress.city forKey:@"shippingAddressCity"];
            }

            if (shippingContact.postalAddress.state) {
                [response setObject:shippingContact.postalAddress.state forKey:@"shippingAddressState"];
            }

            if (shippingContact.postalAddress.postalCode) {
                [response setObject:shippingContact.postalAddress.postalCode forKey:@"shippingPostalCode"];
            }

            if (shippingContact.postalAddress.country) {
                [response setObject:shippingContact.postalAddress.country forKey:@"shippingCountry"];
            }

            if (shippingContact.postalAddress.ISOCountryCode) {
                [response setObject:shippingContact.postalAddress.ISOCountryCode forKey:@"shippingISOCountryCode"];
            }

        }
    }

    return response;
}

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus status))completion
{
    NSLog(@"CDVApplePay: didAuthorizePayment");

    if (completion) {
        self.paymentAuthorizationBlock = completion;
    }
    NSDictionary* response = [self formatPaymentForApplication:payment];

    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:response];
    [self.commandDelegate sendPluginResult:result callbackId:self.paymentCallbackId];
}

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                  didSelectShippingContact:(PKContact *)contact
                                completion:(void (^)(PKPaymentAuthorizationStatus status, NSArray<PKShippingMethod *> *shippingMethods, NSArray<PKPaymentSummaryItem *> *summaryItems))completion
{
    if (self.shippingContactSelectionListenerCallbackId) {
        NSMutableDictionary *response = [[NSMutableDictionary alloc] init];
        if (contact.postalAddress) {
            if (contact.postalAddress.city) {
                [response setObject:contact.postalAddress.city forKey:@"shippingAddressCity"];
            }

            if (contact.postalAddress.state) {
                [response setObject:contact.postalAddress.state forKey:@"shippingAddressState"];
            }

            if (contact.postalAddress.postalCode) {
                [response setObject:contact.postalAddress.postalCode forKey:@"shippingPostalCode"];
            }

            if (contact.postalAddress.ISOCountryCode) {
                [response setObject:[contact.postalAddress.ISOCountryCode uppercaseString] forKey:@"shippingISOCountryCode"];
            }
        }
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:response];
        [result setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:result callbackId:self.shippingContactSelectionListenerCallbackId];
        self.updateItemsAndShippingMethodsBlock = completion;
    } else {
        completion(PKPaymentAuthorizationStatusSuccess, self.shippingMethods, self.summaryItems);
    }
}

- (void)startListeningForShippingContactSelection:(CDVInvokedUrlCommand *)command
{
    self.shippingContactSelectionListenerCallbackId = command.callbackId;
}

- (void)stopListeningForShippingContactSelection:(CDVInvokedUrlCommand *)command
{
    if (self.shippingContactSelectionListenerCallbackId) {
        self.shippingContactSelectionListenerCallbackId = nil;
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    } else {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsBool:NO];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
}

- (PKShippingMethod *)shippingMethodWithIdentifier:(NSString *)idenfifier detail:(NSString *)detail label:(NSString *)label amount:(NSDecimalNumber *)amount
{
    PKShippingMethod *shippingMethod = [PKShippingMethod new];
    shippingMethod.identifier = idenfifier;
    shippingMethod.detail = detail;
    shippingMethod.amount = amount;
    shippingMethod.label = label;

    return shippingMethod;
}


@end
