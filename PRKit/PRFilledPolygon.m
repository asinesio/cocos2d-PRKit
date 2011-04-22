//
//  Surface.mm
//  SpaceHauler
//
//  Created by Andy Sinesio on 6/25/10.
//  Copyright 2010 Precognitive Research, LLC. All rights reserved.
//

#import "PRFilledPolygon.h"
#import "PRRatcliffTriangulator.h"

@interface PRFilledPolygon (privateMethods)

/**
 Recalculate the texture coordinates. Called when setTexture is called.
*/
-(void) calculateTextureCoordinates;

@end

@implementation PRFilledPolygon

@synthesize triangulator;


/**
 Returns an autoreleased polygon.  Default triangulator is used (Ratcliff's).
 */
+(id) filledPolygonWithPoints: (NSArray *) polygonPoints andTexture: (CCTexture2D *) fillTexture {
    return [[[PRFilledPolygon alloc] initWithPoints:polygonPoints andTexture:fillTexture] autorelease];
}

/**
 Returns an autoreleased filled poly with a supplied triangulator.
 */
+(id) filledPolygonWithPoints:(NSArray *)polygonPoints andTexture:(CCTexture2D *)fillTexture usingTriangulator: (id<PRTriangulator>) polygonTriangulator {
    return [[[PRFilledPolygon alloc] initWithPoints:polygonPoints andTexture:fillTexture usingTriangulator:polygonTriangulator] autorelease];
}

-(id) initWithPoints: (NSArray *) polygonPoints andTexture: (CCTexture2D *) fillTexture {
    return [self initWithPoints:polygonPoints andTexture:fillTexture usingTriangulator:[[[PRRatcliffTriangulator alloc] init] autorelease]];
}

-(id) initWithPoints:(NSArray *)polygonPoints andTexture:(CCTexture2D *)fillTexture usingTriangulator: (id<PRTriangulator>) polygonTriangulator {
    if( (self=[super init])) {
		
        self.triangulator = polygonTriangulator;
        
        [self setPoints:polygonPoints];
		self.texture = fillTexture;
        
	}
	
	return self;
}

-(void) setPoints: (NSArray *) points {
    if (areaTrianglePoints)
        free(areaTrianglePoints);
    if (textureCoordinates)
        free(textureCoordinates);
    
    NSArray *triangulatedPoints = [triangulator triangulateVertices:points];
    
    areaTrianglePointCount = [triangulatedPoints count];
    areaTrianglePoints = (CGPoint *) malloc(sizeof(CGPoint) * areaTrianglePointCount);
    textureCoordinates = (CGPoint *) malloc(sizeof(CGPoint) * areaTrianglePointCount);
    
    for (int i = 0; i < areaTrianglePointCount; i++) {
        areaTrianglePoints[i] = [[triangulatedPoints objectAtIndex:i] CGPointValue];
    }
    
    [self calculateTextureCoordinates];

}

-(void) calculateTextureCoordinates {
	for (int j = 0; j < areaTrianglePointCount; j++) {
		textureCoordinates[j] = ccpMult(areaTrianglePoints[j], 1.0f/texture.pixelsWide);
	}
}

-(void) draw {
	// we have a pointer to vertex points so enable client state
	glBindTexture(GL_TEXTURE_2D, self.texture.name);
	
	glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);
	
	glVertexPointer(2, GL_FLOAT, 0, areaTrianglePoints);
	glTexCoordPointer(2, GL_FLOAT, 0, textureCoordinates);
	
	glDrawArrays(GL_TRIANGLES, 0, areaTrianglePointCount);
	glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
	
	//Restore texture matrix and switch back to modelview matrix
	glEnableClientState(GL_COLOR_ARRAY);
	
}

-(void) updateBlendFunc {
	// it's possible to have an untextured sprite
	if( !texture || ! [texture hasPremultipliedAlpha] ) {
		blendFunc.src = GL_SRC_ALPHA;
		blendFunc.dst = GL_ONE_MINUS_SRC_ALPHA;
		//[self setOpacityModifyRGB:NO];
	} else {
		blendFunc.src = CC_BLEND_SRC;
		blendFunc.dst = CC_BLEND_DST;
		//[self setOpacityModifyRGB:YES];
	}
}

-(void) setBlendFunc:(ccBlendFunc)blendFuncIn {
	blendFunc = blendFuncIn;
}

-(ccBlendFunc) blendFunc {
	return blendFunc;
}

-(void) setTexture:(CCTexture2D *) texture2D {
	
	// accept texture==nil as argument
	NSAssert( !texture || [texture isKindOfClass:[CCTexture2D class]], @"setTexture expects a CCTexture2D. Invalid argument");
	
	[texture release];
	texture = [texture2D retain];
	ccTexParams texParams = { GL_NEAREST, GL_NEAREST, GL_REPEAT, GL_REPEAT };
	[texture setTexParameters: &texParams];
	
	[self updateBlendFunc];
	[self calculateTextureCoordinates];
}

-(CCTexture2D *) texture {
	return texture;
}
		 
-(void) dealloc {
    [super dealloc];
	free(areaTrianglePoints);
	free(textureCoordinates);
	[texture release]; texture = nil;
    [triangulator release]; triangulator = nil;

}

@end
