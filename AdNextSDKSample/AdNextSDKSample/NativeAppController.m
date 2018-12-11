//
//  NativeAppController.m
//  AdNextSDKSample
//
//  Created by Mocoplex on 2018. 10. 12..
//  Copyright © 2018년 mocoplex. All rights reserved.
//

#import "NativeAppController.h"
#import "AdNextAdapter.h"

@interface NativeAppController()

@property (nonatomic, strong) ADNextItem *contentItem1;
@property (nonatomic, strong) ADNextItem *contentItem2;

@end

@implementation NativeAppController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _contentItem1 = [ADNextItem itemWithId:@"id-prod1"
                                      name:@"name-prod1"
                                     type:@"product"
                                  quantiy:2
                                    price:1000.0];
    
    _contentItem1.contentImageUrl = @"http://adnext.co/imag?width=240&name=test.png";
    _contentItem1.listPrice = 1100.0;
    _contentItem1.contentSubType = @"subtype&`~!@#$%^&*()-=\\/;',.   end";
    _contentItem1.contentDetailType = @"detail_type&= !!@#$%^&*()-+end";
    
    _contentItem1.outOfStock = NO;
    
    _contentItem2 = [ADNextItem itemWithId:@"id-prod2"
                                     name:@"name-prod2"
                                     type:@"product"
                                  quantiy:3
                                    price:3000.0];
}

- (IBAction)eventViewContents:(id)sender
{
    [[AdNextAdapter sharedInstance] logEventViewItems:@[_contentItem1, _contentItem2] currency:@"KRW"];
}

- (IBAction)eventPurchase:(id)sender
{
    [[AdNextAdapter sharedInstance] logEventPurchaseItems:@[_contentItem1, _contentItem2] currency:@"KRW"];
}

- (IBAction)eventAddToCart:(id)sender
{
    [[AdNextAdapter sharedInstance] logEventAddToCartItems:@[_contentItem1, _contentItem2] currency:@"KRW"];
}

@end
