//
//  ADNextCore.h
//  ADNextCoreSDK
//
//  Created by Mocoplex on 2018. 9. 4..
//  Copyright © 2018년 mocoplex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ADNextCoreSDK/ADNextItem.h>

@import WebKit;

NS_ASSUME_NONNULL_BEGIN



static NSString *const kADNXT_SCHEME_NAME    = @"adnxt";    //커스텀 스키마 네이밍 (옵션값)
static NSString *const kADNXT_QUERYPARAM_CP  = @"adnxtcp";  //광고 캠페인 네트워크 코드 (필수)
static NSString *const kADNXT_QUERYPARAM_PID = @"adnxtpid"; //광고 상품 고유 번호 (옵션값)
static NSString *const kADNXT_QUERYPARAM_URL = @"adnxturl"; //광고 상품 URL 정보 (옵션값)

static NSString *const kADNXT_WEBHANDLER     = @"adnxtjs";  //웹뷰 JS 커스텀핸들러 명칭

static NSString *const ADNextAppEventNameViewContent = @"RAT_VIEW";
static NSString *const ADNextAppEventNamePurchase    = @"RAT_BUY";
static NSString *const ADNextAppEventNameAddedToCart = @"RAT_CART";

typedef NS_ENUM(NSInteger, ADNextLinkType){
    ADNextLinkTypeUniversalLink = 0,  // 유니버셜링크
    ADNextLinkTypeCustomScheme  = 1,  // 커스텀스키마
};


/**
 *  링크유입 URL로 해당 객체를 생성하면 초기화 시 해당 링크 정보를 파싱하여
 *  ADNextUrlSchemeInfo 객체를 생성한다.
 */
@interface ADNextUrlSchemeInfo : NSObject

@property (nonatomic, copy, readonly) NSURL *url;       //링크 오픈시 원본 URL
@property (nonatomic, copy, readonly) NSString *scheme; //url scheme
@property (nonatomic, copy, readonly) NSString *host;   //url host
@property (nonatomic, copy, readonly) NSString *path;   //url path
@property (nonatomic, strong, readonly) NSDictionary *queryComponents; //url 쿼리 파싱된 키,벨류 값 Dictionary

@property (nonatomic, readonly) BOOL isHandled; //default NO : ADNXT 링크트래킹 지원하는 링크인 경우 YES값으로 세팅됨
@property (nonatomic, readonly) ADNextLinkType linkType; // 유입된 링크 타입 : 커스텀 스키마 혹은 링크(유니버셜 링크)

@property (nonatomic, copy, readonly) NSString *campaignId; //필수 : 링크집행시 기입된 광고네트워크 캠페인 아이디값
@property (nonatomic, copy, readonly) NSString *productId;  //옵션 : 링크집행시 기입된 상품정보
@property (nonatomic, copy, readonly) NSString *encodedUrl; //옵션 : 링크집행시 기입된 인코딩된 URL정보

- (instancetype)initWithURL:(NSURL *)url;

@end

/**
 *  ADNextCore 객체로 링크 유입 트래킹 및 하이브리드 웹뷰 이벤트 트래킹 기능을 지원한다.
 */
@interface ADNextCore : NSObject {
    
}

@property (nonatomic, readonly) BOOL enableFaceBook;
@property (nonatomic, readonly) BOOL enableGoogle;
@property (nonatomic, readonly) BOOL enableKakao;

+ (void)initializeSdkWithRatId:(NSString *)ratid; //초기화 함수 : 반드시 발급받은 RAT-ID값으로 사용전 초기화한다
+ (void)activeDebugLog:(BOOL)enable; //default NO : 디버그 메시지 출력여부 지정
+ (instancetype)sharedInstance;

//어플리케이션 유입 링크 url을 통해 ADNextUrlSchemeInfo 객체를 반환한다.
//ADNXT 플랫폼 링크 유입 측정 메소드를 내부적으로 처리한다.
+ (nonnull ADNextUrlSchemeInfo *)setDeepLinks:(NSURL *)url;

//하이브리드앱인 경우 상품페이지의 웹뷰에서 발생하는 이벤트 트래킹을 지원한다. (View/Buy/Cart)
//webkit 스크립트 메시지를 전달 받은 경우 해당함수를 호출하여 ADNXT 플랫폼 이벤트 트래킹함수를 내부적으로 처리한다.
+ (void)webKitUserContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message;
+ (void)logRatEvent:(NSString *)name withItems:(NSArray<ADNextItem *> *)items;

@end

NS_ASSUME_NONNULL_END
