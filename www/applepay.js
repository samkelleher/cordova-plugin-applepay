var argscheck = require('cordova/argscheck'),
  utils = require('cordova/utils'),
  exec = require('cordova/exec');

var executeCallback = function(callback, message) {
    if (typeof callback === 'function') {
        callback(message);
    }
};

var ApplePay = {
    /**
     * Determines if the current device supports Apple Pay and has a supported card installed.
     * @param {Function} [successCallback] - Optional success callback, recieves message object.
     * @param {Function} [errorCallback] - Optional error callback, recieves message object.
     * @returns {Promise}
     */
    canMakePayments: function(query, successCallback, errorCallback) {
        if (typeof query == 'function') { // missing query, method is invoked with two function args only
            errorCallback = successCallback;
            successCallback = query;
            query = {}
        }
        return new Promise(function(resolve, reject) {
            exec(function(message) {
                executeCallback(successCallback, message);
                resolve(message);
            }, function(message) {
                executeCallback(errorCallback, message);
                reject(message);
            }, 'ApplePay', 'canMakePayments', [query]);
        });
    },
    
    /**
     * Opens the Apple Pay sheet and shows the order information.
     * @param {Function} [successCallback] - Optional success callback, recieves message object.
     * @param {Function} [errorCallback] - Optional error callback, recieves message object.
     * @returns {Promise}
     */
    makePaymentRequest: function(order, successCallback, errorCallback) {
        if (!Array.isArray(order.billingAddressRequirement)) {
            order.billingAddressRequirement = [order.billingAddressRequirement];
        }
        if (!Array.isArray(order.shippingAddressRequirement)) {
            order.shippingAddressRequirement = [order.shippingAddressRequirement];
        }
        return new Promise(function(resolve, reject) {
            exec(function(message) {
                executeCallback(successCallback, message);
                resolve(message);
            }, function(message) {
                executeCallback(errorCallback, message);
                reject(message);
            }, 'ApplePay', 'makePaymentRequest', [order]);
        });
    },
    
    /**
     * Starts listening for shipping contact selection changes
     * Any time the user selects shipping contact, this callback will fire.
     * You *must* call `updateItemsAndShippingMethods` in response or else the
     * user will not be able to process payment.
     * @param {Function} [successCallback] - Required success callback
     *  Fires whenever the user updates their shipping contact selection on the
     *  pay sheet (may also fire initially if the user has default information).
     * @param {Function} [errorCallback] - Optional error callback, receives message object.
     * @returns {void}
     */
    startListeningForShippingContactSelection: function(successCallback, errorCallback) {
        exec(function(message) {
            executeCallback(successCallback, message);
        }, function(message) {
            executeCallback(errorCallback, message);
        }, 'ApplePay', 'startListeningForShippingContactSelection');
    },
    
    /**
     * Stops listening for shipping contact selection changes
     * @param {Function} [successCallback] - Optional success callback
     * @param {Function} [errorCallback] - Optional error callback, receives message object.
     * @return {Promise}
     */
    stopListeningForShippingContactSelection: function(successCallback, errorCallback) {
        return new Promise(function(resolve, reject) {
            exec(function(message) {
                executeCallback(successCallback, message);
                resolve(message);
            }, function(message) {
                executeCallback(errorCallback, message);
                reject(message);
            }, 'ApplePay', 'stopListeningForShippingContactSelection');
        });
    },
    
    /**
     * Update the list of pay sheet items and shipping methods in response to
     * a shipping contact selection event. This *must* be called in response to
     * any shipping contact selection event or else the user will not be able
     * to complete a transaction on the pay sheet.
     * @param {Object} including `items` and `shippingMethods` properties.
     * @param {Function} [successCallback] - Optional success callback, receives message object.
     * @param {Function} [errorCallback] - Optional error callback, receives message object.
     * @returns {Promise}
     */
    updateItemsAndShippingMethods: function(list, successCallback, errorCallback) {
        return new Promise(function(resolve, reject) {
            exec(function(message) {
                executeCallback(successCallback, message);
                resolve(message);
            }, function(message) {
                executeCallback(errorCallback, message);
                reject(message);
            }, 'ApplePay', 'updateItemsAndShippingMethods', [list]);
        });
    },
    
    /**
     * While the Apple Pay sheet is still open, and the callback from the `makePaymentRequest` has completed,
     * this call will pass the status to the sheet and close it if successfull.
     * @param {Function} [successCallback] - Optional success callback, recieves message object.
     * @param {Function} [errorCallback] - Optional error callback, recieves message object.
     * @returns {Promise}
     */
    completeLastTransaction: function(status, successCallback, errorCallback) {
        return new Promise(function(resolve, reject) {
            exec(function(message) {
                executeCallback(successCallback, message);
                resolve(message);
            }, function(message) {
                executeCallback(errorCallback, message);
                reject(message);
            }, 'ApplePay', 'completeLastTransaction', [status]);
        });
    }
};

module.exports = ApplePay;
