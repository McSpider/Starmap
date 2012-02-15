//
//  StarmapAppDelegate.h
//  Starmap
//
//  Created by Benjamin Kohler on 12/02/11.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "StarmapView.h"

@interface StarmapAppDelegate : NSObject <NSApplicationDelegate> {
  NSWindow *window;
  StarmapView *mapView;

  IBOutlet NSTextField *seedField;
  IBOutlet NSTextField *starsField;
  IBOutlet NSTextField *radiusField;
  IBOutlet NSTextField *xSizeField;
  IBOutlet NSTextField *ySizeField;
  IBOutlet NSTextField *networkSizeField;
  IBOutlet NSTextField *starMarginField;
  IBOutlet NSTextField *networkMarginField;

  IBOutlet NSTextField *statusField;
  IBOutlet NSButton *networkStarsCheck;
  IBOutlet NSPopUpButton *algorithmSelector;
  IBOutlet NSSegmentedControl *shapeSelector;
  IBOutlet NSTabView *sizeTabView;

  IBOutlet NSButton *generateButton;

  IBOutlet NSProgressIndicator *activityIndicator;


  Starmap *starmap;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet StarmapView *mapView;

@property (nonatomic, assign) Starmap *starmap;

- (IBAction)generate:(id)sender;
- (NSSize)starmapSize;

@end
