//
//  Document.m
//  UltimateComparer
//
//  Created by 徐 磊 on 13-8-29.
//  Copyright (c) 2013年 free. All rights reserved.
//

#import "Document.h"
#import "EncodingName.h"
#import "NoodleLineNumberView.h"
#import "NoodleLineNumberMarker.h"
#import "MarkerLine1.h"
#import "MarkerLine2.h"
#import "NSString+Strings.h"
#import "NSTextView+TextMod.h"
#import "TextView1.h"
#import "TextView2.h"
#import "NSMutableArray+MutArray.h"

#define CORNER_RADIUS	3.0
#define MARKER_HEIGHT	13.0

static BOOL isInitialize = YES;
static NSMutableArray *_file1Array;
static NSMutableArray *_file2Array;
static NSArray *_indexes1;
static NSArray *_indexes2;
static NSMutableDictionary *diffRange1;
static NSMutableDictionary *diffRange2;

enum {
    whiteBG = 0,
    pinkRedBG = 1,
    greyBG = 2,
};

@implementation Document {
    NSUInteger textChangeType;
    NSRange oldRange;
    NSInteger lengthChange;
    
    
    NSInteger index;
    NSInteger counter;
    NSInteger counterOfFlag;
    NSInteger subIndex;
    
    NSMutableArray *tempArray1;
    NSMutableArray *tempArray2;
    
    NSMutableArray *resultCondingArray1;
    NSMutableArray *resultCondingArray2;
    
    NSMutableArray *codingBlocks1;
    NSMutableArray *codingBlocks2;
    NSMutableArray *codingBlocksFlag1;
    NSMutableArray *codingBlocksFlag2;
    NSMutableArray *codingAdditional1;
    NSMutableArray *codingAdditional2;
    
    NSArray *codingEnd1;
    NSArray *codingEnd2;
    
    NSNotificationCenter *nc;
}

@synthesize dragLine;
@synthesize toLine;

- (id)init
{
    self = [super init];
    if (self) {
        index = 0;
        subIndex = 0;
        counter = 0;
        counterOfFlag = 0;
        nc = [NSNotificationCenter defaultCenter];
        
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationCenterForDocument:) name:@"locDone1" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationCenterForDocument:) name:@"locDone2" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationCenterForDocument:) name:@"file1" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationCenterForDocument:) name:@"file2" object:nil];
}

- (void)awakeFromNib {
    
    lineNumView1 = [[MarkerLine1 alloc] initWithScrollView:_scrollView1];
    [_scrollView1 setVerticalRulerView:lineNumView1];
    [_scrollView1 setHasHorizontalRuler:NO];
    [_scrollView1 setHasVerticalRuler:YES];
    [_scrollView1 setRulersVisible:YES];
	
    
    [_textView1 setFont:[NSFont userFixedPitchFontOfSize:[NSFont smallSystemFontSize]]];
    
    lineNumView2 = [[MarkerLine2 alloc] initWithScrollView:_scrollView2];
    [_scrollView2 setVerticalRulerView:lineNumView2];
    [_scrollView2 setHasHorizontalRuler:NO];
    [_scrollView2 setHasVerticalRuler:YES];
    [_scrollView2 setRulersVisible:YES];
	
    [_textView2 setFont:[NSFont userFixedPitchFontOfSize:[NSFont smallSystemFontSize]]];
    
    [_textViewSmall1 setSelectable:NO];
    [_textViewSmall2 setSelectable:NO];
    
}

