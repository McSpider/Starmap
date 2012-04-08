//
//  Starmap.m
//  Starmap
//
//  Created by Ben K on 12/02/13.
//  All code is provided under the New BSD license.
//

#import "Starmap.h"

@implementation Starmap
@synthesize delegate;
@synthesize seed;
@synthesize algorthm;
@synthesize networkSize;
@synthesize networkStarMargin,normalStarMargin;
@synthesize generateNetworkingStars;
@synthesize removeSolitaryStars;
@synthesize starmapShape;
@synthesize starmapSize;
@synthesize starmapStarCount;

- (id)init
{
  return [self initWithSeed:(uint)time(NULL)];
}

- (id)initWithSeed:(uint)aSeed
{
  if ((self = [super init])) {
    // Initialization code here.
    seed = aSeed;
    networkSize = 100;
    normalStarMargin = 5;
    networkStarMargin = 3;
    generateNetworkingStars = YES;
    removeSolitaryStars = NO;
    algorthm = STARMAP_RANDOM_ALGO;
    starmapShape = CIRCULAR_STARMAP;
    starmapSize = NSMakeSize(100, 100);
    starmapStarCount = 100;

    starArray = [[NSMutableArray alloc] init];
  }

  return self;
}

- (void)dealloc
{
  [starArray release];
  [super dealloc];
}


- (void)generateStarmap
{
  if (generatingStarmap)
    return;

  generatingStarmap = YES;
  if ([delegate respondsToSelector:@selector(starmapGeneratorStarted)]) {
    [delegate starmapGeneratorStarted];
  }
  generatorStartTime = [[NSDate date] retain];
  int result = [self generateStarmapWithStars:starmapStarCount size:starmapSize ofType:starmapShape];

  generatingStarmap = NO;
  if (result == 0) {
    if ([delegate respondsToSelector:@selector(starmapGenerationFinishedWithTime:)]) {
      [delegate starmapGenerationFinishedWithTime:[[NSDate date] timeIntervalSinceDate:generatorStartTime]];
    }
  }
  else if (result == 1) {
    if ([delegate respondsToSelector:@selector(starmapGenerationTimedOutWithTime:)]) {
      [delegate starmapGenerationTimedOutWithTime:[[NSDate date] timeIntervalSinceDate:generatorStartTime]];
    }
  }
  [generatorStartTime release];
}

