//
//  NSTextView+TextMod.m
//  UltimateComparer
//
//  Created by 徐 磊 on 13-9-5.
//  Copyright (c) 2013年 free. All rights reserved.
//

#import "NSTextView+TextMod.h"

@implementation NSTextView (TextMod)

- (NSInteger)lineNumOfCursor {
    NSRange range = NSMakeRange(0, [self selectedRange].location);
    NSString *stringInRange = [self.string substringWithRange:range];
    unsigned long numberOfLines, index, stringLength = stringInRange.length;
    for (index = 0, numberOfLines = 0; index < stringLength; numberOfLines++) {
        index = NSMaxRange([stringInRange lineRangeForRange:NSMakeRange(index, 0)]);
    }
    return numberOfLines;
}

- (NSArray *)indexOfEachLineNum {
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    [result addObject:[NSNumber numberWithInteger:0]];
    
    NSString *stringInRange = [self.string substringWithRange:NSMakeRange(0, self.string.length)];
    unsigned long numberOfLines, index, stringLength = stringInRange.length;
    for (index = 0, numberOfLines = 0; index < stringLength; numberOfLines++) {
        index = NSMaxRange([stringInRange lineRangeForRange:NSMakeRange(index, 0)]);
        [result addObject:[NSNumber numberWithLong:index]];
    }
    return result;
}

- (NSArray *)stringOfEachParagraph {
    unsigned long length = [self.string length];
    unsigned long paraStart = 0, paraEnd = 0, contentsEnd = 0;
    NSMutableArray *array = [NSMutableArray array];
    NSRange currentRange;
    while (paraEnd < length) {
        [self.string getParagraphStart:&paraStart end:&paraEnd
                      contentsEnd:&contentsEnd forRange:NSMakeRange(paraEnd, 0)];
        currentRange = NSMakeRange(paraStart, contentsEnd - paraStart);
        [array addObject:[self.string substringWithRange:currentRange]];
    }
    return array;
}

- (NSInteger)countRows {
    NSString *stringInRange = [self.string substringWithRange:NSMakeRange(0, self.string.length)];
    unsigned long numberOfLines, index, stringLength = stringInRange.length;
    for (index = 0, numberOfLines = 0; index < stringLength; numberOfLines++) {
        index = NSMaxRange([stringInRange lineRangeForRange:NSMakeRange(index, 0)]);
    }
    return numberOfLines;
}

- (NSInteger)actualHeightOfLine:(NSRange)tRange {

    NSString *stringInRange = [self.textStorage.mutableString.copy substringWithRange:tRange];
    NSRect rect = [stringInRange boundingRectWithSize:self.bounds.size options:NSStringDrawingUsesLineFragmentOrigin attributes:nil];
    return rect.size.height/15 - 1;
    
}

- (void)modLineHeightOfRange:(NSRange)modRange template:(NSRange)templateRange inTextView:(NSTextView *)textView {
    
    NSInteger actHeightOfTemplate = [textView actualHeightOfLine:templateRange];
    NSInteger actHeightOfMod = [self actualHeightOfLine:modRange];
    
    NSInteger diffHeight = fabs(actHeightOfMod - actHeightOfTemplate);
    
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    
    [paraStyle setParagraphSpacing:15 * diffHeight];
    NSDictionary *attrDict = @{NSParagraphStyleAttributeName: [paraStyle copy]};
    
    NSString *modString = [self.string substringWithRange:modRange];
    NSAttributedString *modedStrings = [[NSAttributedString alloc] initWithString:modString attributes:attrDict];
    
    [self setSelectedRange:modRange];
    [self insertText:modedStrings];
    [self setSelectedRange:NSMakeRange(modRange.location + modRange.length - 1, 0)];
}

- (void)modLineHeightOfRange:(NSRange)modRange targetString:(NSString *)str {
    NSInteger actHeightOfGivenString = [self actualHeightOfString:str];
    NSInteger actHeightOfMod = [self actualHeightOfLine:modRange];
    
    
    NSInteger diffHeight = fabs(actHeightOfMod - actHeightOfGivenString);
    
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    
    [paraStyle setParagraphSpacing:15 * diffHeight];
    NSDictionary *attrDict = @{NSParagraphStyleAttributeName: [paraStyle copy]};
    
    NSString *modString = [self.string substringWithRange:modRange];
    NSAttributedString *modedStrings = [[NSAttributedString alloc] initWithString:modString attributes:attrDict];
    
    [self setSelectedRange:modRange];
    [self insertText:modedStrings];
    [self setSelectedRange:NSMakeRange(modRange.location + modRange.length - 1, 0)];
}

- (NSInteger)actualHeightOfString:(NSString *)str {
    NSRect rect = [str boundingRectWithSize:self.bounds.size options:NSStringDrawingUsesLineFragmentOrigin attributes:nil];
    return rect.size.height/15;
}

- (NSRange)cursorRange {
    return NSMakeRange(self.selectedRange.location, 0);
}

@end
