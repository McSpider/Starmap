//
//  Pathfinder.h
//  Starmap
//
//  Created by Ben K on 12/02/15.
//  All code is provided under the New BSD license.
//

#import <Foundation/Foundation.h>
#import "Star.h"

#define A_STAR 0
#define DJIKSTRA 1

@interface Pathfinder : NSObject {
  
  NSDate *pathfinderStartTime;
  
  int pathfinderType;
}

@property int pathfinderType;

- (NSArray *)runPathfinderWithStars:(NSArray *)nodeData fromStar:(Star *)fromStar toStar:(Star *)toStar;

- (int)heuristicForStar:(Star *)fromStar toStar:(Star *)toStar travelCost:(int)cost;

@end
