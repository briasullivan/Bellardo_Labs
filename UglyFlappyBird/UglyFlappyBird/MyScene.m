//
//  MyScene.m
//  UglyFlappyBird
//
//  Created by Bria Sullivan on 5/19/14.
//  Copyright (c) 2014 Bellardo Curriculum. All rights reserved.
//

#import "MyScene.h"

#define ASTEROID_WIDTH 50.0f
#define SHIP_COLLIDERTYPE 1
#define ASTEROID_COLLIDERTYPE 2

@implementation MyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
    
        self.backgroundColor = [SKColor colorWithRed:0 green:0 blue:0 alpha:1.0];
        
        //SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"star_background.jpg"];
        //background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        
        self.score = 0;
        self.gameOver = YES;
        
        self.gameScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        self.gameScoreLabel.position = CGPointMake(100, self.size.height - 50);
        self.gameScoreLabel.text = [NSString stringWithFormat:@"Score: %i", self.score];
        
        //[self addChild:background];
        [self addChild:self.gameScoreLabel];
        
       self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, 0, self.size.width, self.size.height)];
        self.physicsWorld.contactDelegate = self;
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    if (!self.shipSprite) {
        
        //get first touch
        UITouch *touch = [touches anyObject];
        
        //get location of touch
        CGPoint location = [touch locationInNode:self];
        
        //set sprite image
        self.shipSprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
        
        //set sprite size and position
        self.shipSprite.position = location;
        self.shipSprite.size = CGSizeMake(60.0, 60.0);
        
        //add physics properties to ship
        self.shipSprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.shipSprite.size];
        self.shipSprite.physicsBody.affectedByGravity = YES;
        self.shipSprite.physicsBody.mass = 0.6f;
        
        //add collision detection
        self.shipSprite.physicsBody.categoryBitMask = SHIP_COLLIDERTYPE;
        self.shipSprite.physicsBody.collisionBitMask = ASTEROID_COLLIDERTYPE | SHIP_COLLIDERTYPE;
        self.shipSprite.physicsBody.contactTestBitMask = ASTEROID_COLLIDERTYPE;
        
        //add ship to the scene
        [self addChild:self.shipSprite];
        self.gameOver = NO;
        SKAction *callAddAsteroids = [SKAction performSelector:@selector(addAsteroids) onTarget:self];
        SKAction *wait = [SKAction waitForDuration:1.5];
        SKAction *waitThenAdd = [SKAction sequence:@[callAddAsteroids, wait]];
        SKAction *asteroidLoop = [SKAction repeatActionForever:waitThenAdd];
        [self.shipSprite runAction:asteroidLoop];
    
    } else {
        [self.shipSprite.physicsBody applyImpulse:CGVectorMake(0.0f, 400.0f)];
    }
}

-(void) addAsteroids
{
    SKSpriteNode *topAsteroid = [SKSpriteNode spriteNodeWithColor:[SKColor lightGrayColor] size:CGSizeMake(ASTEROID_WIDTH, self.size.height/2 - 100)];
    SKSpriteNode *bottomAsteroid = [SKSpriteNode spriteNodeWithColor:[SKColor lightGrayColor] size:CGSizeMake(ASTEROID_WIDTH, self.size.height/2 - 100)];
    topAsteroid.position = CGPointMake(self.size.width + ASTEROID_WIDTH/2, self.size.height - topAsteroid.size.height/2);
    bottomAsteroid.position = CGPointMake(self.size.width + ASTEROID_WIDTH/2, bottomAsteroid.size.height/2);
    
    SKAction *moveAsteroid = [SKAction moveToX:-ASTEROID_WIDTH/2 duration:2.0];
    
    //collision detection
    topAsteroid.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:topAsteroid.size];
    topAsteroid.physicsBody.dynamic = NO;
    topAsteroid.physicsBody.categoryBitMask = ASTEROID_COLLIDERTYPE;
    topAsteroid.name = @"topAsteroid";
    
    bottomAsteroid.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bottomAsteroid.size];
    bottomAsteroid.physicsBody.dynamic = NO;
    bottomAsteroid.physicsBody.categoryBitMask = ASTEROID_COLLIDERTYPE;
    
    //[topAsteroid runAction:moveAsteroid];
    [topAsteroid runAction:moveAsteroid completion:^{
        [topAsteroid removeFromParent];
    }];
    //[bottomAsteroid runAction:moveAsteroid];
    [bottomAsteroid runAction:moveAsteroid completion:^{
        [bottomAsteroid removeFromParent];
    }];
    
    
    
    [self addChild:topAsteroid];
    [self addChild:bottomAsteroid];
}

- (void) didBeginContact:(SKPhysicsContact *)contact
{
    NSLog(@"%i %i", contact.bodyA.categoryBitMask, contact.bodyB.categoryBitMask);
    
    if((contact.bodyA.categoryBitMask == SHIP_COLLIDERTYPE && contact.bodyB.categoryBitMask == ASTEROID_COLLIDERTYPE)
       || (contact.bodyA.categoryBitMask == ASTEROID_COLLIDERTYPE && contact.bodyB.categoryBitMask == SHIP_COLLIDERTYPE)) {
        self.paused = YES;
        self.gameOver = YES;
    }
}

-(void)update:(CFTimeInterval)currentTime {
    if (self.gameOver == NO) {
        [self updateScore];
    }
}

-(void) updateScore
{
    [self enumerateChildNodesWithName:@"topAsteroid" usingBlock:^(SKNode *node, BOOL *stop) {
        if(self.shipSprite.position.x > node.position.x) {
            node.name = @"";
            self.score++;
            *stop = YES;
        }
    }];
    self.gameScoreLabel.text = [NSString stringWithFormat:@"Score: %i", self.score];
    
}

@end
