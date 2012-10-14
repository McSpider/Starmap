//
//  SystemPlanet.h
//  Starmap
//
//  Created by Benjamin Kohler on 12/09/11.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
  ET_Agricultural,
  ET_Mining,
  ET_Industrial
} Economy_Types;

@interface SystemPlanet : NSObject {
  NSString *name;
  NSString *type;
  NSString *goverment;
  uint size;
  NSPoint position;  // Radius & Angle
  BOOL habitable;
  uint temperature;
  uint faction;
  uint technologyLevel;
  NSArray *produce;
  NSArray *spaceports;
  NSArray *moons;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *goverment;
@property uint size;
@property NSPoint position;
@property BOOL habitable;
@property uint temperature;
@property uint faction;
@property uint technologyLevel;
@property uint economy;
@property (nonatomic, retain) NSArray *produce;
@property (nonatomic, retain) NSArray *spaceports;
@property (nonatomic, retain) NSArray *moons;


- (NSString *)planetInfo;
- (NSString *)economyString;
- (NSColor *)mapColor;

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
  NSSize size;
  uint shape;
  uint sectorSize;
  uint group;
  SystemPlanet *planet;
  NSMutableArray *objects;
  NSPoint warpZonePosition;
  uint warpZoneRadius;
}

@property NSSize size;
@property uint shape;
@property uint sectorSize;
@property uint group;
@property (nonatomic, retain) SystemPlanet *planet;
@property NSPoint warpZonePosition;
@property uint warpZoneRadius;

- (NSString *)systemInfo;

@end

