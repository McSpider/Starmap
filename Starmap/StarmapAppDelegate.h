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
  
  StarmapView *mainView;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet StarmapView *mainView;

@end
