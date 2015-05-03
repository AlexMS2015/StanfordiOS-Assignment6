//
//  DownloadFlickrData.h
//  CS193P Assignment 5 - Top Places
//
//  Created by Alex Smith on 2/05/2015.
//  Copyright (c) 2015 Alex Smith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlickrDataTVC : UITableViewController

-(NSString *)nameOfCellIdentifier; // abstract method
-(NSDictionary *)dictionaryFromFlickrData; // abstract method. the keys should represent the sections in the table view. each key should map to an object that is an array of dictionaries. this array represents the rows in that section (key) and each dictionary will contain the data for that row.
-(NSString *)getTitleForCellInDictionary:(NSDictionary *)dictionary; // abstract method. the dictionary passed in is for a specific section (key) and row (location in the array in the array of dictionaries for that specific key). simply return the NSString in your dictionary you wish to be the title of the cell.
-(NSString *)getSubtitleForCellInDictionary:(NSDictionary *)dictionary; // abstract method

@end
