//
//  Starmap.m
//  Starmap
//
//  Created by Ben K on 12/02/13.
//  All code is provided under the New BSD license.
//

#import "Starmap.h"

@interface Starmap ()
- (uint)generateRectangularStarmap;
- (uint)generateCircularStarmap;
@end

@implementation Starmap
@synthesize delegate;
@synthesize seed;
@synthesize shape;
@synthesize networkSize;
@synthesize networkStarMargin,normalStarMargin;
@synthesize networkStarNeighbors;
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
  if (!(self = [super init]))
    return nil;
  
  // Initialization code here.
  seed = aSeed;
  networkSize = 100;
  normalStarMargin = 5;
  networkStarMargin = 3;
  networkStarNeighbors = 3;
  generateNetworkingStars = YES;
  removeSolitaryStars = NO;
  shape = S_Eliptical;
  starmapShape = CIRCULAR_STARMAP;
  starmapSize = NSMakeSize(100, 100);
  starmapStarCount = 100;
  
  starArray = [[NSMutableArray alloc] init];
  
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
  uint returnValue = 0;
  mtrand = [[MTRandom alloc] initWithSeed:seed];
  starmapShape = type;
  starmapSize = size;
  starmapStarCount = stars;
  
  if (starmapShape == CIRCULAR_STARMAP) {
    returnValue = [self generateCircularStarmap];
  }
  else if (starmapShape == RECTANGULAR_STARMAP) {
    returnValue = [self generateRectangularStarmap];
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
  
  [mtrand release];
  return returnValue;
}

- (uint)generateRectangularStarmap
{
  int numstars = starmapStarCount;
  int starmapWidth = starmapSize.width;
  int starmapHeight = starmapSize.height;
  float x,y = 0;
  uint star_uid = 0;
  Star *tempStar = nil;
  
  [starArray release];
  starArray = [[NSMutableArray alloc] init];
  
  // Stars
  NSLog(@"Generating Starmap");
  for (int i1 = 0; i1 < numstars; ++i1)  {
    if (tempStar != nil) {
      int loops = 0;
      BOOL validStar = NO;
      NSPoint newStarPosition;
      
      while (!validStar) {
        x = [mtrand randomDoubleFrom:0 to: starmapWidth]-starmapWidth/2;
        y = [mtrand randomDoubleFrom:0 to: starmapHeight]-starmapHeight/2;
        
        newStarPosition = NSMakePoint(x,y);          
        validStar = [self goodStarPosition:newStarPosition checkDistance:5];
        //if (!validStar)
        //  NSLog(@"Invalid Star: %i of %i At: %i,%i",i1+1,numstars,(int)x,(int)y);
        if (loops > 500)
          return SM_TIMEOUT;
        
        loops++;
      }
      
      
      [tempStar release];
      tempStar = [[Star alloc] initWithSeed:[mtrand randomUInt32]];  // create a temporary star
      [tempStar setStarPos:newStarPosition];
      [tempStar setType:PRIMARY_STAR];
      [tempStar setUid:star_uid];
      star_uid ++;
      //NSLog(@"Adding Star: %i of %i At: %i,%i",i1+1,numstars,(int)tempStar.starPos.x,(int)tempStar.starPos.y);
      [starArray addObject:tempStar];
    }
    else {
      x = [mtrand randomDoubleFrom:0 to: starmapWidth]-starmapWidth/2;
      y = [mtrand randomDoubleFrom:0 to: starmapHeight]-starmapHeight/2;
      
      tempStar = [[Star alloc] initWithSeed:[mtrand randomUInt32]];  // create a temporary star
      [tempStar setStarPos:NSMakePoint(x,y)];
      [tempStar setUid:star_uid];
      star_uid ++;
      //NSLog(@"Adding First Star At:  %i,%i",(int)tempStar.starPos.x,(int)tempStar.starPos.y);
      [tempStar setType:FIRST_STAR];
      [starArray addObject:tempStar];
    }
  }
  //NSLog(@"\n");
  
  //Networking Stars - Only generated for stars with less than networkStarNeighbors.
  if (generateNetworkingStars) {
    int i5;
    for (i5 = 0; i5 < [starArray count]; i5++) {
      Star *aStar = [starArray objectAtIndex:i5];
      if (aStar.type == NETWORKING_STAR)
        continue;
      
      NSArray *neighbors = [self neighborStarsForStar:aStar checkDistance:networkSize/2];
      if ([neighbors count] < networkStarNeighbors) {
        
        int loops = 0;
        BOOL validStar = NO;
        NSPoint newStarPosition;
        while (!validStar) {
          float angle = [mtrand randomDoubleFrom:0 to:360]*pi/180;
          float radius = sqrt([mtrand randomDouble]) * (networkSize/2.5);
          
          x = radius * cos(angle);
          y = radius * sin(angle);
          
          
          newStarPosition = NSMakePoint(aStar.starPos.x + x,aStar.starPos.y + y);
          validStar = [self goodStarPosition:newStarPosition checkDistance:networkStarMargin];
          //if (!validStar)
          //  NSLog(@"Invalid Networking Star At: %i,%i",(int)x,(int)y);
          if (loops > 500)
            return SM_TIMEOUT;
          
          loops++;
        }
        
        tempStar = [[Star alloc] initWithSeed:[mtrand randomUInt32]];  // create a temporary star
        [tempStar setStarPos:newStarPosition];
        [tempStar setType:NETWORKING_STAR];
        [tempStar setNetworkStar:aStar];
        [tempStar setUid:star_uid];
        star_uid ++;
        //NSLog(@"Adding Networking Star At: %i,%i",(int)tempStar.starPos.x,(int)tempStar.starPos.y);
        [starArray addObject:tempStar];
        [tempStar release];
      }
    }
    //NSLog(@"\n");
  }
  return 0;
}

