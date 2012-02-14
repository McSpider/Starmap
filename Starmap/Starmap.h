//
//  Starmap.h
//  Starmap
//
//  Created by Benjamin Kohler on 12/02/13.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Star.h"

#define CIRCULAR_STARMAP 0
#define RECTANGULAR_STARMAP 1

#define STARMAP_RANDOM_ALGO 0
#define STARMAP_RECURSIVE_ALGO 1
#define STARMAP_MIXED_ALGO 2

@interface Starmap : NSObject {
  
  unsigned int seed;
  int algorthm;
  int networkSize;
  int networkStarMargin;
  BOOL generateNetworkingStars;
  
  int starmapShape;
  NSSize starmapSize;

  NSMutableArray *starArray;
}

@property unsigned int seed;
@property int algorthm;
@property int networkSize;
@property int networkStarMargin;
@property BOOL generateNetworkingStars;
@property int starmapShape;
@property NSSize starmapSize;

- (id)initWithSeed:(uint)aSeed;

- (void)generateStarmapWithStars:(int)stars size:(NSSize)size ofType:(int)type;

- (BOOL)goodStarPosition:(NSPoint)pos checkDistance:(int)checkDist;
- (NSArray *)neighborStarsForStar:(Star *)theStar checkDistance:(int)checkDist;


- (NSArray *)starArray;

@end
