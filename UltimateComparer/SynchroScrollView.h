//
//  SynchroScrollView.h
//  UltimateComparer
//
//  Created by 徐 磊 on 13-9-3.
//  Copyright (c) 2013年 free. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SynchroScrollView : NSScrollView {
    IBOutlet NSScrollView* synchronizedScrollView; // not retained
}

- (void)setSynchronizedScrollView:(NSScrollView*)scrollview;
- (void)stopSynchronizing;
- (void)synchronizedViewContentBoundsDidChange:(NSNotification *)notification;

@end
