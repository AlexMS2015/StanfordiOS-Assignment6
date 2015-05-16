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

+(Region *)regionWithName:(NSString *)regionName
             addPhotographer:(Photographer *)photographer
                   inContext:(NSManagedObjectContext *)context
{
    Region *region;
    
    // check to see if region already exists
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
    
    [region addUniquePhotographer:photographer inContext:context];
    
    return region;
}

-(void)addUniquePhotographer:(Photographer *)photographer inContext:(NSManagedObjectContext *)context
{
    // check to see if photographer already exists
    NSFetchRequest *photographersInRegion = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
    photographersInRegion.predicate = [NSPredicate predicateWithFormat:@"any photographers.photographerName = %@", photographer.photographerName];
    NSError *fetchReqError;
    NSArray *results = [context executeFetchRequest:photographersInRegion error:&fetchReqError];
    
    if ([results count]) {
        NSLog(@"photographer %@ already exists in %@", photographer.photographerName, self.regionName);
    } else {
        NSLog(@"adding photographer: %@ to %@", photographer.photographerName, self.regionName);
        [self addPhotographersObject:photographer];
        int numPhotographers = [self.numOfPhotgraphers integerValue] + 1;
        self.numOfPhotgraphers = [NSNumber numberWithInt:numPhotographers];
    }
}

@end
