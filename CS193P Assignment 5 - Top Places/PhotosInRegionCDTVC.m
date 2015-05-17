//
//  PhotosInRegionCDTVC.m
//  CS193P Assignment 5 - Top Places
//
//  Created by Alex Smith on 15/05/2015.
//  Copyright (c) 2015 Alex Smith. All rights reserved.
//

#import "PhotosInRegionCDTVC.h"
#import "Region.h"
#import "Photo.h"
#import "PhotoViewController.h"

@interface PhotosInRegionCDTVC ()

@end

@implementation PhotosInRegionCDTVC

-(NSString *)sectionTitleKeyPathForFetchedResultsController
{
    return @"Photographer.photographerName";
}

-(NSFetchRequest *)fetchRequestForFetchedResultsController
{
    NSFetchRequest *photosInRegion = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    
    NSSortDescriptor *photoNameSortDesc = [NSSortDescriptor sortDescriptorWithKey:@"photoTitle" ascending:YES];
    
    photosInRegion.sortDescriptors = @[photoNameSortDesc];
    photosInRegion.predicate = [NSPredicate predicateWithFormat:@"region.regionName = %@", self.regionForPhotos.regionName];

    return photosInRegion;
}

@end
