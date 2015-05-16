//
//  ListOfPhotosTVC.m
//  CS193P Assignment 5 - Top Places
//
//  Created by Alex Smith on 9/05/2015.
//  Copyright (c) 2015 Alex Smith. All rights reserved.
//

#import "ListOfPhotosTVC.h"
#import "FlickrFetcher.h"
#import "PhotoViewController.h"

@interface ListOfPhotosTVC ()

@end

@implementation ListOfPhotosTVC

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

#pragma mark - Other

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual: @"Show Photo"]) {
        NSIndexPath *pathOfSelectedCell = [self.tableView indexPathForCell:sender];
        NSDictionary *cellData = [self dictionaryForCellAtIndexPath:pathOfSelectedCell];
        if ([segue.destinationViewController isMemberOfClass:[PhotoViewController class]]) {
            [self prepareVC:segue.destinationViewController withPhoto:cellData];
        }
    }
}

-(void)prepareVC:(PhotoViewController *)selectedPhoto withPhoto:(NSDictionary *)photo
{
    //selectedPhoto.photo = photo;
    selectedPhoto.title = [self getTitleForCellInDictionary:photo];
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *cellData = [self dictionaryForCellAtIndexPath:indexPath];
    if ([self.splitViewController.viewControllers[1] isMemberOfClass:[UINavigationController class]]) {
        UINavigationController *detailNC = (UINavigationController *)self.splitViewController.viewControllers[1];
        if ([[detailNC.viewControllers lastObject] isMemberOfClass:[PhotoViewController class]]) {
            [self prepareVC:[detailNC.viewControllers lastObject] withPhoto:cellData];
        }
    }
}

@end
