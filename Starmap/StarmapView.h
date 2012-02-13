//
//  StarmapView.h
//  Starmap
//
//  Created by Benjamin Kohler on 12/02/11.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Star.h"

@interface StarmapView : NSView {
  
  IBOutlet NSTextField *seedField;
  IBOutlet NSTextField *starsField;
  IBOutlet NSTextField *sizeField;
  IBOutlet NSPopUpButton *algorithmSelector;
  BOOL networkingStars;

  
  unsigned int seed;
  NSMutableArray *starmap;
  
  NSPoint mousePos;
  NSPoint cameraOffset;
  int zoomFactor;
  
  int networkSize;
  BOOL drawNetwork;
  BOOL drawRings;
  BOOL drawLabels;
}

- (IBAction)generate:(id)sender;
- (IBAction)resetCamera:(id)sender;
- (IBAction)zoomCamera:(id)sender;


- (void)generateStarmapWithSeed:(unsigned int)seed starAmount:(int)stars size:(int)size;

@end
