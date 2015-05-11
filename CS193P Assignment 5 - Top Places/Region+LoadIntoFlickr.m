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

+(Region *)regionFromPlaceID:(NSString *)placeID inContext:(NSManagedObjectContext *)context
{
    __block Region *region;
    
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
                 
                 NSFetchRequest *reqeust = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
                 reqeust.predicate = [NSPredicate predicateWithFormat:@"regionName = %@", regionName];
                 
                 NSError *fetchReqError;
                 NSArray *results = [context executeFetchRequest:reqeust error:&fetchReqError];
                 
                 if (!results || [results count] > 1) {
                     // error handling code
                 } else if (![results count]) {
                     region = [NSEntityDescription insertNewObjectForEntityForName:@"Region"
                                                     inManagedObjectContext:context];
                     region.regionName = regionName;
                 } else {
                     region = [results firstObject];
                 }
             }];
    
    [downloadplaceInfo resume];
    
    return region;
}

@end