- (uint)generateCircularStarmap
{
  int numstars = starmapStarCount;
  int starmapRadius = starmapSize.width;
  float x,y = 0;
  uint star_uid = 0;
  Star *tempStar = nil;
  
  [starArray release];
  starArray = [[NSMutableArray alloc] init];
  
  // Stars
  NSLog(@"Generating Starmap");
  for (int i1 = 0; i1 < numstars; ++i1)  {
    if (tempStar != nil) {
      int loops = 0;
      BOOL validStar = NO;
      NSPoint newStarPosition;
      
      while (!validStar) {
        if (shape == S_Eliptical) {
          float angle = [mtrand randomDoubleFrom:0 to:360]*pi/180;
          float radius = sqrt([mtrand randomDouble]) * (starmapRadius/2);
          
          x = radius * cos(angle);
          y = radius * sin(angle);
        }
        
        newStarPosition = NSMakePoint(x,y);
        validStar = [self goodStarPosition:newStarPosition checkDistance:normalStarMargin];
        //if (!validStar)
        //  NSLog(@"Invalid Star: %i of %i At: %i,%i",i1+1,numstars,(int)x,(int)y);
        if (loops > 500)
          return SM_TIMEOUT;
        
        loops++;
      }
      
      [tempStar release];
      tempStar = [[Star alloc] initWithSeed:[mtrand randomUInt32]];  // create a temporary star
      [tempStar setStarPos:newStarPosition];
      [tempStar setType:PRIMARY_STAR];
      [tempStar setUid:star_uid];
      star_uid ++;
      //NSLog(@"Adding Star: %i of %i At: %i,%i",i1+1,numstars,(int)tempStar.starPos.x,(int)tempStar.starPos.y);
      [starArray addObject:tempStar];
    }
    else {
      if (starmapRadius!=0) {
        float angle = [mtrand randomDoubleFrom:0 to:360]*pi/180;
        float radius = sqrt([mtrand randomDouble]) * (starmapRadius/2);
        
        x = radius * cos(angle);
        y = radius * sin(angle);
        
        tempStar = [[Star alloc] initWithSeed:[mtrand randomUInt32]];  // create a temporary star
        [tempStar setStarPos:NSMakePoint(x,y)];
        NSLog(@"Adding First Star At:  %i,%i",(int)tempStar.starPos.x,(int)tempStar.starPos.y);
        [tempStar setType:FIRST_STAR];
        [tempStar setUid:star_uid];
        star_uid ++;
        [starArray addObject:tempStar];
      }
      else {
        NSLog(@"WARNING: starmapRadius is nil");
        //Note that if starmapRadius is nil then so will stararray.
        return SM_FATAL_ERROR;
      }
    }
  }
  //NSLog(@"\n");
  
  //Networking Stars - Only generated for stars with less than networkStarNeighbors.
  if (generateNetworkingStars) {
    int i5;
    for (i5 = 0; i5 < [starArray count]; i5++) {
      Star *aStar = [starArray objectAtIndex:i5];
      if (aStar.type == NETWORKING_STAR)
        continue;
      
      NSArray *neighbors = [self neighborStarsForStar:aStar checkDistance:networkSize/2];
      if ([neighbors count] < networkStarNeighbors) {
        
        int loops = 0;
        BOOL validStar = NO;
        NSPoint newStarPosition;
        while (!validStar) {
          if (networkSize!=0) {
            float angle = [mtrand randomDoubleFrom:0 to:360]*pi/180;
            float radius = sqrt([mtrand randomDouble]) * (networkSize/2.5);
            
            x = radius * cos(angle);
            y = radius * sin(angle);
            
            
            newStarPosition = NSMakePoint(aStar.starPos.x + x,aStar.starPos.y + y);
            validStar = [self goodStarPosition:newStarPosition checkDistance:networkStarMargin];
            //if (!validStar)
            //  NSLog(@"Invalid Networking Star At: %i,%i",(int)x,(int)y);
            if (loops > 500)
              return SM_TIMEOUT;
            
            loops++;
          }
          else {
            NSLog(@"WARNING: networkSize is nil");
            return SM_FATAL_ERROR;
          }
        }
        
        tempStar = [[Star alloc] initWithSeed:[mtrand randomUInt32]];  // create a temporary star
        [tempStar setStarPos:newStarPosition];
        [tempStar setType:NETWORKING_STAR];
        [tempStar setNetworkStar:aStar];
        [tempStar setUid:star_uid];
        star_uid ++;
        //NSLog(@"Adding Networking Star At: %i,%i",(int)tempStar.starPos.x,(int)tempStar.starPos.y);
        [starArray addObject:tempStar];
        [tempStar release];
      }
    }
    //NSLog(@"\n");
  }
  return 0;
}


