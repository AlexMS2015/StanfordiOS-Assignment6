//
//  TopPlacesTVC.m
//  CS193P Assignment 5 - Top Places
//
//  Created by Alex Smith on 3/05/2015.
//  Copyright (c) 2015 Alex Smith. All rights reserved.
//

#import "TopPlacesTVC.h"
#import "FlickrFetcher.h"

@interface TopPlacesTVC ()

@end

@implementation TopPlacesTVC

#pragma mark - Concrete Methods

-(NSString *)nameOfCellIdentifier
{
    return @"Place Cell";
}

-(NSString *)getTitleForCellInDictionary:(NSDictionary *)dictionary
{
    return dictionary[@"Town"];
}

-(NSString *)getSubtitleForCellInDictionary:(NSDictionary *)dictionary
{
    return dictionary[@"City"];
}

-(NSDictionary *)dictionaryFromFlickrData
{
    
    NSURL *topPlaces = [FlickrFetcher URLforTopPlaces];
    
    NSData *JSONResults = [NSData dataWithContentsOfURL:topPlaces];
    NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:JSONResults
                                                                        options:0
                                                                          error:NULL];
    
    NSArray *placesArray = [propertyListResults valueForKeyPath:FLICKR_RESULTS_PLACES];
    NSMutableDictionary *places = [NSMutableDictionary dictionary];
    
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
            
            if (!places[country]) {
                places[country] = [NSMutableArray array];
                [places[country] addObject:newPlace];
            } else {
                [places[country] addObject:newPlace];
            }
        }];
        
        // for each country, sort by town name within that country alphabetically
        for (NSString *country in places) {
            NSMutableArray *placesInCountry = places[country];
            [placesInCountry sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return [obj1[@"Town"] compare:obj2[@"Town"]];
            }];
        }
    }
    
    return places;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*NSString *countryName = [self.data allKeys][indexPath.section];
     NSDictionary *place = self.data[countryName][indexPath.row];
     
     NSString *placeID = place[@"Place ID"];
     
     NSURL *photosInPlace = [FlickrFetcher URLforPhotosInPlace:placeID maxResults:50];
     NSData *JSONResults = [NSData dataWithContentsOfURL:photosInPlace];
     NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:JSONResults
     options:0
     error:NULL];
     NSLog(@"%@", propertyListResults);*/
}

@end
