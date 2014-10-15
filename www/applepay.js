
var argscheck = require('cordova/argscheck'),
    utils = require('cordova/utils'),
    exec = require('cordova/exec');
    
var ApplePay = {
    
    setMerchantId: function(successCallback, errorCallback, merchantId) {
        exec(successCallback, errorCallback, "ApplePay", "setMerchantId", [merchantId]);
    },
    
    makePaymentRequest: function(successCallback, errorCallback, order) {
        exec(successCallback, errorCallback, "ApplePay", "makePaymentRequest", [order]);
    }
    
};

module.exports = ApplePay;
