//
//  Star.m
//  Starmap
//
//  Created by Ben K on 12/02/11.
//  All code is provided under the New BSD license.
//

#import "Star.h"

@implementation Star
@synthesize starPos;
@synthesize type;
@synthesize networkStar;
@synthesize g, f, h;
@synthesize parentStar;
@synthesize neighbors;



- (id)init
{
  if ((self = [super init])) {
    type = FIRST_STAR;
    starPos = NSZeroPoint;
    networkStar = nil;
    g = f = h = 0;
    parentStar = nil;
    neighbors = [[NSArray alloc] init];

    NSArray *syllables = [NSArray arrayWithObjects:
                          @"en", @"la", @"can", @"be", @"and", @"phi", @"eth", @"ol",
                          @"ve", @"ho", @"a", @"lia", @"an", @"ar", @"ur", @"mi",
                          @"in", @"ti", @"qu", @"so", @"ed", @"ess", @"ex", @"io",
                          @"ce", @"ze", @"fa", @"ay", @"wa", @"da", @"ack", @"gre", nil];

    // use random() instead of rand() to prevent changes to the starmap
    name = [[[NSString stringWithFormat:@"%@%@%@",
              [syllables objectAtIndex:random() % [syllables count]],
              [syllables objectAtIndex:random() % [syllables count]],
              [syllables objectAtIndex:random() % [syllables count]]]
             capitalizedString] retain];

    // No canada tyvm.
    while ([name isEqualToString:@"Canada"]) {
      NSLog(@"Regenerating Canada");
      name = [[[NSString stringWithFormat:@"%@%@%@",
                [syllables objectAtIndex:random() % [syllables count]],
                [syllables objectAtIndex:random() % [syllables count]],
                [syllables objectAtIndex:random() % [syllables count]]]
               capitalizedString] retain];
    }

    if ([name hasPrefix:@"Acki"]) {
      name = [[[name autorelease] stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@"Å"] retain];
    }
    else if ([name hasPrefix:@"Faack"]) {
      name = [[[name autorelease] stringByReplacingCharactersInRange:NSMakeRange(2, 3) withString:@"i"] retain];
    }
  }

  return self;
}

- (void)dealloc
{
  [name release];
  [neighbors release];
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
  return name;
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
