//
//  RecentlyViewedPhotos.h
//  CS193P Assignment 5 - Top Places
//
//  Created by Alex Smith on 9/05/2015.
//  Copyright (c) 2015 Alex Smith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecentlyViewedPhotos : NSObject
+(instancetype)recentPhotos; // singleton class. use this method to access this class!
-(void)addPhoto:(NSDictionary *)photo;
-(NSArray *)recentPhotosArray;
@end
