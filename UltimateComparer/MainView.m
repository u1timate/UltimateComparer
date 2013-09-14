//
//  MainView.m
//  UltimateComparer
//
//  Created by 徐 磊 on 13-9-13.
//  Copyright (c) 2013年 free. All rights reserved.
//

#import "MainView.h"
#import "NSString+Strings.h"
#import "NSTextView+TextMod.h"
#import "Document.h"

@implementation MainView

- (void)awakeFromNib {
    document = [Document alloc];
}

- (void)drawRect:(NSRect)dirtyRect
{
    if ([self inLiveResize]) {
        if (document.file1Array.count != 0 && document.file2Array.count != 0 && document.indexes1.count != 0 && document.indexes2.count != 0) {
            if (document.file1Array.count == document.file2Array.count) {
                for (long i = 1; i < document.file1Array.count; i++) {
                    NSRange range1 = NSMakeRange([document.indexes1[i-1] longValue], [document.indexes1[i] longValue] - [document.indexes1[i-1] longValue]);
                    NSRange range2 = NSMakeRange([document.indexes2[i-1] longValue], [document.indexes2[i] longValue] - [document.indexes2[i-1] longValue]);
                    
                    NSString *subStr1 = [_textView1inMain.string substringWithRange:range1];
                    NSString *subStr2 = [_textView2inMain.string substringWithRange:range2];
                    
                    if (subStr1.length < subStr2.length) {
                        [_textView1inMain modLineHeightOfRange:range1 template:range2 inTextView:_textView2inMain];
                    } else if (subStr1.length > subStr2.length) {
                        [_textView2inMain modLineHeightOfRange:range2 template:range1 inTextView:_textView1inMain];
                    }
                }
            } else {
                NSLog(@"Error Array Counting in Window Resizing");
            }
        }
    }
}

@end
