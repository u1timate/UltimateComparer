//
//  TextView2.m
//  UltimateComparer
//
//  Created by 徐 磊 on 13-9-4.
//  Copyright (c) 2013年 free. All rights reserved.
//

#import "TextView2.h"
#import "NSColor+MyColor.h"
#import "NSTextView+TextMod.h"
#import "Document.h"

static NSMutableDictionary *myDiffRange;

@implementation TextView2

- (id)initWithFrame:(NSRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
    }
    return self;
}

- (void)awakeFromNib {
    document = [Document alloc];
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender{
    highlight=YES;
    [self setNeedsDisplay: YES];
    return NSDragOperationGeneric;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender{
    highlight=NO;
    [self setNeedsDisplay: YES];
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender {
    highlight=NO;
    [self setNeedsDisplay: YES];
    return YES;
}

- (BOOL)performDragOperation:(id < NSDraggingInfo >)sender {
    NSArray *draggedFilenames = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
    if ([[[draggedFilenames objectAtIndex:0] pathExtension] isEqual:@"txt"]){
        return YES;
    } else {
        return NO;
    }
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender{
    NSArray *draggedFilenames = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
    NSString *textDataFile = [NSString stringWithContentsOfFile:[draggedFilenames objectAtIndex:0] encoding:NSUTF8StringEncoding error:nil];
    
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"file1" object:self userInfo:@{@"file1": textDataFile}];
}

- (void)drawRect:(NSRect)rect{
    [super drawRect:rect];
    if ( highlight ) {
        [[NSColor grayColor] set];
        [NSBezierPath setDefaultLineWidth: 5];
        [NSBezierPath strokeRect: [self bounds]];
    }
    
}

- (void)drawViewBackgroundInRect:(NSRect)rect {
    [super drawViewBackgroundInRect:rect];
    
    if ([document.diffRange2 isNotEqualTo:myDiffRange]) {
        myDiffRange = [[NSMutableDictionary alloc] initWithDictionary:document.diffRange2];
    }
    
    NSMutableArray *bPathArray = [[NSMutableArray alloc] init];
    
    if (myDiffRange.count > 0) {
        NSColor* gradientColor2 = [NSColor colorWithCalibratedRed: 0.992 green: 0.882 blue: 0.945 alpha: 0.6];
        NSColor* gradientColor = [NSColor colorWithCalibratedRed: 0.976 green: 0.639 blue: 0.769 alpha: 0.6];
        
        NSGradient* gradient = [[NSGradient alloc] initWithColorsAndLocations:
                                gradientColor, 0.0,
                                gradientColor2, 1.0, nil];
        
        
        for (int i = 0; i < [myDiffRange count]; i++) {
            NSRange sel = [[myDiffRange.allValues objectAtIndex:i] rangeValue];
            NSString *str = [self string];
            if (sel.location <= [str length]) {
                NSRange lineRange = [str lineRangeForRange:NSMakeRange(sel.location,0)];
                NSRect lineRect = [self highlightRectForRange:lineRange];
                [bPathArray addObject:[NSBezierPath bezierPathWithRect:lineRect]];
            }
        }
        
        for (NSBezierPath *path in bPathArray) {
            [gradient drawInBezierPath:path angle:-90];
        }
    }
}

// Returns a rectangle suitable for highlighting a background rectangle for the given text range.
- (NSRect)highlightRectForRange:(NSRange)aRange
{
    NSRange r = aRange;
    NSRange startLineRange = [[self string] lineRangeForRange:NSMakeRange(r.location, 0)];
    NSInteger er = NSMaxRange(r)-1;
    NSString *text = [self string];
    
    NSRange attrRange;
    attrRange = NSMakeRange(0, 0);
    NSAttributedString *attrStr = [self.attributedString attributedSubstringFromRange:aRange];
    NSParagraphStyle *paraStyle = [attrStr attribute:NSParagraphStyleAttributeName atIndex:NSMaxRange(attrRange) effectiveRange:&attrRange];
    CGFloat paraSpacing = [paraStyle paragraphSpacing];
    
    if (er >= [text length]) {
        return NSZeroRect;
    }
    if (er < r.location) {
        er = r.location;
    }
    
    NSRange endLineRange = [[self string] lineRangeForRange:NSMakeRange(er, 0)];
    
    NSRange gr = [[self layoutManager] glyphRangeForCharacterRange:NSMakeRange(startLineRange.location, NSMaxRange(endLineRange)-startLineRange.location-1)
                                              actualCharacterRange:NULL];
    NSRect br = [[self layoutManager] boundingRectForGlyphRange:gr inTextContainer:[self textContainer]];
    NSRect b = [self bounds];
    CGFloat h = br.size.height + paraSpacing;
    CGFloat w = b.size.width;
    CGFloat y = br.origin.y;
    NSPoint containerOrigin = [self textContainerOrigin];
    NSRect aRect = NSMakeRect(0, y, w, h);
    
    // Convert from view coordinates to container coordinates
    aRect = NSOffsetRect(aRect, containerOrigin.x, containerOrigin.y);
    
    return aRect;
}


@end
