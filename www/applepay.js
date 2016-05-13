
var argscheck = require('cordova/argscheck'),
    utils = require('cordova/utils'),
    exec = require('cordova/exec');

var ApplePay = {

    canMakePayments: function(successCallback, errorCallback) {
        exec(successCallback, errorCallback, 'ApplePay', 'canMakePayments', []);
    },    

    makePaymentRequest: function(order, successCallback, errorCallback) {
        exec(successCallback, errorCallback, 'ApplePay', 'makePaymentRequest', [order]);
    },

    completeLastTransaction: function(status, successCallback, errorCallback) {
        exec(successCallback, errorCallback, 'ApplePay', 'completeLastTransaction', [order]);
    }

};

module.exports = ApplePay;
