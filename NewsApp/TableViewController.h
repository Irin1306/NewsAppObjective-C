//
//  TableViewController.h
//  NewsApp
//
//  Created by USER on 22/10/2018.
//  Copyright © 2018 My. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCell.h"


extern NSString *urlForDownload;
extern NSString *downloadedFilePath;


@interface TableViewController : UITableViewController<UISearchResultsUpdating>

@end

 
