//
//  Settings.m
//  Starmap
//
//  Created by Benjamin Kohler on 12/10/14.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Settings.h"

@implementation Settings
@synthesize maxTechLevel;
@synthesize planetTypeSet;
@synthesize govermentTypeSet;

- (id)init
{
  if (!(self = [super init]))
    return nil;
  
  // Initialization code here.
  maxTechLevel = 8;

  NSArray *planetTypes = [NSArray arrayWithObjects:@"Gas", @"Desert", @"Jungle", @"Terra", @"Ocean", @"Snow", @"Ice", @"Rock", nil];
  NSArray *pTypeWeights = [NSArray arrayWithObjects:@"11", @"9", @"3", @"4", @"1", @"6", @"8", @"9", nil];
  planetTypeSet = [[NSDictionary dictionaryWithObjects:pTypeWeights forKeys:planetTypes] retain];
  
  
  NSArray *govermentTypes = [NSArray arrayWithObjects:@"Anarchy", @"Democracy", @"Feudal", @"Communist", @"Multi Government", @"Dictatorship", @"Confederacy", @"Corporate State", @"Pirate State", nil];
  NSArray *gTypeWeights = [NSArray arrayWithObjects:@"5", @"5", @"5", @"5", @"5", @"5", @"5", @"5", @"0", nil];
  govermentTypeSet = [[NSDictionary dictionaryWithObjects:gTypeWeights forKeys:govermentTypes] retain];
  
  return self;
}

- (void)dealloc
{
  [planetTypeSet release];
  [govermentTypeSet release];
  [super dealloc];
}

@end
