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
@synthesize goverment;
@synthesize size;
@synthesize position;
@synthesize habitable;
@synthesize temperature;
@synthesize faction;
@synthesize technologyLevel;
@synthesize economy;
@synthesize produce;
@synthesize spaceports;
@synthesize moons;

- (id)init
{
  self = [super init];
  if (!(self = [super init]))
    return nil;

  // Initialization code here.

  
  return self;
}

- (NSString *)planetInfo
{
  return @"NULL";
}


- (NSString *)economyString
{
  NSString *money = [[NSString alloc] init];
  if (technologyLevel > 5)
    money = @"Rich";
  else if (technologyLevel > 2)
    money = @"Average"; 
  else if (technologyLevel > 0)
    money = @"Poor";
  
  if (economy == ET_Agricultural)
    return [NSString stringWithFormat:@"%@ Agricultural",[money autorelease]];
  else if (economy == ET_Mining)
    return [NSString stringWithFormat:@"%@ Mining",[money autorelease]]; 
  else if (economy == ET_Industrial)
    return [NSString stringWithFormat:@"%@ Industrial",[money autorelease]];
  
  return @"NILL";
}

- (NSColor *)mapColor
{
  if ([type isEqualToString:@"Gas"]) {
    return [NSColor colorWithCalibratedRed:0.30 green:0.03 blue:0.51 alpha:1.00];
  }
  else if ([type isEqualToString:@"Desert"]) {
    return [NSColor colorWithCalibratedRed:0.62 green:0.48 blue:0.05 alpha:1.00];
  }
  else if ([type isEqualToString:@"Ocean"]) {
    return [NSColor colorWithCalibratedRed:0.05 green:0.21 blue:0.62 alpha:1.00];
  }
  else if ([type isEqualToString:@"Jungle"]) {
    return [NSColor colorWithCalibratedRed:0.02 green:0.51 blue:0.06 alpha:1.00];
  }
  else if ([type isEqualToString:@"Rock"]) {
    return [NSColor colorWithCalibratedRed:0.41 green:0.39 blue:0.39 alpha:1.00];
  }
  else if ([type isEqualToString:@"Ice"]) {
    return [NSColor colorWithCalibratedRed:0.48 green:0.55 blue:0.69 alpha:1.00];
  }
  else if ([type isEqualToString:@"Terra"]) {
    return [NSColor colorWithCalibratedRed:0.30 green:0.15 blue:0.00 alpha:1.00];
  }
  else if ([type isEqualToString:@"Snow"]) {
    return [NSColor colorWithCalibratedRed:0.69 green:0.68 blue:0.71 alpha:1.00];
  }
  
  return [NSColor colorWithCalibratedRed:0.20 green:0.44 blue:0.39 alpha:1.00];
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
@synthesize group;
@synthesize planet;
@synthesize warpZonePosition;
@synthesize warpZoneRadius;


- (id)init
{
  if (!(self = [super init]))
    return nil;

  // Initialization code here.  
  size = NSMakeSize(256, 256);
  shape = SHAPE_CIRCULAR;
  sectorSize = 32;
  group = 0;
  planet = [[SystemPlanet alloc] init];
  
  warpZonePosition = NSZeroPoint;
  warpZoneRadius = 20;
  
  return self;
}

- (void)dealloc
{
  [planet release];
  [super dealloc];
}

- (NSString *)systemInfo
{
  return [NSString stringWithFormat:@"%@ Star System \nGoverment: %@ \nTech Level: %i \nType: %@ \nEconomy: %@\nGroup: %i\n",[planet name],[planet goverment],[planet technologyLevel],[planet type],[planet economyString],group];
}

- (NSString *)description
{
  return [self systemInfo];
}

@end
