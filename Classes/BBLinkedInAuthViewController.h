//
//  BBLinkedInAuthViewController.h
//  BBLinkedInAPI
//
//  Created by Martín Fernández on 11/26/13.
//  Copyright (c) 2013 Martín Fernández. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BBLinkedInClient;

@protocol BBOAuth;


/**
 *  <#Description#>
 */

@protocol BBLinkedInAuthViewControllerDelegate <NSObject>

/**
 *  Called when a succesfull authentication has been made. From now on the BBLinkedInClient provided has its own
 *  accesstoken. If none is provided nothing happens.
 */

- (void)succesfullAuthentication;

/**
 *  Called when authentication fail by any reason.
 *
 *  @param error The error causing the failure.
 */

- (void)failedAuthenticationWithError:(NSError *)error;

/**
 *  Called when user cancels the login.
 */
- (void)authenticationCanceled;

@end


/**
 *  BBLinkedInAuthViewController is in charge of displaying oauth web view and handle the rest of the process.
 */

@interface BBLinkedInAuthViewController : UIViewController <UIWebViewDelegate>

/**
 *  BBLinkedInAuthViewControllerDelegate delegate
 */
@property (nonatomic, strong) id<BBLinkedInAuthViewControllerDelegate> delegate;

/**
 *  BBLinkedIn client
 */
@property (nonatomic, strong) BBLinkedInClient * client;


/**
 *  Top navigation bar. Cutomize appearance if you want. 
 */
@property (nonatomic, strong) UINavigationBar *navigationBar;

/**
 *  Prefered initializer.
 *
 *  @param client The client used to make request.
 *  @param scope  The desired scope for the user's access token.
 *
 *  @return A new instance of the BBLinkedInViewController
 */
- (id)initWithClient:(BBLinkedInClient *)client
               scope:(NSString *)scope;

@end
