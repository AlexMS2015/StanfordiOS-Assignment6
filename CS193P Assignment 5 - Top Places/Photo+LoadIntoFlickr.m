//
//  Photo+LoadIntoFlickr.m
//  CS193P Assignment 5 - Top Places
//
//  Created by Alex Smith on 10/05/2015.
//  Copyright (c) 2015 Alex Smith. All rights reserved.
//

#import "Photo+LoadIntoFlickr.h"
#import "FlickrFetcher.h"
#import "Region.h"
#import "Region+LoadIntoFlickr.h"

@implementation Photo (LoadIntoFlickr)

+(void)loadPhoto:(NSDictionary *)photo intoContext:(NSManagedObjectContext *)context
{
    
    Photo *newPhoto = [NSEntityDescription insertNewObjectForEntityForName:@"Photo"
                                                    inManagedObjectContext:context];
    newPhoto.photoDescription = [photo valueForKey:FLICKR_PHOTO_DESCRIPTION];
    newPhoto.photoTitle = [photo valueForKey:FLICKR_PHOTO_TITLE];
    NSURL *photoUrl = [FlickrFetcher URLforPhoto:photo format:FlickrPhotoFormatLarge];
    newPhoto.photoURL = [photoUrl absoluteString];
    newPhoto.region = [Region regionFromPlaceID:[photo valueForKey:FLICKR_PHOTO_ID]
                                    intoContext:context];
}

+(void)loadPhotosFromFlickrArray:(NSArray *)photos intoContext:(NSManagedObjectContext *)context
{
    [photos enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [Photo loadPhoto:obj intoContext:context];
    }];
}

@end
