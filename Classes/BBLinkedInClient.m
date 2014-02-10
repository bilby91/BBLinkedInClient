//
//  BBLinkedInAPI.m
//  BBLinkedInAPI
//
//  Created by Martín Fernández on 11/26/13.
//  Copyright (c) 2013 Martín Fernández. All rights reserved.
//

#import "BBLinkedInClient.h"
#import "NSString+BBEncode.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>

NSString * const kAuthBaseUrl               = @"https://www.linkedin.com";
NSString * const kAPIBaseUrl                = @"https://api.linkedin.com";
NSString * const kAuthorizationCodePath     = @"/uas/oauth2/authorization";
NSString * const kAccessTokenPath           = @"/uas/oauth2/accessToken";
NSString * const kRedirectURI               = @"https://bilby91.com";
NSString * const kDefaultScope              = @"r_basicprofile";

@interface BBLinkedInClient ()


@property (nonatomic, copy) NSURL                           *authBaseURL;
@property (nonatomic, copy) NSURL                           *apiBaseURL;
@property (nonatomic, copy) NSString                        *consumerKey;
@property (nonatomic, copy) NSString                        *secret;
@property (nonatomic, copy) NSString                        *state;
@property (nonatomic, copy) AFHTTPRequestOperationManager   *manager;

@end

@implementation BBLinkedInClient

@synthesize authBaseURL = _authBaseURL;
@synthesize apiBaseURL  = _apiBaseURL;
@synthesize consumerKey = _consumerKey;
@synthesize secret      = _secret;
@synthesize state       = _state;
@synthesize accessToken = _accessToken;
@synthesize manager     = _manager;


- (id)initWithConsumerKey:(NSString *)consumerKey
                andSecret:(NSString *)secret
{
    self = [super init];
    if (!self)
        return nil;

    _consumerKey                = consumerKey;
    _secret                     = secret;
    [self setup];
    
    return self;
}

- (id)initWithAccessToken:(NSString *)accessToken
{
    self = [super init];
    if (!self)
        return nil;
    
    _accessToken = accessToken;
    [self setup];
    
    return self;
}

- (void)setup
{
    _apiBaseURL                 = [NSURL URLWithString:kAPIBaseUrl];
    _authBaseURL                = [NSURL URLWithString:kAuthBaseUrl];
    _manager                    = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:_apiBaseURL];
    _manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [self setupHeaders];
}

- (void)setupHeaders
{
    [_manager.requestSerializer setValue:@"json" forHTTPHeaderField:@"x-li-format"];
}

- (void)setOAuthToken:(NSString *)token
{
    _accessToken = token;
}

- (NSURLRequest *)getAuhorizationCodeRequestWithScope:(NSString *)scope
{
    scope = [self sanitizeScope:scope];
    scope = scope ? scope : kDefaultScope;

    NSString *relativeURL = [NSString stringWithFormat:@"%@?response_type=code&client_id=%@&scope=%@&state=%@&redirect_uri=%@",kAuthorizationCodePath,_consumerKey,scope,self.state,kRedirectURI];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:relativeURL relativeToURL:_authBaseURL]];
    
    return request;
}

- (void)postAccessTokenWithCode:(NSString *)code
                andSuccessBlock:(void (^)(NSDictionary *responeObject))success
                        failure:(void (^)(NSError *))failure
{
    NSString *relativeURL = [NSString stringWithFormat:@"%@?grant_type=authorization_code&code=%@&redirect_uri=%@&client_id=%@&client_secret=%@",kAccessTokenPath,code,kRedirectURI,_consumerKey,_secret];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:relativeURL relativeToURL:_authBaseURL]];
    AFHTTPRequestOperation *operation = [_manager HTTPRequestOperationWithRequest:request
                                                                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                                  success(responseObject);
                                                                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                failure(error);
                                                                          }];
    [[_manager operationQueue] addOperation:operation];
}

- (NSString *)state
{
    if (_state)
        return _state;
    
    _state = [BBLinkedInClient generateRandomState];
    
    return _state;
}

- (BOOL)verifyState:(NSString *)state
{
    return [state isEqualToString:_state];
}

