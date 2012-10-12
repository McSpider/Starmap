//
//  Star.m
//  Starmap
//
//  Created by Ben K on 12/02/11.
//  All code is provided under the New BSD license.
//

#import "Star.h"

@implementation Star
@synthesize position;
@synthesize uid;
@synthesize seed;
@synthesize type;
@synthesize networkStar;
@synthesize starSystem;
// Pathfinding
@synthesize g, f, h;
@synthesize parentStar;
@synthesize neighbors;



- (id)init
{
  return [self initWithSeed:(uint)time(NULL)];
}

- (id)initWithSeed:(uint)aSeed
{
  if (!(self = [super init]))
    return nil;
  
  seed = aSeed;
  mtrand = [[MTRandom alloc] initWithSeed:aSeed];
  
  type = FIRST_STAR;
  uid = 0;
  position = NSZeroPoint;
  networkStar = nil;
  g = f = h = 0;
  parentStar = nil;
  neighbors = [[NSArray alloc] init];
  
  return self;
}

- (void)dealloc
{
  [neighbors release];
  [starSystem release];
  [super dealloc];
}


- (NSString *)description
{
  if (self.type == NETWORKING_STAR) {
    return [NSString stringWithFormat:@"Name: %@ \r\nParent: %@ \r\nNeighbors: %i \r\nType: %@",
            self.starName,self.networkStar.starName,[self.neighbors count],self.starType];
  }
  return [NSString stringWithFormat:@"Name: %@ \r\nNeighbors: %i \r\nType: %@",
          self.starName,[self.neighbors count],self.starType];
}

- (NSColor *)starColor
{
  if (type == PRIMARY_STAR)
    return [NSColor colorWithCalibratedRed:0.00 green:0.00 blue:0.80 alpha:1.00];
  if (type == NETWORKING_STAR)
    return [NSColor colorWithCalibratedRed:0.49 green:0.00 blue:0.80 alpha:1.00];
  if (type == SOLITARY_STAR)
    return [NSColor colorWithCalibratedRed:0.80 green:0.20 blue:0.00 alpha:1.00];
  return [NSColor colorWithCalibratedRed:0.20 green:0.20 blue:0.20 alpha:1.00];
}

- (NSString *)starName
{
  return self.starSystem.planet.name;
}

- (NSString *)randomStarName
{
  NSString *aName;
  NSArray *syllables = [NSArray arrayWithObjects:
                        @"en", @"la", @"can", @"be", @"and", @"phi", @"eth", @"ol",
                        @"ve", @"ho", @"a", @"lia", @"an", @"ar", @"ur", @"mi",
                        @"in", @"ti", @"qu", @"so", @"ed", @"ess", @"ex", @"io",
                        @"ce", @"ze", @"fa", @"ay", @"wa", @"da", @"ack", @"gre", nil];
  
  aName = [[NSString stringWithFormat:@"%@%@",
           [syllables objectAtIndex:[mtrand randomUInt32From:0 to:(uint)[syllables count] - 1]],
           [syllables objectAtIndex:[mtrand randomUInt32From:0 to:(uint)[syllables count] - 1]]]
           capitalizedString];
  
  // 10% chance that the name is only 2 syllables
  if ([mtrand randomUInt32From:0 to:100] > 10)
    aName = [aName stringByAppendingString:[syllables objectAtIndex:[mtrand randomUInt32From:0 to:(uint)[syllables count] - 1]]];
  
  // No canada tyvm.
  while ([aName isEqualToString:@"Canada"]) {
    aName = [self randomStarName];
  }
  
  if ([aName hasPrefix:@"Acki"]) {
    aName = [[aName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@"Å"] retain];
  }
  NSRange range = [aName rangeOfString:@"Faack"];
  if (range.location != NSNotFound) {
    aName = [self randomStarName];
    //aName = [[aName stringByReplacingCharactersInRange:range withString:@"Faick"] retain];
  }
  
  return aName;
}

- (NSString *)starType
{
  NSString *starType = @"First Star";
  if (self.type == PRIMARY_STAR)
    starType = @"Primary Star";
  if (self.type == NETWORKING_STAR)
    starType = @"Networking Star";
  if (self.type == SOLITARY_STAR)
    starType = @"Solitary Star";
  
  return starType;
}


@end
