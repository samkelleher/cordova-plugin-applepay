#import <UIKit/UIKit.h>
#import <Cordova/CDVPlugin.h>

#import <PassKit/PassKit.h>

typedef void (^ARAuthorizationBlock)(PKPaymentAuthorizationStatus);
typedef void (^ARListUpdateBlock)(PKPaymentAuthorizationStatus, NSArray<PKShippingMethod *>*, NSArray<PKPaymentSummaryItem *>*);

@interface CDVApplePay : CDVPlugin <PKPaymentAuthorizationViewControllerDelegate> {}

@property (nonatomic, strong) ARAuthorizationBlock paymentAuthorizationBlock;

@property (nonatomic, strong) ARListUpdateBlock updateItemsAndShippingMethodsBlock;

@property (nonatomic, strong) NSString* paymentCallbackId;

@property (nonatomic, strong) NSString* shippingContactSelectionListenerCallbackId;

@property (nonatomic, strong) NSArray<PKShippingMethod *>* shippingMethods;

@property (nonatomic, strong) NSArray<PKPaymentSummaryItem *>* summaryItems;

- (void)makePaymentRequest:(CDVInvokedUrlCommand*)command;
- (void)startListeningForShippingContactSelection:(CDVInvokedUrlCommand*)command;
- (void)stopListeningForShippingContactSelection:(CDVInvokedUrlCommand*)command;
- (void)updateItemsAndShippingMethods:(CDVInvokedUrlCommand*)command;
- (void)canMakePayments:(CDVInvokedUrlCommand*)command;
- (void)completeLastTransaction:(CDVInvokedUrlCommand*)command;

@end
