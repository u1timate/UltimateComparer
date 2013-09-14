//
//  MarkerLine1.m
//  UltimateComparer
//
//  Created by 徐 磊 on 13-9-3.
//  Copyright (c) 2013年 free. All rights reserved.
//

#import "MarkerLine2.h"
#import "NoodleLineNumberMarker.h"
#import "Document.h"

#define CORNER_RADIUS	3.0
#define MARKER_HEIGHT	13.0

static NSInteger dragLineRaw;
static NSInteger toLineRaw;

@implementation MarkerLine2

+ (NSInteger)dragLineRaw {
    return dragLineRaw;
}

+ (NSInteger)toLineRaw {
    return toLineRaw;
}

- (void)setRuleThickness:(CGFloat)thickness
{
	[super setRuleThickness:thickness];
	
	// Overridden to reset the size of the marker image forcing it to redraw with the new width.
	// If doing this in a non-subclass of NoodleLineNumberView, you can set it to post frame
	// notifications and listen for them.
	[markerImage setSize:NSMakeSize(thickness, MARKER_HEIGHT)];
}

- (void)drawMarkerImageIntoRep:(id)rep
{
	NSBezierPath	*path;
	NSRect			rect;
	
	rect = NSMakeRect(1.0, 2.0, [rep size].width - 1.0, [rep size].height - 2.0);
	
	path = [NSBezierPath bezierPath];
	[path moveToPoint:NSMakePoint(NSMaxX(rect), NSMinY(rect) + NSHeight(rect) / 2)];
	[path lineToPoint:NSMakePoint(NSMaxX(rect) - 5.0, NSMaxY(rect))];
	
	[path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(rect) + CORNER_RADIUS, NSMaxY(rect) - CORNER_RADIUS) radius:CORNER_RADIUS startAngle:90 endAngle:180];
	
	[path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(rect) + CORNER_RADIUS, NSMinY(rect) + CORNER_RADIUS) radius:CORNER_RADIUS startAngle:180 endAngle:270];
	[path lineToPoint:NSMakePoint(NSMaxX(rect) - 5.0, NSMinY(rect))];
	[path closePath];
	
	[[NSColor colorWithCalibratedRed:0.36 green:0.53 blue:0.77 alpha:1.0] set];
	[path fill];
	
	[[NSColor colorWithCalibratedRed:0.21 green:0.32 blue:0.46 alpha:1.0] set];
	
	[path setLineWidth:0.5];
	[path stroke];
}

- (NSImage *)markerImageWithSize:(NSSize)size
{
	if (markerImage == nil)
	{
		NSCustomImageRep	*rep;
		
		markerImage = [[NSImage alloc] initWithSize:size];
		rep = [[NSCustomImageRep alloc] initWithDrawSelector:@selector(drawMarkerImageIntoRep:) delegate:self];
		[rep setSize:size];
		[markerImage addRepresentation:rep];
	}
	return markerImage;
}

- (void)mouseDown:(NSEvent *)theEvent
{
	NSPoint					location;
	NSInteger				line;
	
	location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	line = [self lineNumberForLocation:location.y];
	
	if (line != NSNotFound)
	{
		NoodleLineNumberMarker		*marker;
		
		marker = [self markerAtLine:line];
		
		if (marker != nil)
		{
			[self removeMarker:marker];
		}
		else
		{
			marker = [[NoodleLineNumberMarker alloc] initWithRulerView:self
                                                            lineNumber:line
                                                                 image:[self markerImageWithSize:NSMakeSize([self ruleThickness], MARKER_HEIGHT)]
														   imageOrigin:NSMakePoint(0, MARKER_HEIGHT / 2)];
			[self addMarker:marker];
		}
		[self setNeedsDisplay:YES];
	}
    dragLineRaw = line;
}

- (void)mouseDragged:(NSEvent *)theEvent {
    NSPoint location;
    
    location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    NSInteger line = [self lineNumberForLocation:location.y];
    
    toLineRaw = line;
}

- (void)mouseUp:(NSEvent *)theEvent {
    
    if (theEvent.clickCount == 0) {
        NSPoint location;
        
        location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        
        NSInteger line = [self lineNumberForLocation:location.y];
        
        toLineRaw = line;
        
        NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:@"locDone2" object:self userInfo:@{@"dragLineRaw": [NSNumber numberWithInteger:dragLineRaw],
         @"toLineRaw": [NSNumber numberWithInteger:toLineRaw], @"button": @"left"}];
        
    } else if (theEvent.clickCount == 2) {
        NSLog(@"Click Twice");
        NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:@"locDone2" object:self userInfo:@{@"dragLineRaw": [NSNumber numberWithInteger:0],
         @"toLineRaw": [NSNumber numberWithInteger:0], @"button": @"left"}];
    }
}

- (void)rightMouseUp:(NSEvent *)theEvent {
    
    NSPoint location;
    
    location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    NSInteger line = [self lineNumberForLocation:location.y];
    
    dragLineRaw = line;
    toLineRaw = line;
    
    
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"locDone2" object:self userInfo:@{@"dragLineRaw": [NSNumber numberWithInteger:dragLineRaw],
     @"toLineRaw": [NSNumber numberWithInteger:dragLineRaw], @"button": @"right"}];
}


@end
