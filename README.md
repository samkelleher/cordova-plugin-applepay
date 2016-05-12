# Cordova Apple Pay Plugin
> An adapted Cordova plugin to provide Apple Pay functionality.

Updated to provide additional data access to the plugin, test calls, and compatibility
with newer versions of Cordova.  Originally used for internal use.

## Installation
```
$ cordova plugin add git@bitbucket.org:username/cordova-plugin-applepay.git
```

The plugin exposes the `org.cordova.applepay` plugin, accessible in the browser as `window.ApplePay`.

## Supported Platforms

- iOS, with Cordova 6 and iOS Platform 4

## Methods

- ApplePay.setMerchantId
- ApplePay.makePaymentRequest
- ApplePay.canMakePayments

## ApplePay.setMerchantId
Set your Apple-given merchant ID.

```
	ApplePay.setMerchantId(merchantId, successCallback, errorCallback);
```

## ApplePay.makePaymentRequest
Request a payment with Apple Pay.

```
  ApplePay.makePaymentRequest(order, successCallback, errorCallback);
```

## ApplePay.canMakePayments
Detects if the current iDevice supports Apple Pay and has any capable cards registered.

If the `errorCallback` is called, the device does not support Apple Pay. See the message to see why.
If the `successCallback` is called, you're good to go ahead and display the related UI.

```
  ApplePay.canMakePayments(successCallback, errorCallback);
```

### Parameters

- __order.items__: Array of item objects with form `{ label: 'Item 1', amount: 1.11 }`
- __order.shippingMethods__: Array of item objects with form `{ identifier: 'My Method', detail: 'Ship by method 1', amount: 1.11 }`

### Example
```
function onError(err) {
	  console.log('onError', response);
		alert(JSON.stringify(err));
}
function onSuccess(response) {
	  console.log('onSuccess', response);
		alert(response);
}

ApplePay.setMerchantId('merchant.apple.test', onSuccess, onError);

ApplePay.makePaymentRequest(
	{
		items: [
	      { label: 'item 1', amount: 1.11 },
	      { label: 'item 2', amount: 2.22 }
	  ],
	  shippingMethods: [
	  	{ identifier: 'By Sea', detail: 'Shipmates on a ship.', amount: 1.11 },
	  	{ identifier: 'Airmail', detail: 'Ship it by airplane.', amount: 5.55 }
	  ],
		merchantIdentifier: 'merchant.apple.test',
		currencyCode: 'GBP', // ISO 4217 currency code
		countryCode: 'GB' // ISO 3166-1 alpha-2 country code - Merchant country code (!),
		billingAddressRequirement: 'all',
		shippingAddressRequirement: 'all'
	},
	onSuccess,
	onError
);
```

Valid values for the `billingAddressRequirement` and `shippingAddressRequirement` properties are:
 - `none`
 - `all`
 - `postcode`
 - `name`
 - `email`
 - `phone`
