//
//  MainView.h
//  UltimateComparer
//
//  Created by 徐 磊 on 13-9-13.
//  Copyright (c) 2013年 free. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Document;

@interface MainView : NSView {
    Document *document;
}

@property IBOutlet NSTextView *textView1inMain;
@property IBOutlet NSTextView *textView2inMain;

@end
