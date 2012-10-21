/*
 PRRatcliffTriangulator.mm
 
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


#import "PRRatcliffTriangulator.h"
#import "triangulate.h"

@implementation PRRatcliffTriangulator

- (NSArray *) triangulateVertices:(NSArray *)vertices {
   
    Vector2dVector *inputPointsForTriangulation = new Vector2dVector;
    for (NSValue *value in vertices) {
#ifdef __CC_PLATFORM_IOS
        CGPoint point = [value CGPointValue];
#else
        CGPoint point = [value pointValue];
#endif
        inputPointsForTriangulation->push_back( Vector2d(point.x,point.y));
    }
    // Triangulate results
    Vector2dVector triangulatedPoints;
    
    Triangulate::Process(*inputPointsForTriangulation, triangulatedPoints);
    delete inputPointsForTriangulation;
    
    int triangulatedPointCount = (int)triangulatedPoints.size();
    NSMutableArray *triangulatedPointsArray = [NSMutableArray arrayWithCapacity:triangulatedPointCount];
    for (int i = 0; i < triangulatedPointCount; i++) {
#ifdef __CC_PLATFORM_IOS
        NSValue *triangulatedPointValue = [NSValue valueWithCGPoint:CGPointMake(triangulatedPoints[i].GetX(), triangulatedPoints[i].GetY())];
#else
        NSValue *triangulatedPointValue = [NSValue valueWithPoint:CGPointMake(triangulatedPoints[i].GetX(), triangulatedPoints[i].GetY())];
#endif
        [triangulatedPointsArray addObject:triangulatedPointValue];
    }
    return triangulatedPointsArray;
}

@end
