//
//  JWCWall.h
//  HoleInTheWall
//
//  Created by Jeff Schwab on 2/23/14.
//  Copyright (c) 2014 Jeff Schwab. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "JWCHole.h"

@interface JWCWall : SKSpriteNode

@property (nonatomic) BOOL wallPassed;

/**
 * Creates a wall with initial scale, positioned at center of screen, with a random
 * initial hole;
 */
- (instancetype)initWithScale:(CGFloat)scale;

- (instancetype)initWithOpeningLabelAndScale:(CGFloat)scale;

/**
 *  Currently a recursive method that causes the wall to start scaling to the size 
 *  of the screen. When it reaches this point it quickly scales to offscreen and then
 *  calls itself, starting the process again.
 */
- (void)startMovingWithDuration:(CGFloat)duration;

/**
 * Generates random hole and position and places it in the wall.
 */
- (void)generateHole;

@property (nonatomic) CGPoint holeCenter;
@property (nonatomic) JWCHole *holeInWall;

@end
