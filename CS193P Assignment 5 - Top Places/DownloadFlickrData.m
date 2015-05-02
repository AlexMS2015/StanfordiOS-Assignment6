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
@property (nonatomic, strong) NSMutableDictionary *places;
@end

@implementation DownloadFlickrData

#pragma mark - Properties

-(NSMutableDictionary *)places
{
    if (!_places) {
        _places = [NSMutableDictionary dictionary];
    }
    
    return _places;
}

#pragma mark - View Life Cycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self downloadJSONDataIntoDictionary];
}

-(void)downloadJSONDataIntoDictionary
{
    NSURL *topPlaces = [FlickrFetcher URLforTopPlaces];
    NSData *JSONResults = [NSData dataWithContentsOfURL:topPlaces];
    NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:JSONResults
                                                                        options:0
                                                                          error:NULL];
    
    [self setupTableDataStructuresUsingDictionary:propertyListResults];
    
    NSLog(@"%@", self.places);
}

-(void)setupTableDataStructuresUsingDictionary:(NSDictionary *)propertyListResults;
{
    NSMutableSet *uniqueCountriesSet = [NSMutableSet set];
    
    NSArray *placesArray = [propertyListResults valueForKeyPath:FLICKR_RESULTS_PLACES];
    
    if ([placesArray count]) {
        
        [placesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *placeName = [obj valueForKeyPath:FLICKR_PLACE_NAME];
            NSArray *placeNameArray = [placeName componentsSeparatedByString:@", "];
            NSString *country = [placeNameArray lastObject];
            
            NSDictionary *newPlace = @{@"Place ID" : [obj valueForKey:FLICKR_PLACE_ID],
                                       @"Town" : [placeNameArray firstObject],
                                       @"City" : placeNameArray[1],
                                       @"Country" : [placeNameArray lastObject],
                                       @"Photo Count" : [obj valueForKey:@"photo_count"]};
            
            if (!self.places[country]) {
                self.places[country] = [NSMutableArray array];
                [self.places[country] addObject:newPlace];
            } else {
                [self.places[country] addObject:newPlace];
            }
            
            [uniqueCountriesSet addObject:country];
        }];
        
        // convert the Set of unique countries into an array
        self.uniqueCountries = [NSMutableArray arrayWithArray:[uniqueCountriesSet allObjects]];
        
        /*for (NSMutableArray *country in self.places) {
            [country sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return [obj1[@"Town"] compare:obj2[@"Town"]];
            }];
        }*/
        
        
        /*[self.uniqueCountries sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2];
        }];
        
        // sort the places dictionary by the key so it matches the uniqueCountries array
        [self.places sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return
        }];*/
        
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
    NSString *countryName = self.uniqueCountries[section];
    return [self.places[countryName] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Place Cell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSString *countryName = self.uniqueCountries[indexPath.section];
    NSDictionary *place = self.places[countryName][indexPath.row];
    
    cell.textLabel.text = place[@"Town"];
    cell.detailTextLabel.text = place[@"City"];
    
    return cell;
}

@end
