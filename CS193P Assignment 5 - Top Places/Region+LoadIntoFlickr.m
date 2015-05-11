//
//  Region+LoadIntoFlickr.m
//  CS193P Assignment 5 - Top Places
//
//  Created by Alex Smith on 11/05/2015.
//  Copyright (c) 2015 Alex Smith. All rights reserved.
//

#import "Region+LoadIntoFlickr.h"
#import "FlickrFetcher.h"

@implementation Region (LoadIntoFlickr)

+(Region *)regionFromPlaceID:(NSString *)placeID intoContext:(NSManagedObjectContext *)context
{
    Region *newRegion = [NSEntityDescription insertNewObjectForEntityForName:@"Region"
                                                      inManagedObjectContext:context];
    
    NSURL *placeUURL = [FlickrFetcher URLforInformationAboutPlace:placeID];
    NSURLRequest *placeURLRequest = [NSURLRequest requestWithURL:placeUURL];
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    NSURLSessionDownloadTask *downloadplaceInfo = [session downloadTaskWithRequest:placeURLRequest
             completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                 
                 // load local file contents into NSData
                 NSData *JSONData = [NSData dataWithContentsOfURL:location];
                 NSDictionary *placeInformation = [NSJSONSerialization JSONObjectWithData:JSONData
                                                                                  options:0
                                                                                    error:NULL];
                 NSString *regionName = [FlickrFetcher extractRegionNameFromPlaceInformation:placeInformation];
                 newRegion.regionName = regionName;
             }];
    [downloadplaceInfo resume];
    
    return newRegion;
}

@end
