//
//  HelloWorldLayer.m
//  cocos2d-PRKit
//
//  Created by Andy Sinesio on 4/4/11.
//  Copyright Precognitive Research, LLC 2011. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#import "PRFilledPolygon.h"

#define kTagPoly 10
#define kTagBox 20

// HelloWorldLayer implementation
@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		
		// create and initialize a Label
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Hello World" fontName:@"Marker Felt" fontSize:64];
        
		// ask director the the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
        
		// position the label on the center of the screen
		label.position =  ccp( size.width /2 , size.height/2 );
		
		// add the label as a child to this Layer
		[self addChild: label z:1];
        
        
        // Set up the polygon points
        NSMutableArray *polygonPoints = [NSMutableArray arrayWithCapacity:10];
        [polygonPoints addObject:[NSValue valueWithCGPoint:ccp(100,100)]];
        [polygonPoints addObject:[NSValue valueWithCGPoint:ccp(100,200)]];
        [polygonPoints addObject:[NSValue valueWithCGPoint:ccp(150,110)]];
        [polygonPoints addObject:[NSValue valueWithCGPoint:ccp(400,200)]];
        [polygonPoints addObject:[NSValue valueWithCGPoint:ccp(400,100)]];
        
        CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:@"pattern1.png"];
        PRFilledPolygon *filledPolygon = [[[PRFilledPolygon alloc] initWithPoints:polygonPoints andTexture:texture] autorelease];
        
        
        [self addChild:filledPolygon z:0 tag:kTagPoly];
        
        
        PRFilledPolygon *box = [[[PRFilledPolygon alloc] initWithPoints:[NSArray arrayWithObjects:
                                                                         [NSValue valueWithCGPoint:ccp(0,0)], 
                                                                         [NSValue valueWithCGPoint:ccp(0,75)],
                                                                         [NSValue valueWithCGPoint:ccp(75,75)],
                                                                         [NSValue valueWithCGPoint:ccp(75,0)],
                                                                         nil]
                                                             andTexture:texture] autorelease];
        [self addChild:box z:0 tag:kTagBox];
        
        [self scheduleUpdate];
	}
	return self;
}

- (void) update: (ccTime) dt {
    // change the polys
    if (CCRANDOM_0_1() > 0.95f) {
        float newY = 75.0f * CCRANDOM_0_1();
        CCLOG(@"New Y value: %2.0f", newY);
        
        NSArray *points = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:ccp(0,0)], 
                           [NSValue valueWithCGPoint:ccp(0,75)],
                           [NSValue valueWithCGPoint:ccp(75,newY + 75)],
                           [NSValue valueWithCGPoint:ccp(75,0)],
                           nil];
        id box = [self getChildByTag:kTagBox];
        [box setPoints:points];
    }
    
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
