//
//  BBLinkedInAPI.h
//  BBLinkedInAPI
//
//  Created by Martín Fernández on 11/26/13.
//  Copyright (c) 2013 Martín Fernández. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  <#Description#>
 */

extern NSString * const kRedirectURI;

/**
 *  <#Description#>
 *
 *  @param response <#response description#>
 *
 *  @return <#return value description#>
 */

typedef void (^BBSuccessAPIResponseBlock)(id response);

/**
 *  <#Description#>
 *
 *  @param error <#error description#>
 *
 *  @return <#return value description#>
 */

typedef void (^BBFailureAPIResponseBlock)(NSError *error);

/**
 *  <#Description#>
 */

@interface BBLinkedInClient : NSObject 

/**
 *  <#Description#>
 */
@property (nonatomic, strong) NSString *accessToken;

/**
 *  <#Description#>
 *
 *  @param consumerKey <#consumerKey description#>
 *  @param secret      <#secret description#>
 *
 *  @return <#return value description#>
 */

- (id)initWithConsumerKey:(NSString *)consumerKey andSecret:(NSString *)secret;

/**
 *  <#Description#>
 *
 *  @param accessToken <#accessToken description#>
 *
 *  @return <#return value description#>
 */

- (id)initWithAccessToken:(NSString *)accessToken;

/**
 *  <#Description#>
 *
 *  @param scope <#scope description#>
 *
 *  @return <#return value description#>
 */

- (NSURLRequest *)getAuhorizationCodeRequestWithScope:(NSString *)scope;

/**
 *  <#Description#>
 *
 *  @param code    <#code description#>
 *  @param success <#success description#>
 *  @param failure <#failure description#>
 */

- (void)postAccessTokenWithCode:(NSString *)code
                andSuccessBlock:(void(^)(NSDictionary *responeObject))success
                        failure:(void(^)(NSError *))failure;

/**
 *  <#Description#>
 *
 *  @param token <#token description#>
 */

- (void)setOAuthToken:(NSString *)token;

/**
 *  <#Description#>
 *
 *  @param state <#state description#>
 *
 *  @return <#return value description#>
 */

- (BOOL)verifyState:(NSString *)state;

@end

/**
 *  <#Description#>
 */

@interface BBLinkedInClient (People)

/**
 *  <#Description#>
 *
 *  @param fields  <#fields description#>
 *  @param success <#success description#>
 *  @param failure <#failure description#>
 */

- (void)getCurentUserWithFields:(NSString *)fields
                   successBlock:(BBSuccessAPIResponseBlock)success
                   failureBlock:(BBFailureAPIResponseBlock)failure;

/**
 *  <#Description#>
 *
 *  @param memberId <#memberId description#>
 *  @param fields   <#fields description#>
 *  @param success  <#success description#>
 *  @param failure  <#failure description#>
 */

- (void)getUserWithMemberId:(NSString *)memberId
                     fields:(NSString *)fields
               successBlock:(BBSuccessAPIResponseBlock)success
               failureBlock:(BBFailureAPIResponseBlock)failure;

/**
 *  <#Description#>
 *
 *  @param url     <#url description#>
 *  @param fields  <#fields description#>
 *  @param success <#success description#>
 *  @param failure <#failure description#>
 */

- (void)getUserWithPublicProfileUrl:(NSString *)url
                             fields:(NSString *)fields
                       successBlock:(BBSuccessAPIResponseBlock)success
                       failureBlock:(BBFailureAPIResponseBlock)failure;

@end

/**
 *  <#Description#>
 */

@interface BBLinkedInClient (Connections)

//@start Starting location within the result set for paginated returns. Ranges are specified with
//a starting index and a number of results (count) to return. The default value for this parameter is 0.

//@count Ranges are specified with a starting index and a number of results to return. You may specify any
//number. Default and max page size is 500. Implement pagination to retrieve more than 500 connections.

//@modified Values are updated or new.

// @modified-since Value as a Unix time stamp of milliseconds since epoch.

/**
 *  <#Description#>
 *
 *  @param fields  <#fields description#>
 *  @param success <#success description#>
 *  @param failure <#failure description#>
 */

- (void)getConnectionsForCurrentUserWithFields:(NSString *)fields
                                  successBlock:(BBSuccessAPIResponseBlock)success
                                  failureBlock:(BBFailureAPIResponseBlock)failure;

/**
 *  <#Description#>
 *
 *  @param memberID <#memberID description#>
 *  @param fields   <#fields description#>
 *  @param success  <#success description#>
 *  @param failure  <#failure description#>
 */

- (void)getConnectionsForUserWithMemberId:(NSString *)memberID
                                   fields:(NSString *)fields
                             successBlock:(BBSuccessAPIResponseBlock)success
                             failureBlock:(BBFailureAPIResponseBlock)failure;

/**
 *  <#Description#>
 *
 *  @param url     <#url description#>
 *  @param fields  <#fields description#>
 *  @param success <#success description#>
 *  @param failure <#failure description#>
 */

- (void)getConnectionsForUserWithPublicUrl:(NSString *)url
                                    fields:(NSString *)fields
                              successBlock:(BBSuccessAPIResponseBlock)success
                              failureBlock:(BBFailureAPIResponseBlock)failure;
/**
 *  <#Description#>
 *
 *  @param fields    <#fields description#>
 *  @param start     <#start description#>
 *  @param count     <#count description#>
 *  @param modified  <#modified description#>
 *  @param timestamp <#timestamp description#>
 *  @param success   <#success description#>
 *  @param failure   <#failure description#>
 */

