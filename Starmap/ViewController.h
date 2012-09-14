//
//  ViewController.h
//  IRCBot
//
//  Created by Ben K on 2010/10/10.
//  All code is provided under the New BSD license. Copyright 2011 Ben K
//

#import <Cocoa/Cocoa.h>


@interface ViewController : NSObject {
	IBOutlet NSWindow *mainWindow;
  IBOutlet NSView *contentView;

	IBOutlet NSView *designView;
	IBOutlet NSView *previewView;
	
	IBOutlet NSToolbar *toolBar;
}

- (IBAction)changePanes:(id)sender;
- (void)setPane:(int)index;

@end
