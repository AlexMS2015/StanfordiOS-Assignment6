//
//  ListOfPhotosCDTVC.m
//  CS193P Assignment 5 - Top Places
//
//  Created by Alex Smith on 16/05/2015.
//  Copyright (c) 2015 Alex Smith. All rights reserved.
//

#import "ListOfPhotosCDTVC.h"
#import "Photo.h"
#import "PhotoViewController.h"

@interface ListOfPhotosCDTVC ()

@end

@implementation ListOfPhotosCDTVC

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual: @"Show Photo"]) {
        NSIndexPath *pathOfSelectedCell = [self.tableView indexPathForCell:sender];
        Photo *selectedPhoto = [self.fetchedResultsController objectAtIndexPath:pathOfSelectedCell];
        if ([segue.destinationViewController isMemberOfClass:[PhotoViewController class]]) {
            PhotoViewController *selectedPhotoVC = (PhotoViewController *)segue.destinationViewController;
            selectedPhotoVC.photo = selectedPhoto;
        }
    }
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Photo *selectedPhoto = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UIViewController *detailVC = [self.splitViewController.viewControllers lastObject];
    if ([detailVC isMemberOfClass:[UINavigationController class]]) {
        UINavigationController *navigationVC = (UINavigationController *)detailVC;
        if ([[navigationVC.viewControllers lastObject] isMemberOfClass:[PhotoViewController class]]) {
            PhotoViewController *selectedPhotoVC = (PhotoViewController *)[navigationVC.viewControllers lastObject];
            selectedPhotoVC.photo = selectedPhoto;
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
    
    if (photo.thumbnail) {
        cell.imageView.image = [UIImage imageWithData:photo.thumbnail];
    } else {
        cell.imageView.image = nil; // need to do this because cells are re-used!!!
    }
    
    return cell;
}

@end
