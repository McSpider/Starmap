//
//  Starmap.h
//  Starmap
//
//  Created by Ben K on 12/02/13.
//  All code is provided under the New BSD license.
//

#import <Foundation/Foundation.h>
#import "Settings.h"
#import "Star.h"

#define SM_TIMEOUT 1
#define SM_FATAL_ERROR 2

typedef enum {
  S_Eliptical,
  S_Starburst,
  S_Ring,
  S_Spiral,
} GalaxyShapes;


@protocol StarmapDelegate
@optional

- (void)starmapGeneratorStarted;
- (void)starmapGenerationFinishedWithTime:(float)time;
- (void)starmapGenerationTimedOutWithTime:(float)time;

@end

@interface Starmap : NSObject {
  MTRandom *mtrand;
  Settings *settings;
  id delegate;

  unsigned int seed;
  int shape;
  int networkSize;
  int networkStarMargin;
  int normalStarMargin;
  int networkStarNeighbors;
  int networkStarMinNeighbors;
  BOOL generateNetworkingStars;
  BOOL removeSolitaryStars;

  int starmapShape;
  NSSize starmapSize;
  int starmapStarCount;

  NSMutableArray *starArray;

  BOOL generatingStarmap;
  NSDate *generatorStartTime;
}

@property (nonatomic, assign) id delegate;
@property BOOL generatingStarmap;
@property unsigned int seed;
@property int shape;
@property int networkSize;
@property int networkStarMargin,normalStarMargin;
@property int networkStarNeighbors, networkStarMinNeighbors;
@property BOOL generateNetworkingStars;
@property BOOL removeSolitaryStars;
@property int starmapShape;
@property NSSize starmapSize;
@property int starmapStarCount;

- (id)initWithSeed:(uint)aSeed;

- (void)generateStarmap;
- (int)generateStarmapWithStars:(int)stars size:(NSSize)size ofType:(int)type;

- (BOOL)goodStarPosition:(NSPoint)pos checkDistance:(int)checkDist;
- (NSArray *)neighborStarsForStar:(Star *)theStar checkDistance:(int)checkDist;


- (NSArray *)starArray;
- (NSString *)xmlDataWithNeighbors:(BOOL)saveNeighbors;

@end
