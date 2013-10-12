//
//  CTLDottedLine.h
//  Clientelle
//
//  Created by Kevin Liu on 3/17/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CTLViewDecorator : NSObject

- (CAShapeLayer *)createDottedLine:(CGRect)frame;
- (CAShapeLayer *)createDottedVerticalLine:(CGFloat)height;

@end
