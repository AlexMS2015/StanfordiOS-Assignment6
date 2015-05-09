//
//  PhotosForPlace.m
//  CS193P Assignment 5 - Top Places
//
//  Created by Alex Smith on 3/05/2015.
//  Copyright (c) 2015 Alex Smith. All rights reserved.
//

#import "PhotosForPlaceTVC.h"
#import "FlickrFetcher.h"
#import "PhotoViewController.h"

@implementation PhotosForPlaceTVC

#pragma mark - Concrete Methods

-(NSDictionary *)dictionaryFromFlickrData
{
    NSURL *photosInPlace = [FlickrFetcher URLforPhotosInPlace:self.placeID maxResults:50];
    NSData *JSONResults = [NSData dataWithContentsOfURL:photosInPlace];
    NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:JSONResults
                                                                        options:0
                                                                          error:NULL];
    
    NSMutableDictionary *photos = [NSMutableDictionary dictionary];
    photos[self.placeID] = [propertyListResults valueForKeyPath:FLICKR_RESULTS_PHOTOS];
    
    return photos;
}

@end
