//
//  AppDelegate.m
//  AdNextSDKSample
//
//  Created by Mocoplex on 2018. 9. 4..
//  Copyright © 2018년 mocoplex. All rights reserved.
//

#import "AppDelegate.h"
#import "AdNextAdapter.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)initializeAdNextSDK {
    
    NSString *adnxtRatID   = @"5476d35e0cf2fd8cbba18b7c"; // ADNEXT SDK에 필요한 RAT-ID 키값 추후 전달받은 값으로 교체
    NSString *kakaoTrackId = @"8254003883982697027";      // KAKAO SDK에 필요한 TRK-ID 키값 추후 전달받은 값으로 교체
    BOOL isDebugMode = YES;
    
    [AdNextAdapter initializeWithRatID:adnxtRatID kakaoTrackId:kakaoTrackId enableDebugMode:isDebugMode];
    
    __weak __typeof__(self) weakSelf = self;
    [[AdNextAdapter sharedInstance] setCustomBlockOnHandleDeepLink:^(ADNextUrlSchemeInfo * _Nonnull schemeInfo) {
        
        if (schemeInfo.linkType == ADNextLinkTypeUniversalLink) { //유니버셜 링크처리
            
            NSURL *productUrl = schemeInfo.url;   //하이브리드 웹인경우 URL 주소를 직접 로딩해서 호출
            NSString *pid = schemeInfo.productId; //네이티브앱인경우 product_id를 사용
            
        } else if (schemeInfo.linkType == ADNextLinkTypeCustomScheme) { //커스텀링크처리
            
            NSString *pid = schemeInfo.productId; //네이티브앱인경우 product_id를 사용
            NSString *encodedUrl = schemeInfo.encodedUrl; //하이브리드 웹인경우 encodedUrl 주소를 url디코딩한 이후 사용 혹은
        }
        
        //애드넥스트를 통해 발행한 링크로 상품 정보를 가지고 화면을 구성할수있는 케이스입니다.
        //!!! self 접근 대신 weakSelf를 사용하여 상품 정보를 가지고 화면에 광고 상품 페이지를 구성하는 코드를 여기에 작성.
        //.....
    }];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self initializeAdNextSDK];
    
    BOOL res = [[AdNextAdapter sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    // Add any custom logic here.
    
    return res;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
   
    [[AdNextAdapter sharedInstance] applicationDidBecomeActive:application];
}

//Custom URI Delegate NS_AVAILABLE_IOS(9_0)
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<NSString *, id> *)options {
    
    NSString *sourceApplication = nil;
    id annotation = nil;
    
    if (@available(iOS 9.0, *)) {
        sourceApplication = options[UIApplicationOpenURLOptionsSourceApplicationKey];
        annotation = options[UIApplicationOpenURLOptionsAnnotationKey];
    }
    
    BOOL res = [[AdNextAdapter sharedInstance] application:application
                                                   openURL:url
                                         sourceApplication:sourceApplication
                                                annotation:annotation];
    // Add any custom logic here.
    return res;
}

//Custom URI Delegate NS_DEPRECATED_IOS(4_2, 9_0, "Please use application:openURL:options:")
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    BOOL res = [[AdNextAdapter sharedInstance] application:application
                                                   openURL:url
                                         sourceApplication:sourceApplication
                                                annotation:annotation];
    
    // Add any custom logic here.
    return res;
}

//Universal Links Delegate
- (BOOL)application:(UIApplication *)application
continueUserActivity:(NSUserActivity *)userActivity
 restorationHandler:(void(^)(NSArray * __nullable restorableObjects))restorationHandler {
    
    BOOL handled = [[AdNextAdapter sharedInstance] application:application
                                          continueUserActivity:userActivity
                                            restorationHandler:restorationHandler];
    
    // Add any custom logic here.
    
    return handled;
}

@end
