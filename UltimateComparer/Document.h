//
//  Document.h
//  UltimateComparer
//
//  Created by 徐 磊 on 13-8-29.
//  Copyright (c) 2013年 free. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NoodleLineNumberMarker.h"
#import "SynchroScrollView.h"

@class NoodleLineNumberView;
@class MarkerLine1;
@class MarkerLine2;

@interface Document : NSDocument <NSApplicationDelegate, NSTextViewDelegate> {
    NoodleLineNumberView *lineNumView1;
    NoodleLineNumberView *lineNumView2;
    
    MarkerLine1 *markerLine1;
    MarkerLine2 *markerLine2;
    
    NSInteger dragLine;
    NSInteger toLine;

    NSImage *markerImage;
    
}

@property (copy) NSString *path1;
@property (copy) NSString *path2;
@property (copy) NSString *date1;
@property (copy) NSString *date2;
@property (copy) NSString *size1;
@property (copy) NSString *size2;
@property long long line1;
@property long long line2;

@property NSInteger dragLine;
@property NSInteger toLine;

@property (copy) NSMutableArray *diffArray;

@property (copy) NSString *file1Str;
@property (copy) NSString *file2Str;

@property NSInteger totalLength;

@property (assign) IBOutlet NSWindow *windowMain;

@property (weak) IBOutlet NSToolbarItem *toolbarFile1;
@property (weak) IBOutlet NSToolbarItem *toolbarFile2;

@property IBOutlet NSSplitView *splitBigView;
@property IBOutlet NSScrollView *scrollView1;
@property IBOutlet NSScrollView *scrollView2;
@property IBOutlet NSTextView *textView1;
@property IBOutlet NSTextView *textView2;
@property IBOutlet NSTextView *textViewSmall1;
@property IBOutlet NSTextView *textViewSmall2;

@property IBOutlet NSTextField *labelFileAttr1;
@property IBOutlet NSTextField *labelFileAttr2;
@property IBOutlet NSTextField *labelFilePath1;
@property IBOutlet NSTextField *labelFilePath2;

- (IBAction)toolbarFile1Act:(id)sender;
- (IBAction)toolbarFile2Act:(id)sender;

- (void)afterGetFilePath:(NSString *)file forArea:(int)area;
- (NSMutableArray *)file1Array;
- (NSMutableArray *)file2Array;
- (NSArray *)indexes1;
- (NSArray *)indexes2;
- (NSMutableDictionary *)diffRange1;
- (NSMutableDictionary *)diffRange2;
@end

