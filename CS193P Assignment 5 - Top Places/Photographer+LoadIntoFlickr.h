//
//  Photographer+LoadIntoFlickr.h
//  CS193P Assignment 5 - Top Places
//
//  Created by Alex Smith on 11/05/2015.
//  Copyright (c) 2015 Alex Smith. All rights reserved.
//

#import "Photographer.h"
@class Region;

@interface Photographer (LoadIntoFlickr)
+(Photographer *)photographerWithName:(NSString *)name
                             inRegion:(Region *)region
                            inContext:(NSManagedObjectContext *)context;
@end
