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
  [starmap setGenerateNetworkingStars:YES];
  [starmap setNetworkSize:106];
  [starmap setNetworkStarMargin:3];
  [starmap generateStarmapWithStars:100 size:NSMakeSize(100, 100) ofType:CIRCULAR_STARMAP];
  [mapView setStarmap:starmap];
  [mapView setNeedsDisplay:YES];
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
  [networkSizeSlider setIntValue:106];

  [window center];
  [window zoom:self];
}


- (IBAction)generate:(id)sender
{  
  [starmap setSeed:[seedField intValue]];
  [starmap setNetworkSize:[networkSizeSlider intValue]];
  [starmap setGenerateNetworkingStars:[networkStarsCheck state]];
  [starmap setAlgorthm:(int)[algorithmSelector indexOfSelectedItem]];
  [starmap generateStarmapWithStars:[starsField intValue] size:[self starmapSize] ofType:(int)[shapeSelector selectedSegment]];
  
  [mapView setStarmap:starmap];
  [mapView setNeedsDisplay:YES];
}


- (IBAction)changeMapShape:(id)sender
{
  [sizeTabView selectTabViewItemAtIndex:[sender indexOfSelectedItem]];
}

- (IBAction)toggleNetworkStars:(id)sender
{
  [starmap setGenerateNetworkingStars:[sender state]];
  [starmap generateStarmapWithStars:[starsField intValue] size:[self starmapSize] ofType:(int)[shapeSelector selectedSegment]];
  
  [mapView setStarmap:starmap];
  [mapView setNeedsDisplay:YES];
}

- (IBAction)changeNetworkSize:(id)sender
{
  [starmap setNetworkSize:[sender intValue]];
  [starmap generateStarmapWithStars:[starsField intValue] size:[self starmapSize] ofType:(int)[shapeSelector selectedSegment]];
  
  [mapView setStarmap:starmap];
  [mapView setNeedsDisplay:YES];
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

@end
