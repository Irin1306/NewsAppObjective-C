//
//  NewsViewController.h
//  NewsApp
//
//  Created by USER on 24/10/2018.
//  Copyright © 2018 My. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsViewController : UIViewController 
@property (nonatomic, retain) NSString *titleText;
@property (nonatomic, retain) NSString *descriptionText;
@property (nonatomic, retain) NSString *publishedAt;
@property (nonatomic, retain) NSString *urlToImage;

@property (weak, nonatomic) IBOutlet UIImageView *newsImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *publishedTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionTextLabel;

@end
