//
//  TableViewController.m
//  NewsApp
//
//  Created by USER on 22/10/2018.
//  Copyright © 2018 My. All rights reserved.
//

#import "TableViewController.h"
#import "AppDelegate.h"
#import "NewsViewController.h"

NSString *urlForDownload = @"https://newsapi.org/v2/everything?sources=nhl-news&apiKey=afc4e5873cb0405ebaa4f4474ffb34f2";
NSString *downloadedFilePath = @"";

@interface TableViewController ()
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) UISearchController *searchController;
@end


@implementation TableViewController


NSMutableArray *news;
NSMutableArray *searchResults;
bool filtering = false;



- (void)viewDidLoad {
    [super viewDidLoad];
   
    if (@available(iOS 11.0, *)) {
        //NSLog(@"iOS 11.0");
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAutomatic;
        
        _searchController = [[UISearchController alloc] initWithSearchResultsController: nil];
        self.searchController.searchResultsUpdater = self;
        self.navigationItem.searchController = self.searchController;
        
    }
    
    [self loadNews];
    
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(getJSONDataAtURL) forControlEvents:UIControlEventValueChanged];
    self.tableView.refreshControl = self.refreshControl;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadNews)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
   
}

-(void)dealloc {
   [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

-(void)loadNews {
    NSFileManager *defaultFileManager = [NSFileManager defaultManager];
    
    if ([downloadedFilePath  isEqual: @""]) {
       [self getJSONDataAtURL];
        
    } else {
        if ([defaultFileManager fileExistsAtPath:downloadedFilePath]) {
            NSDictionary *attributes = [defaultFileManager attributesOfItemAtPath:downloadedFilePath error:nil];
            unsigned long long size = [attributes fileSize];
            if (attributes && size != 0) {
                [self downloadFromFile];
                
            } else if (attributes && size == 0) {
                [self getJSONDataAtURL];
                
            }
        }
    }
}

- (void)getJSONDataAtURL  {
   // NSLog(@"'-----------------------------getJSONDataAtURL______________________");
    NSURL *urlWithJSON = [NSURL URLWithString:urlForDownload];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^
                   {
                       // Download the data in background.
                       NSError *error;
                       NSData *data = [NSData dataWithContentsOfURL:urlWithJSON];
                       
                       NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                      
                       if (json != nil) {
                           NSMutableArray *results = [json valueForKey:@"articles"];
                           news = [results copy];
                           searchResults = [results copy];
                          
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              [self.tableView reloadData];
                                              
                                          });
                       }
                       
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          [self.refreshControl endRefreshing];
                                          
                                      });
                       [self saveJSONWithData:data];
                       
                   });
}

-(void)saveJSONWithData:(NSData *)data
{
    NSFileManager *defaultFileManager = [NSFileManager defaultManager];
    
    NSURL *docDirectoryURL = [[[defaultFileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"NewsApp" isDirectory:YES];
    
    if (![defaultFileManager fileExistsAtPath:docDirectoryURL.path]) {
        [defaultFileManager createDirectoryAtPath:docDirectoryURL.path withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    NSURL *downloadedFileURL = [docDirectoryURL URLByAppendingPathComponent:@"news.json"];
    downloadedFilePath = downloadedFileURL.path;
    
    // If there already is a file with the same name, remove it first
    [defaultFileManager removeItemAtPath:downloadedFileURL.path error:nil];
    [data writeToFile:downloadedFileURL.path atomically:YES];
    
}

- (void) downloadFromFile {
    //NSLog(@"'----------------------------- downloadFromFile ______________________");
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        
        NSData *data = [NSData dataWithContentsOfFile:downloadedFilePath];
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            [self jsonParse:data];
            
        });
    });
}
    
- (void) jsonParse:(NSData *) data {
    
    NSError *error;
    
    NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    if (json != nil) {
        NSMutableArray *results = [json valueForKey:@"articles"];
        news = [results copy];
        searchResults = [results copy];
        [self.tableView reloadData];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { 
    return filtering ? searchResults.count : news.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomCell" forIndexPath:indexPath];
    
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CustomCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    id currentItem = filtering ? [searchResults objectAtIndex:indexPath.row] : [news objectAtIndex:indexPath.row];
    
    if([currentItem valueForKey:@"title"] != nil) {
         cell.titleLabel.text = [NSString stringWithFormat: @"%@", [currentItem valueForKey:@"title"]];
    }
    if([currentItem valueForKey:@"description"] != nil) {
        cell.descriptionLabel.text = [NSString stringWithFormat: @"\t%@", [currentItem valueForKey:@"description"]];
    }
    if([currentItem valueForKey:@"urlToImage"] != nil) {
        
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            
            NSURL *url = [NSURL URLWithString:[currentItem valueForKey:@"urlToImage"]];
            NSData *data = [NSData dataWithContentsOfURL:url];
            
            if ( data == nil )
                return;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *img = [[UIImage alloc] initWithData:data];
                cell.cellImageView.image = img;
                
            });
            
        });
    }
    if([currentItem valueForKey:@"publishedAt"] != nil) {
        NSString *substr = [[currentItem valueForKey:@"publishedAt"] substringToIndex:10];
        cell.publishedLabel.text = [NSString stringWithFormat: @"%@", substr];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:true];
    id currentItem = [news objectAtIndex:indexPath.row];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NewsViewController *newsVC = [storyboard instantiateViewControllerWithIdentifier:@"NewsViewController"];
     
    if (newsVC != nil) {
        newsVC.titleText = [currentItem valueForKey:@"title"];
        newsVC.descriptionText = [currentItem valueForKey:@"description"];
        newsVC.publishedAt = [currentItem valueForKey:@"publishedAt"];
        newsVC.urlToImage = [currentItem valueForKey:@"urlToImage"];
        [self.navigationController pushViewController:newsVC animated:YES];
    }      
    
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
   
    NSString *searchText = searchController.searchBar.text;
    
    if (searchText == nil || searchText.length == 0) {
        filtering = false;
        
    } else {
        NSMutableArray *results = [[NSMutableArray alloc] init];
        NSLocale *locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
        
        for (id item in news)
        {
            if ([[item valueForKey:@"title"] rangeOfString:[searchText lowercaseStringWithLocale:locale]].location != NSNotFound) [results addObject:item];
        }
      
        searchResults = results;
        filtering = true;
    }
    [self.tableView reloadData];
}
 
@end