- (void)notificationCenterForDocument:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"locDone1"])
    {
        NSDictionary* userInfo = [notification userInfo];
        
        if ([userInfo[@"dragLineRaw"] integerValue] != 0 && [userInfo[@"toLineRaw"] integerValue] != 0) {
            self.dragLine = [userInfo[@"dragLineRaw"] integerValue];
            self.toLine = [userInfo[@"toLineRaw"] integerValue];
            if ([userInfo[@"button"] isEqualToString:@"left"]) {
                NSLog (@"Drag from line %ld to line %ld", dragLine, toLine);
            } else {
                NSLog(@"Replace left %ld to right %ld", dragLine, toLine);
            }
            [self replaceTextAtRow:toLine ofTextView:_textView2 withStringAtRow:dragLine ofTextView:_textView1];
        } else {
            NSLog(@"double click to select whole line");
        }
    } else if ([[notification name] isEqualToString:@"locDone2"]) {
        NSDictionary* userInfo = [notification userInfo];
        
        if ([userInfo[@"dragLineRaw"] integerValue] != 0 && [userInfo[@"toLineRaw"] integerValue] != 0) {
            self.dragLine = [userInfo[@"dragLineRaw"] integerValue];
            self.toLine = [userInfo[@"toLineRaw"] integerValue];
            if ([userInfo[@"button"] isEqualToString:@"left"]) {
                NSLog (@"Drag from line %ld to line %ld", dragLine, toLine);
            } else {
                NSLog(@"Replace left %ld to right %ld", dragLine, toLine);
            }
            [self replaceTextAtRow:toLine ofTextView:_textView1 withStringAtRow:dragLine ofTextView:_textView2];
        } else {
            NSLog(@"double click to select whole line");
        }
    } else if ([[notification name] isEqualToString:@"file1"]) {
        NSDictionary* userInfo = [notification userInfo];
        
        if ([userInfo[@"file1"] isNotEqualTo:@""]) {
            _file1Array = [[NSMutableArray alloc] initWithArray:userInfo[@"file1"]];
            [self diffTwo];
        }
    } else if ([[notification name] isEqualToString:@"file2"]) {
        NSDictionary* userInfo = [notification userInfo];
        
        
    }
}

- (void)textDidChange:(NSNotification *)notification {
    if (!isInitialize) {
        isInitialize = YES;
        if ([[notification object] isEqualTo:_textView1]) {
            NSLog(@"text1 changed");
            NSRange cursor = [_textView1 cursorRange];
            [self setDiffColor];
            [_textView1 setSelectedRange:cursor];
            [_textView2 setNeedsDisplay:YES];
            [_textView1 setNeedsDisplay:YES];
        } else if ([[notification object] isEqualTo:_textView2]) {
            NSLog(@"text2 changed");
            NSRange cursor = [_textView2 cursorRange];
            [self setDiffColor];
            [_textView2 setSelectedRange:cursor];
            [_textView2 setNeedsDisplay:YES];
            [_textView1 setNeedsDisplay:YES];
        } else {
            NSLog(@"%@ changed", [notification object]);
        }
        isInitialize = NO;
    }
}

- (void)afterGetFilePath:(NSString *)file forArea:(int)area {
    if (area == 1) {
        
        _file1Str = [self stringWithContentOfFileAtPath:file];
        
        [_textView1 readRTFDFromFile:file];
        
        [_labelFilePath1 setStringValue:file];
        NSDictionary *fileAttr = [NSDictionary dictionaryWithDictionary:[[NSFileManager defaultManager] attributesOfItemAtPath:file error:nil]];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        _date1 = [NSString stringWithString:[dateFormatter stringFromDate:[fileAttr valueForKey:NSFileModificationDate]]];
        _size1 = [NSString stringWithString:[self fileSizeTypeOf:(unsigned long long)[fileAttr valueForKey:NSFileSize]]];
        _line1 = [_textView1 countRows];

        NSMutableString *fileAttrStr = [NSMutableString stringWithString:_date1];
        [fileAttrStr appendFormat:@"   %@", _size1];
        [fileAttrStr appendFormat:@"   %lld lines", _line1];
        
        [_labelFileAttr1 setStringValue:fileAttrStr];
    } else if (area == 2) {
        
        _file2Str = [self stringWithContentOfFileAtPath:file];
        
        [_textView2 readRTFDFromFile:file];
        
        [_labelFilePath2 setStringValue:file];
        NSDictionary *fileAttr = [NSDictionary dictionaryWithDictionary:[[NSFileManager defaultManager] attributesOfItemAtPath:file error:nil]];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        _date2 = [NSString stringWithString:[dateFormatter stringFromDate:[fileAttr valueForKey:NSFileModificationDate]]];
        _size2 = [NSString stringWithString:[self fileSizeTypeOf:(unsigned long long)[fileAttr valueForKey:NSFileSize]]];
        _line2 = [_textView2 countRows];
        
        NSMutableString *fileAttrStr = [NSMutableString stringWithString:_date2];
        [fileAttrStr appendFormat:@"   %@", _size2];
        [fileAttrStr appendFormat:@"   %lld lines", _line2];
        
        [_labelFileAttr2 setStringValue:fileAttrStr];
    } else {
        NSLog(@"Error read file area");
    }
    if (_line1 != 0 && _line2 != 0) {
        [self diffTwo];
    }
}

