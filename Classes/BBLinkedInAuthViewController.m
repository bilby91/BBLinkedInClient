//
//  BBLinkedInAuthViewController.m
//  BBLinkedInAPI
//
//  Created by Martín Fernández on 11/26/13.
//  Copyright (c) 2013 Martín Fernández. All rights reserved.
//

#import "BBLinkedInAuthViewController.h"
#import "BBLinkedInClient.h"
#import "NSString+BBEncode.h"
#import "BBErrors.h"


@interface BBLinkedInAuthViewController ()


@property (nonatomic, strong) UIWebView *webView;

@property (nonatomic)           BOOL            isRedirectURL;
@property (nonatomic,copy)      NSString *      scope;


@end

@implementation BBLinkedInAuthViewController

@synthesize webView         = _webView;
@synthesize delegate        = _delegate;
@synthesize client          = _client;
@synthesize isRedirectURL   = _isRedirectURL;
@synthesize scope           = _scope;


- (id)init
{
    self = [super initWithNibName:@"BBLinkedInAuthViewController" bundle:nil];
    
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithClient:(BBLinkedInClient *)client
               scope:(NSString *)scope
{
    self = [super init];
    
    if (!self)
        return nil;
    
    _client     = client;
    _scope      = scope;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.frame = self.view.window.frame;
    
    
    _navigationBar                 = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 60)];
    _navigationBar.tintColor       = [UIColor blackColor];
    _navigationBar.backgroundColor = [UIColor grayColor];
    _navigationBar.translucent     = YES;

    [self.view addSubview:_navigationBar];
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(dissmisButtonPressed:)];
    UINavigationItem *navItem   = [[UINavigationItem alloc] initWithTitle:@""];
    navItem.leftBarButtonItem   = cancelItem;
    _navigationBar.items        = [NSArray arrayWithObject:navItem];
    
    _webView          = [[UIWebView alloc] initWithFrame:CGRectMake(0, 60, _navigationBar.frame.size.width, 500)];
    _webView.delegate = self;
    _webView.hidden   = YES;
    
    [self.view addSubview:_webView];
}

- (void)viewDidAppear:(BOOL)animated
{
    
    NSAssert(_client, @"Client can't be nil.");
    
    NSURLRequest *request = [_client getAuhorizationCodeRequestWithScope:_scope];
    [self.webView loadRequest:request];
}

- (NSDictionary *)parseURLParameters:(NSString *)stringParams
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSArray *kv = [stringParams componentsSeparatedByString:@"&"];
    
    for (NSString* s in kv) {
        NSArray *tmp = [s componentsSeparatedByString:@"="];
        params[[tmp objectAtIndex:0]] = [tmp objectAtIndex:1];
    }
    
    return params;
}

- (NSDictionary *)parseHTTPBody:(NSData *)data
{
    NSError *error;
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    return response;
}

- (void)handleCorrectAuthorizationWithCode:(NSString *)code
{
    [_client postAccessTokenWithCode:code andSuccessBlock:^(NSDictionary *responeObject) {
        NSLog(@"%@",responeObject[@"access_token"]);
        [_client setOAuthToken:responeObject[@"access_token"]];
        [_delegate succesfullAuthentication];
    } failure:^(NSError *error) {
        [_delegate failedAuthenticationWithError:error];
    }];
}

#pragma mark - WebViewDelegate Implementation

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    NSError *error;
    NSString *urlString = [[request URL] absoluteString];
    _isRedirectURL      = [urlString hasPrefix:kRedirectURI];
    if (_isRedirectURL) {
        
        NSString *stringParams = [[urlString componentsSeparatedByString:@"?"] objectAtIndex:1];
        NSDictionary *params   = [self parseURLParameters:stringParams];
        
        
        if (![request HTTPBody]) {
            if (params[@"code"]) {
                BOOL isStateVerified = [_client verifyState:params[@"state"]];
                if (!isStateVerified) {
                    error = [NSError errorWithDomain:BBErrorDomain code:BBInconsistentState userInfo:nil];
                } else {
                    [self handleCorrectAuthorizationWithCode:params[@"code"]];
                }
            } else {
                if ([params[@"error"] isEqualToString:@"access_denied"])
                    error = [NSError errorWithDomain:BBErrorDomain code:BBAccessDenied userInfo:nil];
            }
        }
        
        if (error)
            [_delegate failedAuthenticationWithError:error];
    }
    return !_isRedirectURL;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (!_isRedirectURL)
        [_delegate failedAuthenticationWithError:error];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    _webView.hidden = NO;
}

- (void)dissmisButtonPressed:(id)sender
{
    [_delegate authenticationCanceled];
}
@end
