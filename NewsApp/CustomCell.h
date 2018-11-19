//
//  CustomCell.h
//  NewsApp
//
//  Created by USER on 22/10/2018.
//  Copyright © 2018 My. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell  

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *publishedLabel;
@property (strong, nonatomic) IBOutlet UIImageView *cellImageView;

@end



