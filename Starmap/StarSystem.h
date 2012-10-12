//
//  SystemPlanet.h
//  Starmap
//
//  Created by Benjamin Kohler on 12/09/11.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MAX_TECH_LVL 8

typedef enum {
  PT_Gas,
  PT_Desert,
  PT_Jungle,
  PT_Terra,
  PT_Ocean,
  PT_Snow,
  PT_Ice,
  PT_Rock,
} PlanetTypes;

typedef enum {
  GT_Anarchy,
  GT_Democracy,
  GT_Feudal,
  GT_Communist,
  GT_Multi_Government,
  GT_Dictatorship,
  GT_Confederacy,
  GT_Corporate_State,
  GT_Pirate_State
} Goverment_Types;

typedef enum {
  ET_Agricultural,
  ET_Mining,
  ET_Industrial
} Economy_Types;

@interface SystemPlanet : NSObject {
  NSString *name;
  uint type;
  uint size;
  NSPoint position;  // Radius & Angle
  bool habitable;
  uint temperature;
  uint goverment;
  uint faction;
  uint technologyLevel;
  NSArray *produce;
  NSArray *spaceports;
  NSArray *moons;
}

@property (nonatomic, retain) NSString *name;
@property uint type;
@property uint size;
@property NSPoint position;
@property bool habitable;
@property uint temperature;
@property uint goverment;
@property uint faction;
@property uint technologyLevel;
@property uint economy;
@property (nonatomic, retain) NSArray *produce;
@property (nonatomic, retain) NSArray *spaceports;
@property (nonatomic, retain) NSArray *moons;



- (id)initWithName:(NSString *)aName;

- (NSString *)planetInfo;
- (NSString *)govermentString;
- (NSString *)economyString;
- (NSString *)typeString;
- (NSColor *)mapColor;
- (void)randomizeWithSeed:(uint)aSeed;

@end



#pragma mark -

//
//  SystemStation.h
//  Starmap
//
//  Created by Benjamin Kohler on 12/09/11.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

typedef enum {
  ST_Cave,
  ST_City,
  ST_Floating,
  ST_Orbiting,
  ST_Rock
} StationTypes;

typedef enum {
  SS_Large,
  SS_Medium,
  SS_Small,
  SS_Tiny
} StationSizes;

@interface SystemStation : NSObject {
  uint type;
  uint size;
  NSPoint position;
  uint technology_level;
}

- (NSString *)portInfo;

@end



#pragma mark -

//
//  StarSystem.h
//  Starmap
//
//  Created by Benjamin Kohler on 12/09/03.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#define SHAPE_CIRCULAR 0
#define SHAPE_RECTANGULAR 1

@interface StarSystem : NSObject {
  MTRandom *mtrand;

  NSSize size;
  uint shape;
  uint sectorSize;
  SystemPlanet *planet;
  NSMutableArray *objects;
  NSPoint warpZonePosition;
  uint warpZoneRadius;
}

@property NSSize size;
@property uint shape;
@property uint sectorSize;
@property (nonatomic, retain) SystemPlanet *planet;
@property NSPoint warpZonePosition;
@property uint warpZoneRadius;

- (id)initWithName:(NSString *)aName andSeed:(uint)aSeed;
- (NSString *)systemInfo;

@end

