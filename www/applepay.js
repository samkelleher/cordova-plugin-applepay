
var argscheck = require('cordova/argscheck'),
    utils = require('cordova/utils'),
    exec = require('cordova/exec');

var ApplePay = {

    canMakePayments: function(successCallback, errorCallback) {
        exec(successCallback, errorCallback, 'ApplePay', 'canMakePayments', []);
    },

    setMerchantId: function(merchantId, successCallback, errorCallback) {
        exec(successCallback, errorCallback, 'ApplePay', 'setMerchantId', [merchantId]);
    },

    makePaymentRequest: function(order, successCallback, errorCallback) {
        exec(successCallback, errorCallback, 'ApplePay', 'makePaymentRequest', [order]);
    }

};

module.exports = ApplePay;
