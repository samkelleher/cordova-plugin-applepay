# org.beuckman.applepay

This plugin is to give an idea of what ApplePay will probably look like. Thanks to Max Mamis for [this blog post](http://prolificinteractive.com/blog/2014/09/19/apple-pay-developers/).


## Installation

cordova plugin add https://github.com/jbeuckm/cordova-plugin-applepay.git

## Supported Platforms

- iOS

## Methods

- ApplePay.setMerchantId
- ApplePay.makePaymentRequest

## ApplePay.setMerchantId

Set your Apple-given merchant ID.

	ApplePay.setMerchantId("merchant.my.id");

## ApplePay.makePaymentRequest

Request a payment with Apple Pay.

    ApplePay.makePaymentRequest(successCallback, errorCallback, items);

### Parameters

- __items__: Array of item objects with form ```{ label: "Item 1", amount: 1.11 }```

### Example

	ApplePay.setMerchantId("merchant.apple.test");
    
    function onError(err) {
        alert(JSON.stringify(err));
    }
    function onSuccess(response) {
        alert(response);
    }
	 
    ApplePay.makePaymentRequest(onSuccess, onError, [
        { label: "item 1", amount: 1.11 },
        { label: "item 2", amount: 2.22 }
    ]);

