//
//  StarmapAppDelegate.h
//  Starmap
//
//  Created by Ben K on 12/02/11.
//  All code is provided under the New BSD license.
//

#import <Cocoa/Cocoa.h>
#import "StarmapView.h"

@interface StarmapAppDelegate : NSObject <NSApplicationDelegate, NSTextStorageDelegate> {
  NSWindow *window;
  NSWindow *settingsWindow;
  StarmapView *mapView;

  IBOutlet NSTextField *seedField;
  IBOutlet NSTextField *starsField;
  IBOutlet NSTextField *xSizeField;
  IBOutlet NSTextField *ySizeField;
  IBOutlet NSTextField *networkSizeField;
  IBOutlet NSTextField *starMarginField;
  IBOutlet NSTextField *networkMarginField;
  IBOutlet NSTextField *nStarNeighborsField;
  IBOutlet NSTextField *nStarMinNeighborsField;
  
  IBOutlet NSTextField *statusField;
  IBOutlet NSSegmentedControl *shapeSelector;

  IBOutlet NSButton *generateButton;
  IBOutlet NSProgressIndicator *activityIndicator;


  Starmap *starmap;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSWindow *settingsWindow;
@property (assign) IBOutlet StarmapView *mapView;

@property (nonatomic, assign) Starmap *starmap;

- (IBAction)generate:(id)sender;
- (IBAction)generateRandomSeed:(id)sender;
- (IBAction)saveStarmapXML:(id)sender;

@end
