//
//  DFTextViewController.m
//  DownloadFont
//
//  Created by kishikawa katsumi on 2013/10/27.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "DFTextViewController.h"
#import "DFFontsViewController.h"

@interface DFTextViewController ()

@property (nonatomic, weak) IBOutlet UITextView *textView;

@end

@implementation DFTextViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DFFontsViewController *controller = segue.destinationViewController;
    controller.delegate = self;
}

- (void)fontsViewController:(DFFontsViewController *)controller didChangeFont:(UIFont *)font
{
    self.textView.font = font;
}

@end
