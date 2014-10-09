
var argscheck = require('cordova/argscheck'),
    utils = require('cordova/utils'),
    exec = require('cordova/exec');
    
var ApplePay = {
    
    initWithPaymentRequest: function(successCallback, errorCallback, items) {
        exec(successCallback, errorCallback, "ApplePay", "initWithPaymentRequest", items);
    }
    
};

module.exports = ApplePay;
