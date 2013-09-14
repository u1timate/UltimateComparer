//
//  MarkerLine1.h
//  UltimateComparer
//
//  Created by 徐 磊 on 13-9-3.
//  Copyright (c) 2013年 free. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NoodleLineNumberView.h"

@interface MarkerLine2 : NoodleLineNumberView
{
	NSImage *markerImage;
}

+ (NSInteger)dragLineRaw;
+ (NSInteger)toLineRaw;
@end