- (NSString *)sanitizeScope:(NSString *)scope
{
    return [scope stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString*)generateRandomState
{
    int lenght = 21;
    NSMutableString* string = [NSMutableString stringWithCapacity:lenght];
    for (int i = 0; i < lenght; i++) {
        [string appendFormat:@"%C", (unichar)('a' + arc4random_uniform(25))];
    }
    return string;
}

- (void)dispatchRequestForPath:(NSString *)path
                        method:(NSString *)method
                        params:(NSDictionary *)params
                    needsToken:(BOOL)needsToken
                  successBlock:(BBSuccessAPIResponseBlock)success
                  failureBlock:(BBFailureAPIResponseBlock)failure
{
    
    NSMutableDictionary *mParams;
    
    mParams = params ? [params mutableCopy] : [NSMutableDictionary dictionary];
    
    if (needsToken)
        [mParams addEntriesFromDictionary:@{@"oauth2_access_token" : _accessToken}];
    
    NSMutableURLRequest *request = [_manager.requestSerializer requestWithMethod:method
                                                                   URLString:[[NSURL URLWithString:path
                                                                                     relativeToURL:_apiBaseURL] absoluteString]
                                                                  parameters:mParams];
    
    AFHTTPRequestOperation *operation = [_manager HTTPRequestOperationWithRequest:request
                                                                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                              success(responseObject);
                                                                          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                              failure(error);
                                                                          }];
    [[_manager operationQueue] addOperation:operation];
}


- (NSString *)insertFields:(NSString *)fields
                    inPath:(NSString *)path
{
    NSString *newPath = nil;
    if (fields)
        newPath = [NSString stringWithFormat:@"%@:%@",path,fields];
    
    return newPath ? newPath : path;
}

@end

@implementation BBLinkedInClient(People)

-(void)getCurentUserWithFields:(NSString *)fields
                  successBlock:(BBSuccessAPIResponseBlock)success
                  failureBlock:(BBFailureAPIResponseBlock)failure
{
    NSString *path = [NSString stringWithFormat:@"/v1/people/~"];
    path = [self insertFields:fields inPath:path];
    
    [self dispatchRequestForPath:path
                          method:@"GET"
                          params:nil
                      needsToken:YES
                    successBlock:success
                    failureBlock:failure];
}

- (void)getUserWithMemberId:(NSString *)memberId
                     fields:(NSString *)fields
               successBlock:(BBSuccessAPIResponseBlock)success
               failureBlock:(BBFailureAPIResponseBlock)failure
{
    NSString *path = [NSString stringWithFormat:@"/v1/people/id=%@",memberId];
    path = [self insertFields:fields inPath:path];
    
    [self dispatchRequestForPath:path
                          method:@"GET"
                          params:nil
                      needsToken:YES
                    successBlock:success
                    failureBlock:failure];
}

- (void)getUserWithPublicProfileUrl:(NSString *)url
                             fields:(NSString *)fields
                       successBlock:(BBSuccessAPIResponseBlock)success
                       failureBlock:(BBFailureAPIResponseBlock)failure
{
    NSString *encodedUrl = [[NSString stringWithFormat:@"%@",url] encodedURLString];
    NSString *path = [NSString stringWithFormat:@"/v1/people/url=%@",encodedUrl];
    path = [self insertFields:fields inPath:path];
    
    [self dispatchRequestForPath:path
                          method:@"GET" 
                          params:nil
                      needsToken:YES
                    successBlock:success
                    failureBlock:failure];
}

@end

@implementation BBLinkedInClient(Connections)

- (void)getConnectionsForCurrentUserWithFields:(NSString *)fields
                                  successBlock:(BBSuccessAPIResponseBlock)success
                                  failureBlock:(BBFailureAPIResponseBlock)failure
{
    NSString *path = [NSString stringWithFormat:@"/v1/people/~/connections"];
    path = [self insertFields:fields inPath:path];
    
    [self dispatchRequestForPath:path
                          method:@"GET"
                          params:nil
                      needsToken:YES
                    successBlock:success
                    failureBlock:failure];
}

- (void)getConnectionsForUserWithMemberId:(NSString *)memberID
                                   fields:(NSString *)fields
                             successBlock:(BBSuccessAPIResponseBlock)success
                             failureBlock:(BBFailureAPIResponseBlock)failure
{
    NSString *path = [NSString stringWithFormat:@"/v1/people/id=%@/connections",memberID];
    path = [self insertFields:fields inPath:path];
    
    [self dispatchRequestForPath:path
                          method:@"GET"
                          params:nil
                      needsToken:YES
                    successBlock:success
                    failureBlock:failure];
}

