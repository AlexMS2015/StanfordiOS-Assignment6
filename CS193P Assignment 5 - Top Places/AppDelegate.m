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
#import "DatabaseAvailability.h"

@interface AppDelegate () <NSURLSessionDownloadDelegate>
@property (strong, nonatomic) NSManagedObjectContext *databaseContext;
@property (strong, nonatomic) NSURLSession *flickrDownloadSession;
@end

@implementation AppDelegate

#define FLICKR_FETCH @"Flickr Download Session"
#define DATABASE_NAME @"RegionsAndPhotosDatabase"

#pragma mark - Properties

-(void)setDatabaseContext:(NSManagedObjectContext *)databaseContext
{
    _databaseContext = databaseContext;

    NSDictionary *userInfo = @{DATABASE_AVAILABILITY_CONTEXT : self.databaseContext };
    [[NSNotificationCenter defaultCenter] postNotificationName:DATABASE_AVAILABILITY_NOTIFICATION
                                                        object:self
                                                      userInfo:userInfo];
}

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

#pragma mark - Helper Methods

-(NSManagedObjectContext *)managedContextFromDocument:(UIManagedDocument *)document
{
    if (document.documentState == UIDocumentStateNormal) {
        return document.managedObjectContext;
    } else {
        return nil;
    }
}

-(void)getDatabaseContextAndStartFlickrDownload
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory
                                                    inDomains:NSUserDomainMask] firstObject];
    // the above method returns an array because on OS X there may be many such document directories but there is only one on iOS.
    
    NSURL *urlOfDatabase = [documentDirectory URLByAppendingPathComponent:DATABASE_NAME];
    // think of a UIManagedDocument as simply a container for your Core Data database
    UIManagedDocument *documentForDatabaseContext = [[UIManagedDocument alloc] initWithFileURL:urlOfDatabase];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[urlOfDatabase path]]) {
        [documentForDatabaseContext openWithCompletionHandler:^(BOOL success) {
            if (success) {
                self.databaseContext = [self managedContextFromDocument:documentForDatabaseContext];
                if (self.databaseContext) [self startFlickrFetch];
            }
        }];
    } else {
        [documentForDatabaseContext saveToURL:urlOfDatabase
                             forSaveOperation:UIDocumentSaveForCreating
                            completionHandler:^(BOOL success) {
            if (success) {
                self.databaseContext = [self managedContextFromDocument:documentForDatabaseContext];
                if (self.databaseContext) [self startFlickrFetch];
            }
        }];
    }
}

#pragma mark - Application Life Cycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self getDatabaseContextAndStartFlickrDownload];
    
    return YES;
}

#pragma mark - NSURLSessionDelegate

-(NSArray *)flickrPhotosFromURL:(NSURL *)localPhotoURL;
{
    NSData *JSONResults = [NSData dataWithContentsOfURL:localPhotoURL];
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

// required by the protocol
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    if ([downloadTask.taskDescription isEqualToString:FLICKR_FETCH]) {
        [self loadFlickrPhotosFromLocalURL:location
                               intoContext:self.databaseContext];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error && (session == self.flickrDownloadSession)) {
        NSLog(@"Flickr background download session failed: %@", error.localizedDescription);
    }
}

// required by the protocol
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    // we don't support resuming an interrupted download task
}

// required by the protocol
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    // we don't report the progress of a download in our UI, but this is a cool method to do that with
}

@end
