//
//  AdNextAdapter.h
//  AdNextSDKSample
//
//  Created by Mocoplex on 2018. 9. 5..
//  Copyright © 2018년 mocoplex. All rights reserved.
//

#import <Foundation/Foundation.h>

#define AdNext_Use_Facebook
#define AdNext_Use_Google
#define AdNext_Use_Kakao

@import ADNextCoreSDK;

NS_ASSUME_NONNULL_BEGIN


typedef void (^AdNextAdapterLinkHandler)(ADNextUrlSchemeInfo *schemeInfo)
NS_SWIFT_NAME(AdNextAdapterLinkHandler);


@interface AdNextAdapter : NSObject {
    
}

@property (nonatomic, copy, nullable) AdNextAdapterLinkHandler customBlockOnHandleDeepLink;

+ (instancetype)sharedInstance;
+ (NSString *)adpaterVersion;

+ (void)initializeWithRatID:(NSString *)ratId kakaoTrackId:(NSString *)kakaoTid enableDebugMode:(BOOL)debugMode;

/**
 *  광고 캠페인 유입 동적 링크 처리가 필요한 경우 아래 메소드들을 AppDelegate의 해당 델리게이트에서 호출합니다.
 */

//어플리케이션 처음 열었을 경우 및 지연된 딥링크 처리가 호출됩니다.
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

//어플리케이션이 활성화 상태로 진입 시 필요한 처리가 호출됩니다.
- (void)applicationDidBecomeActive:(UIApplication *)application;

//이 메소드는 iOS 8 이하의 경우 앱이 링크를 수신할 때 및 iOS 버전을 불문하고 앱을 설치한 후 처음으로 열었을 때 호출됩니다.
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

//application:continueUserActivity:restorationHandler: 메소드에서 iOS 9 이상에서 앱이 이미 설치된 경우에 범용 링크로 수신된 링크를 처리합니다.
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray * __nullable restorableObjects))restorationHandler;


/**
 * 하이브리드 웹앱 페이지의 경우 구매전환 SDK 측정이 필요한 경우 아래 메소드를 호출해
 * 커스텀 자바스크립트 핸들러 처리를 등록합니다.
 */

//하이브리드 구매전환 연동시 웹뷰 등록
- (void)augmentHybridWKWebView:(WKWebView *)webView;

/**
 * 네이티브 앱 구성시 구매전환 등 이벤트 측정이 필요한 경우 아래 메소드들 호출해서 사용
 *
 * Currency, is denoted as, e.g. "KRW", "USD", "EUR", "GBP".  See ISO-4217 for
 * specific values.  One reference for these is <http://en.wikipedia.org/wiki/ISO_4217>.
 */

//구매 이벤트 트래킹
- (void)logEventPurchaseItems:(NSArray<ADNextItem *> *)items currency:(NSString *)currency;

//상품 뷰 이벤트 트래킹
- (void)logEventViewItems:(NSArray<ADNextItem *> *)items currency:(NSString *)currency;

//장바구니 이벤트 트래킹
- (void)logEventAddToCartItems:(NSArray<ADNextItem *> *)items currency:(NSString *)currency;

@end
NS_ASSUME_NONNULL_END