- (void)getConnectionsForUserWithPublicUrl:(NSString *)url
                                    fields:(NSString *)fields
                              successBlock:(BBSuccessAPIResponseBlock)success
                              failureBlock:(BBFailureAPIResponseBlock)failure
{
    NSString *encodedUrl = [[NSString stringWithFormat:@"%@",url] encodedURLString];
    NSString *path = [NSString stringWithFormat:@"/v1/people/url=%@/connections",encodedUrl];
    path = [self insertFields:fields inPath:path];
    
    [self dispatchRequestForPath:path
                          method:@"GET"
                          params:nil
                      needsToken:YES
                    successBlock:success
                    failureBlock:failure];
}

- (void)getConnectionsForCurrentUserWithFields:(NSString *)fields
                                     startFrom:(int)start
                                         count:(int)count
                                      modified:(NSString *)modified
                                 modifiedSince:(int)timestamp
                                  successBlock:(BBSuccessAPIResponseBlock)success
                                  failureBlock:(BBFailureAPIResponseBlock)failure
{
    NSString *path = [NSString stringWithFormat:@"/v1/people/~/connections"];
    path = [self insertFields:fields inPath:path];
    
    NSDictionary *params = [self setupConnectionRequestParamsWithStartFrom:start
                                                                     count:count
                                                                  modified:modified
                                                             modifiedSince:timestamp];
    
    [self dispatchRequestForPath:path
                          method:@"GET"
                          params:params
                      needsToken:YES
                    successBlock:success
                    failureBlock:failure];
}

- (void)getConnectionsForUserWithMemberId:(NSString *)memberID
                                   fields:(NSString *)fields
                                startFrom:(int)start
                                    count:(int)count
                                 modified:(NSString *)modified
                            modifiedSince:(int)timestamp
                             successBlock:(BBSuccessAPIResponseBlock)success
                             failureBlock:(BBFailureAPIResponseBlock)failure
{
    
    NSString *path = [NSString stringWithFormat:@"/v1/people/id=%@/connections",memberID];
    path = [self insertFields:fields inPath:path];
    NSDictionary *params = [self setupConnectionRequestParamsWithStartFrom:start
                                                                     count:count
                                                                  modified:modified
                                                             modifiedSince:timestamp];
    
    [self dispatchRequestForPath:path
                          method:@"GET"
                          params:params
                      needsToken:YES
                    successBlock:success
                    failureBlock:failure];
}

- (void)getConnectionsForUserWithPublicUrl:(NSString *)url
                                    fields:(NSString *)fields
                                 startFrom:(int)start
                                     count:(int)count
                                  modified:(NSString *)modified
                             modifiedSince:(int)timestamp
                              successBlock:(BBSuccessAPIResponseBlock)success
                              failureBlock:(BBFailureAPIResponseBlock)failure
{
    NSString *encodedUrl = [[NSString stringWithFormat:@"%@",url] encodedURLString];
    NSString *path = [NSString stringWithFormat:@"/v1/people/url=%@/connections",encodedUrl];
    path = [self insertFields:fields inPath:path];
    
    
    NSDictionary *params = [self setupConnectionRequestParamsWithStartFrom:start
                                                                     count:count
                                                                  modified:modified
                                                             modifiedSince:timestamp];
    
    [self dispatchRequestForPath:path
                          method:@"GET"
                          params:params
                      needsToken:YES
                    successBlock:success
                    failureBlock:failure];
}

- (NSDictionary *)setupConnectionRequestParamsWithStartFrom:(int)start
                                                      count:(int)count
                                                   modified:(NSString *)modified
                                              modifiedSince:(int)timestamp
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    count = count == 0 ? 500 : count;
    
    params[@"start"] = [NSNumber numberWithInt:start];
    params[@"count"] = [NSNumber numberWithInt:count];
    
    if (modified) params[@"modified"]           = modified;
    if (timestamp) params[@"modified-since"]    = [NSNumber numberWithInt:timestamp];
    
    return params;
}

@end

@implementation BBLinkedInClient(Group)

- (void)getGroupWithId:(NSString *)groupId
                fields:(NSString *)fields
          successBlock:(BBSuccessAPIResponseBlock)success
          failureBlock:(BBFailureAPIResponseBlock)failure
{
    NSString *path = [NSString stringWithFormat:@"/v1/groups/%@",groupId];
    path = [self insertFields:fields inPath:path];
    
    [self dispatchRequestForPath:path
                          method:@"GET"
                          params:nil
                      needsToken:YES
                    successBlock:success
                    failureBlock:failure];
}

