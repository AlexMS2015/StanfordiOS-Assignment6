//
//  RecentlyViewedPhotos.m
//  CS193P Assignment 5 - Top Places
//
//  Created by Alex Smith on 9/05/2015.
//  Copyright (c) 2015 Alex Smith. All rights reserved.
//

#import "RecentlyViewedPhotos.h"
#import "FlickrFetcher.h"

@interface RecentlyViewedPhotos ()
@property (strong, nonatomic) NSUserDefaults *defaults;
@end

@implementation RecentlyViewedPhotos

static NSString *recentPhotosKey = @"Recently Viewed";

/*
 static keyword in Objective-C (and C/C++) indicates the visibility of the variable. A static variable (not in a method) may only be accessed within that particular .m file. A static local variable on the other hand, gets allocated only once.
 
 const on the other hand, indicates that the reference may not be modified and/or reassigned; and is orthogonal on how it can be created (compilers may optimize consts though).
*/

-(void)addPhoto:(NSDictionary *)photo
{
    NSMutableArray *recentlyViewedPhotos = [[self.defaults valueForKey:recentPhotosKey] mutableCopy];
        
    if ([recentlyViewedPhotos containsObject:photo]) {
        [recentlyViewedPhotos removeObject:photo];
    }
    
    [recentlyViewedPhotos insertObject:photo atIndex:0];
    [self.defaults setObject:recentlyViewedPhotos forKey:recentPhotosKey];
    [self.defaults synchronize];
}

-(NSArray *)recentPhotosArray
{
    return [[self.defaults valueForKey:recentPhotosKey] copy];
}

+(instancetype)recentPhotos
{
    static RecentlyViewedPhotos *recentPhotos; // a static variable is not destroyed when the method is done executing, it is not kept on the stack. the first time this method is called, sharedStore will be set to point to an instance of RecentlyViewedPhotos. This pointer will never be destroyed and hence the object it points to never will be either (it points strongly at it).
     
    // do I need to create a shared instance of the class?
    if (!recentPhotos) {
         recentPhotos = [[self alloc] initPrivate];
    }
    
    return recentPhotos;
}

-(instancetype)initPrivate
{
    self = [super init];
    
    if (self) {
        self.defaults = [NSUserDefaults standardUserDefaults];
        if (![self.defaults valueForKey:recentPhotosKey]) {
            [self.defaults setObject:@[] forKey:recentPhotosKey];
        }
    }
    
    return self;
}

@end