- (IBAction)toolbarFile1Act:(id)sender {
    NSOpenPanel *openDlg = [NSOpenPanel openPanel];
    
    [openDlg setCanChooseFiles:YES];
    [openDlg setCanChooseDirectories:NO];
    [openDlg setCanCreateDirectories:NO];
    [openDlg setPrompt:NSLocalizedString(@"Select", @"Select")];
    void (^chooseFolderHandler)(NSInteger) = ^( NSInteger resultCode ) {
        if (resultCode == NSOKButton) {
            NSURL *currentPathURL = [openDlg URL];
            if (currentPathURL){
                NSString *currentPath = [currentPathURL path];
                if (currentPath) {
                    _path1 = [[NSString alloc] initWithUTF8String:currentPath.UTF8String];
                    [self afterGetFilePath:currentPath forArea:1];
                }
            }
        }
    };
    [openDlg beginSheetModalForWindow:_windowMain completionHandler:chooseFolderHandler];
    
}

- (IBAction)toolbarFile2Act:(id)sender {
    NSOpenPanel *openDlg = [NSOpenPanel openPanel];
    
    [openDlg setCanChooseFiles:YES];
    [openDlg setCanChooseDirectories:NO];
    [openDlg setCanCreateDirectories:NO];
    [openDlg setPrompt:NSLocalizedString(@"Select", @"Select")];
    void (^chooseFolderHandler)(NSInteger) = ^( NSInteger resultCode ) {
        if (resultCode == NSOKButton) {
            NSURL *currentPathURL = [openDlg URL];
            if (currentPathURL){
                NSString *currentPath = [currentPathURL path];
                if (currentPath) {
                    _path2 = [[NSString alloc] initWithUTF8String:currentPath.UTF8String];
                    [self afterGetFilePath:currentPath forArea:2];
                }
            }
        }
    };
    [openDlg beginSheetModalForWindow:_windowMain completionHandler:chooseFolderHandler];
    
}

- (NSMutableString *)stringWithContentOfFileAtPath:(NSString *)path {
    NSError *error;
    NSStringEncoding encoding;
    
    NSMutableString *str = [[NSMutableString alloc] initWithContentsOfFile:path usedEncoding:&encoding error:&error];
    
    EncodingName *encodingName = [[EncodingName alloc] init];
    [encodingName setEncodedNum:encoding];
    [encodingName returnEncoding:encoding];
    
    NSLog(@"File Used Encoding: %@", encodingName);
    
    return str;
}

- (void)diffArrayOfText {
    for (long j = index; j < MAX(_file1Array.count, _file2Array.count); j++) {
        
        if (index == MIN(_file1Array.count, _file2Array.count) && index != MAX(_file1Array.count, _file2Array.count)) {
            if (index == _file1Array.count) {
                while (index < _file2Array.count) {
                    [_file1Array addObject:@""];
                    index++;
                }
            } else if (index == _file2Array.count) {
                while (index < _file1Array.count) {
                    [_file2Array addObject:@""];
                    index++;
                }
            }
        } else {
            for (long i = index; i < _file2Array.count; i++) {
                if ([_file1Array[j] percentageOfSimilarityTo:_file2Array[i]] > 0.4) {
                    if (j == i) {
                        index++;
                        break;
                    } else {
                        for (long k = 0; k < fabs(i - j); k++) {
                            [_file1Array insertObject:@"" atIndex:j];
                        }
                        index += fabs(i - j) + 1;
                        [self diffArrayOfText];
                        return;
                    }
                } else if (i == _file2Array.count - 1){
                    [_file2Array insertObject:@"" atIndex:j];
                    index++;
                    [self diffArrayOfText];
                    return;
                } else {
                    NSLog(@"No match found at index: %ld", i);
                }
            }
        }
    }
}

