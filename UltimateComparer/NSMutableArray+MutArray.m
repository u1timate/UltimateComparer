//
//  NSMutableArray+MutArray.m
//  UltimateComparer
//
//  Created by 徐 磊 on 13-9-9.
//  Copyright (c) 2013年 free. All rights reserved.
//

#import "NSMutableArray+MutArray.h"
#import "NSString+Strings.h"

@implementation NSMutableArray (MutArray)

- (void)removeNilObj {
    for (id obj in self) {
        if (![obj hasNonSpaceCharacter]) {
            [self removeObject:obj];
            [self removeNilObj];
            return;
        }
    }
}

- (BOOL)isCodingArray {
    
    NSString *specialCharacterString = @"{}[]";
    NSCharacterSet *specialCharacterSet = [NSCharacterSet characterSetWithCharactersInString:specialCharacterString];
    
    long counts = 0;
    
    for (id obj in self) {
        if ([obj rangeOfCharacterFromSet:specialCharacterSet].location != NSNotFound) {
            counts++;
        }
    }
    
    if ((float)counts / self.count > 0.6) {
        return YES;
    } else {
        return NO;
    }
    
}

- (NSArray *)codingBlock {

    NSMutableArray *codeArea = [[NSMutableArray alloc] init];
    
    for (long i = 0; i < self.count; i++) {
        if ([self[i] rangeOfString:@"}"].location != NSNotFound) {
            [codeArea addObject:[NSString stringWithFormat:@"end.%ld", i]];
        }
        if ([self[i] rangeOfString:@"{"].location != NSNotFound) {
            [codeArea addObject:[NSString stringWithFormat:@"start.%ld", i]];
        }
    }
    
    return codeArea;
}

- (NSArray *)codingBeginLocation {
    
    NSMutableArray *codeLoc = [[NSMutableArray alloc] init];
    
    for (long i = 0; i < self.count; i++) {
        
        if ([self[i] rangeOfString:@"{"].location != NSNotFound) {
            [codeLoc addObject:[NSNumber numberWithLong:i]];
        }
    }
    
    return codeLoc;
}

- (NSArray *)codingEndLocation {
    NSMutableArray *edLoc = [[NSMutableArray alloc] init];
    
    for (long i = 0; i < self.count; i++) {
        
        if ([self[i] rangeOfString:@"}"].location != NSNotFound) {
            [edLoc addObject:[NSNumber numberWithLong:i]];
        }
    }
    
    return edLoc;
}

- (NSArray *)codingCombinedBeginAndEnd {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for (long i = 0; i < self.count; i++) {
        if ([self[i] rangeOfString:@"}"].location != NSNotFound || [self[i] rangeOfString:@"{"].location != NSNotFound) {
            [result addObject:[NSNumber numberWithLong:i]];
        }
    }
    
    return result;
}

- (NSArray *)codingBlockFlag {
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for (long i = 0; i < self.count; i++) {
        if ([self[i] rangeOfString:@"}"].location != NSNotFound && [self[i] rangeOfString:@"{"].location != NSNotFound) {
            [result addObject:@"both"];
        } else {
            if ([self[i] rangeOfString:@"}"].location != NSNotFound) {
                [result addObject:@"end"];
            } else if ([self[i] rangeOfString:@"{"].location != NSNotFound) {
                [result addObject:@"begin"];
            }
        }
    }
    
    return result;
}

- (NSArray *)pairCodeArea {
    NSArray *codingArea = [self codingBlock];
    
    NSMutableArray *result  = [[NSMutableArray alloc] init];
    
    long counts = 0;
    
    for (long i = 0; i< codingArea.count; i++) {
        NSArray *arr = [codingArea[i] componentsSeparatedByString:@"."];
        NSString *flag = arr[0];
        NSInteger loc = [arr[1] integerValue];
        
        if ([flag isEqualToString:@"start"]) {
            
            NSDictionary *dict = @{@"start": [NSNumber numberWithInteger:loc],
                                   @"end": @"NONE"};
            [result addObject:dict];
            counts++;
        } else if ([flag isEqualToString:@"end"]) {
            for (long m = [result count] - 1; m >= 0; m--) {
                if ([[[result valueForKey:@"end"] objectAtIndex:m] isEqualTo:@"NONE"]) {
                    NSDictionary *dict = @{@"start": [[result valueForKey:@"start"] objectAtIndex:m],
                                           @"end": [NSNumber numberWithInteger:loc]};
                    [result replaceObjectAtIndex:m withObject:dict];
                    counts--;
                    break;
                } else {
                    NSLog(@"Pairing Coding Area: Object at %ld is full.", m);
                }
            }
        }
    }
    
    NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"end" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
    NSArray *sortedArray = [result sortedArrayUsingDescriptors:sortDescriptors];
    
    return sortedArray;
}

@end
