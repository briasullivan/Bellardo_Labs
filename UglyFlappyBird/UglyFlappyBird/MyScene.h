//
//  MyScene.h
//  UglyFlappyBird
//

//  Copyright (c) 2014 Bellardo Curriculum. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface MyScene : SKScene<SKPhysicsContactDelegate>

@property (nonatomic, strong) SKSpriteNode *shipSprite;
@property (nonatomic, strong) SKLabelNode *gameScoreLabel;
@property (nonatomic) int score;
@property (nonatomic) BOOL gameOver;

@end
