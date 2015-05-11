//
//  Region.h
//  CS193P Assignment 5 - Top Places
//
//  Created by Alex Smith on 11/05/2015.
//  Copyright (c) 2015 Alex Smith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo, Photographer;

@interface Region : NSManagedObject

@property (nonatomic, retain) NSString * regionName;
@property (nonatomic, retain) NSNumber * numOfPhotgraphers;
@property (nonatomic, retain) NSSet *photos;
@property (nonatomic, retain) NSSet *photgraphers;
@end

@interface Region (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

- (void)addPhotgraphersObject:(Photographer *)value;
- (void)removePhotgraphersObject:(Photographer *)value;
- (void)addPhotgraphers:(NSSet *)values;
- (void)removePhotgraphers:(NSSet *)values;

@end
