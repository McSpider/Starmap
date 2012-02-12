//
//  StarmapAppDelegate.h
//  Starmap
//
//  Created by Benjamin Kohler on 12/02/11.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface StarmapAppDelegate : NSObject <NSApplicationDelegate> {
  NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
