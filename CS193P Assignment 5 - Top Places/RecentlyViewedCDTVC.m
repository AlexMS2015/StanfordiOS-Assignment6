//
//  RecentlyViewedCDTVC.m
//  CS193P Assignment 5 - Top Places
//
//  Created by Alex Smith on 16/05/2015.
//  Copyright (c) 2015 Alex Smith. All rights reserved.
//

#import "RecentlyViewedCDTVC.h"
#import "DatabaseAvailability.h"

@interface RecentlyViewedCDTVC ()

@end

@implementation RecentlyViewedCDTVC

-(void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserverForName:DATABASE_AVAILABILITY_NOTIFICATION
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      self.context = note.userInfo[DATABASE_AVAILABILITY_CONTEXT];
                                                  }];
}

-(void)viewDidLoad
{
    NSLog(@"loding recents now");
}

-(NSFetchRequest *)fetchRequestForFetchedResultsController
{
    NSFetchRequest *recentlyViewed = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    
    NSSortDescriptor *photoTitleSortDesc = [NSSortDescriptor sortDescriptorWithKey:@"photoTitle" ascending:YES];
    
    recentlyViewed.sortDescriptors = @[photoTitleSortDesc];
    recentlyViewed.predicate = [NSPredicate predicateWithFormat:@"recentlyViewed = %d", 1];
    
    return recentlyViewed;
}

@end