- (int)generateStarmapWithStars:(int)stars size:(NSSize)size ofType:(int)type;
{
  srand(seed);
  srandom(seed);
  starmapShape = type;
  starmapSize = size;
  starmapStarCount = stars;

  if (starmapShape == CIRCULAR_STARMAP) {
    int numstars = stars;
    int starmapRadius = starmapSize.width;
    float x,y = 0;
    Star *tempStar = nil;

    [starArray release];
    starArray = [[NSMutableArray alloc] init];

    // Stars
    NSLog(@"Generating Starmap");
    for (int i1 = 0; i1 < numstars; ++i1)  {
      if (tempStar != nil) {
        NSPoint previousPos = tempStar.starPos;

        int loops = 0;
        BOOL validStar = NO;
        NSPoint newStarPosition;
        while (!validStar) {
          float angle = rand() % 360;
          float radius = rand() % starmapRadius;

          x = sqrt(radius) * cos(angle);
          y = sqrt(radius) * sin(angle);

          x *= 20;
          y *= 20;

          if (algorthm == STARMAP_RECURSIVE_ALGO) {
            // Normalize new star postion relative to the previous star
            newStarPosition = NSMakePoint(previousPos.x + x,previousPos.y + y);
          }
          else if (algorthm == STARMAP_MIXED_ALGO) {
            Star *randomStar = [starArray objectAtIndex:rand() % [starArray count]];
            newStarPosition = NSMakePoint(randomStar.starPos.x + x,randomStar.starPos.y + y);
          }
          else { // STARMAP_RANDOM_ALGO
            newStarPosition = NSMakePoint(x,y);
          }

          validStar = [self goodStarPosition:newStarPosition checkDistance:normalStarMargin];
          //if (!validStar)
          //  NSLog(@"Invalid Star: %i of %i At: %i,%i",i1+1,numstars,(int)x,(int)y);
          if (loops > 100)
            return 1;

          loops++;
        }

        [tempStar release];
        tempStar = [[Star alloc] init];  // create a temporary star
        [tempStar setStarPos:newStarPosition];
        [tempStar setType:PRIMARY_STAR];
        //NSLog(@"Adding Star: %i of %i At: %i,%i",i1+1,numstars,(int)tempStar.starPos.x,(int)tempStar.starPos.y);
        [starArray addObject:tempStar];
      }
      else {
          if (starmapRadius!=0){
        float angle = rand() % 360;
        float radius = rand() % starmapRadius/2;

        x = sqrt(radius) * cos(angle);
        y = sqrt(radius) * sin(angle);

        x *= 20;
        y *= 20;

        tempStar = [[Star alloc] init];  // create a temporary star
        [tempStar setStarPos:NSMakePoint(x,y)];
        //NSLog(@"Adding First Star At:  %i,%i",(int)tempStar.starPos.x,(int)tempStar.starPos.y);
        [tempStar setType:FIRST_STAR];
        [starArray addObject:tempStar];
          }else{
              NSLog(@"WARNING: starmapRadius is nil");
              //Note that if starmapRadius is nil then so will stararray.
              return 0;
          }
      }
    }
    //NSLog(@"\n");

    //Networking Stars - Only generated for stars with less than 3 neighbors.
    if (generateNetworkingStars) {
      int i5;
      for (i5 = 0; i5 < [starArray count]; i5++) {
        Star *aStar = [starArray objectAtIndex:i5];
        if (aStar.type == NETWORKING_STAR)
          continue;

        NSArray *neighbors = [self neighborStarsForStar:aStar checkDistance:networkSize/2];
        if ([neighbors count] < 3) {

          int loops = 0;
          BOOL validStar = NO;
          NSPoint newStarPosition;
          while (!validStar) {
              if (networkSize!=0) {
            float angle = rand() % 360;
            float radius = rand() % networkSize/20;
            
            x = sqrt(radius) * cos(angle);
            y = sqrt(radius) * sin(angle);
            
            x *= 20;
            y *= 20;


            newStarPosition = NSMakePoint(aStar.starPos.x + x,aStar.starPos.y + y);
            validStar = [self goodStarPosition:newStarPosition checkDistance:networkStarMargin];
            //if (!validStar)
            //  NSLog(@"Invalid Networking Star At: %i,%i",(int)x,(int)y);
            if (loops > 100)
              return 1;

            loops++;
              }else {
                  NSLog(@"WARNING: networkSize is nil");
                  return 0;
              }
          }

          tempStar = [[Star alloc] init];  // create a temporary star
          [tempStar setStarPos:newStarPosition];
          [tempStar setType:NETWORKING_STAR];
          [tempStar setNetworkStar:aStar];
          //NSLog(@"Adding Networking Star At: %i,%i",(int)tempStar.starPos.x,(int)tempStar.starPos.y);
          [starArray addObject:tempStar];
          [tempStar release];
        }
      }
      //NSLog(@"\n");
    }
  }
  else if (starmapShape == RECTANGULAR_STARMAP) {
    int numstars = stars;
    int starmapWidth = starmapSize.width;
    int starmapHeight = starmapSize.height;
    float x,y = 0;
    Star *tempStar = nil;

    [starArray release];
    starArray = [[NSMutableArray alloc] init];

    // Stars
    NSLog(@"Generating Starmap");
    for (int i1 = 0; i1 < numstars; ++i1)  {
      if (tempStar != nil) {
        NSPoint previousPos = tempStar.starPos;

        int loops = 0;
        BOOL validStar = NO;
        NSPoint newStarPosition;
        while (!validStar) {
          x = rand() % starmapWidth - starmapWidth/2;
          y = rand() % starmapHeight  - starmapHeight/2;

          if (algorthm == STARMAP_RECURSIVE_ALGO) {
            // Normalize new star postion relative to the previous star
            newStarPosition = NSMakePoint(previousPos.x + x,previousPos.y + y);
          }
          else if (algorthm == STARMAP_MIXED_ALGO) {
            Star *randomStar = [starArray objectAtIndex:rand() % [starArray count]];
            newStarPosition = NSMakePoint(randomStar.starPos.x + x,randomStar.starPos.y + y);
          }
          else { // STARMAP_RANDOM_ALGO
            newStarPosition = NSMakePoint(x,y);
          }

          validStar = [self goodStarPosition:newStarPosition checkDistance:5];
          //if (!validStar)
          //  NSLog(@"Invalid Star: %i of %i At: %i,%i",i1+1,numstars,(int)x,(int)y);
          if (loops > 100)
            return 1;

          loops++;
        }


        [tempStar release];
        tempStar = [[Star alloc] init];  // create a temporary star
        [tempStar setStarPos:newStarPosition];
        [tempStar setType:PRIMARY_STAR];
        //NSLog(@"Adding Star: %i of %i At: %i,%i",i1+1,numstars,(int)tempStar.starPos.x,(int)tempStar.starPos.y);
        [starArray addObject:tempStar];
      }
      else {
        x = rand() % starmapWidth - starmapWidth/2;
        y = rand() % starmapHeight - starmapHeight/2;

        tempStar = [[Star alloc] init];  // create a temporary star
        [tempStar setStarPos:NSMakePoint(x,y)];
        //NSLog(@"Adding First Star At:  %i,%i",(int)tempStar.starPos.x,(int)tempStar.starPos.y);
        [tempStar setType:FIRST_STAR];
        [starArray addObject:tempStar];
      }
    }
    //NSLog(@"\n");

    //Networking Stars - Only generated for stars with less than 3 neighbors.
    if (generateNetworkingStars) {
      int i5;
      for (i5 = 0; i5 < [starArray count]; i5++) {
        Star *aStar = [starArray objectAtIndex:i5];
        if (aStar.type == NETWORKING_STAR)
          continue;

        NSArray *neighbors = [self neighborStarsForStar:aStar checkDistance:networkSize/2];
        if ([neighbors count] < 3) {

          int loops = 0;
          BOOL validStar = NO;
          NSPoint newStarPosition;
          while (!validStar) {
            float angle = rand() % 360;
            float radius = rand() % networkSize/20;

            x = sqrt(radius) * cos(angle);
            y = sqrt(radius) * sin(angle);

            x *= 20;
            y *= 20;

            newStarPosition = NSMakePoint(aStar.starPos.x + x,aStar.starPos.y + y);
            validStar = [self goodStarPosition:newStarPosition checkDistance:networkStarMargin];
            //if (!validStar)
            //  NSLog(@"Invalid Networking Star At: %i,%i",(int)x,(int)y);
            if (loops > 100)
              return 1;

            loops++;
          }

          tempStar = [[Star alloc] init];  // create a temporary star
          [tempStar setStarPos:newStarPosition];
          [tempStar setType:NETWORKING_STAR];
          [tempStar setNetworkStar:aStar];
          //NSLog(@"Adding Networking Star At: %i,%i",(int)tempStar.starPos.x,(int)tempStar.starPos.y);
          [starArray addObject:tempStar];
          [tempStar release];
        }
      }
      //NSLog(@"\n");
    }
  }
  
  // Get all neighbors for all stars
  for (Star *aStar in starArray) {
    [aStar setNeighbors:[self neighborStarsForStar:aStar checkDistance:networkSize/2]];
  }
  
  // Mark solitary stars
  NSMutableArray *solitaryStars = [[NSMutableArray alloc] init];
  for (Star *aStar in starArray) {
    if ([aStar.neighbors count] == 0) {
      [solitaryStars addObject:aStar];
    }
    else if ([aStar.neighbors count] == 1) {
      Star *nextStar1 = [aStar.neighbors objectAtIndex:0];
      if ([nextStar1.neighbors count] == 1) {
        [solitaryStars addObject:aStar];
        [solitaryStars addObject:nextStar1];
      }
    }
    else if ([aStar.neighbors count] == 2) {
      Star *nextStar1 = [aStar.neighbors objectAtIndex:0];
      Star *nextStar2 = [aStar.neighbors objectAtIndex:1];
      if ([nextStar1.neighbors count] == 1 && [nextStar2.neighbors count] == 1) {
        [solitaryStars addObject:aStar];
        [solitaryStars addObject:nextStar1];
      }
    }
  }

  for (Star *aStar in solitaryStars) {
    [aStar setType:SOLITARY_STAR];
  }
  if (removeSolitaryStars) {
    [starArray removeObjectsInArray:solitaryStars];
  }
  [solitaryStars release];

  return 0;
}