- (void)getConnectionsForCurrentUserWithFields:(NSString *)fields
                                     startFrom:(int)start
                                         count:(int)count
                                      modified:(NSString *)modified
                                modifiedSince:(int)timestamp
                                  successBlock:(BBSuccessAPIResponseBlock)success
                                  failureBlock:(BBFailureAPIResponseBlock)failure;
/**
 *  <#Description#>
 *
 *  @param memberID  <#memberID description#>
 *  @param fields    <#fields description#>
 *  @param start     <#start description#>
 *  @param count     <#count description#>
 *  @param modified  <#modified description#>
 *  @param timestamp <#timestamp description#>
 *  @param success   <#success description#>
 *  @param failure   <#failure description#>
 */

- (void)getConnectionsForUserWithMemberId:(NSString *)memberID
                                   fields:(NSString *)fields
                                startFrom:(int)start
                                    count:(int)count
                                 modified:(NSString *)modified
                           modifiedSince:(int)timestamp
                             successBlock:(BBSuccessAPIResponseBlock)success
                             failureBlock:(BBFailureAPIResponseBlock)failure;

/**
 *  <#Description#>
 *
 *  @param url       <#url description#>
 *  @param fields    <#fields description#>
 *  @param start     <#start description#>
 *  @param count     <#count description#>
 *  @param modified  <#modified description#>
 *  @param timestamp <#timestamp description#>
 *  @param success   <#success description#>
 *  @param failure   <#failure description#>
 */

- (void)getConnectionsForUserWithPublicUrl:(NSString *)url
                                    fields:(NSString *)fields
                                 startFrom:(int)start
                                     count:(int)count
                                  modified:(NSString *)modified
                            modifiedSince:(int)timestamp
                              successBlock:(BBSuccessAPIResponseBlock)success
                              failureBlock:(BBFailureAPIResponseBlock)failure;

@end

@interface BBLinkedInClient (PeopleSearch)



@end

/**
 *  <#Description#>
 */

@interface BBLinkedInClient (Group)

/**
 *  <#Description#>
 *
 *  @param groupId <#groupId description#>
 *  @param fields  <#fields description#>
 *  @param success <#success description#>
 *  @param failure <#failure description#>
 */

- (void)getGroupWithId:(NSString *)groupId
                fields:(NSString *)fields
          successBlock:(BBSuccessAPIResponseBlock)success
          failureBlock:(BBFailureAPIResponseBlock)failure;

/**
 *  <#Description#>
 *
 *  @param fields  <#fields description#>
 *  @param success <#success description#>
 *  @param failure <#failure description#>
 */

- (void)getCurrentUserGroupMembershipsWithFields:(NSString *)fields
                                    successBlock:(BBSuccessAPIResponseBlock)success
                                    failureBlock:(BBFailureAPIResponseBlock)failure;

/**
 *  <#Description#>
 *
 *  @param fields  <#fields description#>
 *  @param success <#success description#>
 *  @param failure <#failure description#>
 */

- (void)getCurrentUserGroupMembershipsHeIsMemberWithFields:(NSString *)fields
                                              successBlock:(BBSuccessAPIResponseBlock)success
                                              failureBlock:(BBFailureAPIResponseBlock)failure;

/**
 *  <#Description#>
 *
 *  @param groupId <#groupId description#>
 *  @param fields  <#fields description#>
 *  @param success <#success description#>
 *  @param failure <#failure description#>
 */

/**
 *  <#Description#>
 *
 *  @param groupId <#groupId description#>
 *  @param fields  <#fields description#>
 *  @param success <#success description#>
 *  @param failure <#failure description#>
 */

- (void)getCurrentUserSettingForGroupWithId:(NSString *)groupId
                                     fields:(NSString *)fields
                               successBlock:(BBSuccessAPIResponseBlock)success
                               failureBlock:(BBFailureAPIResponseBlock)failure;

/**
 *  <#Description#>
 *
 *  @param groupId   <#groupId description#>
 *  @param fields    <#fields description#>
 *  @param start     <#start description#>
 *  @param count     <#count description#>
 *  @param order     <#order description#>
 *  @param timestamp <#timestamp description#>
 *  @param category  <#category description#>
 *  @param success   <#success description#>
 *  @param failure   <#failure description#>
 */

- (void)getPostsFromGroupWithId:(NSString *)groupId
                         fields:(NSString *)fields
                      startFrom:(int)start
                          count:(int)count
                          order:(NSString *)order
                  modifiedSince:(int)timestamp
                       category:(NSString *)category
                   successBlock:(BBSuccessAPIResponseBlock)success
                   failureBlock:(BBFailureAPIResponseBlock)failure;

/**
 *  <#Description#>
 *
 *  @param groupId   <#groupId description#>
 *  @param fields    <#fields description#>
 *  @param start     <#start description#>
 *  @param count     <#count description#>
 *  @param order     <#order description#>
 *  @param role      <#role description#>
 *  @param timestamp <#timestamp description#>
 *  @param category  <#category description#>
 *  @param success   <#success description#>
 *  @param failure   <#failure description#>
 */

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

@end

//@interface BBLinkedInAPI (Companies)

//@end

//@interface BBLinkedInAPI (JobsLookup)

//@end

//@interface BBLinkedInAPI (JobsBookmarks)

//@end

//@interface BBLinkedInAPI (JobsSearch)

//@end

//@interface BBLinkedInAPI (Share)

//@end
