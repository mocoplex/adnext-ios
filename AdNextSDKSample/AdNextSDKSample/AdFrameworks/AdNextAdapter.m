//
//  AdNextAdapter.m
//  AdNextSDKSample
//
//  Created by Mocoplex on 2018. 9. 5..
//  Copyright © 2018년 mocoplex. All rights reserved.
//

#import "AdNextAdapter.h"

@import WebKit;

#ifdef AdNext_Use_Facebook
@import FBSDKCoreKit;
@import Bolts;
#endif

#ifdef AdNext_Use_Google
@import FirebaseCore;
@import FirebaseAnalytics;
@import FirebaseDynamicLinks;
#endif

#ifdef AdNext_Use_Kakao
@import KakaoAdSDK;
#endif

@interface AdNextAdapter() <WKScriptMessageHandler>

@property (nonatomic) BOOL debugMode;

@end

@implementation AdNextAdapter

+ (NSString *)adpaterVersion
{
    return @"1.001";
}

+ (void)initializeWithRatID:(NSString *)ratId kakaoTrackId:(NSString *)kakaoTid enableDebugMode:(BOOL)debugMode
{
    [[AdNextAdapter sharedInstance] setDebugMode:debugMode];
    
    [ADNextCore activeDebugLog:debugMode];
    [ADNextCore initializeSdkWithRatId:ratId];
    
#ifdef AdNext_Use_Kakao
    //Kakao - 카카오 테스트 키입니다. 카카오 플랫폼을 사용하실 경우 매체사에서 발급받은 라이브키로 교체해서 사용해주세요.
    KakaoAdTracker.trackId = kakaoTid;
#endif
    
}

// 초기화에 필요한 코드들을 기입합니다.
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifdef AdNext_Use_Facebook
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    //FB 지연된 딥링크 기능 사용 시 (옵션)
    __weak __typeof__(self) weakSelf = self;
    if (launchOptions[UIApplicationLaunchOptionsURLKey] == nil) {
        [FBSDKAppLinkUtility fetchDeferredAppLink:^(NSURL *url, NSError *error) {
            if (error) {
                
            }
            if (url) {
                [weakSelf handleWithDeepLink:url];
            }
        }];
    }
#endif
    
#ifdef AdNext_Use_Google
    [FIRApp configure];
#endif
    
    return YES;
}

// 딥링크를 커스텀URL을 통해 광고 캠페인에 해당하는 웹페이지를 앱에서 사용하는 웹뷰에 로딩하는 처리를 이부분에 구현합니다.
- (BOOL)handleWithDeepLink:(NSURL *)linkUrl
{
    if (_debugMode) {
        NSLog(@"handleWithDeepLink : %@", linkUrl);
    }
    
    BOOL handleWithLink = NO;
    
    ADNextUrlSchemeInfo *schemeInfo = [ADNextCore setDeepLinks:linkUrl];
    BOOL isAdNxtHandledLink = schemeInfo.isHandled;
    if (isAdNxtHandledLink) {
        
        if (_customBlockOnHandleDeepLink != nil) {
            if (_debugMode) {
                NSLog(@"call _customBlockOnHandleDeepLink : %@", schemeInfo);
            }
            _customBlockOnHandleDeepLink(schemeInfo);
        }
        
        handleWithLink = YES;
    }
    
    return handleWithLink;
}

/////////////////////////////////////////////////////////////////////////////////////////
//아래 내용은 구현에 필요한 내용을 사전에 구현하여 배포하는 메소드들로 별도로 수정 이슈가 없는 코드들입니다.
/////////////////////////////////////////////////////////////////////////////////////////

- (void)applicationDidBecomeActive:(UIApplication *)application
{
#ifdef AdNext_Use_Kakao
    [KakaoAdTracker activate];
#endif
}

//openURL 커스텀 스키마에 대한 처리를 수행합니다.
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    //NSLog(@"application openUrl : %@\nsourceApplication = %@\nannotaion = %@", url, sourceApplication, annotation);
    
#ifdef AdNext_Use_Google
    FIRDynamicLink *dynamicLink = [[FIRDynamicLinks dynamicLinks] dynamicLinkFromCustomSchemeURL:url];
    if (dynamicLink) {
        if (dynamicLink.url) {
            [self handleWithDeepLink:dynamicLink.url];
        }
        return YES;
    }
#endif
    
