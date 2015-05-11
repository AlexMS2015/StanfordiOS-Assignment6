//
//  AppDelegate.m
//  CS193P Assignment 5 - Top Places
//
//  Created by Alex Smith on 2/05/2015.
//  Copyright (c) 2015 Alex Smith. All rights reserved.
//

#import "AppDelegate.h"
#import "FlickrFetcher.h"
#import "Photo+LoadIntoFlickr.h"

@interface AppDelegate () <NSURLSessionDownloadDelegate>
@property (strong, nonatomic) NSManagedObjectContext *databaseContext;
@property (strong, nonatomic) NSURLSession *flickrDownloadSession;
@end

@implementation AppDelegate

#define FLICKR_FETCH @"Flickr Download Session"
#define DATABASE_NAME @"RegionsAndPhotosDatabase"

#pragma mark - Properties

-(NSURLSession *)flickrDownloadSession
{
    if (!_flickrDownloadSession) {
        static dispatch_once_t onceToken;
        
        dispatch_once(&onceToken, ^{
            
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:FLICKR_FETCH];
            _flickrDownloadSession = [NSURLSession sessionWithConfiguration:configuration
                                                                   delegate:self
                                                              delegateQueue:nil]; // nil means "a random, non-main-queue queue"
        });
    }
    
    return _flickrDownloadSession;
}

#pragma mark - Helper Methods

-(NSManagedObjectContext *)managedContextFromDocument:(UIManagedDocument *)document
{
    if (document.documentState == UIDocumentStateNormal) {
        return document.managedObjectContext;
    } else {
        return nil;
    }
}

-(NSManagedObjectContext *)getDatabaseContext
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentDirectory = [[fileManager URLsForDirectory:NSDocumentationDirectory
                                                    inDomains:NSUserDomainMask] firstObject];
    // the above method returns an array because on OS X there may be many such document directories but there is only one on iOS.
    
    NSString *databaseName = DATABASE_NAME;
    NSURL *urlOfDatabase = [documentDirectory URLByAppendingPathComponent:databaseName];
    // think of a UIManagedDocument as simply a container for your Core Data database
    UIManagedDocument *documentForDatabaseContext = [[UIManagedDocument alloc] initWithFileURL:urlOfDatabase];
    __block NSManagedObjectContext *context;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[urlOfDatabase path]]) {
        [documentForDatabaseContext openWithCompletionHandler:^(BOOL success) {
            if (success) {
                context = [self managedContextFromDocument:documentForDatabaseContext];
            }
        }];
    } else {
        [documentForDatabaseContext saveToURL:urlOfDatabase forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success) {
                context = [self managedContextFromDocument:documentForDatabaseContext];
            }
        }];
    }
    
    return context;
}

#pragma mark - Flickr Fetching

-(void)startFlickrFetch
{
    [self.flickrDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if (![downloadTasks count]) {
            NSURLSessionDownloadTask *task = [self.flickrDownloadSession downloadTaskWithURL:[FlickrFetcher URLforRecentGeoreferencedPhotos]];
            task.taskDescription = FLICKR_FETCH;
            [task resume];
        } else {
            for (NSURLSessionDownloadTask *task in downloadTasks) {
                [task resume];
            }
        }
    }];
}

#pragma mark - Application Life Cycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.databaseContext = [self getDatabaseContext];
    [self startFlickrFetch];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - NSURLSessionDelegate

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    if ([downloadTask.taskDescription isEqualToString:FLICKR_FETCH]) {
        [self loadFlickrPhotosFromLocalURL:location
                               intoContext:self.databaseContext];
    }
}

-(NSArray *)flickrPhotosFromURL:(NSURL *)photoURL;
{
    NSData *JSONResults = [NSData dataWithContentsOfURL:photoURL];
    NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:JSONResults
                                                                        options:0
                                                                          error:NULL];
    return [propertyListResults valueForKeyPath:FLICKR_RESULTS_PHOTOS];
}

-(void)loadFlickrPhotosFromLocalURL:(NSURL *)localFile intoContext:(NSManagedObjectContext *)context
{
    [Photo loadPhotosFromFlickrArray:[self flickrPhotosFromURL:localFile]
                         intoContext:self.databaseContext];
}

@end
