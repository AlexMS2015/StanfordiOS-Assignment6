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
    
    //Region *region;
    //NSURL *location = [FlickrFetcher URLforInformationAboutPlace:placeID];

         // load local file contents into NSData
         NSData *JSONData = [NSData dataWithContentsOfURL:location];
         NSDictionary *placeInformation = [NSJSONSerialization JSONObjectWithData:JSONData
                                                                          options:0
                                                                            error:NULL];
             NSString *regionName = [FlickrFetcher extractRegionNameFromPlaceInformation:placeInformation];
            
             NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
             request.predicate = [NSPredicate predicateWithFormat:@"regionName = %@", regionName];
             
             NSError *fetchReqError;
             NSArray *results = [context executeFetchRequest:request error:&fetchReqError];
             
             if (!results || [results count] > 1) {
                 // error handling code
             } else if (![results count]) {
                 region = [NSEntityDescription insertNewObjectForEntityForName:@"Region"
                                                 inManagedObjectContext:context];
                 region.regionName = regionName;
                 NSLog(@"adding new region: %@", region.regionName);
             } else {
                 region = [results firstObject];
                 NSLog(@"found existing region");
             }
    
            NSFetchRequest *photographersInRegion = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
            photographersInRegion.predicate = [NSPredicate predicateWithFormat:@"any photographers.photographerName = %@", photographer.photographerName];
            results = [context executeFetchRequest:photographersInRegion error:&fetchReqError];
    
            if ([results count]) {
                NSLog(@"photographer %@ already exists in %@", photographer.photographerName, region.regionName);
            } else {
                [region addPhotographersObject:photographer];
                NSLog(@"adding photographer: %@ to %@", photographer.photographerName, region.regionName);
                int numPhotographers = [region.numOfPhotgraphers integerValue] + 1;
                region.numOfPhotgraphers = [NSNumber numberWithInt:numPhotographers];
            }
    }];
    [downloadPlaceInfo resume];
    
    return region;
}

@end
