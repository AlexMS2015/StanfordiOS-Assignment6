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

@interface PhotosInRegionCDTVC ()

@end

@implementation PhotosInRegionCDTVC

-(NSFetchRequest *)fetchRequestForFetchedResultsController
{
    NSFetchRequest *photosInRegion = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    
    NSSortDescriptor *photoNameSortDesc = [NSSortDescriptor sortDescriptorWithKey:@"photoTitle" ascending:YES];
    
    photosInRegion.sortDescriptors = @[photoNameSortDesc];
    photosInRegion.predicate = [NSPredicate predicateWithFormat:@"region.regionName = %@", self.regionForPhotos.regionName];
    
    NSError *error;
    NSArray *photoResults = [self.context executeFetchRequest:photosInRegion error:&error];
    
    NSLog(@"found photos: %@ in %@", photoResults, self.regionForPhotos.regionName);
    
    return photosInRegion;
}

-(void)setContext:(NSManagedObjectContext *)context
{
    [super setContext:context];
    
    //self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:[self fetchRequestForFetchedResultsController] managedObjectContext:context sectionNameKeyPath:@"Photographer.photographerName" cacheName:nil];
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
