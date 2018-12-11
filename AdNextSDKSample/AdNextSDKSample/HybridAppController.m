//
//  ViewController.m
//  AdNextSDKSample
//
//  Created by Mocoplex on 2018. 9. 4..
//  Copyright © 2018년 mocoplex. All rights reserved.
//

#import "HybridAppController.h"
#import "AdNextAdapter.h"

@interface HybridAppController ()

@end

@implementation HybridAppController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    NSString *ratTestPage = @"http://storage0.mocoplex.com/uidev/network/rat_test.html";
    NSString *adsTestPage = @"http://storage0.mocoplex.com/uidev/network/test.html";
    
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:adsTestPage]];
    
    _webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    [[AdNextAdapter sharedInstance] augmentHybridWKWebView:_webView];
    
    [self.view addSubview:_webView];
    [_webView loadRequest:req];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
