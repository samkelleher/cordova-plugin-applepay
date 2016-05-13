
var argscheck = require('cordova/argscheck'),
    utils = require('cordova/utils'),
    exec = require('cordova/exec');

var ApplePay = {

    canMakePayments: function(successCallback, errorCallback) {
      return new Promise(function(resolve, reject) {
          exec(function(message) {
            successCallback(message);
            resolve(message);
          }, function(message) {
            errorCallback(message);
            reject(message);
          }, 'ApplePay', 'canMakePayments', []);
      });

    },

    makePaymentRequest: function(order, successCallback, errorCallback) {

      return new Promise(function(resolve, reject) {
          exec(function(message) {
            successCallback(message);
            resolve(message);
          }, function(message) {
            errorCallback(message);
            reject(message);
          }, 'ApplePay', 'makePaymentRequest', [order]);
      });

    },

    completeLastTransaction: function(status, successCallback, errorCallback) {

      return new Promise(function(resolve, reject) {
          exec(function(message) {
            successCallback(message);
            resolve(message);
          }, function(message) {
            errorCallback(message);
            reject(message);
          }, 'ApplePay', 'completeLastTransaction', [status]);
      });

    }

};

module.exports = ApplePay;
