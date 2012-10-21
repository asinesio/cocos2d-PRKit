PRKit
=====

PRKit is a library of some small additions to the fantastic <a href="http://cocos2d-iphone.org">cocos2d for iphone</a> project that some people on the cocos2d forums found useful and figured others might like as well.

PRKit was contributed to the open source community by <a href="http://precognitiveresearch.com">Precognitive Research, LLC</a>.

License
----------
This is licensed using the same license as cocos2d itself and provided with absolutely no warranty.  You are free to use the PRKit code as you wish as long as you keep the license in the source code.

This code uses the excellent <a href="http://www.flipcode.com/archives/Efficient_Polygon_Triangulation.shtml">Triangulate C++ classes</a> written by <a href="mailto:jratcliff@verant.com">John W. Ratcliff</a>.

Changes in this fork
--------------------

Cocos2D is not included in this project, but it is used as an external
static library.
Instructions on how to obtain it, build it, and install it can be found
here:

https://github.com/Panajev/CocosLib#howto-install

Installation
------------
Download the source and add the files under ''PRKit'' to your project:
* PRFilledPolygon.h
* PRFilledPolygon.m
* PRTriangulator.h
* PRRatcliffTriangulator.h
* PRRatcliffTriangulator.mm
* triangulate.h
* triangulate.cpp 

Class Overview
--------------
### PRFilledPolygon

PRFilledPolygon will fill a polygon of arbitrary points with a texture; think of it like using the Polygon tool in Photoshop and then filling it in using the paint bucket tool.

The class inherits from CCNode, so it can be added to your hierarchy as any other class and should respond to position changes like any other node. (Please test and let us know!)

    NSMutableArray *polygonPoints = [NSMutableArray arrayWithCapacity:10];
    [polygonPoints addObject:[NSValue valueWithCGPoint:ccp(100,100)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:ccp(200,100)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:ccp(300,200)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:ccp(400,300)]];
    [polygonPoints addObject:[NSValue valueWithCGPoint:ccp(500,500)]]; 
    
    CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:@"pattern1.png"];
    PRFilledPolygon *filledPolygon = [[[PRFilledPolygon alloc] initWithPoints:polygonPoints andTexture:texture] autorelease];
    [self addChild:filledPolygon z:0];

You can also change the points on the fly by calling setPoints:

    float newY = 75.0f * CCRANDOM_0_1();       
    NSArray *points = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:ccp(0,0)], 
        [NSValue valueWithCGPoint:ccp(0,75)],
        [NSValue valueWithCGPoint:ccp(75,newY + 75)],
        [NSValue valueWithCGPoint:ccp(75,0)],
        nil];
    id box = [self getChildByTag:kTagBox];
    [box setPoints:points];

The class also supports pluggable <i>PRTriangulator</i> implementations. Just set the triangulator object with something that implements the <i>PRTriangulator</i> protocol.

### PRTriangulator

This is a protocol for pluggable triangulators.  The Ratcliff implementation is the only one that ships with PRKit right now, but should you want to write your own, go right ahead -- you only have to implement one method:

    - (NSArray *) triangulateVertices:(NSArray *)vertices;

There is a <a href="http://www.vterrain.org/Implementation/Libs/triangulate.html">great reference on vterrian.org</a> with links to many different triangulation algorithms.

### PRRatcliffTriangulator

This implements the <i>PRTriangulator</i> and is the default triangulator supplied for PRKit.  It uses Ratcliff's triangulator from flipcode (shipped with the code as <i>triangulator.h</i> and <i>triangulator.cpp</i>).
