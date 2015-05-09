//
//  PhotosForPlace.h
//  CS193P Assignment 5 - Top Places
//
//  Created by Alex Smith on 3/05/2015.
//  Copyright (c) 2015 Alex Smith. All rights reserved.
//

#import "FlickrDataTVC.h"
#import "ListOfPhotosTVC.h"

@interface PhotosForPlaceTVC : ListOfPhotosTVC
@property (nonatomic, strong) NSString *placeID;
@property (nonatomic, strong) NSString *placeName;
@end
