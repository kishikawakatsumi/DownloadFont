//
//  DFFontsViewController.h
//  DownloadFont
//
//  Created by kishikawa katsumi on 2013/10/27.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DFFontsViewController : UITableViewController

@property (nonatomic, weak) id delegate;

@end

@protocol DFFontsViewControllerDelegate <NSObject>

- (void)fontsViewController:(DFFontsViewController *)controller didChangeFont:(UIFont *)font;

@end