#ifdef AdNext_Use_Facebook
    [[FBSDKApplicationDelegate sharedInstance] application:application
                                                   openURL:url
                                         sourceApplication:sourceApplication
                                                annotation:annotation];
    
    BFURL *parsedUrl = [BFURL URLWithInboundURL:url sourceApplication:sourceApplication];
    if ([parsedUrl appLinkData]) {
        //BFAppLink *reffererLink = [parsedUrl appLinkReferer];
        // this is an applink url, handle it here
        NSURL *targetUrl = [parsedUrl targetURL];
        if (targetUrl) {
            [self handleWithDeepLink:targetUrl];
        }
        return YES;
    }
    
#endif
    
    //페북, 카카오 딥링크가 아닌 케이스에 대한 처리 시도
    BOOL res = [self handleWithDeepLink:url];
    
    return res;
}

//유니버셜링크에 대한 처리를 수행합니다.
- (BOOL)application:(UIApplication *)application
continueUserActivity:(NSUserActivity *)userActivity
 restorationHandler:(void(^)(NSArray * __nullable restorableObjects))restorationHandler
{
    BOOL handled = NO;
    
#ifdef AdNext_Use_Google
    //https://firebase.google.com/docs/dynamic-links/debug?hl=ko
    __weak __typeof__(self) weakSelf = self;
    handled = [[FIRDynamicLinks dynamicLinks] handleUniversalLink:userActivity.webpageURL
                                                       completion:^(FIRDynamicLink * _Nullable dynamicLink, NSError * _Nullable error) {
                                                           
                                                           // Handle the deep link.
                                                           if (dynamicLink) {
                                                               if (dynamicLink.url) {
                                                                   [weakSelf handleWithDeepLink:dynamicLink.url];
                                                               }
                                                           }
                                                       }];
    if (handled) {
        return YES;
    }
#endif
    
    NSURL *linkUrl = userActivity.webpageURL;
    handled = [self handleWithDeepLink:linkUrl];
    
    return handled;
}

+ (instancetype)sharedInstance
{
    static AdNextAdapter *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

#pragma mark - WKScriptMessageHandler

- (void)augmentHybridWKWebView:(WKWebView *)webView
{
    if (webView == nil) return;
    
#ifdef AdNext_Use_Facebook
    if ([ADNextCore sharedInstance].enableFaceBook) {
        [FBSDKAppEvents augmentHybridWKWebView:webView];
    }
#endif
    
    //For Google, etc.. platforms
    [webView.configuration.userContentController addScriptMessageHandler:self name:kADNXT_WEBHANDLER];
}

// [START handle_messages]

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    @try{
        NSString *command = message.body[@"command"];
        
        [ADNextCore webKitUserContentController:userContentController didReceiveScriptMessage:message];
        
#ifdef AdNext_Use_Google
        if ([command isEqual: @"gadEvent"] && [ADNextCore sharedInstance].enableGoogle) {
            //구글 파이어베이스 이벤트 처리
            [FIRAnalytics logEventWithName:message.body[@"name"] parameters:message.body[@"parameters"]];
        }
#endif
        
#ifdef AdNext_Use_Kakao
        if ([command isEqual: @"kakaoEvent"] && [ADNextCore sharedInstance].enableKakao) {
            [self kakao_userContentController:userContentController didReceiveScriptMessage:message];
        }
#endif
    }
    @catch(NSException *e) {
        
    }
}

- (void)kakao_userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
#ifdef AdNext_Use_Kakao
    
    NSString *tag = message.body[@"name"];
    NSDictionary<NSString *, id> *params = message.body[@"parameters"];
    if (tag == nil || params == nil) {
        return;
    }
    
    if ([tag isEqualToString:@"view"]) {
        
        NSString *pid = params[@"id"];
        if (pid) {
            [KakaoAdTracker sendViewContentEventWithTag:tag contentId:pid];
        }
        
    } else if ([tag isEqualToString:@"buy"]) {
        
        NSString *total_quantity = params[@"total_quantity"];
        NSString *total_price = params[@"total_price"];
        NSString *currency = params[@"currency"];
        
        NSArray *products = params[@"products"];
        NSMutableArray *plist = [[NSMutableArray alloc] init];
        
        for (NSDictionary *prod in products) {
            NSString *name = prod[@"name"];
            NSString *quantity = prod[@"quantity"];
            NSString *price = prod[@"price"];
            
            KakaoAdDetailProduct* p = [[KakaoAdDetailProduct alloc] initWithName:name
                                                                        quantity:[quantity integerValue]
                                                                           price:[price doubleValue]];
            [plist addObject:p];
        }
        
        [KakaoAdTracker sendPurchaseEventWithTag:tag
                                   totalQuantity:[total_quantity integerValue]
                                      totalPrice:[total_price integerValue]
                                        currency:currency
                                        products:products];
    }
    
