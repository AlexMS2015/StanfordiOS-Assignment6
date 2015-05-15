//
//  Region+LoadIntoFlickr.m
//  CS193P Assignment 5 - Top Places
//
//  Created by Alex Smith on 11/05/2015.
//  Copyright (c) 2015 Alex Smith. All rights reserved.
//

#import "Region+LoadIntoFlickr.h"
#import "FlickrFetcher.h"
#import "Photographer.h"

@implementation Region (LoadIntoFlickr)

+(Region *)regionFromPlaceID:(NSString *)placeID
             addPhotographer:(Photographer *)photographer
                   inContext:(NSManagedObjectContext *)context
{
    NSURL *placeURL = [FlickrFetcher URLforInformationAboutPlace:placeID];
    NSURLRequest *placeURLRequest = [NSURLRequest requestWithURL:placeURL];
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    __block Region *region;

    NSURLSessionDownloadTask *downloadPlaceInfo = [session downloadTaskWithRequest:placeURLRequest
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
                 NSLog(@"adding new region");
             } else {
                 region = [results firstObject];
                 NSLog(@"found existing region");
             }
                 
                 [region addPhotgraphersObject:photographer];
                 int numPhotographers = [region.numOfPhotgraphers integerValue] + 1;
                 region.numOfPhotgraphers = [NSNumber numberWithInt:numPhotographers];

    }];
    
    [downloadPlaceInfo resume];
    
    return region;
}

@end
