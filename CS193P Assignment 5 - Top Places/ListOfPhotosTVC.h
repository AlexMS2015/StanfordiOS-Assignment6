//
//  ListOfPhotosTVC.h
//  CS193P Assignment 5 - Top Places
//
//  Created by Alex Smith on 9/05/2015.
//  Copyright (c) 2015 Alex Smith. All rights reserved.
//

#import "FlickrDataTVC.h"

@interface ListOfPhotosTVC : FlickrDataTVC

/*
 
THIS CLASS LEAVES THESE METHODS FOR CONCRETE SUBCLASSES TO IMPLEMENT


-(NSDictionary *)dictionaryForCellAtIndexPath:(NSIndexPath *)indexPath; // dictionary of data for a particular cell. the keys will be as specific in the subclass method dictionaryFromFlickrData;

 
THIS CLASS IMPLEMENTS THE FOLLOWING ABSTRACT METHODS FROM THE SUPERCLASS

-(NSString *)nameOfCellIdentifier; // abstract method
-(NSString *)getTitleForCellInDictionary:(NSDictionary *)dictionary; // abstract method. the dictionary passed in is for a specific section (key) and row (location in the array in the array of dictionaries for that specific key). simply return the NSString in your dictionary you wish to be the title of the cell.
-(NSString *)getSubtitleForCellInDictionary:(NSDictionary *)dictionary; // abstract method

 */

@end