#endif
}

// [END handle_messages]

- (void)logEventViewItems:(NSArray<ADNextItem *> *)items currency:(NSString *)currency
{
    if (_debugMode) {
        NSLog(@"%s > %@",__PRETTY_FUNCTION__, items);
    }
    
    if (items.count < 1) return;
    if (currency == nil) currency = @"KRW";
    
    [ADNextCore logRatEvent:ADNextAppEventNameViewContent withItems:items];
    
    if ([ADNextCore sharedInstance].enableKakao) {
        [self nativeCall_KakaoViewWithItems:items];
    }
    if ([ADNextCore sharedInstance].enableFaceBook) {
        [self nativeCall_FacebookEvent:FBSDKAppEventNameViewedContent withItems:items currency:currency];
    }
    if ([ADNextCore sharedInstance].enableGoogle) {
        [self nativeCall_GoogleEventName:kFIREventViewItem withItems:items currency:currency];
    }
}

- (void)logEventPurchaseItems:(NSArray<ADNextItem *> *)items currency:(NSString *)currency
{
    if (_debugMode) {
        NSLog(@"%s > %@",__PRETTY_FUNCTION__, items);
    }
    
    if (items.count < 1) return;
    if (currency == nil) currency = @"KRW";
    
    [ADNextCore logRatEvent:ADNextAppEventNamePurchase withItems:items];
    
    if ([ADNextCore sharedInstance].enableKakao) {
        [self nativeCall_KakaoPurchaseWithItems:items currency:currency];
    }
    if ([ADNextCore sharedInstance].enableFaceBook) {
        [self nativeCall_FacebookPurchaseWithItems:items currency:currency];
    }
    if ([ADNextCore sharedInstance].enableGoogle) {
        [self nativeCall_GoogleEventName:kFIREventEcommercePurchase withItems:items currency:currency];
    }
}

- (void)logEventAddToCartItems:(NSArray<ADNextItem *> *)items currency:(NSString *)currency
{
    if (_debugMode) {
        NSLog(@"%s > %@",__PRETTY_FUNCTION__, items);
    }
    
    if (items.count < 1) return;
    if (currency == nil) currency = @"KRW";
    
    [ADNextCore logRatEvent:ADNextAppEventNameAddedToCart withItems:items];
    
    if ([ADNextCore sharedInstance].enableFaceBook) {
        [self nativeCall_FacebookEvent:FBSDKAppEventNameAddedToCart withItems:items currency:currency];
    }
    if ([ADNextCore sharedInstance].enableGoogle) {
        [self nativeCall_GoogleEventName:kFIREventAddToCart withItems:items currency:currency];
    }
}

/**
 *  Kakao Native Api : VIEW / BUY
 */
- (void)nativeCall_KakaoViewWithItems:(NSArray<ADNextItem *> *)items
{
#ifdef AdNext_Use_Kakao
    NSString *tag = @"nview";
    for (ADNextItem *item in items) {
        NSString *contentId = item.contentId;
        [KakaoAdTracker sendViewContentEventWithTag:tag contentId:contentId];
    }
#endif
}

- (void)nativeCall_KakaoPurchaseWithItems:(NSArray<ADNextItem *> *)items currency:(NSString *)currency
{
#ifdef AdNext_Use_Kakao
    NSString *tag = @"nbuy";
    
    NSInteger totalQuantity = 0;
    double totalPrice = 0;
    NSMutableArray<KakaoAdDetailProduct*> *products = [NSMutableArray array];
    
    for (ADNextItem *item in items) {
        
        NSString *name = item.contentName;
        if (name == nil) continue;
        
        NSUInteger quantity = item.quantity;
        double price = item.price;
        
        totalPrice += (price * quantity);
        totalQuantity += quantity;
        
        KakaoAdDetailProduct* p = [[KakaoAdDetailProduct alloc] initWithName:name
                                                                    quantity:quantity
                                                                       price:price];
        [products addObject:p];
    }
    
    [KakaoAdTracker sendPurchaseEventWithTag:tag
                               totalQuantity:totalQuantity
                                  totalPrice:totalPrice
                                    currency:currency
                                    products:products];
#endif
}