- (void)diffArrayOfCoding {
    codingBlocks1 = [[_file1Array codingCombinedBeginAndEnd] mutableCopy];
    codingBlocks2 = [[_file2Array codingCombinedBeginAndEnd] mutableCopy];
    codingBlocksFlag1 = [[_file1Array codingBlockFlag] mutableCopy];
    codingBlocksFlag2 = [[_file2Array codingBlockFlag] mutableCopy];
    
    if ([codingBlocks1.lastObject longValue] < _file1Array.count) {
        codingAdditional1 = [[NSMutableArray alloc] init];
        NSInteger last = [codingBlocks1.lastObject longValue] + 1;
        while (last < _file1Array.count) {
            [codingAdditional1 addObject:_file1Array[last]];
            last++;
        }
    }
    
    if ([codingBlocks2.lastObject longValue] < _file2Array.count) {
        codingAdditional2 = [[NSMutableArray alloc] init];
        NSInteger last = [codingBlocks2.lastObject longValue] + 1;
        while (last < _file2Array.count) {
            [codingAdditional2 addObject:_file2Array[last]];
            last++;
        }
    }
    
    codingEnd1 = [_file1Array codingEndLocation];
    codingEnd2 = [_file2Array codingEndLocation];
    
    NSArray *codingBegin1 = [[_file1Array codingBeginLocation] mutableCopy];
    NSArray *codingBegin2 = [[_file2Array codingBeginLocation] mutableCopy];
    
    tempArray1 = [[NSMutableArray alloc] init];
    for (id obj in codingBegin1) {
        NSInteger i = [obj integerValue];
        [tempArray1 addObject:_file1Array[i]];
    }
    
    tempArray2 = [[NSMutableArray alloc] init];
    for (id obj in codingBegin2) {
        NSInteger i = [obj integerValue];
        [tempArray2 addObject:_file2Array[i]];
    }
    
    index = 0;
    
    [self diffTempArray];
    
    
    resultCondingArray1 = [[NSMutableArray alloc] initWithArray:tempArray1];
    resultCondingArray2 = [[NSMutableArray alloc] initWithArray:tempArray2];
    
    int count = 0;
    for (long i  = 0; i < tempArray1.count; i++) {
        if ([tempArray1[i] isEqualToString:@""]) {
            count++;
            if ([tempArray1[i+1] isNotEqualTo:@""]) {
                
                for (int j = 0; j < count; j++) {
                    NSInteger blockIndex = [codingBlocks1 indexOfObject:[NSNumber numberWithInteger:[_file1Array indexOfObject:tempArray1[i+1]]]];
                    [codingBlocksFlag1 insertObject:@"NULL" atIndex:blockIndex];
                    [codingBlocks1 insertObject:@"NULL" atIndex:blockIndex];
                }
                count = 0;
            }
        }
    }
    
    count = 0;
    for (long i  = 0; i < tempArray2.count; i++) {
        if ([tempArray2[i] isEqualToString:@""]) {
            count++;
            if ([tempArray2[i+1] isNotEqualTo:@""]) {
                
                for (int j = 0; j < count; j++) {
                    NSInteger blockIndex = [codingBlocks2 indexOfObject:[NSNumber numberWithInteger:[_file2Array indexOfObject:tempArray2[i+1]]]];
                    [codingBlocksFlag2 insertObject:@"NULL" atIndex:blockIndex];
                    [codingBlocks2 insertObject:@"NULL" atIndex:blockIndex];
                }
                count = 0;
            }
        }
    }
    
    index = 0;
    
    [self subDiffArrayOfCoding];
    
}

