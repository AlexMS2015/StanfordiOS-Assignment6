//
//  DownloadFlickrData.m
//  CS193P Assignment 5 - Top Places
//
//  Created by Alex Smith on 2/05/2015.
//  Copyright (c) 2015 Alex Smith. All rights reserved.
//

#import "FlickrDataTVC.h"

@interface FlickrDataTVC () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSString *cellIdentifier;
@property (nonatomic, strong) NSDictionary *data;
@end

@implementation FlickrDataTVC

#pragma mark - Properties

-(NSString *)cellIdentifier
{
    if (!_cellIdentifier) {
        _cellIdentifier = [self nameOfCellIdentifier];
    }
    
    return _cellIdentifier;
}

#pragma mark - View Life Cycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    //[self downloadDataAndRefreshUI];
}

-(IBAction)downloadDataAndRefreshUI // IBAction links to the refresh control so whenever the user refreshes the table by dragging down, this method will be called.
{
    self.data = nil;
    [self.refreshControl beginRefreshing];
    
    dispatch_queue_t queryQueue = dispatch_queue_create("Query Queue", NULL);
    dispatch_async(queryQueue, ^{
        self.data = [self dictionaryFromFlickrData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        });
    });
}

#pragma mark - UITableViewDataSource

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([self.data count] > 1) {
        return [self.data allKeys][section];
    } else {
        return nil;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.data count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *sectionName = [self.data allKeys][section];
    return [self.data[sectionName] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    
    NSString *sectionName = [self.data allKeys][indexPath.section];
    NSDictionary *dictionaryInSection = self.data[sectionName][indexPath.row];
    
    cell.textLabel.text = [self getTitleForCellInDictionary:dictionaryInSection];
    cell.detailTextLabel.text = [self getSubtitleForCellInDictionary:dictionaryInSection];
    return cell;
}

#pragma mark - Other

-(NSDictionary *)dictionaryForCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *sectionName = [self.data allKeys][indexPath.section];
    return self.data[sectionName][indexPath.row];
}

#pragma mark - Abstract Methods

-(NSString *)nameOfCellIdentifier // abstract method
{
    return @"";
}

-(NSString *)getTitleForCellInDictionary:(NSDictionary *)dictionary;
{
    return @"";
}

-(NSString *)getSubtitleForCellInDictionary:(NSDictionary *)dictionary;
{
    return @"";
}

-(NSDictionary *)dictionaryFromFlickrData;
{
    return @{};
}

@end
