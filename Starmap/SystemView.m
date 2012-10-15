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
  
  //float sSize = activeStar.starSystem.sectorSize;
  float sWidth = activeStar.starSystem.size.width;
  float sHeight = activeStar.starSystem.size.height;

  
  [[NSColor colorWithDeviceWhite:0.7 alpha:1] set];
  NSRectFill(self.bounds);

  
  if (!activeStar)
    return;
  
  // 20px margin
  NSRect mapMargin = NSMakeRect(0+(int)cameraOffset.x+width/2-sWidth/2,
                                0+(int)cameraOffset.y+height/2-sHeight/2,
                                sWidth, sHeight);
  
  NSBezierPath *mapMarginPath = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(mapMargin, -2, -2) xRadius:2 yRadius:2];
  [[NSColor colorWithDeviceWhite:0 alpha:0.1] set];
  [mapMarginPath setLineWidth:4];
  [mapMarginPath stroke];
  
  mapMarginPath = [NSBezierPath bezierPathWithRoundedRect:mapMargin xRadius:2 yRadius:2];
  [[NSColor colorWithDeviceWhite:0 alpha:0.4] set];
  [mapMarginPath setLineWidth:1];
  [mapMarginPath stroke];
  
  [[NSColor whiteColor] set];
  [mapMarginPath fill];
  
  
  // Grid lines
  /*for (int i1 = -1 * sWidth+sSize; i1 < (sWidth/sSize)-sSize; i1+=sSize) {
    NSBezierPath *starPath = [NSBezierPath bezierPath];
    [starPath moveToPoint:NSMakePoint((i1)+width/2+sWidth/2+(int)cameraOffset.x, height/2-sHeight/2+(int)cameraOffset.y)];
    [starPath lineToPoint:NSMakePoint((i1)+width/2+sWidth/2+(int)cameraOffset.x, height/2+sHeight/2+(int)cameraOffset.y)];
    
    [[NSColor colorWithDeviceWhite:0 alpha:0.05] set];
    [starPath setLineWidth:1];
    [starPath stroke];
  }
  for (int i1 = -1 * sHeight+sSize; i1 < (sHeight/sSize)-sSize; i1+=sSize) {
    NSBezierPath *starPath = [NSBezierPath bezierPath];
    [starPath moveToPoint:NSMakePoint(width/2-sWidth/2+(int)cameraOffset.x, (i1)+height/2+sHeight/2+(int)cameraOffset.y)];
    [starPath lineToPoint:NSMakePoint(width/2+sWidth/2+(int)cameraOffset.x, (i1)+height/2+sHeight/2+(int)cameraOffset.y)];
    
    [[NSColor colorWithDeviceWhite:0 alpha:0.05] set];
    [starPath setLineWidth:1];
    [starPath stroke];
  }*/
  
  // Draw the center star
  NSBezierPath * path;
  int xPos = 0;
  int yPos = 0;
  
  NSRect dotRect = NSMakeRect(xPos+(int)cameraOffset.x+width/2-2, yPos+(int)cameraOffset.y+height/2-2, 4, 4);
  path = [NSBezierPath bezierPathWithOvalInRect:dotRect];
  [[activeStar.starSystem.planet mapColor] set];
  [path fill];
  
  path = [NSBezierPath bezierPathWithOvalInRect:NSInsetRect(dotRect, -3, -3)];
  [[[activeStar.starSystem.planet mapColor] colorWithAlphaComponent:0.2] set];
  [path setLineWidth:1.5];
  [path stroke];      
  
  // Draw label
  NSString *nameLabel = [NSString stringWithFormat:@"%@",activeStar.starName];
  NSDictionary *attr = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:5],NSFontAttributeName,
                        [NSColor colorWithDeviceWhite:0.0 alpha:0.8],NSForegroundColorAttributeName,nil];
  [nameLabel drawAtPoint:NSMakePoint(xPos+(int)cameraOffset.x+width/2, yPos+(int)cameraOffset.y+height/2) withAttributes:attr];
  
  
  
  // Draw the warp zone
  xPos = activeStar.starSystem.warpZonePosition.x;
  yPos = activeStar.starSystem.warpZonePosition.y;
  NSBezierPath * warpPath;  
  NSRect warpRect = NSMakeRect(xPos+(int)cameraOffset.x+width/2-3, yPos+(int)cameraOffset.y+height/2-3, 6, 6);
  
  warpPath = [NSBezierPath bezierPathWithOvalInRect:warpRect];
  [[NSColor colorWithCalibratedRed:0.000 green:0.578 blue:0.428 alpha:0.8] set];
  [warpPath setLineWidth:1.5];
  [warpPath fill];      
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
    
    //int width = self.bounds.size.width;
    //int height = self.bounds.size.height;
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
