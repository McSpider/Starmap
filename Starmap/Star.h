//
//  Star.h
//  Starmap
//
//  Created by Ben K on 12/02/11.
//  All code is provided under the New BSD license.
//

#import <Foundation/Foundation.h>
#import "StarSystem.h"

#define FIRST_STAR 1
#define PRIMARY_STAR 2
#define NETWORKING_STAR 3
#define SOLITARY_STAR 4

@interface Star : NSObject {
  MTRandom *mtrand;
  
  NSPoint starPos;

  NSString *name;
  uint uid;
  int type;

  Star *networkStar;
  StarSystem *starSystem;
  
  // Pathfinding stuff
  int g;
  int f;
  int h;
  
  Star *parentStar;
  NSArray *neighbors;
}

@property NSPoint starPos;
@property uint uid;
@property int type;

@property (nonatomic, assign) Star *networkStar;
@property (nonatomic, retain) StarSystem *starSystem;

@property int g;
@property int f;
@property int h;
@property (nonatomic, assign) Star *parentStar;
@property (nonatomic, retain) NSArray *neighbors;

- (id)initWithSeed:(uint)aSeed;

- (NSColor *)starColor;
- (NSString *)starName;
- (NSString *)starType;

- (NSString *)randomStarName;

@end
