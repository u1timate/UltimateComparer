//
//  EncodingName.h
//  UltimateComparer
//
//  Created by 徐 磊 on 13-8-29.
//  Copyright (c) 2013年 free. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EncodingName : NSObject

@property unsigned long encodedNum;

- (NSString *)returnEncoding:(unsigned long)encoding;

@end
