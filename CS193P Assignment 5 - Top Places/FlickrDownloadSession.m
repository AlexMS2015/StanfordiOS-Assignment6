//
//  FlickrDownloadSession.m
//  CS193P Assignment 5 - Top Places
//
//  Created by Alex Smith on 17/05/2015.
//  Copyright (c) 2015 Alex Smith. All rights reserved.
//

#import "FlickrDownloadSession.h"
#import "FlickrFetcher.h"

@interface FlickrDownloadSession ()
@end

@implementation FlickrDownloadSession

+(NSURLSession *)sharedFlickrDownloadSession
{
    
    static NSURLSession *flickrDownloadSession;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        flickrDownloadSession = [NSURLSession sessionWithConfiguration:configuration];
    });
    
    return flickrDownloadSession;
}

@end