- (void)subDiffArrayOfCoding {
    
    if (resultCondingArray1.count == resultCondingArray2.count) {
        
        long i = subIndex;
        if (i < resultCondingArray1.count) {
            
            NSInteger a1, a2, b1, b2;
            
            tempArray1 = [[NSMutableArray alloc] init];
            if ([resultCondingArray1[i] isNotEqualTo:@""]) {
                a1 = [codingBlocks1 indexOfObject:[NSNumber numberWithInteger:[_file1Array indexOfObject:resultCondingArray1[i]]]];
                a2 = a1 + 1;
                if (a2 < codingBlocks1.count) {
                    for (long j = [codingBlocks1[a1] integerValue] + 1; j < [codingBlocks1[a2] integerValue]; j++) {
                        [tempArray1 addObject:_file1Array[j]];
                    }
                }
            }
            
            tempArray2 = [[NSMutableArray alloc] init];
            if ([resultCondingArray2[i] isNotEqualTo:@""]) {
                b1 = [codingBlocks2 indexOfObject:[NSNumber numberWithInteger:[_file2Array indexOfObject:resultCondingArray2[i]]]];
                b2 = b1 + 1;
                if (b2 < codingBlocks2.count) {
                    for (long j = [codingBlocks2[b1] integerValue] + 1; j < [codingBlocks2[b2] integerValue]; j++) {
                        [tempArray2 addObject:_file2Array[j]];
                    }
                }
            }
            
            
            if (tempArray1.count != 0 || tempArray2.count !=0) {
                index = 0;
                [self diffTempArray];
            }
            
            if (tempArray1.count != 0) {
                for (long j = tempArray1.count - 1; j >= 0; j--) {
                    [resultCondingArray1 insertObject:tempArray1[j] atIndex:i+1];
                    subIndex++;
                }
            }
            
            if (counter + 1 < codingBlocksFlag1.count) {
                if ([codingBlocksFlag1[counter + 1] isEqualToString:@"end"] ) {
                    NSLog(@"%@", [_file1Array objectAtIndex:[[codingBlocks1 objectAtIndex:counter+1] integerValue]]);
                    [resultCondingArray1 insertObject:[_file1Array objectAtIndex:[[codingBlocks1 objectAtIndex:counter+1] integerValue]] atIndex:subIndex+1];
                }
            } else {
                [resultCondingArray1 addObject:@""];
                subIndex++;
            }
            
            if (tempArray2.count != 0) {
                for (long j = tempArray2.count - 1; j >= 0; j--) {
                    [resultCondingArray2 insertObject:tempArray2[j] atIndex:i+1];
                }
            }
            
            if (counter + 1 < codingBlocksFlag2.count) {
                if ([codingBlocksFlag2[counter + 1] isEqualToString:@"end"]) {
                    NSLog(@"%@", [_file2Array objectAtIndex:[[codingBlocks2 objectAtIndex:counter+1] integerValue]]);
                    [resultCondingArray2 insertObject:[_file2Array objectAtIndex:[[codingBlocks2 objectAtIndex:counter+1] integerValue]] atIndex:subIndex+1];
                }
            } else {
                [resultCondingArray2 addObject:@""];
                if (counter + 1 < codingBlocksFlag1.count) {
                    subIndex++;
                }
            }
            
            counter++;
            
            subIndex++;
            
            [self subDiffArrayOfCoding];
            
            return;
            
        } else {
            tempArray1 = [[NSMutableArray alloc] initWithArray:codingAdditional1];
            tempArray2 = [[NSMutableArray alloc] initWithArray:codingAdditional2];
            
            [self diffTempArray];
            
            [resultCondingArray1 addObjectsFromArray:tempArray1];
            [resultCondingArray2 addObjectsFromArray:tempArray2];
            
            _file1Array = [[NSMutableArray alloc] initWithArray:resultCondingArray1];
            _file2Array = [[NSMutableArray alloc] initWithArray:resultCondingArray2];
            
        }
    } else {
        NSLog(@"error processing coding array");
    }
    
    
}

- (void)diffTempArray {
    for (long j = index; j < MAX(tempArray1.count, tempArray2.count); j++) {
        
        if (index == MIN(tempArray1.count, tempArray2.count) && index != MAX(tempArray1.count, tempArray2.count)) {
            if (index == tempArray1.count) {
                while (index < tempArray2.count) {
                    [tempArray1 addObject:@""];
                    index++;
                }
            } else if (index == tempArray2.count) {
                while (index < tempArray1.count) {
                    [tempArray2 addObject:@""];
                    index++;
                }
            } else {
                NSLog(@"Error Index Number");
            }
        } else {
            for (long i = index; i < tempArray2.count; i++) {
                if ([tempArray1[j] percentageOfSimilarityTo:tempArray2[i]] > 0.4) {
                    if (j == i) {
                        index++;
                        break;
                    } else {
                        for (long k = 0; k < fabs(i - j); k++) {
                            [tempArray1 insertObject:@"" atIndex:j];
                        }
                        index += fabs(i - j) + 1;
                        [self diffTempArray];
                        return;
                    }
                } else if (i == tempArray2.count - 1){
                    [tempArray2 insertObject:@"" atIndex:j];
                    index++;
                    [self diffTempArray];
                    return;
                } else {
                    NSLog(@"No match found at index: %ld", i);
                }
            }
        }
    }
}


- (NSArray *)getInsertIndex:(NSArray *)array {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (long i = 0; i < [array count]; i++) {
        if (![array[i] hasNonSpaceCharacter]) {
            long notNullIndex = 0;
            while (![array[i+notNullIndex] hasNonSpaceCharacter]) {
                if (i + notNullIndex < [array count] - 1) {
                    notNullIndex++;
                } else {
                    break;
                }
            }
            [result addObject:array[i+notNullIndex]];
        }
    }
    return [result copy];
}

