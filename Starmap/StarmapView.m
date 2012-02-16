//
//  StarmapView.m
//  Starmap
//
//  Created by Benjamin Kohler on 12/02/11.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "StarmapView.h"

@implementation StarmapView
@synthesize selectedStar;

- (id)initWithFrame:(NSRect)frameRect
{
  if ((self = [super initWithFrame:frameRect])) {
    starmap = [[Starmap alloc] init];
    selectedStar = nil;
    selectedStarPath = [[NSArray alloc] init];
    cameraOffset = NSMakePoint(0, 0);
    drawNetwork = YES;
    drawRings = NO;
    drawLabels = YES;
    zoomFactor = 1;
  }

  return self;
}

- (void)awakeFromNib {
  [self scaleUnitSquareToSize:NSMakeSize(2, 2)];
  zoomFactor += 1;

  [self setNeedsDisplay:YES];
}

- (void)dealloc
{
  [selectedStarPath release];
  [starmap release];
  [super dealloc];
}


- (IBAction)resetCamera:(id)sender
{
  cameraOffset = NSMakePoint(0, 0);
  [self setNeedsDisplay:YES];

  if (zoomFactor == 4) {
    [self scaleUnitSquareToSize:NSMakeSize(0.50, 0.50)];
    [self scaleUnitSquareToSize:NSMakeSize(0.50, 0.50)];
    zoomFactor = 2;
  }
  else if (zoomFactor == 3) {
    [self scaleUnitSquareToSize:NSMakeSize(0.50, 0.50)];
    zoomFactor = 2;
  }
  else if (zoomFactor == 1) {
    [self scaleUnitSquareToSize:NSMakeSize(2, 2)];
    zoomFactor = 2;
  }
  else if (zoomFactor == 0) {
    [self scaleUnitSquareToSize:NSMakeSize(2, 2)];
    [self scaleUnitSquareToSize:NSMakeSize(2, 2)];
    zoomFactor = 2;
  }
}

- (IBAction)zoomCamera:(id)sender
{
  if ([sender indexOfSelectedItem] == 0) {
    if (zoomFactor <= 0)
      return;
    [self scaleUnitSquareToSize:NSMakeSize(0.50, 0.50)];
    zoomFactor -= 1;
  }
  else if ([sender indexOfSelectedItem] == 1) {
    if (zoomFactor >= 4)
      return;
    [self scaleUnitSquareToSize:NSMakeSize(2, 2)];
    zoomFactor += 1;
  }

  [self setNeedsDisplay:YES];
}

- (IBAction)saveToPDF:(id)sender
{
  NSRect mapMargin = NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height);

  NSSavePanel *savepanel;

	savepanel = [NSSavePanel savePanel];
  [savepanel setAllowedFileTypes:[NSArray arrayWithObject:@"pdf"]];
	[savepanel setCanSelectHiddenExtension:YES];
  [savepanel setNameFieldStringValue:@"SMOutput.pdf"];
  [savepanel setMessage:@"Only saves what is currently visible."];

	/* if successful, save file under designated name */
	if ([savepanel runModal] == NSOKButton) {
		[[self dataWithPDFInsideRect:mapMargin] writeToURL:[savepanel URL] atomically:YES];
	}
}

