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
@synthesize faction;
@synthesize technologyLevel;
@synthesize economy;
@synthesize produce;
@synthesize spaceports;
@synthesize moons;

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

- (NSString *)economyString
{
  NSString *money;
  if (technologyLevel > 5)
    money = @"Rich";
  else if (technologyLevel > 2)
    money = @"Average"; 
  else if (technologyLevel > 0)
    money = @"Poor";
  
  if (economy == ET_Agricultural)
    return [NSString stringWithFormat:@"%@ Agricultural",money];
  else if (economy == ET_Mining)
    return [NSString stringWithFormat:@"%@ Mining",money]; 
  else if (economy == ET_Industrial)
    return [NSString stringWithFormat:@"%@ Industrial",money];
  
  return @"NILL";
}

- (NSString *)typeString
{
  if (type == PT_Gas) {
    return @"Gas";
  }
  else if (type == PT_Desert) {
    return @"Desert";
  }
  else if (type == PT_Ocean) {
    return @"Ocean";
  }
  else if (type == PT_Jungle) {
    return @"Jungle";
  }
  else if (type == PT_Rock) {
    return @"Rock";
  }
  else if (type == PT_Ice) {
    return @"Ice";
  }
  else if (type == PT_Terra) {
    return @"Terra";
  }
  else if (type == PT_Snow) {
    return @"Snow";
  }
  
  return @"Xyphon";
}

- (NSColor *)mapColor
{
  if (type == PT_Gas) {
    return [NSColor colorWithCalibratedRed:0.30 green:0.03 blue:0.51 alpha:1.00];
  }
  else if (type == PT_Desert) {
    return [NSColor colorWithCalibratedRed:0.62 green:0.48 blue:0.05 alpha:1.00];
  }
  else if (type == PT_Ocean) {
    return [NSColor colorWithCalibratedRed:0.05 green:0.21 blue:0.62 alpha:1.00];
  }
  else if (type == PT_Jungle) {
    return [NSColor colorWithCalibratedRed:0.02 green:0.51 blue:0.06 alpha:1.00];
  }
  else if (type == PT_Rock) {
    return [NSColor colorWithCalibratedRed:0.41 green:0.39 blue:0.39 alpha:1.00];
  }
  else if (type == PT_Ice) {
    return [NSColor colorWithCalibratedRed:0.48 green:0.55 blue:0.69 alpha:1.00];
  }
  else if (type == PT_Terra) {
    return [NSColor colorWithCalibratedRed:0.30 green:0.15 blue:0.00 alpha:1.00];
  }
  else if (type == PT_Snow) {
    return [NSColor colorWithCalibratedRed:0.69 green:0.68 blue:0.71 alpha:1.00];
  }
  
  return [NSColor colorWithCalibratedRed:0.20 green:0.44 blue:0.39 alpha:1.00];
}

- (void)randomizeWithSeed:(uint)aSeed
{
  MTRandom *mtrand = [[MTRandom alloc] initWithSeed:aSeed];

  uint gov = [mtrand randomUInt32From:0 to:7];
  // 10% chance that the goverment becomes a pirate state
  if (gov == GT_Anarchy && ([mtrand randomUInt32From:0 to:100] < 10))
    gov = GT_Pirate_State;
  
  [self setGoverment:gov];
  [self setTechnologyLevel:(int)[mtrand randomUInt32From:0 to:7] + 1];
  
  float rTypeP = [mtrand randomDoubleFrom:0 to:7];
  // Causes types near the end and beginning of the list to be more common (I think so anyway :| )
  // Kinda works, what I really want is to assign a precentage to each type ie PT_Ocean has a 20% chance to appear.
  float nTypeV = 7*powf(sin(pi/7*rTypeP/2),3);
  [self setType:roundf(nTypeV)];  
  
  [self setEconomy:(int)[mtrand randomUInt32From:0 to:2]];
  
  while (((type == PT_Ice || type == PT_Gas) && economy == ET_Agricultural) ||
         ((type == PT_Gas) && economy == ET_Industrial))
    [self setEconomy:(int)[mtrand randomUInt32From:0 to:2]];
  
  [mtrand release];
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
  return [self initWithName:@"NULL" andSeed:(uint)time(NULL)];
}

- (id)initWithName:(NSString *)aName andSeed:(uint)aSeed
{
  if (!(self = [super init]))
    return nil;
  
  // Initialization code here.
  mtrand = [[MTRandom alloc] initWithSeed:aSeed];
  
  size = NSMakeSize(256, 256);
  shape = SHAPE_CIRCULAR;
  sectorSize = 32;
  group = 0;
  planet = [[SystemPlanet alloc] initWithName:aName];
  [planet randomizeWithSeed:aSeed];
  
  warpZonePosition = NSMakePoint([mtrand randomDoubleFrom:0 to:size.width]-size.width/2, [mtrand randomDoubleFrom:0 to:size.height]-size.height/2);
  warpZoneRadius = [mtrand randomUInt32From:5 to:20];
  
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
  return [NSString stringWithFormat:@"%@ Star System \nGoverment: %@ \nTech Level: %i \nType: %@ \nEconomy: %@\nGroup: %i\n",[planet name],[planet govermentString],[planet technologyLevel],[planet typeString],[planet economyString],group];
}

- (NSString *)description
{
  return [self systemInfo];
}

@end
