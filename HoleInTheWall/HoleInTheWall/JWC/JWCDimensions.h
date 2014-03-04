//
//  JWCDimensions.h
//  HoleInTheWall
//
//  Created by Jeff Schwab on 3/4/14.
//  Copyright (c) 2014 Jeff Schwab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JWCDimensions : NSObject

@property (nonatomic) CGSize size;
@property (nonatomic) CGPoint holePosition;

+ (JWCDimensions *)sharedController;

@end
