//
//  TextView1.h
//  UltimateComparer
//
//  Created by 徐 磊 on 13-9-4.
//  Copyright (c) 2013年 free. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Document;

@interface TextView1 : NSTextView {
    BOOL highlight;
    Document *document;
}

@end
