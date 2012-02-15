//
//  StarmapView.h
//  Starmap
//
//  Created by Benjamin Kohler on 12/02/11.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Starmap.h"

@interface StarmapView : NSView {
  id delegate;

  NSPoint mousePos;
  NSPoint cameraOffset;
  BOOL wasDragging;
  int zoomFactor;

  BOOL drawNetwork;
  BOOL drawRings;
  BOOL drawLabels;

  Starmap *starmap;
  Star *selectedStar;
}

@property (nonatomic, readonly) Star *selectedStar;


- (IBAction)resetCamera:(id)sender;
- (IBAction)zoomCamera:(id)sender;

- (IBAction)saveToPDF:(id)sender;

- (void)setStarmap:(Starmap *)aStarmap;

@end
