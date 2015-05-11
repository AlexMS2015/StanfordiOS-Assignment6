//
//  Photographer+LoadIntoFlickr.m
//  CS193P Assignment 5 - Top Places
//
//  Created by Alex Smith on 11/05/2015.
//  Copyright (c) 2015 Alex Smith. All rights reserved.
//

#import "Photographer+LoadIntoFlickr.h"

@implementation Photographer (LoadIntoFlickr)

+(Photographer *)photographerWithName:(NSString *)name
                             inRegion:(Region *)region
                            inContext:(NSManagedObjectContext *)context;{
    Photographer *photographer;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photographer"];
    request.predicate = [NSPredicate predicateWithFormat:@"photographerName = %@", name];
    
    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    if (!results || [results count] > 1) {
        // error code here
    } else if (![results count]) {
        photographer = [ NSEntityDescription insertNewObjectForEntityForName:@"Photographer"
                                                      inManagedObjectContext:context];
        photographer.region = region;
    } else {
        photographer = [results firstObject];
    }
    
    return photographer;
}
@end
