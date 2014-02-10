//
//  BBErrors.h
//  BBLinkedInAPI
//
//  Created by Martín Fernández on 11/27/13.
//  Copyright (c) 2013 Martín Fernández. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  BBLinkedInClient error domain.
 */

extern NSString * const BBErrorDomain;

/**
 *  Authorization error codes.
 */

enum BBOAuthErrorCodes {
    BBInconsistentState = 1,
    BBAccessDenied      = 2
};