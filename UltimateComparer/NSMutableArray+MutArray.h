//
//  NSMutableArray+MutArray.h
//  UltimateComparer
//
//  Created by 徐 磊 on 13-9-9.
//  Copyright (c) 2013年 free. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (MutArray)

- (void)removeNilObj;
- (NSArray *)codingBlock;
- (NSArray *)pairCodeArea;
- (BOOL)isCodingArray;
- (NSArray *)codingBeginLocation;
- (NSArray *)codingEndLocation;
- (NSArray *)codingCombinedBeginAndEnd;
- (NSArray *)codingBlockFlag;
@end
