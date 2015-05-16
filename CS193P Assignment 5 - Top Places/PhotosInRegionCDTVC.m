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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual: @"Show Photo"]) {
        NSIndexPath *pathOfSelectedCell = [self.tableView indexPathForCell:sender];
        Photo *selectedPhoto = [self.fetchedResultsController objectAtIndexPath:pathOfSelectedCell];
        if ([segue.destinationViewController isMemberOfClass:[PhotoViewController class]]) {
            PhotoViewController *selectedPhotoVC = (PhotoViewController *)segue.destinationViewController;
            selectedPhotoVC.photoURL = [NSURL URLWithString:selectedPhoto.photoURL];
        }
    }
}

#pragma mark - UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Photo Cell"];
    
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = photo.photoTitle;
    cell.detailTextLabel.text = photo.photoDescription;
    
    return cell;
}

@end
