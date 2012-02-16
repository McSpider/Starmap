//
//  Star.h
//  Starmap
//
//  Created by Benjamin Kohler on 12/02/11.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FIRST_STAR 1
#define PRIMARY_STAR 2
#define NETWORKING_STAR 3
#define SOLITARY_STAR 4

@interface Star : NSObject {

  NSPoint starPos;

  NSString *name;
  int type;

  Star *networkStar;
  
  // Pathfinding stuff
  int g;
  int f;
  int h;
  
  Star *parentStar;
  NSArray *neighbors;
}

@property NSPoint starPos;
@property int type;

@property (nonatomic, assign) Star *networkStar;

@property int g;
@property int f;
@property int h;
@property (nonatomic, assign) Star *parentStar;
@property (nonatomic, retain) NSArray *neighbors;


- (NSColor *)starColor;
- (NSString *)starName;
- (NSString *)starType;


@end