- (void)diffTwo {
    isInitialize = YES;
    
    _file1Array = [[NSMutableArray alloc] initWithArray:[_file1Str componentsSeparatedByString:@"\n"]];
    _file2Array = [[NSMutableArray alloc] initWithArray:[_file2Str componentsSeparatedByString:@"\n"]];
    
    NSArray *blankArr1 = [[NSMutableArray alloc] initWithArray:[self getInsertIndex:_file1Array]];
    NSArray *blankArr2 = [[NSMutableArray alloc] initWithArray:[self getInsertIndex:_file2Array]];
    
    [_file1Array removeNilObj];
    [_file2Array removeNilObj];
    
    if ([_file1Array isCodingArray] && [_file2Array isCodingArray]) {
        [self diffArrayOfCoding];
    } else {
        [self diffArrayOfText];
    }
    
    for (id obj in blankArr1) {
        if ([obj isNotEqualTo:@""]) {
            NSInteger i = [_file1Array indexOfObject:obj];
            [_file2Array insertObject:@"" atIndex:i];
            [_file1Array insertObject:@"" atIndex:i];
        } else {
            [_file2Array addObject:@""];
            [_file1Array addObject:@""];
        }
    }
    
    for (id obj in blankArr2) {
        if ([obj isNotEqualTo:@""]) {
            NSInteger i = [_file2Array indexOfObject:obj];
            [_file1Array insertObject:@"" atIndex:i];
            [_file2Array insertObject:@"" atIndex:i];
        } else {
            [_file1Array addObject:@""];
            [_file2Array addObject:@""];
        }
    }
    
    if ([_file1Array count] == [_file2Array count]) {
        for (long i = 1; i < [_file1Array count]; i++) {
            if (![_file1Array[i] hasNonSpaceCharacter] && ![_file2Array[i] hasNonSpaceCharacter] && ![_file1Array[i - 1] hasNonSpaceCharacter] && ![_file2Array[i - 1] hasNonSpaceCharacter]) {
                
                [_file1Array removeObjectAtIndex:i];
                [_file2Array removeObjectAtIndex:i];
            }
        }
    } else {
        NSLog(@"Error Array Counting");
    }
    
    _file1Str = [_file1Array componentsJoinedByString:@"\n"];
    _file2Str = [_file2Array componentsJoinedByString:@"\n"];
    
    [_textView1 setString:_file1Str];
    [_textView2 setString:_file2Str];

    NSMutableDictionary *longerLine = [[NSMutableDictionary alloc] init];
    if (_file1Array.count == _file2Array.count) {
        for (long k = 0; k < _file1Array.count; k++) {
            id key = [NSNumber numberWithLong:k];
            if ([_file1Array[k] length] > [_file2Array[k] length]) {
                [longerLine setObject:_file1Array[k] forKey:key];
            } else {
                [longerLine setObject:_file2Array[k] forKey:key];
            }
        }
    }
    
    [_textViewSmall1 setFont:[self fontSizedForAreaSize:_textViewSmall1.bounds.size withString:_file1Str usingFont:[NSFont systemFontOfSize:13]]];
    [_textViewSmall2 setFont:[self fontSizedForAreaSize:_textViewSmall2.bounds.size withString:_file2Str usingFont:[NSFont systemFontOfSize:13]]];
    
    [_textViewSmall1 setString:_file1Str];
    [_textViewSmall2 setString:_file2Str];

    [self setDiffColor];
    
    isInitialize = NO;
    
}

