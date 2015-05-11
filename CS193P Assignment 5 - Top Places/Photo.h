//
//  Photo.h
//  CS193P Assignment 5 - Top Places
//
//  Created by Alex Smith on 11/05/2015.
//  Copyright (c) 2015 Alex Smith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photographer, Region;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * photoURL;
@property (nonatomic, retain) NSString * photoTitle;
@property (nonatomic, retain) NSString * photoDescription;
@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) Region *region;
@property (nonatomic, retain) Photographer *photographer;

@end
