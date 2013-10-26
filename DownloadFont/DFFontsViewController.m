//
//  DFFontsViewController.m
//  DownloadFont
//
//  Created by kishikawa katsumi on 2013/10/27.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "DFFontsViewController.h"
#import "DFTextViewController.h"
#import "DFFontDownloader.h"
#import "FFCircularProgressView.h"
#import <CoreText/CoreText.h>

static NSString * const DFDownloadedFontsKey = @"DownloadedFonts";

void FontManagerRegisteredFontsChanged(CFNotificationCenterRef center,
                                       void *observer,
                                       CFStringRef name,
                                       const void *object,
                                       CFDictionaryRef userInfo)
{
    NSLog(@"%@", @"Registrered Font Changed");
    NSLog(@"%@", name);
    NSLog(@"%@", object);
    NSLog(@"%@", userInfo);
}

@interface DFFontsViewController ()

@property (nonatomic) NSArray *fontNames;
@property (nonatomic) DFFontDownloader *downloader;

@property (nonatomic, weak) DFTextViewController *textViewController;

@end

@implementation DFFontsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.fontNames = @[@"HiraKakuStdN-W8", @"HiraMaruProN-W4", @"YuGo-Medium", @"YuGo-Bold", @"YuMin-Medium", @"YuMin-Demibold"];
    self.downloader = [[DFFontDownloader alloc] init];
    self.downloader.delegate = self;
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, FontManagerRegisteredFontsChanged, kCTFontManagerRegisteredFontsChangedNotification, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    
    NSDictionary *downloadedFonts = [[NSUserDefaults standardUserDefaults] valueForKey:DFDownloadedFontsKey];
    for (NSString *downloadedFontName in downloadedFonts.allKeys) {
        [self.downloader registerDownloadedFontNamed:downloadedFontName];
    }
}

- (BOOL)isAvailableFontNamed:(NSString *)fontName
{
    UIFont *font = [UIFont fontWithName:fontName size:1.0f];
    return font && ([font.fontName compare:fontName] == NSOrderedSame || [font.familyName compare:fontName] == NSOrderedSame);
}

- (void)notifyFontChanged:(NSString *)fontName
{
    UIFont *font = [UIFont fontWithName:fontName size:18.0f];
    
    if ([self.delegate respondsToSelector:@selector(fontsViewController:didChangeFont:)]) {
        [self.delegate fontsViewController:self didChangeFont:font];
    }
}

#pragma mark -

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *fontName = self.fontNames[indexPath.row];
    if ([self isAvailableFontNamed:fontName]) {
        cell.accessoryView = nil;
    } else {
        cell.accessoryView = [[FFCircularProgressView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 24.0f, 24.0f)];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *fontName = self.fontNames[indexPath.row];
    
    if ([self isAvailableFontNamed:fontName]) {
        [self notifyFontChanged:fontName];
    } else {
        [self.downloader downloadFontNamed:fontName];
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        FFCircularProgressView *progressView = (FFCircularProgressView *)cell.accessoryView;
        [progressView startSpinProgressBackgroundLayer];
    }
}

#pragma mark -

- (void)fontDownloaderDidBegin:(DFFontDownloader *)downloader fontName:(NSString *)fontName
{
    NSLog(@"Begin download: %@", fontName);
}

- (void)fontDownloaderDidFinish:(DFFontDownloader *)downloader fontName:(NSString *)fontName
{
    NSLog(@"Finished download: %@", fontName);
    
    NSInteger index = [self.fontNames indexOfObject:fontName];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    cell.accessoryView = nil;
    
    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
    if (indexPath) {
        NSString *selectedFontName = self.fontNames[indexPath.row];
        [self notifyFontChanged:selectedFontName];
    }
    
    NSMutableDictionary *downloadedFonts = [[[NSUserDefaults standardUserDefaults] valueForKey:DFDownloadedFontsKey] mutableCopy];
    if (!downloadedFonts) {
        downloadedFonts = [[NSMutableDictionary alloc] init];
    }
    
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)fontName, 0.0f, NULL);
    CFStringRef fontURL = CTFontCopyAttribute(fontRef, kCTFontURLAttribute);
    NSLog(@"Font URL: %@", (__bridge NSURL*)(fontURL));
    downloadedFonts[fontName] = ((__bridge NSURL *)fontURL).absoluteString;
    CFRelease(fontURL);
    CFRelease(fontRef);
    
    [[NSUserDefaults standardUserDefaults] setObject:downloadedFonts forKey:DFDownloadedFontsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)fontDownloader:(DFFontDownloader *)downloader didFailWithError:(NSError *)error fontName:(NSString *)fontName
{
    NSLog(@"Failed download: %@", fontName);
    
    NSInteger index = [self.fontNames indexOfObject:fontName];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
    FFCircularProgressView *progressView = (FFCircularProgressView *)cell.accessoryView;
    progressView.progress = 0.0f;
}

- (void)fontDownloader:(DFFontDownloader *)downloader progress:(CGFloat)progress fontName:(NSString *)fontName
{
    NSLog(@"Progress: %@ %f", fontName, progress);

    NSInteger index = [self.fontNames indexOfObject:fontName];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
    FFCircularProgressView *progressView = (FFCircularProgressView *)cell.accessoryView;
    progressView.progress = progress;
    
    if (progress > 0.0) {
        [progressView stopSpinProgressBackgroundLayer];
    }
}

@end
