//
//  EncodingName.m
//  UltimateComparer
//
//  Created by 徐 磊 on 13-8-29.
//  Copyright (c) 2013年 free. All rights reserved.
//

#import "EncodingName.h"

@implementation EncodingName

- (NSString *)returnEncoding:(unsigned long)encoding {
    switch (encoding) {
        case 1:
            return @"ASCII";
            break;
            
        case 2:
            return @"NEXTSTEP";
            break;
            
        case 3:
            return @"Japanese EUC";
            break;
            
        case 4:
            return @"UTF-8";
            break;
            
        case 5:
            return @"ISO-Latin1";
            break;
            
        case 6:
            return @"Symbol";
            break;
            
        case 7:
            return @"Non-Lossy ASCII";
            break;
            
        case 8:
            return @"Shift-JIS";
            break;
            
        case 9:
            return @"ISOLatin2";
            break;
            
        case 10:
            return @"UTF-16/Unicode";
            break;
            
        case 11:
            return @"Windows CP1251";
            break;
            
        case 12:
            return @"Windows CP1252";
            break;
            
        case 13:
            return @"Windows CP1253";
            break;
            
        case 14:
            return @"Windows CP1254";
            break;
            
        case 15:
            return @"Windows CP1250";
            break;
            
        case 21:
            return @"ISO2022 JP";
            break;
            
        case 30:
            return @"MacOSRoman";
            break;
            
        case 0x90000100:
            return @"UTF-16 Big Endian";
            break;
            
        case 0x94000100:
            return @"UTF-16 Little Endian";
            break;
            
        case 0x8c000100:
            return @"UTF-32";
            break;
            
        case 0x98000100:
            return @"UTF-32 Big Endian";
            break;
            
        case 0x9c000100:
            return @"UTF-32 Little Endian";
            break;
            
        case 65536:
            return @"Proprietary";
            break;
            
        default:
            break;
    }
    return @"Error Encoding Value";
}

- (NSString *)description {
    return [self returnEncoding:_encodedNum];
}

@end
