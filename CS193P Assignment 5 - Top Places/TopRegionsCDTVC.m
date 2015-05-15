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

@interface TopRegionsCDTVC ()

@end

@implementation TopRegionsCDTVC

#pragma mark - Properties

-(void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserverForName:DATABASE_AVAILABILITY_NOTIFICATION
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                            self.context = note.userInfo[DATABASE_AVAILABILITY_CONTEXT];
    }];
}

-(void)setContext:(NSManagedObjectContext *)context
{    
    _context = context;
        
    NSFetchRequest *topRegions = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
    
    NSSortDescriptor *numPhotosSortDesc = [NSSortDescriptor sortDescriptorWithKey:@"numOfPhotgraphers" ascending:NO];
    NSSortDescriptor *regionNameSortDesc = [NSSortDescriptor sortDescriptorWithKey:@"regionName" ascending:YES selector:@selector(localizedCompare:)];

    topRegions.sortDescriptors = @[numPhotosSortDesc, regionNameSortDesc];
    topRegions.predicate = nil;
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:topRegions managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
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
