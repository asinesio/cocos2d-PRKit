//
//  PRRatcliffTriangulator.mm
//  cocos2D-PRKit-Example
//
//  Created by Andy Sinesio on 4/21/11.
//  Copyright 2011 Precognitive Research, LLC. All rights reserved.
//

#import "PRRatcliffTriangulator.h"
#import "triangulate.h"

@implementation PRRatcliffTriangulator

- (NSArray *) triangulateVertices:(NSArray *)vertices {
   
    Vector2dVector *inputPointsForTriangulation = new Vector2dVector;
    for (NSValue *value in vertices) {
        CGPoint point = [value CGPointValue];
        inputPointsForTriangulation->push_back( Vector2d(point.x,point.y));
    }
    // Triangulate results
    Vector2dVector triangulatedPoints;
    
    Triangulate::Process(*inputPointsForTriangulation, triangulatedPoints);
    delete inputPointsForTriangulation;
    
    int triangulatedPointCount = triangulatedPoints.size();
    NSMutableArray *triangulatedPointsArray = [NSMutableArray arrayWithCapacity:triangulatedPointCount];
    for (int i = 0; i < triangulatedPointCount; i++) {
        NSValue *triangulatedPointValue = [NSValue valueWithCGPoint:CGPointMake(triangulatedPoints[i].GetX(), triangulatedPoints[i].GetY())];
        [triangulatedPointsArray addObject:triangulatedPointValue];
    }
    return triangulatedPointsArray;
}

@end