- (void)drawRect:(NSRect)dirtyRect
{
	// Drawing code here.
  int width = self.bounds.size.width;
  int height = self.bounds.size.height;

  [[NSColor colorWithDeviceWhite:0.7 alpha:1] set];
  NSRectFill(self.bounds);

  if ([starmap.starArray count] == 0)
    return;

  if (starmap.starmapShape == CIRCULAR_STARMAP) {
    int starmapRadius = starmap.starmapSize.width;
    starmapRadius = sqrt(starmapRadius);
    starmapRadius *= 20*2;

    // 20px margin
    starmapRadius += 20;
    NSRect mapMargin = NSMakeRect(0+width/2+(int)cameraOffset.x-starmapRadius/2,
                                  0+height/2+(int)cameraOffset.y-starmapRadius/2,
                                  starmapRadius, starmapRadius);

    NSBezierPath *mapMarginPath = [NSBezierPath bezierPathWithOvalInRect:mapMargin];
    [[NSColor colorWithDeviceWhite:0 alpha:0.1] set];
    [mapMarginPath setLineWidth:4];
    [mapMarginPath stroke];

    mapMarginPath = [NSBezierPath bezierPathWithOvalInRect:NSInsetRect(mapMargin, 2, 2)];
    [[NSColor colorWithDeviceWhite:0 alpha:0.4] set];
    [mapMarginPath setLineWidth:1];
    [mapMarginPath stroke];

    [[NSColor whiteColor] set];
    [mapMarginPath fill];
  }
  else if (starmap.starmapShape == RECTANGULAR_STARMAP) {
    NSRect mapMargin = NSMakeRect(0+width/2+(int)cameraOffset.x-starmap.starmapSize.width/2,
                                  0+height/2+(int)cameraOffset.y-starmap.starmapSize.height/2,
                                  starmap.starmapSize.width, starmap.starmapSize.height);


    // 20px margin
    mapMargin = NSInsetRect(mapMargin, -10, -10);

    NSBezierPath *mapMarginPath = [NSBezierPath bezierPathWithRect:mapMargin];
    [[NSColor colorWithDeviceWhite:0 alpha:0.1] set];
    [mapMarginPath setLineWidth:4];
    [mapMarginPath stroke];

    mapMarginPath = [NSBezierPath bezierPathWithRect:NSInsetRect(mapMargin, 2, 2)];
    [[NSColor colorWithDeviceWhite:0 alpha:0.4] set];
    [mapMarginPath setLineWidth:1];
    [mapMarginPath stroke];

    [[NSColor whiteColor] set];
    [mapMarginPath fill];
  }


  // Draw Network
  if (starmap.networkSize != 0) {
    NSBezierPath * circlesPath = [NSBezierPath bezierPath];
    int i3;
    for (i3 = 0; i3 < [starmap.starArray count]; i3++) {
      Star *aStar = [starmap.starArray objectAtIndex:i3];

      int xPos = aStar.starPos.x;
      int yPos = aStar.starPos.y;

      [circlesPath appendBezierPathWithOvalInRect:
       NSMakeRect(xPos+width/2+(int)cameraOffset.x-starmap.networkSize/2,
                  yPos+height/2+(int)cameraOffset.y-starmap.networkSize/2,
                  starmap.networkSize, starmap.networkSize)];
    }

    [[NSColor colorWithDeviceWhite:0 alpha:0.05] set];
    [circlesPath fill];

    if (drawRings) {
      [[NSColor colorWithDeviceWhite:0 alpha:0.1] set];
      [circlesPath setLineWidth:0.5];
      [circlesPath stroke];
    }
  }

  // Darken Selected Star Network Ring
  if (selectedStar != nil && drawRings) {    
    float radius = starmap.networkSize/2; //sqrt(starmap.networkSize/20)*20;
    
    int xPos = selectedStar.starPos.x;
    int yPos = selectedStar.starPos.y;
    
    NSBezierPath * circlesPath = [NSBezierPath bezierPathWithOvalInRect:
                                  NSMakeRect(xPos+width/2+(int)cameraOffset.x-radius,
                                             yPos+height/2+(int)cameraOffset.y-radius,
                                             radius*2, radius*2)];
    
    [[NSColor colorWithDeviceWhite:0 alpha:0.2] set];
    [circlesPath setLineWidth:0.5];
    [circlesPath stroke];
  }

  // Draw Network Lines
  if (drawNetwork) {
    int i1;
    for (i1 = 0; i1 < [starmap.starArray count]; i1++) {
      Star *aStar = [starmap.starArray objectAtIndex:i1];

      NSArray *aArray = aStar.neighbors;

      int xFrom = aStar.starPos.x;
      int yFrom = aStar.starPos.y;

      for (int i4 = 0; i4 < [aArray count]; i4++) {
        Star *neighborStar = [aArray objectAtIndex:i4];

        int xTo = neighborStar.starPos.x;
        int yTo = neighborStar.starPos.y;

        NSBezierPath *starPath = [NSBezierPath bezierPath];
        [starPath moveToPoint:NSMakePoint(xFrom+width/2+(int)cameraOffset.x, yFrom+height/2+(int)cameraOffset.y)];
        [starPath lineToPoint:NSMakePoint(xTo+width/2+(int)cameraOffset.x, yTo+height/2+(int)cameraOffset.y)];

        [[NSColor colorWithDeviceWhite:0 alpha:0.2] set];
        [starPath setLineWidth:0.5];
        [starPath stroke];
      }
    }
  }

  // Draw Route to selectedStar
  if (selectedStar != nil && selectedStarPath != nil) {
    [[NSColor colorWithDeviceWhite:0 alpha:0.5] set];
    
    int i1;
    for (i1 = 0; i1 < [selectedStarPath count]; i1++) {
      Star *aStar = [selectedStarPath objectAtIndex:i1];
            
      int xFrom = aStar.starPos.x;
      int yFrom = aStar.starPos.y;
      
      if ([selectedStarPath count] > i1+1) {
        Star *nextStar = [selectedStarPath objectAtIndex:i1+1];
        
        int xTo = nextStar.starPos.x;
        int yTo = nextStar.starPos.y;
        
        NSBezierPath *starPath = [NSBezierPath bezierPath];
        [starPath moveToPoint:NSMakePoint(xFrom+width/2+(int)cameraOffset.x, yFrom+height/2+(int)cameraOffset.y)];
        [starPath lineToPoint:NSMakePoint(xTo+width/2+(int)cameraOffset.x, yTo+height/2+(int)cameraOffset.y)];
        
        [starPath setLineWidth:0.5];
        [starPath stroke];
      }
    }
  }

	// Draw Points
  int i2;
  for (i2 = 0; i2 < [starmap.starArray count]; i2++) {
    Star *aStar = [starmap.starArray objectAtIndex:i2];

  	NSBezierPath * path;
    int xPos = aStar.starPos.x;
    int yPos = aStar.starPos.y;

    NSRect dotRect = NSMakeRect(xPos+width/2+(int)cameraOffset.x-2, yPos+height/2+(int)cameraOffset.y-2, 4, 4);
    path = [NSBezierPath bezierPathWithOvalInRect:dotRect];
    [[aStar starColor] set];
  	[path fill];

    if (aStar == selectedStar) {
      path = [NSBezierPath bezierPathWithOvalInRect:NSInsetRect(dotRect, -4, -4)];
      [[[aStar starColor] colorWithAlphaComponent:0.2] set];
      [path setLineWidth:2];
      [path stroke];
      
      // Also hilight netwrok star
      if (aStar.type == NETWORKING_STAR) {
        NSBezierPath * path;
        int xPos = aStar.networkStar.starPos.x;
        int yPos = aStar.networkStar.starPos.y;
        
        NSRect dotRect = NSMakeRect(xPos+width/2+(int)cameraOffset.x-2, yPos+height/2+(int)cameraOffset.y-2, 4, 4);
        path = [NSBezierPath bezierPathWithOvalInRect:NSInsetRect(dotRect, -4, -4)];
        [[[aStar.networkStar starColor] colorWithAlphaComponent:0.2] set];
        [path setLineWidth:2];
        [path stroke];
      }
    }
  }

  // Draw star names
  if (drawLabels) {
    int i3;
    for (i3 = 0; i3 < [starmap.starArray count]; i3++) {
      Star *aStar = [starmap.starArray objectAtIndex:i3];

      int xPos = aStar.starPos.x;
      int yPos = aStar.starPos.y;

      NSString *nameLabel = [NSString stringWithFormat:@"%@",aStar.starName];
      NSDictionary *attr = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:5],NSFontAttributeName,
                            [NSColor colorWithDeviceWhite:0.0 alpha:0.8],NSForegroundColorAttributeName,nil];
      [nameLabel drawAtPoint:NSMakePoint(xPos+width/2+(int)cameraOffset.x, yPos+height/2+(int)cameraOffset.y) withAttributes:attr];

      if (zoomFactor >= 3){
        NSString *posLabel = [NSString stringWithFormat:@"%.1f,%.1f",aStar.starPos.x,aStar.starPos.y];
        attr = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:3],NSFontAttributeName,
                              [NSColor colorWithDeviceWhite:0.0 alpha:0.8],NSForegroundColorAttributeName,nil];
        [posLabel drawAtPoint:NSMakePoint(xPos+width/2+(int)cameraOffset.x+2, yPos+height/2+(int)cameraOffset.y-2) withAttributes:attr];
      }

    }
  }
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
    
    BOOL starSelected = NO;
    
    int i2;
    for (i2 = 0; i2 < [starmap.starArray count]; i2++) {
      Star *aStar = [starmap.starArray objectAtIndex:i2];
      
      int xPos = aStar.starPos.x;
      int yPos = aStar.starPos.y;
      
      NSRect dotRect = NSMakeRect(xPos+width/2+(int)cameraOffset.x-2, yPos+height/2+(int)cameraOffset.y-2, 4, 4);
      if (NSPointInRect(mousePos, dotRect)) {
        [self willChangeValueForKey:@"selectedStar"];
        selectedStar = aStar;
        starSelected = YES;
        [self didChangeValueForKey:@"selectedStar"];
        
        Pathfinder *pathF = [[Pathfinder alloc] init];
        [selectedStarPath release];
        selectedStarPath = [[pathF runPathfinderWithStars:starmap.starArray fromStar:[starmap.starArray objectAtIndex:0] toStar:selectedStar] retain];
        [pathF release];
      }
    }
    if (!starSelected) {
      [self willChangeValueForKey:@"selectedStar"];
      selectedStar = nil;
      [selectedStarPath release];
      selectedStarPath = nil;
      [self didChangeValueForKey:@"selectedStar"];
    }
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


- (void)setStarmap:(Starmap *)aStarmap
{
  if (aStarmap != starmap) {
    [starmap release];
    starmap = [aStarmap retain];
  }
  [self willChangeValueForKey:@"selectedStar"];
  selectedStar = nil;
  [self didChangeValueForKey:@"selectedStar"];
  [selectedStarPath release];
  selectedStarPath = nil;
}

- (void)setDrawNetwork:(BOOL)flag
{
  drawNetwork = flag;
  [self setNeedsDisplay:YES];
}

- (int)drawNetwork
{
  return drawNetwork;
}

- (void)setDrawRings:(BOOL)flag
{
  drawRings = flag;
  [self setNeedsDisplay:YES];
}

- (int)drawRings
{
  return drawRings;
}

- (void)setDrawLabels:(BOOL)flag
{
  drawLabels = flag;
  [self setNeedsDisplay:YES];
}

- (int)drawLabels
{
  return drawLabels;
}


@end
