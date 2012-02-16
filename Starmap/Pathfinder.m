//
//  Pathfinder.m
//  Starmap
//
//  Created by Benjamin Kohler on 12/02/15.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Pathfinder.h"
#import "Star.h"

@implementation Pathfinder

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (int)heuristicForStar:(Star *)fromStar toStar:(Star *)toStar travelCost:(int)cost
{
  int dx = fromStar.starPos.x - toStar.starPos.x;
	int dy = fromStar.starPos.y - toStar.starPos.y;
	return sqrt( dx * dx + dy * dy ) * cost;
}

static NSInteger numericSort(id star1, id star2, void *context) {
  int num1 = [(Star *)star1 f];
  int num2 = [(Star *)star2 f];
  
  if (num1 < num2)
    return NSOrderedAscending;
  else if (num1 > num2)
    return NSOrderedDescending;
  
  return NSOrderedSame;
}

- (NSArray *)runPathfinderWithStars:(NSArray *)starData fromStar:(Star *)fromStar toStar:(Star *)toStar
{
  // G . the exact cost to reach this node from the starting node.
  // H . the estimated(heuristic) cost to reach the destination from here.
  // F = G + H . As the algorithm runs the F value of a node tells us how expensive we think it will be to reach our goal by way of that node.
  
  // create the open list of nodes, initially containing only our starting node
  NSMutableArray *openStars = [[NSMutableArray alloc] init];
  // create the closed list of nodes, initially empty
  NSMutableArray *closedStars = [[NSMutableArray alloc] init];
  
  
  Star *currentStar;
  currentStar = [starData objectAtIndex:0];
  Star *testStar;
  NSArray *connectedNodes;
  int travelCost = 1.0;
  int g,h,f;
  [currentStar setG:0];
  [currentStar setH:[self heuristicForStar:currentStar toStar:toStar travelCost:travelCost]];
  [currentStar setF:currentStar.g + currentStar.h];
  int l = (int)[starData count];
  int i;
    
  while (currentStar != toStar) {
    connectedNodes = currentStar.neighbors;
    l = (int)[connectedNodes count];
    for (i = 0; i < l; ++i) {
      testStar = [connectedNodes objectAtIndex:i];
      if (testStar == currentStar) continue;
      g = currentStar.g  + travelCost;
      h = [self heuristicForStar:testStar toStar:toStar travelCost:travelCost];
      f = g + h;
      if ([openStars containsObject:testStar] || [closedStars containsObject:testStar])	{
        if(testStar.f > f)
        {
          testStar.f = f;
          testStar.g = g;
          testStar.h = h;
          testStar.parentStar = currentStar;
        }
      } else {
        testStar.f = f;
        testStar.g = g;
        testStar.h = h;
        testStar.parentStar = currentStar;
        [openStars addObject:testStar ];
      }
    }
    [closedStars addObject:currentStar];
    if ([openStars count] == 0) {
      return nil;
    }
    [openStars sortUsingFunction:numericSort context:NULL];
    currentStar = [openStars objectAtIndex:0];
    [openStars removeObjectAtIndex:0];
  }
  
  
  NSLog(@"Stars %@",starData);
  
  NSMutableArray *path = [[NSMutableArray alloc] init];
  Star *star = toStar;
  [path addObject:star];
  while (star != fromStar) {
    star = star.parentStar;
    [path insertObject:star atIndex:0];
  }
  NSLog(@"Finished Path %@",path);
  return [NSArray arrayWithArray:[path autorelease]];
}

@end
