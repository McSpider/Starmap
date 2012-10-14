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

- (void)randomizePlanet:(SystemPlanet *)aPlanet;
- (NSString *)weightedRandomFromSet:(NSDictionary *)dataSet;
- (void)groupStarSystemsForStar:(Star *)aStar groupIndex:(NSNumber *)groupIndex;
@end

@implementation Starmap
@synthesize delegate;
@synthesize generatingStarmap;
@synthesize seed;
@synthesize shape;
@synthesize networkSize;
@synthesize networkStarMargin,normalStarMargin;
@synthesize networkStarNeighbors, networkStarMinNeighbors;
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
  networkStarMargin = 6;
  networkStarNeighbors = 3;
  networkStarMinNeighbors = 2;
  generateNetworkingStars = YES;
  removeSolitaryStars = NO;
  shape = S_Eliptical;
  starmapShape = SHAPE_CIRCULAR;
  starmapSize = NSMakeSize(100, 100);
  starmapStarCount = 100;
  
  starArray = [[NSMutableArray alloc] init];
  settings = [[Settings alloc] init];
  
  return self;
}

- (void)dealloc
{
  [starArray release];
  [settings release];
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
  else if (result == SM_TIMEOUT) {
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
  
  if (starmapShape == SHAPE_CIRCULAR) {
    returnValue = [self generateCircularStarmap];
  }
  else if (starmapShape == SHAPE_RECTANGULAR) {
    returnValue = [self generateRectangularStarmap];
  }
  
  // Get all neighbors for all stars
  for (Star *aStar in starArray) {
    [aStar setNeighbors:[self neighborStarsForStar:aStar checkDistance:networkSize/2]];
  }
  
  
  // This block of code should be changed so that it uses the StarSystem group variable.
  // If the group count is under a certian threshold remove the whole group.
  
  // Mark solitary stars
  NSMutableArray *solitaryStars = [[NSMutableArray alloc] init];
  for (Star *aStar in starArray) {
    if ([aStar.neighbors count] == 0) {
      [aStar setType:SOLITARY_STAR];
      [solitaryStars addObject:aStar];
    }
    else if ([aStar.neighbors count] == 1) {
      Star *nextStar1 = [aStar.neighbors objectAtIndex:0];
      if ([nextStar1.neighbors count] == 1) {
        [aStar setType:SOLITARY_STAR];
        [nextStar1 setType:SOLITARY_STAR];
        [solitaryStars addObject:aStar];
        [solitaryStars addObject:nextStar1];
      }
    }
    else if ([aStar.neighbors count] == 2) {
      Star *nextStar1 = [aStar.neighbors objectAtIndex:0];
      Star *nextStar2 = [aStar.neighbors objectAtIndex:1];
      if ([nextStar1.neighbors count] == 1 && [nextStar2.neighbors count] == 1) {
        [aStar setType:SOLITARY_STAR];
        [nextStar1 setType:SOLITARY_STAR];
        [solitaryStars addObject:aStar];
        [solitaryStars addObject:nextStar1];
      }
    }
  }
  
  if (removeSolitaryStars) {
    [starArray removeObjectsInArray:solitaryStars];
  }
  [solitaryStars release];
  
  
  // Generate system data
  for (Star *aStar in starArray) {
    StarSystem *starSystem = [[StarSystem alloc] init];
    [starSystem setPlanet:[[SystemPlanet alloc] init]];
    [starSystem.planet setName:[aStar randomStarName]];
    [self randomizePlanet:starSystem.planet];
    
    NSLog(@"%@",[starSystem systemInfo]);

    [aStar setStarSystem:starSystem];
    [starSystem release];
  }
  
  // Group star systems
  BOOL systemsGrouped = NO;
  uint groupIndex = 1;
  while (!systemsGrouped) {
    for (uint i1 = 0; i1 < starArray.count; i1++) {
      Star *aStar = [starArray objectAtIndex:i1];
      if (aStar.starSystem.group == 0) {
        [self groupStarSystemsForStar:aStar groupIndex:[NSNumber numberWithUnsignedInt:groupIndex]];
        groupIndex++;
      }
    }
    systemsGrouped = YES;
  }
  
  // Generate faction areas etc
  
  [mtrand release];
  return returnValue;
}


- (void)randomizePlanet:(SystemPlanet *)aPlanet;
{  
  NSString *newGovermentType = [self weightedRandomFromSet:settings.govermentTypeSet];
  // 10% chance that the goverment becomes a pirate state
  if ([newGovermentType isEqualToString:@"Anarchy"] && ([mtrand randomUInt32From:0 to:100] < 10))
    newGovermentType = @"Pirate State";
  
  [aPlanet setGoverment:newGovermentType];
  [aPlanet setTechnologyLevel:(int)[mtrand randomUInt32From:0 to:settings.maxTechLevel]];
  
  NSString *newPlanetType = [self weightedRandomFromSet:settings.planetTypeSet];
  [aPlanet setType:newPlanetType];
  
  [aPlanet setEconomy:(int)[mtrand randomUInt32From:0 to:2]];
  
  while ((([aPlanet.type isEqualToString:@"Ice"] || [aPlanet.type isEqualToString:@"Gas"]) && aPlanet.economy == ET_Agricultural) ||
         (([aPlanet.type isEqualToString:@"Gas"]) && aPlanet.economy == ET_Industrial))
    [aPlanet setEconomy:(int)[mtrand randomUInt32From:0 to:2]];
  
}

- (NSString *)weightedRandomFromSet:(NSDictionary *)dataSet
{
  int total = 0;
  for (id key in dataSet) {
    NSNumber *weight = [dataSet objectForKey:key];
    total = total + [weight intValue];
  }
  
  int threshold = [mtrand randomUInt32From:0 to:total];
  NSString *found = [[NSString alloc] init];
  
  for (id key in dataSet) {
    NSNumber *weight = [dataSet objectForKey:key];
    threshold = threshold - [weight intValue];
    if (threshold < 0) {
      found = key;
      break;
    }
  }
  
  return found;  
}

- (void)groupStarSystemsForStar:(Star *)aStar groupIndex:(NSNumber *)groupIndex
{
  // Loop through all star neighbors and set a group index unless it's already set.
  [aStar.starSystem setGroup:groupIndex.unsignedIntValue];
  for (Star *star in aStar.neighbors) {
    if (star.starSystem.group == 0) {
      [self groupStarSystemsForStar:star groupIndex:groupIndex];
    }
  }
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
      [tempStar setPosition:newStarPosition];
      [tempStar setType:PRIMARY_STAR];
      [tempStar setUid:star_uid];
      star_uid ++;
      //NSLog(@"Adding Star: %i of %i At: %i,%i",i1+1,numstars,(int)tempStar.position.x,(int)tempStar.position.y);
      [starArray addObject:tempStar];
    }
    else {
      if (starmapRadius <= 0) {
        NSLog(@"WARNING: starmapRadius is zero");
        //Note that if starmapRadius is nil then so will stararray.
        return SM_FATAL_ERROR;
      }
      float angle = [mtrand randomDoubleFrom:0 to:360]*pi/180;
      float radius = sqrt([mtrand randomDouble]) * (starmapRadius/2);
      
      x = radius * cos(angle);
      y = radius * sin(angle);
      
      tempStar = [[Star alloc] initWithSeed:[mtrand randomUInt32]];  // create a temporary star
      [tempStar setPosition:NSMakePoint(x,y)];
      NSLog(@"Adding First Star At:  %i,%i",(int)tempStar.position.x,(int)tempStar.position.y);
      [tempStar setType:FIRST_STAR];
      [tempStar setUid:star_uid];
      star_uid ++;
      [starArray addObject:tempStar];
    }
  }
  //NSLog(@"\n");
  
  //Networking Stars - Only generated for stars with less than networkStarNeighbors.
  if (generateNetworkingStars) {
    if (networkSize <= 0) {
      NSLog(@"WARNING: networkSize is zero");
      return SM_FATAL_ERROR;
    }
    
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
          
          
          newStarPosition = NSMakePoint(aStar.position.x + x,aStar.position.y + y);
          validStar = [self goodStarPosition:newStarPosition checkDistance:networkStarMargin];
          
          Star *nStar = [[Star alloc] init];
          [nStar setPosition:newStarPosition];
          if ([[self neighborStarsForStar:nStar checkDistance:networkSize/2] count] < networkStarMinNeighbors){
            validStar = NO;
          }
          [nStar release];
          //if (!validStar)
          //  NSLog(@"Invalid Networking Star At: %i,%i",(int)x,(int)y);
          if (loops > 500)
            return SM_TIMEOUT;
          
          loops++;
        }
        
        tempStar = [[Star alloc] initWithSeed:[mtrand randomUInt32]];  // create a temporary star
        [tempStar setPosition:newStarPosition];
        [tempStar setType:NETWORKING_STAR];
        [tempStar setNetworkStar:aStar];
        [tempStar setUid:star_uid];
        star_uid ++;
        //NSLog(@"Adding Networking Star At: %i,%i",(int)tempStar.position.x,(int)tempStar.position.y);        
        [starArray addObject:tempStar];
        [tempStar release];
      }
    }
    //NSLog(@"\n");
  }
  return 0;
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
        validStar = [self goodStarPosition:newStarPosition checkDistance:normalStarMargin];
        //if (!validStar)
        //  NSLog(@"Invalid Star: %i of %i At: %i,%i",i1+1,numstars,(int)x,(int)y);
        if (loops > 500)
          return SM_TIMEOUT;
        
        loops++;
      }
      
      
      [tempStar release];
      tempStar = [[Star alloc] initWithSeed:[mtrand randomUInt32]];  // create a temporary star
      [tempStar setPosition:newStarPosition];
      [tempStar setType:PRIMARY_STAR];
      [tempStar setUid:star_uid];
      star_uid ++;
      //NSLog(@"Adding Star: %i of %i At: %i,%i",i1+1,numstars,(int)tempStar.position.x,(int)tempStar.position.y);
      [starArray addObject:tempStar];
    }
    else {
      if (starmapWidth <= 0 || starmapHeight <= 0) {
        NSLog(@"WARNING: starmapSize is zero");
        //Note that if starmapSize is nil then so will stararray.
        return SM_FATAL_ERROR;
      }

      x = [mtrand randomDoubleFrom:0 to: starmapWidth]-starmapWidth/2;
      y = [mtrand randomDoubleFrom:0 to: starmapHeight]-starmapHeight/2;
      
      tempStar = [[Star alloc] initWithSeed:[mtrand randomUInt32]];  // create a temporary star
      [tempStar setPosition:NSMakePoint(x,y)];
      [tempStar setUid:star_uid];
      star_uid ++;
      //NSLog(@"Adding First Star At:  %i,%i",(int)tempStar.position.x,(int)tempStar.position.y);
      [tempStar setType:FIRST_STAR];
      [starArray addObject:tempStar];
    }
  }
  //NSLog(@"\n");
  
  //Networking Stars - Only generated for stars with less than networkStarNeighbors.
  if (generateNetworkingStars) {
    if (networkSize <= 0) {
      NSLog(@"WARNING: networkSize is zero");
      return SM_FATAL_ERROR;
    }
    
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
          
          
          newStarPosition = NSMakePoint(aStar.position.x + x,aStar.position.y + y);
          validStar = [self goodStarPosition:newStarPosition checkDistance:networkStarMargin];
          
          Star *nStar = [[Star alloc] init];
          [nStar setPosition:newStarPosition];
          if ([[self neighborStarsForStar:nStar checkDistance:networkSize/2] count] < networkStarMinNeighbors){
            validStar = NO;
          }
          [nStar release];
          //if (!validStar)
          //  NSLog(@"Invalid Networking Star At: %i,%i",(int)x,(int)y);
          if (loops > 500)
            return SM_TIMEOUT;
          
          loops++;
        }
        
        tempStar = [[Star alloc] initWithSeed:[mtrand randomUInt32]];  // create a temporary star
        [tempStar setPosition:newStarPosition];
        [tempStar setType:NETWORKING_STAR];
        [tempStar setNetworkStar:aStar];
        [tempStar setUid:star_uid];
        star_uid ++;
        //NSLog(@"Adding Networking Star At: %i,%i",(int)tempStar.position.x,(int)tempStar.position.y);        
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
  
  if (starmapShape == SHAPE_CIRCULAR) {
    float dist = sqrt(powf(0 - pos.x,2) + powf(0 - pos.y,2));
    if (dist > starmapSize.width/2)
      return NO;
  }
  else if (starmapShape == SHAPE_RECTANGULAR) {
    if (pos.x > starmapSize.width/2 || pos.x < starmapSize.width/-2)
      return NO;
    else if (pos.y > starmapSize.height/2 || pos.y < starmapSize.height/-2)
      return NO;
  }
  
  for (Star *aStar in starArray) {
    float nomX = pos.x - aStar.position.x;
    float nomY = pos.y - aStar.position.y;
    
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
    
    float nomX = theStar.position.x - aStar.position.x;
    float nomY = theStar.position.y - aStar.position.y;
    
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
  if (starmapShape == SHAPE_CIRCULAR) {
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
                         i1,aStar.starName,aStar.position.x,aStar.position.y,aStar.type];
    
    
    if (saveNeighbors) {
      xmlStar = [xmlStar stringByAppendingString:@"  <neighbors>\n"];
      for (uint i2 = 0; i2 < aStar.neighbors.count; i2++) {
        Star *nStar = [aStar.neighbors objectAtIndex:i2];
        NSString *neighborStar = [NSString stringWithFormat:@"    <star index=\"%u\">\n      <name>%@</name>\n      <pos>%f,%f</pos>\n      <type>%i</type>\n    </star>\n",i2,nStar.starName,nStar.position.x,nStar.position.y,nStar.type];
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
