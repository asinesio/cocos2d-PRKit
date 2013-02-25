/*
 PRFilledPolygon.m
 
 PRKit:  Precognitive Research additions to Cocos2D.  http://cocos2d-iphone.org
 Contact us if you like it:  http://precognitiveresearch.com
 
 Created by Andy Sinesio on 6/25/10.
 Copyright 2011 Precognitive Research, LLC. All rights reserved.
 
 This class fills a polygon as described by an array of NSValue-encapsulated points with a texture.
 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

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
    return [[PRFilledPolygon alloc] initWithPoints:polygonPoints andTexture:fillTexture];
}

/**
 Returns an autoreleased filled poly with a supplied triangulator.
 */
+(id) filledPolygonWithPoints:(NSArray *)polygonPoints andTexture:(CCTexture2D *)fillTexture usingTriangulator: (id<PRTriangulator>) polygonTriangulator {
    return [[PRFilledPolygon alloc] initWithPoints:polygonPoints andTexture:fillTexture usingTriangulator:polygonTriangulator];
}

-(id) initWithPoints: (NSArray *) polygonPoints andTexture: (CCTexture2D *) fillTexture {
    return [self initWithPoints:polygonPoints andTexture:fillTexture usingTriangulator:[[PRRatcliffTriangulator alloc] init]];
}

-(id) initWithPoints:(NSArray *)polygonPoints andTexture:(CCTexture2D *)fillTexture usingTriangulator: (id<PRTriangulator>) polygonTriangulator {
    if( (self=[super init])) {
		
        self.triangulator = polygonTriangulator;
        
        [self setPoints:polygonPoints];
		self.texture = fillTexture;
        
        self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTexture];
	}
	
	return self;
}

-(void) setPoints: (NSArray *) points {
    if (areaTrianglePoints)
        free(areaTrianglePoints);
    if (textureCoordinates)
        free(textureCoordinates);
    
    NSArray *triangulatedPoints = [triangulator triangulateVertices:points];
    
    areaTrianglePointCount = (int)[triangulatedPoints count];
    areaTrianglePoints = (ccVertex2F *) malloc(sizeof(ccVertex2F) * areaTrianglePointCount);
    textureCoordinates = (ccVertex2F *) malloc(sizeof(ccVertex2F) * areaTrianglePointCount);
    
    for (int i = 0; i < areaTrianglePointCount; i++) {
        
#ifdef __CC_PLATFORM_IOS
        CGPoint vert = [[triangulatedPoints objectAtIndex:i] CGPointValue];
#else
        CGPoint vert = [[triangulatedPoints objectAtIndex:i] pointValue];
#endif
        areaTrianglePoints[i] = (ccVertex2F) { vert.x, vert.y };
    }
    
    [self calculateTextureCoordinates];

}

-(void) calculateTextureCoordinates {
    for (int j = 0; j < areaTrianglePointCount; j++) {
        GLfloat scale = 1.0f/texture.pixelsWide * CC_CONTENT_SCALE_FACTOR();
        textureCoordinates[j] = (ccVertex2F) { areaTrianglePoints[j].x * scale, areaTrianglePoints[j].y * scale };
        textureCoordinates[j].y = 1 - textureCoordinates[j].y;
    }
}

-(void) draw {
    CC_NODE_DRAW_SETUP();
    
    ccGLBindTexture2D( self.texture.name );
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    
    ccGLBlendFunc( blendFunc.src, blendFunc.dst);
    
    ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position | kCCVertexAttribFlag_TexCoords );
    
    glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, areaTrianglePoints);
    glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLES, 0, areaTrianglePointCount);
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
	
	texture = texture2D;
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
	 texture = nil;
    triangulator = nil;
}

@end
