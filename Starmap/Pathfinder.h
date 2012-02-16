//
//  Pathfinder.h
//  Starmap
//
//  Created by Benjamin Kohler on 12/02/15.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Star.h"

@interface Pathfinder : NSObject {
  
  
}

- (NSArray *)runPathfinderWithStars:(NSArray *)nodeData fromStar:(Star *)fromStar toStar:(Star *)toStar;

- (int)heuristicForStar:(Star *)fromStar toStar:(Star *)toStar travelCost:(int)cost;

@end
