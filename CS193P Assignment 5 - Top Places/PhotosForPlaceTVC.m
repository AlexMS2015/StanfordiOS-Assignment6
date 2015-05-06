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

@interface PhotosForPlaceTVC ()

@end

@implementation PhotosForPlaceTVC

#pragma mark - Life Cycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = self.placeName;
}

#pragma mark - Properties

-(NSString *)placeID
{
    if (!_placeID) {
        _placeID = [NSString string];
    }
    
    return _placeID;
}

#pragma mark - Concrete Methods

-(NSString *)nameOfCellIdentifier
{
    return @"Photo Cell";
}

-(NSString *)getTitleForCellInDictionary:(NSDictionary *)dictionary
{
    if (![[dictionary valueForKeyPath:FLICKR_PHOTO_TITLE] isEqualToString:@""]) {
        return [dictionary valueForKeyPath:FLICKR_PHOTO_TITLE];
    } else if (![[dictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION] isEqualToString:@""]) {
        return [dictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    } else {
        return @"Unknown";
    }
}

-(NSString *)getSubtitleForCellInDictionary:(NSDictionary *)dictionary
{
    if (![[dictionary valueForKeyPath:FLICKR_PHOTO_TITLE] isEqualToString:@""]) {
        return [dictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    } else {
        return @"";
    }
}

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

#pragma mark - Other

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual: @"Show Photo"]) {
        NSIndexPath *pathOfSelectedCell = [self.tableView indexPathForCell:sender];
        NSDictionary *cellData = [self dictionaryForCellAtIndexPath:pathOfSelectedCell];
        if ([segue.destinationViewController isMemberOfClass:[PhotoViewController class]]) {
            PhotoViewController *selectedPhoto = (PhotoViewController *)segue.destinationViewController;
            selectedPhoto.photo = cellData;
        }
    }
}

@end
