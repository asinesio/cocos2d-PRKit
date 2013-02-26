PRKit
=====

PRKit is a library of some small additions to the fantastic <a href="http://cocos2d-iphone.org">cocos2d for iphone</a> project that some people on the cocos2d forums found useful and figured others might like as well.

PRKit was contributed to the open source community by <a href="http://precognitiveresearch.com">Precognitive Research, LLC</a>.

License
----------
This is licensed using the same license as cocos2d itself and provided with absolutely no warranty.  You are free to use the PRKit code as you wish as long as you keep the license in the source code.

This code uses the excellent <a href="http://www.flipcode.com/archives/Efficient_Polygon_Triangulation.shtml">Triangulate C++ classes</a> written by <a href="mailto:jratcliff@verant.com">John W. Ratcliff</a>.

Release Notes
-------------

##### Version 0.3 (2013-02-24)
* Fixed issue with Mac OS X and 64 bit (#9)
* Restructured project into more sensible structure.

##### Version 0.2 (2013-02-13)
* Support for cocos2d 2.0 (thanks to [Panajev's](http://github.com/panajev) pull request)

##### Version 0.1 (2012-02-24)
* Initial release for cocos2d 1.1.

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

Compatibility
-------------
Tested with cocos2d 2.0 for iOS and Mac OS X.

Other Documentation
-------------------
Allen Tan wrote a great [tutorial on making a game with PRKit](http://www.raywenderlich.com/14302/how-to-make-a-game-like-fruit-ninja-with-box2d-and-cocos2d-part-1).  

Note that the changes to PRKit described in the tutorial are not needed, since they've been merged into the code. 


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
