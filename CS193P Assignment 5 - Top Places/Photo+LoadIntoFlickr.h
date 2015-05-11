//
//  Photo+LoadIntoFlickr.h
//  CS193P Assignment 5 - Top Places
//
//  Created by Alex Smith on 10/05/2015.
//  Copyright (c) 2015 Alex Smith. All rights reserved.
//

#import "Photo.h"

@interface Photo (LoadIntoFlickr)
+(void)loadPhotosFromFlickrArray:(NSArray *)photos intoContext:(NSManagedObjectContext *)context;
+(void)photoFromFlickrPhoto:(NSDictionary *)photo inContext:(NSManagedObjectContext *)context;
@end
