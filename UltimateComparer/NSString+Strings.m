//
//  NSString+Strings.m
//  UltimateComparer
//
//  Created by 徐 磊 on 13-9-5.
//  Copyright (c) 2013年 free. All rights reserved.
//

#import "NSString+Strings.h"

enum {
    whiteBG = 0,
    pinkRedBG = 1,
    greyBG = 2,
};

@implementation NSString (Strings)

- (NSAttributedString *)changeStringBackgroundColorTo:(NSInteger)color {
    
    NSString *result = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSDictionary *attrGB;
    
    if (color == pinkRedBG) {
        attrGB = @{NSBackgroundColorAttributeName: [NSColor colorWithCalibratedRed:0.973 green:0.624 blue:0.624 alpha:1.0]};
    } else if (color == greyBG) {
        attrGB = @{NSBackgroundColorAttributeName: [NSColor colorWithCalibratedRed:0.776 green:0.776 blue:0.776 alpha:1.0]};
    } else {
        attrGB = @{NSBackgroundColorAttributeName: [NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:1.0]};
    }
    
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:result attributes:attrGB];
    
    NSRange nonspaceRange = [self rangeOfString:result options:NSLiteralSearch range:NSMakeRange(0, self.length)];
    
    NSMutableAttributedString *mStr = [[NSMutableAttributedString alloc] initWithString:self];
    [mStr deleteCharactersInRange:nonspaceRange];
    [mStr appendAttributedString:attrStr];
    
    return mStr;
}

- (NSArray *)indexOfEachLineBreak {
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    [result addObject:[NSNumber numberWithInteger:0]];
    
    NSString *stringInRange = [self substringWithRange:NSMakeRange(0, self.length)];
    unsigned long numberOfLines, index, stringLength = stringInRange.length;
    for (index = 0, numberOfLines = 0; index < stringLength; numberOfLines++) {
        index = NSMaxRange([stringInRange lineRangeForRange:NSMakeRange(index, 0)]);
        [result addObject:[NSNumber numberWithLong:index]];
    }
    return result;
}

- (NSArray *)enumerateWordsInString {
    
    NSString *specialCharacterString = @"!~`@#$%^&*-+();:={}[],.<>?\\/\"\'";
    NSCharacterSet *specialCharacterSet = [NSCharacterSet
                                           characterSetWithCharactersInString:specialCharacterString];

    
    NSString *str = [self stringByTrimmingCharactersInSet:specialCharacterSet];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    [str enumerateSubstringsInRange:NSMakeRange(0, str.length)
                                   options:NSStringEnumerationByWords | NSStringEnumerationLocalized
                                usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                    [result addObject:substring];
                                }
    ];
    
    return [NSArray arrayWithArray:result];
}

- (float)percentageOfSimilarityTo:(NSString *)str {
    
    NSMutableArray *myArray = [[NSMutableArray alloc] initWithArray:[self enumerateWordsInString]];
    NSMutableArray *cpdArray = [[NSMutableArray alloc] initWithArray:[str enumerateWordsInString]];
    
    long maxLength = MAX([myArray count], [cpdArray count]);
    
    NSInteger counts = 0;
    
    for (id myObj in myArray) {
        if ([cpdArray containsObject:myObj]) {
            counts++;
            [cpdArray removeObject:myObj];
        }
    }
    
    if (maxLength == 0) {
        return 1;
    } else {
        return (float)counts / maxLength;
    }
    
}

- (NSInteger)actualHeightOfLineInTextView:(NSTextView *)textView {

    NSRect rect = [self boundingRectWithSize:textView.bounds.size options:NSStringDrawingUsesLineFragmentOrigin attributes:nil];
    return rect.size.height/15 - 1;
}

- (BOOL)hasNonSpaceCharacter {
    NSString *str = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([str isEqualToString:@""]) {
        return NO;
    } else if ([self rangeOfString:str options:NSLiteralSearch range:NSMakeRange(0, self.length)].location != NSNotFound) {
        return YES;
    } else {
        return NO;
    }
}


@end
