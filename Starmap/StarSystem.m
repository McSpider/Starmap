//
//  SystemPlanet.m
//  Starmap
//
//  Created by Benjamin Kohler on 12/09/11.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "StarSystem.h"
#import "Star.h"

@implementation SystemPlanet
@synthesize name;
@synthesize type;
@synthesize size;
@synthesize position;
@synthesize habitable;
@synthesize temperature;
@synthesize goverment;
@synthesize technologyLevel;
@synthesize produce;
@synthesize spaceports;

- (id)init
{
  return [self initWithName:@"NULL"];
}

- (id)initWithName:(NSString *)aName
{
  self = [super init];
  if (!(self = [super init]))
    return nil;
  
  // Initialization code here.
  self.name = aName;
  
  return self;
}

- (NSString *)planetInfo
{
  return @"NULL";
}

- (NSString *)govermentString
{
  if (goverment == GT_Anarchy)
    return @"Anarchy";
  else if (goverment == GT_Democracy)
    return @"Democracy"; 
  else if (goverment == GT_Feudal)
    return @"Feudal";
  else if (goverment == GT_Communist)
    return @"Communist";
  else if (goverment == GT_Multi_Government)
    return @"Multi Goverment";
  else if (goverment == GT_Dictatorship)
    return @"Dictatorship";
  else if (goverment == GT_Confederacy)
    return @"Confederacy";
  else if (goverment == GT_Corporate_State)
    return @"Corporate State";
  
  return @"Pirate State";
}

- (NSString *)economy
{
  return @"NULL";
}


@end



#pragma mark -

//
//  SystemPlanet.m
//  Starmap
//
//  Created by Benjamin Kohler on 12/09/11.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

@implementation SystemStation

- (id)init
{
  self = [super init];
  if (self) {
    // Initialization code here.
  }
  
  return self;
}

- (NSString *)portInfo
{
  return @"NULL";
}


@end



#pragma mark -

//
//  StarSystem.m
//  Starmap
//
//  Created by Benjamin Kohler on 12/09/03.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

@implementation StarSystem
@synthesize size;
@synthesize shape;
@synthesize sectorSize;
@synthesize planet;

- (id)init
{
  return [self initWithName:@"NULL" andSeed:(uint)time(NULL)];
}

- (id)initWithName:(NSString *)aName andSeed:(uint)aSeed
{
  if (!(self = [super init]))
    return nil;
  
  // Initialization code here.
  mtrand = [[MTRandom alloc] initWithSeed:aSeed];
  
  size = NSMakeSize(512, 512);
  shape = SHAPE_CIRCULAR;
  sectorSize = 64;
  planet = [[SystemPlanet alloc] initWithName:aName];
  uint gov = [mtrand randomUInt32From:0 to:7];
  // 10% chance that the goverment becomes a pirate state
  if (gov == GT_Anarchy && ([mtrand randomUInt32From:0 to:100] < 10))
    gov = GT_Pirate_State;
  
  [planet setGoverment:gov];
  [planet setTechnologyLevel:(int)[mtrand randomUInt32From:0 to:7] + 1];
  
  return self;
}

- (void)dealloc
{
  [mtrand release];
  [planet release];
  [super dealloc];
}

- (NSString *)systemInfo
{
  return [NSString stringWithFormat:@"%@ Star System - Goverment: %@, Tech Level: %i",[planet name],[planet govermentString],[planet technologyLevel]];
}


@end
