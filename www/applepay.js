
var argscheck = require('cordova/argscheck'),
    utils = require('cordova/utils'),
    exec = require('cordova/exec');
    
var ApplePay = {
    
    setMerchantId: function(successCallback, errorCallback, merchantId) {
        exec(successCallback, errorCallback, "ApplePay", "setMerchantId", [merchantId]);
    },
    
    makePaymentRequest: function(successCallback, errorCallback, items) {
        exec(successCallback, errorCallback, "ApplePay", "makePaymentRequest", items);
    }
    
};

module.exports = ApplePay;
