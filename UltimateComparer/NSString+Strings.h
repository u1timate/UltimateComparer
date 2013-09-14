//
//  NSString+Strings.h
//  UltimateComparer
//
//  Created by 徐 磊 on 13-9-5.
//  Copyright (c) 2013年 free. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Strings)

- (NSArray *)indexOfEachLineBreak;
- (float)percentageOfSimilarityTo:(NSString *)str;
- (NSArray *)enumerateWordsInString;
- (NSInteger)actualHeightOfLineInTextView:(NSTextView *)textView;
- (BOOL)hasNonSpaceCharacter;
@end
