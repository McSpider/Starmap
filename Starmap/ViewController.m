//
//  ViewController.m
//  IRCBot
//
//  Created by Ben K on 2010/10/10.
//  All code is provided under the New BSD license. Copyright 2011 Ben K
//

#import "ViewController.h"
#define WINDOW_TOOLBAR_HEIGHT 62


@implementation ViewController

- (void)awakeFromNib
{
  [toolBar setSelectedItemIdentifier:@"Design"];
  [self setPane:0];
  [mainWindow center];
}

- (void)windowDidResignKey:(NSNotification *)notification
{
	if ([notification object] == mainWindow) {
		// Save settings
	}
}

- (IBAction)changePanes:(id)sender
{
	NSView *view = nil;
	BOOL changePane = YES;
	
	switch ([sender tag]) {
		case 0:
			if ([[mainWindow title] isEqualToString:@"Starmap - Design"])
				changePane = NO;
			[mainWindow setTitle:@"Starmap - Design"];
			view = designView;
			break;
		case 1:
			if ([[mainWindow title] isEqualToString:@"Starmap - Map Preview"])
				changePane = NO;
			[mainWindow setTitle:@"Starmap - Map Preview"];
			view = previewView;
			break;
		default:
			[mainWindow setTitle:@"Starmap - Design"];
			view = designView;
			break;
	}
	
	// Don't replace the contents of a pane if they're the same
	if (changePane) {
		NSRect windowFrame = [mainWindow frame];
		windowFrame.origin.y = NSMaxY([mainWindow frame]) - ([view frame].size.height + WINDOW_TOOLBAR_HEIGHT);
		windowFrame.origin.x = windowFrame.origin.x + (windowFrame.size.width-[view frame].size.width)/2;
		windowFrame.size.height = [view frame].size.height + WINDOW_TOOLBAR_HEIGHT;
		windowFrame.size.width = [view frame].size.width;
		
		
		if ([[contentView subviews] count] != 0) {
			[[[contentView subviews] objectAtIndex:0] removeFromSuperview];
		}
		
		//[mainWindow setFrame:windowFrame display:YES animate:YES];
		//[contentView setFrame:[view frame]];
    [view setFrame:contentView.frame];
		[contentView addSubview:view];
		[view setAlphaValue:0.0];
		[[view animator] setAlphaValue:1.0]; // fade in
		[mainWindow recalculateKeyViewLoop];
	}
}

- (void)setPane:(int)index
{
	NSView *view = nil;
	
	switch (index) {
		case 0:
			[mainWindow setTitle:@"Starmap - Design"];
			view = designView;
			break;
		case 1:
			[mainWindow setTitle:@"Starmap - Map Preview"];
			view = previewView;
			break;
		default:
			[mainWindow setTitle:@"Starmap - Design"];
			view = designView;
			break;
	}
	
	NSRect windowFrame = [mainWindow frame];
	windowFrame.size.height = [view frame].size.height + WINDOW_TOOLBAR_HEIGHT;
	windowFrame.size.width = [view frame].size.width;
	windowFrame.origin.y = NSMaxY([mainWindow frame]) - ([view frame].size.height + WINDOW_TOOLBAR_HEIGHT);
	
	if ([[contentView subviews] count] != 0) {
		[[[contentView subviews] objectAtIndex:0] removeFromSuperview];
	}
	
	//[mainWindow setFrame:windowFrame display:YES animate:YES];
	//[contentView setFrame:[view frame]];
  [view setFrame:contentView.frame];
	[contentView addSubview:view];
	[mainWindow recalculateKeyViewLoop];
}

@end
