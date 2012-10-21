/*
 *  triangulate.cpp
 
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

// COTD Entry submitted by John W. Ratcliff [jratcliff@verant.com]

// ** THIS IS A CODE SNIPPET WHICH WILL EFFICIEINTLY TRIANGULATE ANY
// ** POLYGON/CONTOUR (without holes) AS A STATIC CLASS.  THIS SNIPPET
// ** IS COMPRISED OF 3 FILES, TRIANGULATE.H, THE HEADER FILE FOR THE
// ** TRIANGULATE BASE CLASS, TRIANGULATE.CPP, THE IMPLEMENTATION OF
// ** THE TRIANGULATE BASE CLASS, AND TEST.CPP, A SMALL TEST PROGRAM
// ** DEMONSTRATING THE USAGE OF THE TRIANGULATOR.  THE TRIANGULATE
// ** BASE CLASS ALSO PROVIDES TWO USEFUL HELPER METHODS, ONE WHICH
// ** COMPUTES THE AREA OF A POLYGON, AND ANOTHER WHICH DOES AN EFFICENT
// ** POINT IN A TRIANGLE TEST.
// ** SUBMITTED BY JOHN W. RATCLIFF (jratcliff@verant.com) July 22, 2000


/**************************************************************************/
/*** END OF HEADER FILE TRIANGULATE.H BEGINNING OF CODE TRIANGULATE.CPP ***/
/**************************************************************************/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#include "triangulate.h"

static const float EPSILON=0.0000000001f;

float Triangulate::Area(const Vector2dVector &contour)
{
	
	int n = (int)contour.size();
	
	float A=0.0f;
	
	for(int p=n-1,q=0; q<n; p=q++)
	{
		A+= contour[p].GetX()*contour[q].GetY() - contour[q].GetX()*contour[p].GetY();
	}
	return A*0.5f;
}

/*
 InsideTriangle decides if a point P is Inside of the triangle
 defined by A, B, C.
 */
bool Triangulate::InsideTriangle(float Ax, float Ay,
								 float Bx, float By,
								 float Cx, float Cy,
								 float Px, float Py)

{
	float ax, ay, bx, by, cx, cy, apx, apy, bpx, bpy, cpx, cpy;
	float cCROSSap, bCROSScp, aCROSSbp;
	
	ax = Cx - Bx;  ay = Cy - By;
	bx = Ax - Cx;  by = Ay - Cy;
	cx = Bx - Ax;  cy = By - Ay;
	apx= Px - Ax;  apy= Py - Ay;
	bpx= Px - Bx;  bpy= Py - By;
	cpx= Px - Cx;  cpy= Py - Cy;
	
	aCROSSbp = ax*bpy - ay*bpx;
	cCROSSap = cx*apy - cy*apx;
	bCROSScp = bx*cpy - by*cpx;
	
	return ((aCROSSbp >= 0.0f) && (bCROSScp >= 0.0f) && (cCROSSap >= 0.0f));
};

bool Triangulate::Snip(const Vector2dVector &contour,int u,int v,int w,int n,int *V)
{
	int p;
	float Ax, Ay, Bx, By, Cx, Cy, Px, Py;
	
	Ax = contour[V[u]].GetX();
	Ay = contour[V[u]].GetY();
	
	Bx = contour[V[v]].GetX();
	By = contour[V[v]].GetY();
	
	Cx = contour[V[w]].GetX();
	Cy = contour[V[w]].GetY();
	
	if ( EPSILON > (((Bx-Ax)*(Cy-Ay)) - ((By-Ay)*(Cx-Ax))) ) return false;
	
	for (p=0;p<n;p++)
	{
		if( (p == u) || (p == v) || (p == w) ) continue;
		Px = contour[V[p]].GetX();
		Py = contour[V[p]].GetY();
		if (InsideTriangle(Ax,Ay,Bx,By,Cx,Cy,Px,Py)) return false;
	}
	
	return true;
}

