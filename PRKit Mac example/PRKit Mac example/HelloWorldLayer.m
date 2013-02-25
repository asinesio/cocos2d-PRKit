//
//  HelloWorldLayer.m
//  PRKit Mac example
//
//  Created by Andy Sinesio on 2/24/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#import "PRFilledPolygon.h"


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
	if( (self=[super init]) ) {
		
		// create and initialize a Label
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Hello World" fontName:@"Marker Felt" fontSize:64];

		// ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
	
		// position the label on the center of the screen
		label.position =  ccp( size.width /2 , size.height/2 );
		
		// add the label as a child to this Layer
		[self addChild: label];
        
        // Set up the polygon points
        NSMutableArray *polygonPoints = [NSMutableArray arrayWithCapacity:10];
        [polygonPoints addObject:[NSValue valueWithPoint:ccp(100,100)]];
        [polygonPoints addObject:[NSValue valueWithPoint:ccp(200,100)]];
        [polygonPoints addObject:[NSValue valueWithPoint:ccp(300,200)]];
        [polygonPoints addObject:[NSValue valueWithPoint:ccp(400,300)]];
        [polygonPoints addObject:[NSValue valueWithPoint:ccp(500,500)]];
        
        CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:@"pattern1.png"];
       
        PRFilledPolygon *filledPolygon = [[[PRFilledPolygon alloc] initWithPoints:polygonPoints andTexture:texture] autorelease];
        filledPolygon.position =  ccp( size.width /2 , size.height/2 );
        [self addChild:filledPolygon z:0];

	}
	return self;
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
