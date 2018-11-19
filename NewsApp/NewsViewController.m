//
//  NewsViewController.m
//  NewsApp
//
//  Created by USER on 24/10/2018.
//  Copyright © 2018 My. All rights reserved.
//

#import "NewsViewController.h"

 
@implementation NewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(iOS 11.0, *)) {
        NSLog(@"iOS 11.0");
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    
    if(self.titleText != nil) {
        self.titleTextLabel.text = [NSString stringWithFormat: @"%@", self.titleText];
    }
    if(self.descriptionText != nil) {
        self.descriptionTextLabel.text = [NSString stringWithFormat: @"\t%@", self.descriptionText];
    }
    
    if(self.urlToImage != nil) {
        NSURL *url = [NSURL URLWithString: self.urlToImage];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *img = [[UIImage alloc] initWithData:data];
        self.newsImageView.image = img;
    }
    
    if(self.publishedAt != nil) {        
        NSString *substr = [self.publishedAt substringToIndex:10];
        self.publishedTextLabel.text = [NSString stringWithFormat: @"%@", substr];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
