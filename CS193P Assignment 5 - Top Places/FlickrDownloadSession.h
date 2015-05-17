//
//  FlickrDownloadSession.h
//  CS193P Assignment 5 - Top Places
//
//  Created by Alex Smith on 17/05/2015.
//  Copyright (c) 2015 Alex Smith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlickrDownloadSession : NSObject

+(NSURLSession *)sharedFlickrDownloadSession;

@end