- (BOOL)goodStarPosition:(NSPoint)pos checkDistance:(int)checkDist
{
  if (pos.x == 0 && pos.y == 0)
    return NO;
  
  if (starmapShape == CIRCULAR_STARMAP) {
    float dist = sqrt(pos.x * pos.x + pos.y * pos.y);
    if (dist > starmapSize.width)
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

- (NSString *)xmlDataWithNeighbors:(BOOL)saveNeighbors
{
  NSString *xmlString = [[NSString alloc] initWithString:@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n"];
  
  // Identify starmap type and shape
  NSString *bShape = @"square";
  NSString *size = [NSString stringWithFormat:@"%.0f,%.0f",self.starmapSize.width,self.starmapSize.height];
  if (starmapShape == CIRCULAR_STARMAP) {
    bShape = @"circular";
    size = [NSString stringWithFormat:@"%.0f",self.starmapSize.width];
  }
  
  // Open the main <starmap> tag and write the starmap information into it
  xmlString = [xmlString stringByAppendingString:
               [NSString stringWithFormat:@"<starmap seed=\"%u\" size=\"%@\"  networkSize=\"%i\" stars=\"%i\" shape=\"%@\">\n",
                self.seed,size,self.networkSize,self.starmapStarCount,bShape]];
  
  // Loop through all stars and save their data to a XML string
  for (uint i1 = 0; i1 < starArray.count; i1++) {
    Star *aStar = [starArray objectAtIndex:i1];
    NSString *xmlStar = [NSString stringWithFormat:@"<star index=\"%u\">\n  <name>%@</name>\n  <pos>%f,%f</pos>\n  <type>%i</type>\n",
                         i1,aStar.starName,aStar.starPos.x,aStar.starPos.y,aStar.type];
    
    
    if (saveNeighbors) {
      xmlStar = [xmlStar stringByAppendingString:@"  <neighbors>\n"];
      for (uint i2 = 0; i2 < aStar.neighbors.count; i2++) {
        Star *nStar = [aStar.neighbors objectAtIndex:i2];
        NSString *neighborStar = [NSString stringWithFormat:@"    <star index=\"%u\">\n      <name>%@</name>\n      <pos>%f,%f</pos>\n      <type>%i</type>\n    </star>\n",i2,nStar.starName,nStar.starPos.x,nStar.starPos.y,nStar.type];
        xmlStar = [xmlStar stringByAppendingString:neighborStar];
      }
      xmlStar = [xmlStar stringByAppendingString:@"  </neighbors>\n"];
    }
    
    xmlStar = [xmlStar stringByAppendingString:@"</star>\n"];
    xmlString = [xmlString stringByAppendingString:xmlStar];
  }
  xmlString = [xmlString stringByAppendingString:@"</starmap>\n"];
  
  return [xmlString autorelease];
}

@end
