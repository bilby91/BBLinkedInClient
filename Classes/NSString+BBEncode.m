//
//  NSString+BBEncode.m
//  BBLinkedInAPI
//
//  Created by Martín Fernández on 11/26/13.
//  Copyright (c) 2013 Martín Fernández. All rights reserved.
//

#import "NSString+BBEncode.h"
#import <CoreFoundation/CoreFoundation.h>

@implementation NSString (BBEncode)

- (NSString *)encodedURLString
{
    NSString *encodedString = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                        (__bridge CFStringRef)self,
                                                                                        NULL,
                                                                                        CFSTR("!*'();:@&=+@,/?#[]{}"),
                                                                                    	kCFStringEncodingUTF8));
    
    return encodedString ? encodedString : @"";
}

@end
