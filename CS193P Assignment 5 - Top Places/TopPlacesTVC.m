//
//  TopPlacesTVC.m
//  CS193P Assignment 5 - Top Places
//
//  Created by Alex Smith on 3/05/2015.
//  Copyright (c) 2015 Alex Smith. All rights reserved.
//

#import "TopPlacesTVC.h"
#import "FlickrFetcher.h"
#import "PhotosForPlaceTVC.h"

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

-(NSArray *)getArrayOfTopPlaces
{
    NSURL *topPlaces = [FlickrFetcher URLforTopPlaces];
    NSData *JSONResults = [NSData dataWithContentsOfURL:topPlaces];
    NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:JSONResults
                                                                        options:0
                                                                          error:NULL];
    return [propertyListResults valueForKeyPath:FLICKR_RESULTS_PLACES];
}

-(void)sortArrayOfDictionaries:(NSMutableArray *)array withKey:(NSString *)key
{
    [array sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1[key] compare:obj2[key]];
    }];
}

-(NSDictionary *)dictionaryFromFlickrData
{
    NSArray *placesArray = [self getArrayOfTopPlaces];
    
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
            [self sortArrayOfDictionaries:placesInCountry withKey:@"Town"];
        }
        

    }
    
    return places;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    

}

#pragma mark - Other

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual: @"Show Photos for Place"]) {
        NSIndexPath *pathOfSelectedCell = [self.tableView indexPathForCell:sender];
        NSDictionary *cellData = [self dictionaryForCellAtIndexPath:pathOfSelectedCell];
        if ([segue.destinationViewController isMemberOfClass:[PhotosForPlaceTVC class]]) {
            PhotosForPlaceTVC *photosForSelectedPlace = (PhotosForPlaceTVC *)segue.destinationViewController;
            photosForSelectedPlace.placeID = cellData[@"Place ID"];
            photosForSelectedPlace.placeName = cellData[@"Town"];
        }
    }
}

@end
