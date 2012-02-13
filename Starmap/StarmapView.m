//
//  StarmapView.m
//  Starmap
//
//  Created by Benjamin Kohler on 12/02/11.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "StarmapView.h"

@implementation StarmapView

- (id)initWithFrame:(NSRect)frameRect
{
  if ((self = [super initWithFrame:frameRect])) {
    cameraOffset = NSMakePoint(0, 0);
    starmap = [[NSMutableArray alloc] init];
    seed = 23747;
    networkSize = 106;
    drawNetwork = YES;
    networkingStars = YES;
    drawRings = NO;
    drawLabels = YES;
    zoomFactor = 1;
  }
  
  return self;
}

- (void)awakeFromNib {  
  [seedField setStringValue:@"23747"];
  [starsField setStringValue:@"100"];
  [sizeField setStringValue:@"100"];
  [self generateStarmapWithSeed:23747 starAmount:100 size:100];
  [[self window] center];
  [[self window] zoom:self];
  
  [self scaleUnitSquareToSize:NSMakeSize(2, 2)];
  zoomFactor += 1;
}

- (void)dealloc
{
  [starmap release];
  [super dealloc];
}

- (IBAction)generate:(id)sender
{
  [self generateStarmapWithSeed:[seedField intValue] starAmount:[starsField intValue] size:[sizeField intValue]];
}