- (void)setDiffColor {
    _indexes1 = [[NSArray alloc] initWithArray:[_textView1 indexOfEachLineNum]];
    _indexes2 = [[NSArray alloc] initWithArray:[_textView2 indexOfEachLineNum]];
    _file1Array = [[NSMutableArray alloc] initWithArray:[_textView1.string componentsSeparatedByString:@"\n"]];
    _file2Array = [[NSMutableArray alloc] initWithArray:[_textView2.string componentsSeparatedByString:@"\n"]];
    diffRange1 = [[NSMutableDictionary alloc] init];
    diffRange2 = [[NSMutableDictionary alloc] init];
    if (_file1Array.count == _file2Array.count) {
        for (long i = 1; i < _file1Array.count; i++) {
            NSRange range1 = NSMakeRange([_indexes1[i-1] longValue], [_indexes1[i] longValue] - [_indexes1[i-1] longValue]);
            NSRange range2 = NSMakeRange([_indexes2[i-1] longValue], [_indexes2[i] longValue] - [_indexes2[i-1] longValue]);
            
            NSString *subStr1 = [_textView1.string substringWithRange:range1];
            NSString *subStr2 = [_textView2.string substringWithRange:range2];
            
            id key = [NSNumber numberWithLong:i-1];
            
            if (![subStr1 isEqualToString:subStr2]) {
                [diffRange1 setObject:[NSValue valueWithRange:range1] forKey:key];
                [diffRange2 setObject:[NSValue valueWithRange:range2] forKey:key];
            }
            
            if (subStr1.length < subStr2.length) {
                [_textView1 modLineHeightOfRange:range1 template:range2 inTextView:_textView2];
            } else if (subStr1.length > subStr2.length) {
                [_textView2 modLineHeightOfRange:range2 template:range1 inTextView:_textView1];
            }
        }
    } else {
        NSLog(@"Error Array Counting");
    }
}

- (void)insertText:(id)text atIndex:(NSInteger)ind ofTextView:(NSTextView *)textView {

    NSRange r = NSMakeRange(ind, 0);
    
    [textView setSelectedRange:r];
    
    [textView insertText:text];
}

- (void)replaceTextAtRow:(NSInteger)row1 ofTextView:(NSTextView *)textView1 withStringAtRow:(NSInteger)row2 ofTextView:(NSTextView *)textView2 {

    NSRange r1; NSRange r2;
    
    if ([textView1 isEqualTo:_textView1]) {
        r1 = NSMakeRange([[_indexes1 objectAtIndex:row1 - 1] longValue], [[_indexes1 objectAtIndex:row1] longValue] - [[_indexes1 objectAtIndex:row1 - 1] longValue]);
        r2 = NSMakeRange([[_indexes2 objectAtIndex:row2 - 1] longValue], [[_indexes2 objectAtIndex:row2] longValue] - [[_indexes2 objectAtIndex:row2 - 1] longValue]);
    } else {
        r1 = NSMakeRange([[_indexes2 objectAtIndex:row1 - 1] longValue], [[_indexes2 objectAtIndex:row1] longValue] - [[_indexes2 objectAtIndex:row1 - 1] longValue]);
        r2 = NSMakeRange([[_indexes1 objectAtIndex:row2 - 1] longValue], [[_indexes1 objectAtIndex:row2] longValue] - [[_indexes1 objectAtIndex:row2 - 1] longValue]);
    }
    
    NSString *sub = [textView2.textStorage.mutableString.copy substringWithRange:r2];
    [textView1 setSelectedRange:r1];
    [textView1 insertText:sub];
    if ([textView1 isEqualTo:_textView1]) {
        _indexes1 = [[NSMutableArray alloc] initWithArray:[textView1 indexOfEachLineNum]];
    } else {
        _indexes2 = [[NSMutableArray alloc] initWithArray:[textView1 indexOfEachLineNum]];
    }
}

- (float)scaleToAspectFit:(CGSize)source into:(CGSize)into padding:(float)padding
{
    return MIN((into.width-padding) / source.width, (into.height-padding) / source.height);
}

- (NSFont*)fontSizedForAreaSize:(NSSize)size withString:(NSString*)string usingFont:(NSFont*)font;
{
    NSFont* sampleFont = [NSFont fontWithDescriptor:font.fontDescriptor size:12.];//use standard size to prevent error accrual
    CGSize sampleSize = [string sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:sampleFont, NSFontAttributeName, nil]];
    float scale = [self scaleToAspectFit:sampleSize into:size padding:10];
    if (scale < 0.3) {
        scale = 0.3;
    }
    return [NSFont fontWithDescriptor:font.fontDescriptor size:scale * sampleFont.pointSize];
}

- (NSString *)fileSizeTypeOf:(unsigned long long)size {
    int count = 0;
    while (size > 1000) {
        if (count > 5) {
            break;
        }
        size /= 1000;
        count++;
    }
    
    NSString *sizeType;
    
    switch (count) {
        case 0:
            sizeType = @"Bytes";
            break;
            
        case 1:
            sizeType = @"KB";
            break;
            
        case 2:
            sizeType = @"MB";
            break;
            
        case 3:
            sizeType = @"GB";
            break;
            
        case 4:
            sizeType = @"TB";
            break;
            
        case 5:
            sizeType = @"PB";
            break;
    }
    
    return [NSString stringWithFormat:@"%lld %@", size, sizeType];
}