- (BOOL)goodStarPosition:(NSPoint)pos checkDistance:(int)checkDist
{
  if (pos.x == 0 && pos.y == 0)
    return NO;

  if (starmapShape == CIRCULAR_STARMAP) {
    float dist = sqrt(pos.x * pos.x + pos.y * pos.y);
    if (dist > (sqrt(starmapSize.width)*20))
      return NO;
  }
  else if (starmapShape == RECTANGULAR_STARMAP) {
    if (pos.x > starmapSize.width/2 || pos.x < starmapSize.width/-2)
      return NO;
    else if (pos.y > starmapSize.height/2 || pos.y < starmapSize.height/-2)
      return NO;
  }

  for (Star *aStar in starArray) {
    float nomX = pos.x - aStar.starPos.x;
    float nomY = pos.y - aStar.starPos.y;

    float dist = sqrt(nomX * nomX + nomY * nomY);
    if (dist < checkDist)
      return NO;
  }
  return YES;
}

- (NSArray *)neighborStarsForStar:(Star *)theStar checkDistance:(int)checkDist
{
  NSMutableArray *neighborsArray = [[NSMutableArray alloc] init];

  for (Star *aStar in starArray) {
    if (aStar == theStar)
      continue;

    float nomX = theStar.starPos.x - aStar.starPos.x;
    float nomY = theStar.starPos.y - aStar.starPos.y;

    float dist = sqrt(nomX * nomX + nomY * nomY);
    if (dist < checkDist)
      [neighborsArray addObject:aStar];
  }
  return [NSArray arrayWithArray:[neighborsArray autorelease]];
}


- (NSArray *)starArray
{
  return [NSArray arrayWithArray:starArray];
}

@end
