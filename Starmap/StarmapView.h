//
//  StarmapView.h
//  Starmap
//
//  Created by Ben K on 12/02/11.
//  All code is provided under the New BSD license.
//

#import <Cocoa/Cocoa.h>
#import "Starmap.h"
#import "Pathfinder.h"
#import "SystemView.h"

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
  Star *firstStar;
  
  NSArray *selectedStarPath;
  
  IBOutlet SystemView *systemView;
}

@property (nonatomic, readonly) Star *selectedStar;
@property (nonatomic, assign) SystemView *systemView;


- (IBAction)resetCamera:(id)sender;
- (IBAction)zoomCamera:(id)sender;

- (IBAction)saveToPDF:(id)sender;

- (void)setStarmap:(Starmap *)aStarmap;

@end
