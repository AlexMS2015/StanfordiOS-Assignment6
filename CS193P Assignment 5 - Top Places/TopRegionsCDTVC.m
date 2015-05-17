//
//  TopRegionsCDTVC.m
//  CS193P Assignment 5 - Top Places
//
//  Created by Alex Smith on 11/05/2015.
//  Copyright (c) 2015 Alex Smith. All rights reserved.
//

#import "TopRegionsCDTVC.h"
#import "Region.h"
#import "DatabaseAvailability.h"
#import "PhotosInRegionCDTVC.h"

@implementation TopRegionsCDTVC

-(void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserverForName:DATABASE_AVAILABILITY_NOTIFICATION
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                    self.context = note.userInfo[DATABASE_AVAILABILITY_CONTEXT];
    }];
}

-(NSFetchRequest *)fetchRequestForFetchedResultsController
{
    NSFetchRequest *topRegions = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
    
    NSSortDescriptor *numPhotosSortDesc = [NSSortDescriptor sortDescriptorWithKey:@"numOfPhotgraphers" ascending:NO];
    NSSortDescriptor *regionNameSortDesc = [NSSortDescriptor sortDescriptorWithKey:@"regionName" ascending:YES selector:@selector(localizedCompare:)];
    
    topRegions.sortDescriptors = @[numPhotosSortDesc, regionNameSortDesc];
    topRegions.predicate = nil;
    
    return topRegions;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Photos For Region"]) {
        NSIndexPath *pathOfSelectedCell = [self.tableView indexPathForCell:sender];
        Region *selectedRegion = [self.fetchedResultsController objectAtIndexPath:pathOfSelectedCell];
        if ([segue.destinationViewController isMemberOfClass:[PhotosInRegionCDTVC class]]) {
            PhotosInRegionCDTVC *photosInRegion = (PhotosInRegionCDTVC *)segue.destinationViewController;
            [self preparePhotosInRegionVC:photosInRegion WithRegion:selectedRegion];
        }
    }
}

-(void)preparePhotosInRegionVC:(PhotosInRegionCDTVC *)photosInRegion
                    WithRegion:(Region *)selectedRegion
{
    photosInRegion.regionForPhotos = selectedRegion;
    photosInRegion.title = [NSString stringWithFormat:@"Photos in %@", selectedRegion.regionName];
    photosInRegion.context = self.context;
}

#pragma mark - UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Region Cell"];
    
    Region *region = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = region.regionName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Active photgraphers: %@", [region.numOfPhotgraphers stringValue]];
    
    return cell;
}

@end
