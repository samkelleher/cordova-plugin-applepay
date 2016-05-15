# Cordova Apple Pay Plugin
> An adapted Cordova plugin to provide Apple Pay functionality.

Updated to provide additional data access to the plugin, test calls, and compatibility
with newer versions of Cordova. Uses a Promise based interface in JavaScript.

This plugin is compatible with all payment processors (eg Stripe etc) because
the token is handled back your JavaScript application to pass to which ever payment
processor you use.

## Installation
```
$ cordova plugin add cordova-applepay
```

Install the plugin using Cordova 6 and above, which is based on npm. The plugin
exposes the `window.ApplePay` global in the browser.


## Supported Platforms

- iOS 8 and iOS 9
- Requires Cordova 6 running iOS Platform 4.1.1

## Methods
The methods available all return promises, or accept success and error callbacks.
- ApplePay.canMakePayments
- ApplePay.makePaymentRequest
- ApplePay.completeLastTransaction

## ApplePay.canMakePayments
Detects if the current iDevice supports Apple Pay and has any *capable* cards registered.

```
ApplePay.canMakePayments()
    .then(() => {
        // Apple Pay is enabled and a supported card is setup.
    })
    .catch((message) => {
        // The device is too old for Apple Pay
        // It's a good device, but no *supported* cards have been registered.
    });
```

## ApplePay.makePaymentRequest
Request a payment with Apple Pay, returns a Promise that once resolved, has the payment token.

```
ApplePay.makePaymentRequest(order)
    .then((token) => {
        // User approved payment, token generated.
    })
    .catch((message) => {
        // Error or user cancelled.
    });
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
          merchantIdentifier: 'merchant.apple.test',
          currencyCode: 'GBP',
          countryCode: 'GB'
          billingAddressRequirement: 'none',
          shippingAddressRequirement: 'none',
          shippingType: 'shipping'
    })
    .then((token) => {
        // The user has authorized the payment.

        // Handle the token, asynchronously, i.e. pass to your merchant bank to
        // action the payment, then once finished, depending on the outcome:

        // MyPaymentProvider.authorizeApplePayToken(token)
        //    .then((captureStatus) => { })
        //    .catch(());

        // Displays the 'done' green tick and closes the sheet.
        ApplePay.completeLastTransaction('success');

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