- (void)getCurrentUserGroupMembershipsWithFields:(NSString *)fields
                                    successBlock:(BBSuccessAPIResponseBlock)success
                                    failureBlock:(BBFailureAPIResponseBlock)failure
{
    NSString *path = [NSString stringWithFormat:@"/v1/people/~/group-memberships"];
    path = [self insertFields:fields inPath:path];
    
    [self dispatchRequestForPath:path
                          method:@"GET"
                          params:nil
                      needsToken:YES
                    successBlock:success
                    failureBlock:failure];
}

- (void)getCurrentUserGroupMembershipsHeIsMemberWithFields:(NSString *)fields
                                              successBlock:(BBSuccessAPIResponseBlock)success
                                              failureBlock:(BBFailureAPIResponseBlock)failure
{
    NSString *path = [NSString stringWithFormat:@"/v1/people/~/group-memberships"];
    path = [self insertFields:fields inPath:path];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"membership-state"] = @"member";
    
    [self dispatchRequestForPath:path
                          method:@"GET"
                          params:params
                      needsToken:YES
                    successBlock:success
                    failureBlock:failure];
    
}

- (void)getCurrentUserSettingForGroupWithId:(NSString *)groupId
                                     fields:(NSString *)fields
                               successBlock:(BBSuccessAPIResponseBlock)success
                            	failureBlock:(BBFailureAPIResponseBlock)failure
{
    NSString *path = [NSString stringWithFormat:@"/v1/people/~/group-memberships/%@",groupId];
    path = [self insertFields:fields inPath:path];

    [self dispatchRequestForPath:path
                          method:@"GET"
                          params:nil
                      needsToken:YES
                    successBlock:success
                    failureBlock:failure];
}

- (void)getPostsFromGroupWithId:(NSString *)groupId
                         fields:(NSString *)fields
                      startFrom:(int)start
                          count:(int)count
                          order:(NSString *)order
                  modifiedSince:(int)timestamp
                       category:(NSString *)category
                   successBlock:(BBSuccessAPIResponseBlock)success
                   failureBlock:(BBFailureAPIResponseBlock)failure;
{
    NSString *path = [NSString stringWithFormat:@"/v1/groups/%@/posts",groupId];
    path = [self insertFields:fields inPath:path];
    NSDictionary *params = [self setupPostsRequestParamsWithStartFrom:start
                                                                count:count
                                                                order:order
                                                                 role:nil
                                                        modifiedSince:timestamp
                                                             category:category];
    
    [self dispatchRequestForPath:path
                          method:@"GET"
                          params:params
                      needsToken:YES
                    successBlock:success
                    failureBlock:failure];
}

- (void)getPostsFromGroupMembershipWithId:(NSString *)groupId
                                   fields:(NSString *)fields
                                startFrom:(int)start
                                    count:(int)count
                                    order:(NSString *)order
                                     role:(NSString *)role
                            modifiedSince:(int)timestamp
                                 category:(NSString *)category
                             successBlock:(BBSuccessAPIResponseBlock)success
                             failureBlock:(BBFailureAPIResponseBlock)failure;
{
    NSString *path = [NSString stringWithFormat:@"/v1/people/~/group-membership/%@/posts",groupId];
    path = [self insertFields:fields inPath:path];
    
    NSDictionary *params = [self setupPostsRequestParamsWithStartFrom:start
                                                                count:count
                                                                order:order
                                                                 role:role
                                                        modifiedSince:timestamp
                                                             category:category];
    
    [self dispatchRequestForPath:path
                          method:@"GET"
                          params:params
                      needsToken:YES
                    successBlock:success
                    failureBlock:failure];
}

- (NSDictionary *)setupPostsRequestParamsWithStartFrom:(int)start
                                                 count:(int)count
                                                 order:(NSString *)order
                                                  role:(NSString *)role
                                         modifiedSince:(int)timestamp
                                              category:(NSString *)category
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    count = count == 0 ? 500 : count;
    
    params[@"start"] = [NSNumber numberWithInt:start];
    params[@"count"] = [NSNumber numberWithInt:count];
    
    if (order) params[@"order"]                 = order;
    if (role) params[@"role"]                   = role;
    if (timestamp) params[@"modified-since"]    = [NSNumber numberWithInt:timestamp];
    if (category) params[@"category"]           = category;
    
    return params;
}
@end