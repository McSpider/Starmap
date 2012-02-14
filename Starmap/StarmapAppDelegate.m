//
//  StarmapAppDelegate.m
//  Starmap
//
//  Created by Benjamin Kohler on 12/02/11.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
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
  [starmap setStarmapSize:NSMakeSize(100, 100)];
  [starmap setStarmapShape:CIRCULAR_STARMAP];
  [starmap setStarmapStarCount:100];
  
  [starmap performSelectorInBackground:@selector(generateStarmap) withObject:nil];
}

- (void)dealloc
{
  [starmap release];
  [super dealloc];
}

- (void)awakeFromNib {
  [seedField setStringValue:@"23747"];
  [starsField setStringValue:@"100"];
  [radiusField setStringValue:@"100"];
  [xSizeField  setStringValue:@"500"];
  [ySizeField  setStringValue:@"500"];
  [networkSizeField setStringValue:@"106"];
  [statusField setStringValue:@""];

  [window center];
  [window zoom:self];
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

- (void)willCreateStarmap:(BOOL)flag
{
  if (flag == YES) {
    [statusField setStringValue:@"Generating Starmap"];
    [activityIndicator startAnimation:self];
    [generateButton setEnabled:NO];
  }
}

- (void)didCreateStarmap
{
  [statusField setStringValue:@"Starmap Created"];
  [activityIndicator stopAnimation:self];
  [generateButton setEnabled:YES];
  NSLog(@"Created Starmap");
  [mapView setStarmap:starmap];
  [mapView setNeedsDisplay:YES];
}

@end
