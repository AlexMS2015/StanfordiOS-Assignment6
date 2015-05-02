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
@property (strong, nonatomic) NSMutableArray *uniqueCountries;
@property (nonatomic, strong) NSMutableArray *places;
@end

@implementation DownloadFlickrData

#pragma mark - Properties

-(void)setPlaces:(NSMutableArray *)places
{
    _places = places;
    [self.tableView reloadData];
}

#pragma mark - View Life Cycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self downloadData];
}

-(void)downloadData
{
    NSURL *topPlaces = [FlickrFetcher URLforTopPlaces];
    NSData *JSONResults = [NSData dataWithContentsOfURL:topPlaces];
    NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:JSONResults
                                                                        options:0
                                                                          error:NULL];
    
    self.places = [propertyListResults valueForKeyPath:FLICKR_RESULTS_PLACES]; // FLICKR_RESULTS_PLACES = places.place.... "places" is the key for the only object in the top level dictionary while "place" is the key for an array of dictionaries inside the "places" dictionary. Dictionary > Places key for another dictionary > Place key for an array of dictionaries
    
    [self setupTableDataStructures];
    //NSLog(@"%@", self.places);
}

-(void)setupTableDataStructures
{
    NSMutableArray *placesTemp = [NSMutableArray array];
    NSMutableSet *uniqueCountriesSet = [NSMutableSet set];
    
    if ([self.places count]) {
        
        [self.places enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *placeName = [obj valueForKeyPath:FLICKR_PLACE_NAME];
            NSArray *placeNameArray = [placeName componentsSeparatedByString:@", "];
            
            NSDictionary *newPlace = @{@"Place ID" : [obj valueForKey:FLICKR_PLACE_ID],
                                       @"Town" : [placeNameArray firstObject],
                                       @"City" : placeNameArray[1],
                                       @"Country" : [placeNameArray lastObject],
                                       @"Photo Count" : [obj valueForKey:@"photo_count"]};
            
            [placesTemp addObject:newPlace];
            [uniqueCountriesSet addObject:[placeNameArray lastObject]];
        }];
        
        // convert the Set of unique countries into a sorted array
        self.uniqueCountries = [NSMutableArray arrayWithArray:[uniqueCountriesSet allObjects]];
        [self.uniqueCountries sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2];
        }];
        
        self.places = [placesTemp copy];
    }
}

#pragma mark - UITableViewDelegate

#pragma mark - UITableViewDataSource

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
   return self.uniqueCountries[section];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.uniqueCountries count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.places count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Place Cell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSDictionary *place = self.places[indexPath.row];

    
    cell.textLabel.text = place[@"Town"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", place[@"City"], place[@"Country"]];
    
    return cell;
}

@end
