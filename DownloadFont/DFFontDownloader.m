//
//  DFFontDownloader.m
//  DownloadFont
//
//  Created by kishikawa katsumi on 2013/10/27.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "DFFontDownloader.h"
#import <CoreText/CoreText.h>

@implementation DFFontDownloader

- (void)downloadFontNamed:(NSString *)fontName
{
    if (!fontName) {
        return;
    }
    
    NSDictionary *attributes = @{(id)kCTFontNameAttribute: fontName};
    
	CTFontDescriptorRef fontDescriptor = CTFontDescriptorCreateWithAttributes((__bridge CFDictionaryRef)attributes);
    NSArray *fontDescriptors = @[(__bridge id)fontDescriptor];
    CFRelease(fontDescriptor);
    
	__block BOOL errorDuringDownload = NO;
	
    CTFontDescriptorMatchFontDescriptorsWithProgressHandler((__bridge CFArrayRef)fontDescriptors, NULL, ^bool(CTFontDescriptorMatchingState state, CFDictionaryRef progressParameter) {
        NSDictionary *parameter = (__bridge NSDictionary *)progressParameter;
		double progressValue = [parameter[(id)kCTFontDescriptorMatchingPercentage] doubleValue];
		
		if (state == kCTFontDescriptorMatchingDidBegin) {
			dispatch_async( dispatch_get_main_queue(), ^ {
                if ([self.delegate respondsToSelector:@selector(fontDownloaderDidBegin:fontName:)]) {
                    [self.delegate fontDownloaderDidBegin:self fontName:fontName];
                }
			});
		} else if (state == kCTFontDescriptorMatchingDidFinish) {
			dispatch_async( dispatch_get_main_queue(), ^ {
                UIFont *font = [UIFont fontWithName:fontName size:1.0f];
                if (font) {
                    if ([self.delegate respondsToSelector:@selector(fontDownloaderDidFinish:fontName:)]) {
                        [self.delegate fontDownloaderDidFinish:self fontName:fontName];
                    }
                } else {
                    if ([self.delegate respondsToSelector:@selector(fontDownloader:didFailWithError:fontName:)]) {
                        [self.delegate fontDownloader:self didFailWithError:nil fontName:fontName];
                    }
                }
			});
		} else if (state == kCTFontDescriptorMatchingWillBeginDownloading) {
			dispatch_async( dispatch_get_main_queue(), ^ {
                if ([self.delegate respondsToSelector:@selector(fontDownloader:progress:fontName:)]) {
                    [self.delegate fontDownloader:self progress:0.0f fontName:fontName];
                }
			});
		} else if (state == kCTFontDescriptorMatchingDownloading) {
			dispatch_async( dispatch_get_main_queue(), ^ {
                if ([self.delegate respondsToSelector:@selector(fontDownloader:progress:fontName:)]) {
                    [self.delegate fontDownloader:self progress:progressValue / 100.0 fontName:fontName];
                }
			});
		} else if (state == kCTFontDescriptorMatchingDidFinishDownloading) {
            if ([self.delegate respondsToSelector:@selector(fontDownloader:progress:fontName:)]) {
                [self.delegate fontDownloader:self progress:1.0f fontName:fontName];
            }
		} else if (state == kCTFontDescriptorMatchingDidFailWithError) {
            
            if (!errorDuringDownload) {
                NSError *error = parameter[(id)kCTFontDescriptorMatchingError];
                errorDuringDownload = YES;
                
                dispatch_async( dispatch_get_main_queue(), ^ {
                    if ([self.delegate respondsToSelector:@selector(fontDownloader:didFailWithError:fontName:)]) {
                        [self.delegate fontDownloader:self didFailWithError:error fontName:fontName];
                    }
                });
            }
		}
        
		return (bool)YES;
    });
}

- (void)loadDownloadedFontNamed:(NSString *)fontName
{
    if (!fontName) {
        return;
    }
    
    NSDictionary *attributes = @{(id)kCTFontNameAttribute: fontName};
    
	CTFontDescriptorRef fontDescriptor = CTFontDescriptorCreateWithAttributes((__bridge CFDictionaryRef)attributes);
    NSArray *fontDescriptors = @[(__bridge id)fontDescriptor];
    CFRelease(fontDescriptor);
    
    CTFontDescriptorMatchFontDescriptorsWithProgressHandler((__bridge CFArrayRef)fontDescriptors, NULL, ^bool(CTFontDescriptorMatchingState state, CFDictionaryRef progressParameter) {
        if (state == kCTFontDescriptorMatchingDidFinish) {
			dispatch_async( dispatch_get_main_queue(), ^ {
                UIFont *font = [UIFont fontWithName:fontName size:1.0f];
                if (font) {
                    NSLog(@"%@", @"kCTFontDescriptorMatchingDidFinish");
                    if ([self.delegate respondsToSelector:@selector(fontDownloaderDidFinish:fontName:)]) {
                        [self.delegate fontDownloaderDidFinish:self fontName:fontName];
                    }
                }
			});
		} else if (state == kCTFontDescriptorMatchingWillBeginDownloading) {
            NSLog(@"%@", @"kCTFontDescriptorMatchingWillBeginDownloading");
            return (bool)NO;
		}
        
		return (bool)YES;
    });
}

@end
