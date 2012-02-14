//
//  Star.m
//  Starmap
//
//  Created by Benjamin Kohler on 12/02/11.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Star.h"

@implementation Star
@synthesize starPos;
@synthesize type;
@synthesize neighbors;


- (id)init
{
  if ((self = [super init])) {
    type = FIRST_STAR;
    starPos = NSZeroPoint;
    
    neighbors = [[NSArray alloc] init];
    
    NSArray *syllables = [NSArray arrayWithObjects: 
                          @"en", @"la", @"can", @"be", @"and", @"phi", @"eth", @"ol",
                          @"ve", @"ho", @"a", @"lia", @"an", @"ar", @"ur", @"mi",
                          @"in", @"ti", @"qu", @"so", @"ed", @"ess", @"ex", @"io",
                          @"ce", @"ze", @"fa", @"ay", @"wa", @"da", @"ack", @"gre", nil];
    
    // use random() istead of rand() to prevent changes to the starmap
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
    
  }
  
  return self;
}

- (void)dealloc
{
  [name release];
  [neighbors release];
  [super dealloc];
}


- (NSColor *)starColor
{
  if (type == PRIMARY_STAR)
    return [NSColor colorWithCalibratedRed:0.00 green:0.00 blue:0.80 alpha:1.00];
  if (type == NETWORKING_STAR)
    return [NSColor colorWithCalibratedRed:0.49 green:0.00 blue:0.80 alpha:1.00];
  return [NSColor colorWithCalibratedRed:0.20 green:0.20 blue:0.20 alpha:1.00];
}

- (NSString *)starName
{
  return name;
}


@end
