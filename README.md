# Cordova Apple Pay Plugin
> A dependency-free Cordova plugin to provide Apple Pay functionality.

Updated to provide additional data access to the plugin, test calls, and compatibility
with newer versions of Cordova. Uses a Promise based interface in JavaScript.

This plugin is compatible with any payment processor (eg Stripe, Adyen etc) because
the payment token is handled back your JavaScript application to pass to which ever payment
processor you use.

## Installation
```
$ cordova plugin add cordova-plugin-applepay
```

Install the plugin using Cordova 6 and above, which is based on [npm](https://www.npmjs.com/package/cordova-plugin-applepay). The plugin
exposes the `window.ApplePay` global in the browser.

## Updating Entitlements
This plugin does not automatically update the necessary entitlements for using Apple Pay (required in production). You can update your `config.xml` to set the merchant ID with the proper entitlements. You can also do this at build / signing time when creating the app build through Xcode.

```
<!-- example for updates to config.xml -->
<platform name="ios">
  <!-- other properties here -->
  <config-file target="*-Debug.plist" parent="com.apple.developer.in-app-payments">
    <array>
      <string>Put your debug / developer merchant ID here</string>
    </array>
  </config-file>

  <config-file target="*-Release.plist" parent="com.apple.developer.in-app-payments">
    <array>
      <string>Put your production merchant ID here</string>
    </array>
  </config-file>
</platform>
```

## Compatibility

- iOS 9.2-12
- Requires Cordova 6 running at least iOS Platform 4.1.1

## Methods
The methods available all return promises, or accept success and error callbacks.
- ApplePay.canMakePayments
- ApplePay.makePaymentRequest
- ApplePay.completeLastTransaction
- ApplePay.startListeningForShippingContactSelection - This does _not_ return a promise, but it fires the success callback upon shipping contact selection. See below.
- ApplePay.updateItemsAndShippingMethods
- ApplePay.stopListeningForShippingContactSelection

## ApplePay.canMakePayments
Detects if the current device supports Apple Pay and has any *capable* cards registered.

```ecmascript 6
ApplePay.canMakePayments().then((message) => {
  // Apple Pay is enabled. Expect:
  // 'This device can make payments.'
}).catch((message) => {
  // There is an issue, examine the message to see the details, will be:
  // 'This device cannot make payments.''
  // 'This device can make payments but has no supported cards'
});
```

Detects if the current device supports Apple Pay and has any cards of `supportedNetworks` and `merchantCapabilities`.
```ecmascript 6
ApplePay.canMakePayments({
  // supportedNetworks should not be an empty array. The supported networks currently are: amex, discover, masterCard, visa
  supportedNetworks: ['visa', 'amex'],
  
  // when merchantCapabilities is passed in, supportedNetworks must also be provided. Valid values: 3ds, debit, credit, emv
  merchantCapabilities: ['3ds', 'debit', 'credit']
}).then((message) => {
  // Apple Pay is enabled and a supported card is setup. Expect:
  // 'This device can make payments and has a supported card'
}).catch((message) => {
  // There is an issue, examine the message to see the details, will be:
  // 'This device cannot make payments.''
  // 'This device can make payments but has no supported cards'
});
```

If in your `catch` you get the message `This device can make payments but has no supported cards` - you can decide if you want to handle this by showing the 'Setup Apple Pay' buttons instead of the
normal 'Pay with Apple Bay' buttons as per the Apple Guidelines.

## ApplePay.makePaymentRequest
Request a payment with Apple Pay, returns a Promise that once resolved, has the payment token.
In your `order`, you will set parameters like the merchant ID, country, address requirements,
order information etc. See a full example of an order at the end of this document.

```
ApplePay.makePaymentRequest(order)
    .then((paymentResponse) => {
        // User approved payment, token generated.
    })
    .catch((message) => {
        // Error or user cancelled.
    });
```

### Example Response

The `paymentResponse` is an object with the keys that contain the token itself,
this is what you'll need to pass along to your payment processor. Also, if you requested
billing or shipping addresses, this information is also included.

```
{
    "shippingAddressState": "London",
    "shippingCountry": "United Kingdom",
    "shippingISOCountryCode": "gb",
    "billingAddressCity": "London",
    "billingISOCountryCode": "gb",
    "shippingNameLast": "Name",
    "paymentData": "<BASE64 ENCODED TOKEN WILL APPEAR HERE>",
    "shippingNameFirst": "First",
    "billingAddressState": "London",
    "billingAddressStreet": "Street 1\n",
    "billingNameFirst": "First",
    "billingPostalCode": "POST CODE",
    "shippingPostalCode": "POST CODE",
    "shippingAddressStreet": "Street Line 1\nStreet Line 2",
    "billingNameLast": "NAME",
    "billingSupplementarySubLocality": "",
    "billingCountry": "United Kingdom",
    "shippingAddressCity": "London",
    "shippingSupplementarySubLocality": "",
    "transactionIdentifier": "Simulated Identifier",
    "paymentMethodDisplayName": "MasterCard 1234",
    "paymentMethodNetwork": "MasterCard",
    "paymentMethodTypeCard": "credit"
}
```

## ApplePay.completeLastTransaction
Once the makePaymentRequest has been resolved successfully, the device will be waiting for a completion event.
This means, that the application must proceed with the token authorisation and return a success, failure, or other validation error. Once this has been passed back, the Apple Pay sheet will be dismissed via an animation.

```
ApplePay.completeLastTransaction('success');
```

You can dismiss or invalidate the Apple Pay sheet by calling `completeLastTransaction` with a status string which can be `success`, `failure`, `invalid-billing-address`, `invalid-shipping-address`, `invalid-shipping-contact`, `require-pin`, `incorrect-pin`, `locked-pin`.

### Payment Flow Example

The order request object closely follows the format of the `PKPaymentRequest` class and thus its [documentation](https://developer.apple.com/library/ios/documentation/PassKit/Reference/PKPaymentRequest_Ref/index.html#//apple_ref/occ/cl/PKPaymentRequest) will make excellent reading.

```
ApplePay.makePaymentRequest(
    {
          items: [
              {
                  label: '3 x Basket Items',
                  amount: 49.99
              },
              {
                  label: 'Next Day Delivery',
                  amount: 3.99
              },
                      {
                  label: 'My Fashion Company',
                  amount: 53.98
              }
          ],
          shippingMethods: [
              {
                  identifier: 'NextDay',
                  label: 'NextDay',
                  detail: 'Arrives tomorrow by 5pm.',
                  amount: 3.99
              },
              {
                  identifier: 'Standard',
                  label: 'Standard',
                  detail: 'Arrive by Friday.',
                  amount: 4.99
              },
              {
                  identifier: 'SaturdayDelivery',
                  label: 'Saturday',
                  detail: 'Arrive by 5pm this Saturday.',
                  amount: 6.99
              }
          ],
          supportedNetworks: ['visa', 'masterCard', 'discover'],
          merchantCapabilities: ['3ds', 'debit', 'credit'],          
          merchantIdentifier: 'merchant.apple.test',
          currencyCode: 'GBP',
          countryCode: 'GB',
          billingAddressRequirement: 'none',
          shippingAddressRequirement: 'none',
          shippingType: 'shipping'
    })
    .then((paymentResponse) => {
        // The user has authorized the payment.

        // Handle the token, asynchronously, i.e. pass to your merchant bank to
        // action the payment, then once finished, depending on the outcome:

        // Here is an example implementation:

        // MyPaymentProvider.authorizeApplePayToken(token.paymentData)
        //    .then((captureStatus) => {
        //        // Displays the 'done' green tick and closes the sheet.
        //        ApplePay.completeLastTransaction('success');
        //    })
        //    .catch((err) => {
        //        // Displays the 'failed' red cross.
        //        ApplePay.completeLastTransaction('failure');
        //    });


    })
    .catch((e) => {
        // Failed to open the Apple Pay sheet, or the user cancelled the payment.
    })
```

Valid values for the `shippingType` are:

 * `shipping` (default)
 * `delivery`
 * `store`
 * `service`

Valid values for the `billingAddressRequirement` and `shippingAddressRequirement`
properties are:

 * `none` (default)
 * `all`
 * `postcode`
 * `name`
 * `email`
 * `phone`

You can set these as an array if you want, for example,
`['name', 'email', 'phone']`.

## Responding to User Shipping Contact Selection Events
Use the following methods together to work with user shipping contact selection events.

### ApplePay.startListeningForShippingContactSelection
Starts listening for shipping contact selection changes Any time the user selects shipping contact, this callback will fire.  You *must* call `ApplePay.updateItemsAndShippingMethods` (see below) in response or else the user will not be able to process payment. Apple Pay waits for a completion method to be called to update these proprties before allowing the user to process payments.

Any time the user updates their shipping contact, the success callback to this method will trigger. Then, you must update the items / shipping methods as a result of the user's selection.

You can also call `ApplePay.stopListeningForShippingContactSelection` to stop listening for shipping contact selection changes. Then, you no longer have to call `updateItemsAndShippingMethods` on shipping method selection.

### ApplePay.updateItemsAndShippingMethods
Call this in response to any `startListeningForShippingContactSelection` event. Provide a list similar to `makePaymentRequest` including `items` and `shippingMethods` arrays. The other properties are not used.

This method returns a promise that wraps the shipping contact selection completion method and should generally succeed.

### ApplePay.stopListeningForShippingContactSelection
Call this when you no longer need to listen to shipping contact selection events or after completing a transaction attempt.

This method returns a promise that wraps unsubscribing from the Apple Pay event internally. The Promise will be rejected if you were not subscribed to listen to these events initially.

### Example

```
// Set this up initially. This will also fire if the user has a default
// shipping contact in the apple pay sheet
ApplePay.startListeningForShippingContactSelection(async selection => {
    const { items, shippingMethods } = getItemsAndMethodsFromAddressInfo(
        selection.shippingAddressCity,
        selection.shippingAddressState,
        selection.shippingPostalCode,
        selection.shippingISOCountryCode, // this is capitalized
    );

    try {
        await ApplePay.updateItemsAndShippingMethods({ items, shippingMethods });
    }
    catch (e) {
        // handle error if shipping contact selection couldn't complete for some reason
    }
});

try {
    const response = await ApplePay.makePaymentRequest(paymentRequestOptions);
    const success = await MyPaymentProvider.authorize(response.paymentData);

    if (success) {
        await ApplePay.completeLastTransaction('success');
    }
    else {
        await ApplePay.completeLastTransaction('failure');
    }
}
catch (err) {
    // handle payment request or transaction errors
}

try {
    await ApplePay.stopListeningForShippingContactSelection();
}
catch (err) {
    // handle error if you could not unsubscribe from shipping contact selection events
}
```

## Limitations and TODOs
* *Support more networks* - currently only Visa, MasterCard, American Express and Discover are accepted as config options.
* *Event binds for delivery method selector* - An event can be raised when the customer
selects different delivery options, so the merchant can update the delivery charges.

## License

This project is licensed under *Apache 2.0*.

This project is currently maintained by [Andrew Crites](https://github.com/ajcrites).

It is originally the work of [Sam Kelleher](https://samkelleher.com/). It is an alteration of an older project originally started by [@jbeuckm](https://github.com/jbeuckm)
