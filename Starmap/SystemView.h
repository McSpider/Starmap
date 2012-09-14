//
//  SystemView.h
//  Starmap
//
//  Created by Benjamin Kohler on 12/09/03.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Star;

@interface SystemView : NSView {
  NSPoint mousePos;
  NSPoint cameraOffset;
  BOOL wasDragging;
  
  Star *activeStar;
  
  uint sectorSize;
}

@property (nonatomic, assign) Star *activeStar;
@property uint sectorSize;

@end