/**
 *  FAN Native Api : VIEW / BUY / CART
 */
- (void)nativeCall_FacebookEvent:(NSString *)eventName withItems:(NSArray<ADNextItem *> *)items currency:(NSString *)currency
{
#ifdef AdNext_Use_Facebook
    
    double totalPrice = 0;
    NSMutableArray *productList = [NSMutableArray array];
    
    for (ADNextItem *item in items) {
        
        NSString *contentId = item.contentId;
        if (contentId == nil) continue;
        
        NSUInteger quantity = item.quantity;
        double price = item.price;
        totalPrice += (price * quantity);
        
        NSDictionary *p = @{@"id" : contentId,
                            @"quantity" : [NSNumber numberWithUnsignedInteger:quantity],
                            @"item_price" : [NSNumber numberWithDouble:price]
                            };
        [productList addObject:p];
    }
    
    NSString *contentType = @"product";
    if (productList.count == 0) {
        return;
    } else if (productList.count > 1) {
        contentType = @"product_group";
    }
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:productList options:0 error:&error];
    if (error != nil) return;
    
    NSString *contentData = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSDictionary *params =
    @{
      FBSDKAppEventParameterNameContent : contentData,
      FBSDKAppEventParameterNameContentType : contentType,
      FBSDKAppEventParameterNameCurrency : currency
      };
    
    if ([eventName isEqualToString:FBSDKAppEventNameViewedContent] || [eventName isEqualToString:FBSDKAppEventNameAddedToCart]) {
        [FBSDKAppEvents logEvent:eventName valueToSum:totalPrice parameters:params];
    }
    
#endif
}

- (void)nativeCall_FacebookPurchaseWithItems:(NSArray<ADNextItem *> *)items currency:(NSString *)currency
{
#ifdef AdNext_Use_Facebook
    
    double totalPrice = 0;
    NSMutableArray *productList = [NSMutableArray array];
    
    for (ADNextItem *item in items) {
        
        NSString *contentId = item.contentId;
        if (contentId == nil) continue;
        
        NSUInteger quantity = item.quantity;
        double price = item.price;
        totalPrice += (price * quantity);
        
        NSDictionary *p = @{@"id" : contentId,
                            @"quantity" : [NSNumber numberWithUnsignedInteger:quantity],
                            @"item_price" : [NSNumber numberWithDouble:price]
                            };
        [productList addObject:p];
    }
    
    NSString *contentType = @"product";
    if (productList.count == 0) {
        return;
    } else if (productList.count > 1) {
        contentType = @"product_group";
    }
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:productList options:0 error:&error];
    if (error != nil) return;
    
    NSString *contentData = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSDictionary *params =
    @{
      FBSDKAppEventParameterNameContent : contentData,
      FBSDKAppEventParameterNameContentType : contentType,
      FBSDKAppEventParameterNameCurrency : currency
      };
    
    [FBSDKAppEvents logPurchase:totalPrice currency:currency parameters:params];
#endif
}


/**
 *  Google Firebase Native Api : VIEW / BUY / CART
 *  https://developers.google.com/tag-manager/ios/v5/enhanced-ecommerce
 */

- (void)nativeCall_GoogleEventName:(NSString *)eventName withItems:(NSArray<ADNextItem *> *)items currency:(NSString *)currency
{
    NSMutableArray *productList = [NSMutableArray array];
    double totalPrice = 0;
    
    for (ADNextItem *item in items) {
        
        NSString *contentId = item.contentId;
        NSString *contentName = item.contentName;
        
        if (contentId == nil || contentName == nil) continue;
        
        NSString *contentCategory = item.contentType;
        NSUInteger quantity = item.quantity;
        double price = item.price;
        totalPrice += (price * quantity);
        
        NSDictionary *product = @{
                                  kFIRParameterItemID : contentId,
                                  kFIRParameterItemName :contentName,
                                  kFIRParameterPrice : [NSNumber numberWithDouble:price],
                                  kFIRParameterCurrency : currency,
                                  kFIRParameterQuantity : [NSNumber numberWithInteger:quantity]
                                  };
        [productList addObject:product];
    }
    
    [FIRAnalytics logEventWithName:eventName //kFIREventEcommercePurchase
                        parameters:@{
                                     @"items": productList,
                                     kFIRParameterValue: [NSNumber numberWithDouble:totalPrice],
                                     kFIRParameterCurrency: currency
                                     }];
}

@end
