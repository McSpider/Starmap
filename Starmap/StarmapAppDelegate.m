//
//  StarmapAppDelegate.m
//  Starmap
//
//  Created by Ben K on 12/02/11.
//  All code is provided under the New BSD license.
//

#import "StarmapAppDelegate.h"

@implementation StarmapAppDelegate
@synthesize window,mapView;
@synthesize starmap;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  starmap = [[Starmap alloc] initWithSeed:23747];
  [starmap setDelegate:self];
  [starmap setGenerateNetworkingStars:YES];
  [starmap setNetworkSize:106];
  [starmap setNetworkStarMargin:3];
  [starmap setStarmapSize:NSMakeSize(200, 200)];
  [starmap setStarmapShape:CIRCULAR_STARMAP];
  [starmap setStarmapStarCount:100];

  [starmap performSelectorInBackground:@selector(generateStarmap) withObject:nil];
}

- (void)dealloc
{
  [starmap release];
  [super dealloc];
}

- (void)awakeFromNib
{
  [seedField setStringValue:@"23747"];
  [starsField setStringValue:@"100"];
  [radiusField setStringValue:@"200"];
  [xSizeField  setStringValue:@"500"];
  [ySizeField  setStringValue:@"500"];
  [networkSizeField setStringValue:@"106"];
  [statusField setStringValue:@""];
  [networkMarginField setStringValue:@"3"];
  [starMarginField setStringValue:@"5"];

  [window center];
  [window zoom:self];
}

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)anItem
{
	if (anItem.action == @selector(saveStarmapXML:)) {
		return starmap.starArray.count != 0;
	}
	return YES;
}


- (IBAction)saveStarmapXML:(id)sender
{  
  NSSavePanel *savepanel;
  
	savepanel = [NSSavePanel savePanel];
  [savepanel setAllowedFileTypes:[NSArray arrayWithObject:@"xml"]];
	[savepanel setCanSelectHiddenExtension:YES];
  [savepanel setNameFieldStringValue:@"Starmap_XML.xml"];
  [savepanel setMessage:@"Only saves what is currently visible."];
  
	/* if successful, save file under designated name */
	if ([savepanel runModal] == NSOKButton) {
		[[starmap xmlData] writeToURL:[savepanel URL] atomically:YES encoding:NSUTF8StringEncoding error:nil];
	}
}

- (IBAction)generate:(id)sender
{
  [starmap setSeed:[seedField intValue]];
  [starmap setNetworkSize:[networkSizeField intValue]];
  [starmap setGenerateNetworkingStars:[networkStarsCheck state]];
  [starmap setAlgorthm:(int)[algorithmSelector indexOfSelectedItem]];

  [starmap setStarmapSize:[self starmapSize]];
  [starmap setStarmapShape:(int)[shapeSelector selectedSegment]];
  [starmap setStarmapStarCount:[starsField intValue]];

  [starmap setNormalStarMargin:[starMarginField intValue]];
  [starmap setNetworkStarMargin:[networkMarginField intValue]];

  [starmap performSelectorInBackground:@selector(generateStarmap) withObject:nil];
}

- (NSSize)starmapSize
{
  NSSize mapSize;
  if ([shapeSelector selectedSegment] == 0) {
    mapSize = NSMakeSize([radiusField intValue], [radiusField intValue]);
  }
  else if ([shapeSelector selectedSegment] == 1) {
    mapSize = NSMakeSize([xSizeField intValue], [ySizeField intValue]);
  }
  return mapSize;
}

- (void)starmapGeneratorStarted
{
  [statusField setStringValue:@"Generating Starmap"];
  [activityIndicator startAnimation:self];
  [generateButton setEnabled:NO];
}

- (void)starmapGenerationFinishedWithTime:(float)time
{
  [statusField setStringValue:[NSString stringWithFormat:@"Starmap Created - Generation Time %fsec",time]];
  [activityIndicator stopAnimation:self];
  [generateButton setEnabled:YES];
  NSLog(@"Starmap Created");
  NSLog(@"Generation Time: %fsec",time);
  [mapView setStarmap:starmap];
  [mapView setNeedsDisplay:YES];

  if (starmap.starmapShape == CIRCULAR_STARMAP) {
    int starmapRadius = starmap.starmapSize.width;
    starmapRadius = sqrt(starmapRadius);
    starmapRadius *= 20*2;

    [statusField setStringValue:[NSString stringWithFormat:@"%@ - Actual Radius %i",[statusField stringValue],starmapRadius]];
  }
}

- (void)starmapGenerationTimedOutWithTime:(float)time
{
  [statusField setStringValue:[NSString stringWithFormat:@"Starmap Generator Timed Out - Generation Time %fsec",time]];
  [activityIndicator stopAnimation:self];
  [generateButton setEnabled:YES];
  NSLog(@"Starmap Generator Timed Out");
  NSLog(@"Generation Time: %fsec",time);
  [mapView setStarmap:starmap];
  [mapView setNeedsDisplay:YES];
}

@end
