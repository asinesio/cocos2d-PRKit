//
//  PRTriangulator.h
//  cocos2D-PRKit-Example
//
//  Created by Andy Sinesio on 4/21/11.
//  Copyright 2011 Precognitive Research, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol PRTriangulator <NSObject>

- (NSArray *) triangulateVertices: (NSArray *) vertices;

@end
