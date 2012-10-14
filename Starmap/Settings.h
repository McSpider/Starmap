//
//  Settings.h
//  Starmap
//
//  Created by Benjamin Kohler on 12/10/14.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Settings : NSObject {
  uint maxTechLevel;
  NSDictionary *planetTypeSet;
  NSDictionary *govermentTypeSet;
}

@property (readonly) uint maxTechLevel;
@property (readonly) NSDictionary *planetTypeSet;
@property (readonly) NSDictionary *govermentTypeSet;


@end
