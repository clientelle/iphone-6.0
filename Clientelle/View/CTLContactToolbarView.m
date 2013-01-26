//
//  CTLContactToolbarView.m
//  Clientelle
//
//  Created by Kevin Liu on 9/27/12.
//  Copyright (c) 2012 Clientelle Leads LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIColor+CTLColor.h"
#import "CTLContactToolbarView.h"

CGFloat const CTLContactModeToolbarViewHeight = 70;

@implementation CTLContactToolbarView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        self.appointmentButton = [self createButton:@"11-clock.png" withIndex:0];
        self.emailButton = [self createButton:@"18-envelope.png" withIndex:1];
        self.callButton = [self createButton:@"75-phone.png" withIndex:2];
        self.smsButton = [self createButton:@"09-chat-2.png" withIndex:3];
        self.mapButton = [self createButton:@"07-map-marker.png" withIndex:4];
    }
    return self;
}

- (UIButton *)createButton:(NSString *)imageName withIndex:(int)index{
    
    CGFloat buttonHeight = 50.0f;
    CGFloat buttonWidth = 62.0f;
    CGFloat topMargin = 8.0f;
    CGFloat leftPosition = (buttonWidth * index) + 5;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button setFrame:CGRectMake(leftPosition, topMargin, buttonWidth, buttonHeight)];
    [button setTintColor:[UIColor redColor]];
    [self addSubview:button];
    return button;
}

-(void)drawRect:(CGRect)rect {
    
    CGFloat bumpHeight = 8.0f;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, 0, bumpHeight);
    CGPathAddLineToPoint(path, NULL, 128.0f, bumpHeight);
    CGPathAddLineToPoint(path, NULL, 138.0f, -bumpHeight);
    CGPathAddLineToPoint(path, NULL, 182.0f, -bumpHeight);
    CGPathAddLineToPoint(path, NULL, 192.0f, bumpHeight);
    CGPathAddLineToPoint(path, NULL, rect.size.width, bumpHeight);
    CGPathAddLineToPoint(path, NULL, rect.size.width, rect.size.height);
    CGPathAddLineToPoint(path, NULL, 0.0f, rect.size.height);

    CGPathCloseSubpath(path);
    CGContextAddPath(context, path);
        
    self.layer.shadowOpacity = 0.75f;
    self.layer.shadowRadius = 2.0f;
    self.layer.shadowOffset = CGSizeMake(0, 0);
        
    CGContextSetFillColorWithColor(context, [UIColor colorFromUnNormalizedRGB:177.0f green:204.0f blue:187.0f alpha:1.0f].CGColor);

    CGContextFillPath(context);
    CGContextSaveGState(context);
    CGPathRelease(path);
}

@end
