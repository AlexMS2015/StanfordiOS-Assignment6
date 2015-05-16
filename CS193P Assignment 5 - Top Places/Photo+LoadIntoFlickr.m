//
//  Photo+LoadIntoFlickr.m
//  CS193P Assignment 5 - Top Places
//
//  Created by Alex Smith on 10/05/2015.
//  Copyright (c) 2015 Alex Smith. All rights reserved.
//

#import "Photo+LoadIntoFlickr.h"
#import "FlickrFetcher.h"
#import "Region+LoadIntoFlickr.h"
#import "Photographer.h"
#import "Photographer+LoadIntoFlickr.h"

@implementation Photo (LoadIntoFlickr)

+(void)photoFromFlickrPhoto:(NSDictionary *)photo inContext:(NSManagedObjectContext *)context
{
    
    Photo *newPhoto = [NSEntityDescription insertNewObjectForEntityForName:@"Photo"
                                                    inManagedObjectContext:context];
    
    newPhoto.photoDescription = [photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    newPhoto.photoTitle = [photo valueForKeyPath:FLICKR_PHOTO_TITLE];
    NSURL *photoUrl = [FlickrFetcher URLforPhoto:photo format:FlickrPhotoFormatLarge];
    newPhoto.photoURL = [photoUrl absoluteString];
    
    Photographer *photographer = [Photographer photographerWithName:[photo valueForKeyPath:FLICKR_PHOTO_OWNER] inContext:context];
    
    newPhoto.photographer = photographer;
    newPhoto.region = [Region regionFromPlaceID:[photo valueForKeyPath:FLICKR_PLACE_ID]
                                addPhotographer:photographer
                                     inContext:context];
    NSLog(@"returned");
    
    //NSLog(@"SPECIAL: photo = %@, photgrapher = %@, photographer's region = %@", newPhoto.photoTitle, newPhoto.photographer, newPhoto.photographer.region);
}

+(void)loadPhotosFromFlickrArray:(NSArray *)photos intoContext:(NSManagedObjectContext *)context
{
    NSLog(@"there are %d photos to load", [photos count]);
    [photos enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (idx < 100) {
            NSLog(@"-------------");
            NSLog(@"loading photo %d", idx);
            [Photo photoFromFlickrPhoto:obj inContext:context];
        }
    }];
}

@end
