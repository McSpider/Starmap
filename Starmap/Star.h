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

@interface Star : NSObject {
  
  NSPoint starPos;
  
  int type;
  
  NSString *name;
  
  NSArray *neighbors;
}

@property NSPoint starPos;
@property int type;

@property (nonatomic, retain) NSArray *neighbors; 

- (NSColor *)starColor;
- (NSColor *)starName;


@end
