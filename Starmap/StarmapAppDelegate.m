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
  [self performSelectorInBackground:@selector(generate:) withObject:self];
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
  [xSizeField setStringValue:@"500"];
  [ySizeField setStringValue:@"500"];
  [networkSizeField setStringValue:@"100"];
  [statusField setStringValue:@""];
  [networkMarginField setStringValue:@"6"];
  [nStarNeighborsField setStringValue:@"3"];
  [nStarMinNeighborsField setStringValue:@"2"];
  [starMarginField setStringValue:@"5"];
  
  [[settingsView textStorage] setDelegate:self];
  [settingsView setFont:[NSFont fontWithName:@"Menlo" size:12]];
  [settingsView setString:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SM_Generator" ofType:@"yml"] encoding:NSUTF8StringEncoding error:nil]];
  
  [statusField setStringValue:@"Opening Connection to Xyphon. Wayfarer Information Loaded."];

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

- (void)textStorageDidProcessEditing:(NSNotification *)notification
{
  NSTextStorage *textStorage = [notification object];
  NSColor *blue = [NSColor colorWithCalibratedRed:0.000 green:0.251 blue:0.502 alpha:1.000];
  NSRange found, area;
  NSString *string = [textStorage string];
  NSUInteger length = [string length];
  
  // remove the old colors
  area.location = 0;
  area.length = length;
  [textStorage removeAttribute:NSForegroundColorAttributeName range:area];
  
  // add new colors
  while (area.length) {
    found = [string rangeOfString:@":" 
                          options:NSCaseInsensitiveSearch 
                            range:area];
    if (found.location == NSNotFound) break;
    [textStorage addAttribute:NSForegroundColorAttributeName
                        value:blue
                        range:found];
    area.location = NSMaxRange(found);
    area.length = length - area.location;    
  }
}


- (IBAction)saveStarmapXML:(id)sender
{  
  NSSavePanel *savepanel;
  
	savepanel = [NSSavePanel savePanel];
  [savepanel setAllowedFileTypes:[NSArray arrayWithObject:@"xml"]];
	[savepanel setCanSelectHiddenExtension:YES];
  [savepanel setNameFieldStringValue:@"Starmap_XML.xml"];
  
	/* if successful, save file under designated name */
	if ([savepanel runModal] == NSOKButton) {
		[[starmap xmlDataWithNeighbors:YES] writeToURL:[savepanel URL] atomically:YES encoding:NSUTF8StringEncoding error:nil];
	}
}

- (IBAction)generate:(id)sender
{
  [starmap setSeed:[seedField intValue]];
  [starmap setNetworkSize:[networkSizeField intValue]];
  [starmap setGenerateNetworkingStars:([nStarNeighborsField intValue] <= 0?NO:YES)];

  [starmap setStarmapSize:NSMakeSize([xSizeField intValue], [ySizeField intValue])];
  [starmap setStarmapShape:(int)[shapeSelector selectedSegment]];
  [starmap setStarmapStarCount:[starsField intValue]];

  [starmap setNormalStarMargin:[starMarginField intValue]];
  [starmap setNetworkStarMargin:[networkMarginField intValue]];
  [starmap setNetworkStarNeighbors:[nStarNeighborsField intValue]];
  [starmap setNetworkStarMinNeighbors:[nStarMinNeighborsField intValue]];
  
  [starmap performSelectorInBackground:@selector(generateStarmap) withObject:nil];
}

- (void)starmapGeneratorStarted
{
  [statusField setStringValue:@"Generating Starmap"];
  [activityIndicator startAnimation:self];
  [generateButton setEnabled:NO];
}

- (void)starmapGenerationFinishedWithTime:(float)time
{
  [statusField setStringValue:[NSString stringWithFormat:@"Starmap Created - Generation Time %f sec",time]];
  [activityIndicator stopAnimation:self];
  [generateButton setEnabled:YES];
  NSLog(@"Starmap Created");
  NSLog(@"Generation Time: %fsec",time);
  [mapView setStarmap:starmap];
  [mapView setNeedsDisplay:YES];

  if (starmap.starmapShape == SHAPE_CIRCULAR) {
    float starmapRadius = starmap.starmapSize.width;
    [statusField setStringValue:[NSString stringWithFormat:@"%@ - Radius %.0f",[statusField stringValue],starmapRadius]];
  }
}

- (void)starmapGenerationTimedOutWithTime:(float)time
{
  [statusField setStringValue:[NSString stringWithFormat:@"Starmap Generator Timed Out - Generation Time %f sec",time]];
  [activityIndicator stopAnimation:self];
  [generateButton setEnabled:YES];
  NSLog(@"Starmap Generator Timed Out");
  NSLog(@"Generation Time: %fsec",time);
  [mapView setStarmap:starmap];
  [mapView setNeedsDisplay:YES];
}

@end
