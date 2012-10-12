//
//  Pathfinder.m
//  Starmap
//
//  Created by Ben K on 12/02/15.
//  All code is provided under the New BSD license.
//

#import "Pathfinder.h"
#import "Star.h"

@implementation Pathfinder
@synthesize pathfinderType;

- (id)init
{
  if (!(self = [super init]))
    return nil;
  
  pathfinderType = DJIKSTRA;
  return self;
}

- (int)heuristicForStar:(Star *)fromStar toStar:(Star *)toStar travelCost:(int)cost
{
  // A Star pathfinding uses heristics Djikstra's doesn't.
  if (pathfinderType == A_STAR) {
    float dx = fromStar.position.x - toStar.position.x;
    float dy = fromStar.position.y - toStar.position.y;
    return sqrt( dx * dx + dy * dy ) * cost;
  }
  // pathfinderType == DJIKSTRA
  return 0;
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
  pathfinderStartTime = [[NSDate date] retain];
  // G . the exact cost to reach this node from the starting node.
  // H . the estimated(heuristic) cost to reach the destination from here.
  // F = G + H . As the algorithm runs the F value of a node tells us how expensive we think it will be to reach our goal by way of that node.
  
  // create the open list of nodes, initially containing only our starting node
  NSMutableArray *openStars = [[NSMutableArray alloc] init];
  // create the closed list of nodes, initially empty
  NSMutableArray *closedStars = [[NSMutableArray alloc] init];
  
  
  Star *currentStar;
  currentStar = fromStar;
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
      [openStars release];
      [closedStars release];
      return nil;
    }
    [openStars sortUsingFunction:numericSort context:NULL];
    currentStar = [openStars objectAtIndex:0];
    [openStars removeObjectAtIndex:0];
  }
  
  [openStars release];
  [closedStars release];
  
  NSMutableArray *path = [[NSMutableArray alloc] init];
  Star *star = toStar;
  [path addObject:star];
  while (star != fromStar) {
    star = star.parentStar;
    [path insertObject:star atIndex:0];
  }
  
  // Get run time
  NSLog(@"Pathfinder Time: %fsec",[[NSDate date] timeIntervalSinceDate:pathfinderStartTime]);
  [pathfinderStartTime release];
  
  return [NSArray arrayWithArray:[path autorelease]];
}

@end