- (IBAction)resetCamera:(id)sender
{
  cameraOffset = NSMakePoint(0, 0);
  [self setNeedsDisplay:YES];
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

- (BOOL)goodStarPosition:(NSPoint)pos checkDistance:(int)checkDist
{  
  if (pos.x == 0 && pos.y == 0)
    return NO;
  
  for (Star *aStar in starmap) {
    
    float nomX = pos.x - aStar.xPos;
    float nomY = pos.y - aStar.yPos;
    
    float dist = sqrt(nomX * nomX + nomY * nomY);
    if (dist < checkDist)
      return NO;
  }
  return YES;
}

- (NSArray *)neighborStars:(NSPoint)pos checkDistance:(int)checkDist
{
  NSMutableArray *aArray = [[NSMutableArray alloc] init];
  if (pos.x == 0 && pos.y == 0)
    return NO;
  
  for (Star *aStar in starmap) {
    if (aStar.type == NETWORKING_STAR && !networkingStars)
      continue;
    
    float nomX = pos.x - aStar.xPos;
    float nomY = pos.y - aStar.yPos;
    
    float dist = sqrt(nomX * nomX + nomY * nomY);
    if (dist < checkDist)
      [aArray addObject:aStar];
  }
  return [NSArray arrayWithArray:[aArray autorelease]];
}

- (void)generateStarmapWithSeed:(unsigned int)aSeed starAmount:(int)stars size:(int)size;
{
  seed = aSeed;
  srand(seed);
  srandom(seed);
      
  int numstars = stars;
  float x,y = 0;
  Star *tempStar = nil;
  
  [starmap release];
  starmap = [[NSMutableArray alloc] init];
  
  // Stars
  NSLog(@"Initializing Starmap");
  for (int i1 = 0; i1 < numstars; ++i1)  {
    if (tempStar != nil) {
      float oldX = tempStar.xPos;
      float oldY = tempStar.xPos;
      
      
      BOOL validStar = NO;
      while (!validStar) {
        float angle = rand() % 360;
        float radius = rand() % stars;
        
        x = sqrt(radius) * cos(angle);
        y = sqrt(radius) * sin(angle);
        
        x *= 20;
        y *= 20;

        validStar = [self goodStarPosition:NSMakePoint(x, y) checkDistance:5];
        if (!validStar)
          NSLog(@"Invalid Star: %i of %i At: %i,%i",i1+1,numstars,(int)x,(int)y);        
      }

      
      [tempStar release];
      tempStar = [[Star alloc] init];  // create a temporary star
      
      if ([algorithmSelector indexOfSelectedItem] == 3) {
        // Normalize new star postion relative to the previous star
        [tempStar setXPos:oldX + x];
        [tempStar setYPos:oldY + y];
      }
      else if ([algorithmSelector indexOfSelectedItem] == 4) {
        Star *randomStar = [starmap objectAtIndex:rand() % [starmap count]];
        // Normalize new star postion relative to a random star
        [tempStar setXPos:randomStar.xPos + x];
        [tempStar setYPos:randomStar.yPos + y];
      }
      else {
        [tempStar setXPos:x];
        [tempStar setYPos:y];
      }
      [tempStar setType:PRIMARY_STAR];
      NSLog(@"Adding Star: %i of %i At: %i,%i",i1+1,numstars,(int)tempStar.xPos,(int)tempStar.yPos);
      [starmap addObject:tempStar];
    }
    else {
      float angle = rand() % 360;
      float radius = rand() % stars/2;
      
      x = sqrt(radius) * cos(angle);
      y = sqrt(radius) * sin(angle);
      
      x *= 20;
      y *= 20;
      
      tempStar = [[Star alloc] init];  // create a temporary star
      [tempStar setXPos:x];
      [tempStar setYPos:y];
      NSLog(@"Adding First Star");
      [tempStar setType:FIRST_STAR];
      [starmap addObject:tempStar];
    }
  }
  NSLog(@"\n");
  
  //Networking Stars - Only generated for stars with less than 3 neighbors.
  if (networkingStars) {
    int i5;
    for (i5 = 0; i5 < [starmap count]; i5++) {
      Star *aStar = [starmap objectAtIndex:i5];
      if (aStar.type == NETWORKING_STAR)
        continue;
      
      NSArray *neighbors = [self neighborStars:NSMakePoint(aStar.xPos, aStar.yPos) checkDistance:networkSize/2];
      if ([neighbors count] <= 3) {
        
        BOOL validStar = NO;
        while (!validStar) {
          float angle = rand() % 360;
          float radius = rand() % networkSize/20;
          
          x = sqrt(radius) * cos(angle);
          y = sqrt(radius) * sin(angle);
          
          x *= 20;
          y *= 20;
          
          validStar = [self goodStarPosition:NSMakePoint(x, y) checkDistance:3];
          if (!validStar)
            NSLog(@"Invalid Networking Star At: %i,%i",(int)x,(int)y);        
        }
        
        tempStar = [[Star alloc] init];  // create a temporary star
        [tempStar setXPos:aStar.xPos - x];
        [tempStar setYPos:aStar.yPos - y];
        [tempStar setType:NETWORKING_STAR];
        NSLog(@"Adding Networking Star At: %i,%i",(int)tempStar.xPos,(int)tempStar.yPos);
        [starmap addObject:tempStar];
      }
    }
    NSLog(@"\n");
  }
  
  
  [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{  
	// Drawing code here.
  int width = self.bounds.size.width;
  int height = self.bounds.size.height;
  
  [[NSColor whiteColor] set];
  NSRectFill(self.bounds);

  
  // Draw Network
  
  if (networkSize != 0) {
    NSBezierPath * circlesPath = [NSBezierPath bezierPath];
    int i3;
    for (i3 = 0; i3 < [starmap count]; i3++) {
      Star *aStar = [starmap objectAtIndex:i3];      
      
      int xPos = aStar.xPos;
      int yPos = aStar.yPos;
      
      [circlesPath appendBezierPathWithOvalInRect:NSMakeRect(xPos+width/2+(int)cameraOffset.x-networkSize/2, yPos+height/2+(int)cameraOffset.y-networkSize/2, networkSize, networkSize)];
    }
    
    [[NSColor colorWithDeviceWhite:0 alpha:0.05] set];
    [circlesPath fill];      

    if (drawRings) {
      [[NSColor colorWithDeviceWhite:0 alpha:0.1] set];
      [circlesPath setLineWidth:0.5];
      [circlesPath stroke];
    }
  }
  
  // Draw Network Lines
  if (drawNetwork) {
    int i1;
    for (i1 = 0; i1 < [starmap count]; i1++) {
      Star *aStar = [starmap objectAtIndex:i1];
      
      NSArray *aArray = [self neighborStars:NSMakePoint(aStar.xPos, aStar.yPos) checkDistance:networkSize/2];
      
      int xPos = aStar.xPos;
      int yPos = aStar.yPos;
      
      for (int i4 = 0; i4 < [aArray count]; i4++) {
        Star *neighborStar = [aArray objectAtIndex:i4];
        
        NSBezierPath *starPath = [NSBezierPath bezierPath];
        [starPath moveToPoint:NSMakePoint(xPos+width/2+(int)cameraOffset.x, yPos+height/2+(int)cameraOffset.y)];
        [starPath lineToPoint:NSMakePoint(neighborStar.xPos+width/2+(int)cameraOffset.x, neighborStar.yPos+height/2+(int)cameraOffset.y)];
        
        [[NSColor colorWithDeviceWhite:0 alpha:0.2] set];
        [starPath setLineWidth:0.5];
        [starPath stroke];
      }
    }
  }
  
	// Draw Points
  int i2;
  for (i2 = 0; i2 < [starmap count]; i2++) {
    Star *aStar = [starmap objectAtIndex:i2];
    
  	NSBezierPath * path;
  	int xPos = aStar.xPos;
  	int yPos = aStar.yPos;
    
    NSRect dotRect = NSMakeRect(xPos+width/2+(int)cameraOffset.x-2, yPos+height/2+(int)cameraOffset.y-2, 4, 4);
    path = [NSBezierPath bezierPathWithOvalInRect:dotRect];
    [[aStar starColor] set];
  	[path fill];
    
    path = [NSBezierPath bezierPathWithOvalInRect:NSInsetRect(dotRect, -4, -4)];
    [[[aStar starColor] colorWithAlphaComponent:0.2] set];
    [path setLineWidth:2];
  	[path stroke];
  }
  
  // Draw star names
  if (drawLabels) {
    int i3;
    for (i3 = 0; i3 < [starmap count]; i3++) {
      Star *aStar = [starmap objectAtIndex:i3];
      
      int xPos = aStar.xPos;
      int yPos = aStar.yPos;
      
      NSString *label = [NSString stringWithFormat:@"%@",aStar.starName];
      NSDictionary *attr = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:5],NSFontAttributeName,
                            [NSColor colorWithDeviceWhite:0.0 alpha:0.8],NSForegroundColorAttributeName,nil];
      [label drawAtPoint:NSMakePoint(xPos+width/2+(int)cameraOffset.x, yPos+height/2+(int)cameraOffset.y) withAttributes:attr];
    }
  }
}

- (void)mouseDown:(NSEvent *)theEvent
{
  mousePos = [self convertPoint:[theEvent locationInWindow] fromView:nil];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
  NSPoint dragPos = [self convertPoint:[theEvent locationInWindow] fromView:nil];
  cameraOffset = NSMakePoint(cameraOffset.x + (dragPos.x - mousePos.x), cameraOffset.y + (dragPos.y - mousePos.y));
  mousePos = dragPos;

  [self setNeedsDisplay:YES];
}


- (void)setNetworkSize:(int)aNetworkSize
{
  networkSize = aNetworkSize;
  [self generate:self];
  [self setNeedsDisplay:YES];
}

- (int)networkSize
{
  return networkSize;
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

- (void)setNetworkingStars:(BOOL)flag
{
  networkingStars = flag;
  [self generate:self];
  [self setNeedsDisplay:YES];
}

- (int)networkingStars
{
  return networkingStars;
}

@end
