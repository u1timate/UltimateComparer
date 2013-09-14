//
//  NSTextView+TextMod.h
//  UltimateComparer
//
//  Created by 徐 磊 on 13-9-5.
//  Copyright (c) 2013年 free. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSTextView (TextMod)

- (NSArray *)stringOfEachParagraph;
- (NSInteger)lineNumOfCursor;
- (NSArray *)indexOfEachLineNum;
- (NSInteger)countRows;
- (NSInteger)actualHeightOfLine:(NSRange)tRange;
- (void)modLineHeightOfRange:(NSRange)modRange template:(NSRange)templateRange inTextView:(NSTextView *)textView;
- (void)modLineHeightOfRange:(NSRange)modRange targetString:(NSString *)str;
- (NSInteger)actualHeightOfString:(NSString *)str;
@end