bool Triangulate::Process(const Vector2dVector &contour,Vector2dVector &result)
{
	/* allocate and initialize list of Vertices in polygon */
	
	int n = (int)contour.size();
	if ( n < 3 ) return false;
	
	int *V = new int[n];
	
	/* we want a counter-clockwise polygon in V */
	
	if ( 0.0f < Area(contour) )
		for (int v=0; v<n; v++) V[v] = v;
	else
		for(int v=0; v<n; v++) V[v] = (n-1)-v;
	
	int nv = n;
	
	/*  remove nv-2 Vertices, creating 1 triangle every time */
	int count = 2*nv;   /* error detection */
	
	for(int m=0, v=nv-1; nv>2; )
	{
		/* if we loop, it is probably a non-simple polygon */
		if (0 >= (count--))
		{
			//** Triangulate: ERROR - probable bad polygon!
			return false;
		}
		
		/* three consecutive vertices in current polygon, <u,v,w> */
		int u = v  ; if (nv <= u) u = 0;     /* previous */
		v = u+1; if (nv <= v) v = 0;     /* new v    */
		int w = v+1; if (nv <= w) w = 0;     /* next     */
		
		if ( Snip(contour,u,v,w,nv,V) )
		{
			int a,b,c,s,t;
			
			/* true names of the vertices */
			a = V[u]; b = V[v]; c = V[w];
			
			/* output Triangle */
			result.push_back( contour[a] );
			result.push_back( contour[b] );
			result.push_back( contour[c] );
			
			m++;
			
			/* remove v from remaining polygon */
			for(s=v,t=v+1;t<nv;s++,t++) V[s] = V[t]; nv--;
			
			/* resest error detection counter */
			count = 2*nv;
		}
	}
	
	
	
	delete V;
	
	return true;
}


///************************************************************************/
///*** END OF CODE SECTION TRIANGULATE.CPP BEGINNING OF TEST.CPP A SMALL **/
///*** TEST APPLICATION TO DEMONSTRATE THE USAGE OF THE TRIANGULATOR     **/
///************************************************************************/
//
//#include <stdio.h>
//#include <stdlib.h>
//#include <string.h>
//#include <assert.h>
//
//
//#include "triangulate.h"
//
//void main(int argc,char **argv)
//{
//	
//	// Small test application demonstrating the usage of the triangulate
//	// class.
//	
//	
//	// Create a pretty complicated little contour by pushing them onto
//	// an stl vector.
//	
//	Vector2dVector a;
//	
//	a.push_back( Vector2d(0,6));
//	a.push_back( Vector2d(0,0));
//	a.push_back( Vector2d(3,0));
//	a.push_back( Vector2d(4,1));
//	a.push_back( Vector2d(6,1));
//	a.push_back( Vector2d(8,0));
//	a.push_back( Vector2d(12,0));
//	a.push_back( Vector2d(13,2));
//	a.push_back( Vector2d(8,2));
//	a.push_back( Vector2d(8,4));
//	a.push_back( Vector2d(11,4));
//	a.push_back( Vector2d(11,6));
//	a.push_back( Vector2d(6,6));
//	a.push_back( Vector2d(4,3));
//	a.push_back( Vector2d(2,6));
//	
//	// allocate an STL vector to hold the answer.
//	
//	Vector2dVector result;
//	
//	//  Invoke the triangulator to triangulate this polygon.
//	Triangulate::Process(a,result);
//	
//	// print out the results.
//	int tcount = result.size()/3;
//	
//	for (int i=0; i<tcount; i++)
//	{
//		const Vector2d &p1 = result[i*3+0];
//		const Vector2d &p2 = result[i*3+1];
//		const Vector2d &p3 = result[i*3+2];
//		printf("Triangle %d => (%0.0f,%0.0f) (%0.0f,%0.0f) (%0.0f,%0.0f)\n",i+1,p1.GetX(),p1.GetY(),p2.GetX(),p2.GetY(),p3.GetX(),p3.GetY());
//	}
//	
//}