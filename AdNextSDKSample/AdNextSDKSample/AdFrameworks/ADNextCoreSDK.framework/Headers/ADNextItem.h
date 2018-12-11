//
//  ADNextItem.h
//  ADNextCoreSDK
//
//  Created by Mocoplex on 2018. 10. 10..
//  Copyright © 2018년 mocoplex. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ADNextItem : NSObject

@property (nonatomic, strong, readonly) NSString * contentId;   //상품 고유아이디
@property (nonatomic, strong, readonly) NSString * contentName; //상품 명
@property (nonatomic, strong, readonly) NSString * contentType; //상품 카테고리

@property (nonatomic, readonly) NSUInteger quantity;            //상품 수량
@property (nonatomic, readonly) double price;                   //상품 가격

//Optional - 필요에 따라 추가로 직접 세팅할 수 있는 파라메터 값.

@property (nonatomic) BOOL outOfStock;                                 //품절여부, 기본값 NO
@property (nonatomic) double listPrice;                                //상품정가, 기본값 price와 동일하게 세팅됨.
@property (nonatomic, strong, nullable) NSString * contentImageUrl;    //상품 이미지 URL
@property (nonatomic, strong, nullable) NSString * contentSubType;     //상품 카테고리 중분류명
@property (nonatomic, strong, nullable) NSString * contentDetailType;  //상품 카테고리 소분류명

@property (nonatomic, strong, nullable) NSDictionary *extraParams;     //추가로 수집하고 싶은 데이터의 키/벨류 값

+ (instancetype)itemWithId:(NSString *)itemId
                      name:(NSString *)itemName
                      type:(NSString *)itemType
                   quantiy:(NSUInteger)quantity
                     price:(NSUInteger)price;

@end

NS_ASSUME_NONNULL_END
