//
//  SystemView.m
//  Starmap
//
//  Created by Benjamin Kohler on 12/09/03.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SystemView.h"
#import "Star.h"

@implementation SystemView
@synthesize activeStar;
@synthesize sectorSize;

- (id)initWithFrame:(NSRect)frame
{
  if (!(self = [super initWithFrame:frame]))
    return nil;
  
  // Initialization code here.
  cameraOffset = NSMakePoint(0, 0);
  sectorSize = 64;
  return self;
}

- (void)awakeFromNib
{
  [self scaleUnitSquareToSize:NSMakeSize(2, 2)];
}

- (void)drawRect:(NSRect)dirtyRect
{
	// Drawing code here.
  int width = self.bounds.size.width;
  int height = self.bounds.size.height;
  
  [[NSColor colorWithDeviceWhite:0.7 alpha:1] set];
  NSRectFill(self.bounds);

  
  if (!activeStar)
    return;
  
    
  int starSystemRadius = activeStar.starSystem.size;
  
  // 20px margin
  starSystemRadius += 20;
  NSRect mapMargin = NSMakeRect(0+(int)cameraOffset.x+width/2-starSystemRadius/2,
                                0+(int)cameraOffset.y+height/2-starSystemRadius/2,
                                starSystemRadius, starSystemRadius);
  
  NSBezierPath *mapMarginPath = [NSBezierPath bezierPathWithRoundedRect:mapMargin xRadius:2 yRadius:2];
  [[NSColor colorWithDeviceWhite:0 alpha:0.1] set];
  [mapMarginPath setLineWidth:4];
  [mapMarginPath stroke];
  
  mapMarginPath = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(mapMargin, 2, 2) xRadius:2 yRadius:2];
  [[NSColor colorWithDeviceWhite:0 alpha:0.4] set];
  [mapMarginPath setLineWidth:1];
  [mapMarginPath stroke];
  
  [[NSColor whiteColor] set];
  [mapMarginPath fill];
  
  
  // Draw Center Star
  NSBezierPath * path;
  int xPos = 0;
  int yPos = 0;
  
  NSRect dotRect = NSMakeRect(xPos+(int)cameraOffset.x+width/2-2, yPos+(int)cameraOffset.y+height/2-2, 4, 4);
  path = [NSBezierPath bezierPathWithOvalInRect:dotRect];
  [[activeStar starColor] set];
  [path fill];
  
  path = [NSBezierPath bezierPathWithOvalInRect:NSInsetRect(dotRect, -3, -3)];
  [[[activeStar starColor] colorWithAlphaComponent:0.2] set];
  [path setLineWidth:1.5];
  [path stroke];      
  
  // Draw Label
  NSString *nameLabel = [NSString stringWithFormat:@"%@",activeStar.starName];
  NSDictionary *attr = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:5],NSFontAttributeName,
                        [NSColor colorWithDeviceWhite:0.0 alpha:0.8],NSForegroundColorAttributeName,nil];
  [nameLabel drawAtPoint:NSMakePoint(xPos+(int)cameraOffset.x+width/2, yPos+(int)cameraOffset.y+height/2) withAttributes:attr];
  
}



- (BOOL)isOpaque
{
  return YES;
}

- (BOOL)canBecomeKeyView
{
  return YES;
}

- (void)mouseDown:(NSEvent *)theEvent
{
  mousePos = [self convertPoint:[theEvent locationInWindow] fromView:nil];
}

- (void)mouseUp:(NSEvent *)theEvent
{
  if (!wasDragging) {
    mousePos = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    int width = self.bounds.size.width;
    int height = self.bounds.size.height;
  }
  
  wasDragging = NO;
  [self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
  NSPoint dragPos = [self convertPoint:[theEvent locationInWindow] fromView:nil];
  cameraOffset = NSMakePoint(cameraOffset.x + (dragPos.x - mousePos.x), cameraOffset.y + (dragPos.y - mousePos.y));
  mousePos = dragPos;
  
  wasDragging = YES;
  [self setNeedsDisplay:YES];
}




- (void)setActiveStar:(Star *)newActiveStar
{
  activeStar = newActiveStar;
  [self setNeedsDisplay:YES];
  cameraOffset = NSMakePoint(0, 0);
}

@end