- (NSMutableArray *)file1Array {
    return _file1Array;
}

- (NSMutableArray *)file2Array {
    return _file2Array;
}

- (NSArray *)indexes1 {
    return _indexes1;
}

- (NSArray *)indexes2 {
    return _indexes2;
}

- (NSMutableDictionary *)diffRange1 {
    return diffRange1;
}

- (NSMutableDictionary *)diffRange2 {
    return diffRange2;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"Document";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    if (outError) {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
    }
    
    _diffArray = [[NSMutableArray alloc] initWithObjects:@{@"file1": _textView1.textStorage.mutableString.copy, @"file2": _textView2.textStorage.mutableString.copy}, nil];
    
    if (_path1 != nil && _path2 != nil && _date1 != nil && _date2 != nil && _size1 != nil && _size2 != nil && _line1 != 0 && _line2 != 0) {
        [_diffArray addObject:@{@"path1": _path1, @"path2": _path2}];
        [_diffArray addObject:@{@"date1": _date1, @"date2": _date2}];
        [_diffArray addObject:@{@"size1": _size1, @"size2": _size2}];
        [_diffArray addObject:@{@"line1": [NSNumber numberWithLongLong:_line1], @"line2": [NSNumber numberWithLongLong:_line2]}];
    } else {
        [_diffArray addObject:@{@"path1": @"NULL File Path", @"path2": @"NULL File Path"}];
        [_diffArray addObject:@{@"date1": [NSDate date], @"date2": [NSDate date]}];
        [_diffArray addObject:@{@"size1": @"NULL File Size", @"size2": @"NULL File Size"}];
        [_diffArray addObject:@{@"line1": [NSNumber numberWithLongLong:[_textView1 countRows]], @"line2": [NSNumber numberWithLongLong:[_textView2 countRows]]}];
    }
    
    return [NSKeyedArchiver archivedDataWithRootObject:self.diffArray];
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
    if (outError) {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
    }
    [self setDiffArray:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
    
    _file1Str = [[_diffArray valueForKey:@"file1"] objectAtIndex:0];
    _file2Str = [[_diffArray valueForKey:@"file2"] objectAtIndex:0];
    
    _path1 = [[_diffArray valueForKey:@"path1"] objectAtIndex:1];
    _path2 = [[_diffArray valueForKey:@"path2"] objectAtIndex:1];
    _date1 = [[_diffArray valueForKey:@"date1"] objectAtIndex:2];
    _date2 = [[_diffArray valueForKey:@"date2"] objectAtIndex:2];
    _size1 = [[_diffArray valueForKey:@"size1"] objectAtIndex:3];
    _size2 = [[_diffArray valueForKey:@"size2"] objectAtIndex:3];
    
    _line1 = [[[_diffArray valueForKey:@"line1"] objectAtIndex:4] longLongValue];
    _line2 = [[[_diffArray valueForKey:@"line2"] objectAtIndex:4] longLongValue];
    
    [NSTimer scheduledTimerWithTimeInterval:0.1
                                     target:self
                                   selector:@selector(loadViewContents)
                                   userInfo:nil
                                    repeats:NO];
    
    return YES;
}

- (void)loadViewContents {
    [_labelFilePath1 setStringValue:_path1];
    [_labelFilePath2 setStringValue:_path2];
    [_labelFileAttr1 setStringValue:[NSString stringWithFormat:@"%@   %@   %lld lines", _date1, _size1, _line1]];
    [_labelFileAttr2 setStringValue:[NSString stringWithFormat:@"%@   %@   %lld lines", _date2, _size2, _line2]];
    
    [_textView1 setString:_file1Str];
    [_textView2 setString:_file2Str];
    
    [_textViewSmall1 setFont:[self fontSizedForAreaSize:_textViewSmall1.bounds.size withString:_file1Str usingFont:[NSFont systemFontOfSize:13]]];
    [_textViewSmall2 setFont:[self fontSizedForAreaSize:_textViewSmall2.bounds.size withString:_file2Str usingFont:[NSFont systemFontOfSize:13]]];
    
    [_textViewSmall1 setString:_file1Str];
    [_textViewSmall2 setString:_file2Str];
    
    [self setDiffColor];
    
    isInitialize = NO;
}

@end
