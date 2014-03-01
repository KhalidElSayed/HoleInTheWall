//
//  JWCScrene.m
//  HoleInTheWall
//
//  Created by Jeff Schwab on 2/23/14.
//  Copyright (c) 2014 Jeff Schwab. All rights reserved.
//

#import "JWCScene.h"
#import "JWCShapeType.h"
#import "MMRCheckForCollision.h"
#import "WTMGlyphDetector.h"

#import <GameCenterManager/GameCenterManager.h>

@interface JWCScene () <WTMGlyphDelegate, GameCenterManagerDelegate>
{
    int _wallsPassed;
    BOOL _glyphDetected;
    BOOL _wallScaling;
    
    BOOL _shadowRemoved;
}


@property (nonatomic) JWCShape *playerShape;
@property (nonatomic) JWCHole *currentHole;

@property (nonatomic) NSMutableArray *glyphs;
@property (nonatomic) WTMGlyphDetector *glyphDetector;

@end

@implementation JWCScene

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        self.anchorPoint = CGPointMake(0.5, 0.5);
        
        [self setupGlyphCollection];
        
        self.wall = [[JWCWall alloc] initWithScale:.2];
        [self addChild:self.wall];
        
        [self.wall startMovingWithDuration:6];
        _wallScaling = YES;
        
        self.backgroundColor = [UIColor colorWithRed:0.000 green:0.816 blue:1.000 alpha:1.000];
    }
    
    [GameCenterManager sharedManager].delegate = self;
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [[touches anyObject] locationInView:self.view];
    [self.glyphDetector addPoint:touchPoint];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_glyphDetected) {
        CGPoint touchPoint = [[touches anyObject] locationInView:self.view];
        [self.glyphDetector addPoint:touchPoint];
    } else {
        self.playerShape.position = [[touches anyObject] locationInNode:self];
        [self moveShadowWithReferencePoint:[[touches anyObject] locationInNode:self]];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_glyphDetected) {
        [self.glyphDetector addPoint:[[touches anyObject] locationInView:self.view]];
        [self.glyphDetector detectGlyph];
    } else {
        _glyphDetected = NO;
        [self.playerShape removeFromParent];
        [self removeShadow];
    }
}

#pragma mark - Glyph Setup
- (void)setupGlyphCollection
{
    self.glyphDetector = [WTMGlyphDetector detector];
    self.glyphDetector.delegate = self;
    
    for (int i = 1; i < 6; i++) {
        NSString *sqaureFileName = [NSString stringWithFormat:@"square%d",i];
        [self addGlyphWithJSONFileName:sqaureFileName withShapeName:@"square"];
        
        NSString *triangleFileName = [NSString stringWithFormat:@"triangle%d",i];
        [self addGlyphWithJSONFileName:triangleFileName withShapeName:@"triangle"];
    }
    [self addGlyphWithJSONFileName:@"circle" withShapeName:@"circle"];
}

- (void)addGlyphWithJSONFileName:(NSString *)fileName withShapeName:(NSString *)shapeName
{
    NSString *glyphFilePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"json"];
    NSData *glyphData = [NSData dataWithContentsOfFile:glyphFilePath];
    
    [self.glyphDetector addGlyphFromJSON:glyphData name:shapeName];
}

- (void)glyphDetected:(WTMGlyph *)glyph withScore:(float)score
{
    if (!_glyphDetected) {
        _glyphDetected = YES;
        [self.glyphDetector reset];
            
        NSLog(@"%@, %f", glyph.name, score);
        
        if ([glyph.name isEqualToString:@"square"]) {
            self.playerShape = [[JWCShape alloc] initWithShapeType:JWCShapeTypeSquare size:CGSizeMake(150, 150)];
            self.playerShape.position = CGPointZero;
        } else if ([glyph.name isEqualToString:@"triangle"]) {
            self.playerShape = [[JWCShape alloc] initWithShapeType:JWCShapeTypeTriangle size:CGSizeMake(150, 150)];
            self.playerShape.position = CGPointZero;
        } else if ([glyph.name isEqualToString:@"circle"]) {
            self.playerShape = [[JWCShape alloc] initWithShapeType:JWCShapeTypeCircle size:CGSizeMake(150, 150)];
            self.playerShape.position = CGPointZero;
        }
        
        
        
        [self addChild:self.playerShape];
        [self addShadowForReferencePoint:CGPointZero];
        _shadowRemoved = YES;
    }
}

- (void)update:(CFTimeInterval)currentTime
{
    if (self.wall.yScale >= 0.91 && self.wall.yScale <= 0.92) {
        MMRCheckForCollision *collisionCheck = [[MMRCheckForCollision alloc] init];
    
        if ([collisionCheck checkForCollision:self.playerShape andHoleInTheWall:self.wall.holeInWall]) {
            
            float xValue = (arc4random() % (int)self.size.width) * 2;
            float yValue = (arc4random() % (int)self.size.height) * 2;
            
            SKAction *rotation1 = [SKAction rotateByAngle: M_PI/4.0 duration:0];
            SKAction *sendToPoint = [SKAction moveTo:CGPointMake(xValue, yValue) duration:1.0];
            SKAction *scalePlayerSHape = [SKAction scaleBy:3 duration:1.0];
            SKAction *oneRevolution = [SKAction rotateByAngle:-M_PI*2 duration:2.0];

            
            SKAction *actions = [SKAction sequence:@[rotation1,rotation1,rotation1,rotation1,rotation1,rotation1,rotation1]];
            
            SKAction *group = [SKAction group:@[sendToPoint,scalePlayerSHape,oneRevolution]];
            [self.playerShape runAction:group];
            
            if (self.playerShape.parent && !_shadowRemoved) {
                _shadowRemoved = NO;
                [self removeShadow];
            }
        } else {
            [self reportScore];
            _wallsPassed++;
        }
        
    }
}

- (void)reportScore
{
    // TODO: Implement this with our real achievement name
//    [[GameCenterManager sharedManager] saveAndReportScore:100
//                                              leaderboard:@"com.jeffwritescode.holeinthewall.hiscore" sortOrder:GameCenterSortOrderHighToLow];
//    if (_wallsPassed > 5) {
//        [[GameCenterManager sharedManager] saveAndReportAchievement:@"com.jeffwritescode.holeinthewall.collisions" percentComplete:100.0 shouldDisplayNotification:YES];
//    }
}

@end
