//
//  DFFontDownloader.h
//  DownloadFont
//
//  Created by kishikawa katsumi on 2013/10/27.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFFontDownloader : NSObject

@property (nonatomic, weak) id delegate;

- (void)downloadFontNamed:(NSString *)fontName;
- (void)registerDownloadedFontNamed:(NSString *)fontName;

@end

@protocol DFFontDownloaderDelegate

- (void)fontDownloaderDidBegin:(DFFontDownloader *)downloader fontName:(NSString *)fontName;;
- (void)fontDownloaderDidFinish:(DFFontDownloader *)downloader fontName:(NSString *)fontName;
- (void)fontDownloader:(DFFontDownloader *)downloader didFailWithError:(NSError *)error fontName:(NSString *)fontName;
- (void)fontDownloader:(DFFontDownloader *)downloader progress:(CGFloat)progress fontName:(NSString *)fontName;

@end
