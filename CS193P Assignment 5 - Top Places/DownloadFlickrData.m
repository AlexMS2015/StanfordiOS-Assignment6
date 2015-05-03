//
//  DownloadFlickrData.m
//  CS193P Assignment 5 - Top Places
//
//  Created by Alex Smith on 2/05/2015.
//  Copyright (c) 2015 Alex Smith. All rights reserved.
//

#import "DownloadFlickrData.h"
#import "FlickrFetcher.h"

@interface DownloadFlickrData () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSMutableDictionary *data;
@property (nonatomic, strong) NSString *cellIdentifier;
@end

@implementation DownloadFlickrData

#pragma mark - Properties

-(NSString *)cellIdentifier
{
    if (!_cellIdentifier) {
        _cellIdentifier = @"Place Cell";
    }
    
    return _cellIdentifier;
}

-(NSMutableDictionary *)data
{
    if (!_data) {
        _data = [NSMutableDictionary dictionary];
    }
    
    return _data;
}

#pragma mark - View Life Cycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self downloadJSONDataIntoDictionary];
}

-(IBAction)downloadJSONDataIntoDictionary // IBAction links to the refresh control so whenever the user refreshes the table by dragging down, this method will be called.
{
    [self.refreshControl beginRefreshing];
    
    self.data = nil;
    NSURL *topPlaces = [FlickrFetcher URLforTopPlaces];

    dispatch_queue_t queryQueue = dispatch_queue_create("Query Queue", NULL);
    dispatch_async(queryQueue, ^{
       
        NSData *JSONResults = [NSData dataWithContentsOfURL:topPlaces];
        NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:JSONResults
                                                                            options:0
                                                                              error:NULL];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setupTableDataStructuresUsingDictionary:propertyListResults];
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        });
    });
}

-(void)setupTableDataStructuresUsingDictionary:(NSDictionary *)propertyListResults;
{
    NSArray *placesArray = [propertyListResults valueForKeyPath:FLICKR_RESULTS_PLACES];
    
    if ([placesArray count]) {
        [placesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *placeName = [obj valueForKeyPath:FLICKR_PLACE_NAME];
            NSArray *placeNameArray = [placeName componentsSeparatedByString:@", "];
            NSString *country = [placeNameArray lastObject];
            
            NSDictionary *newPlace = @{@"Place ID" : [obj valueForKey:FLICKR_PLACE_ID],
                                       @"Town" : [placeNameArray firstObject],
                                       @"City" : placeNameArray[1],
                                       @"Photo Count" : [obj valueForKey:@"photo_count"]};
            //NSLog(@"%p points at %p", &newPlace, newPlace);
            
            if (!self.data[country]) {
                self.data[country] = [NSMutableArray array];
                [self.data[country] addObject:newPlace];
            } else {
                [self.data[country] addObject:newPlace];
            }
        }];
        
        // for each country, sort by town name within that country alphabetically
        for (NSString *country in self.data) {
            NSMutableArray *placesInCountry = self.data[country];
            [placesInCountry sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return [obj1[@"Town"] compare:obj2[@"Town"]];
            }];
        }
    }
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *countryName = [self.data allKeys][indexPath.section];
    NSDictionary *place = self.data[countryName][indexPath.row];
    
    NSString *placeID = place[@"Place ID"];
    
    NSURL *photosInPlace = [FlickrFetcher URLforPhotosInPlace:placeID maxResults:50];
    NSData *JSONResults = [NSData dataWithContentsOfURL:photosInPlace];
    NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:JSONResults
                                                                        options:0
                                                                          error:NULL];
    NSLog(@"%@", propertyListResults);
}

#pragma mark - UITableViewDataSource

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.data allKeys][section];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.data count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *countryName = [self.data allKeys][section];
    return [self.data[countryName] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    cell.textLabel.text = [self getTitleForCellAtIndexPath:indexPath];
    cell.detailTextLabel.text = [self getSubtitleForCellAtIndexPath:indexPath];
    return cell;
}

-(NSString *)getTitleForCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *countryName = [self.data allKeys][indexPath.section];
    NSDictionary *place = self.data[countryName][indexPath.row];
    return place[@"Town"];
}

-(NSString *)getSubtitleForCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *countryName = [self.data allKeys][indexPath.section];
    NSDictionary *place = self.data[countryName][indexPath.row];
    return place[@"City"];
}

@end
