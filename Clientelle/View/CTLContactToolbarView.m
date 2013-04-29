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
        self.appointmentButton = [self createButton:@"11-clock" withIndex:0];
        self.callButton = [self createButton:@"75-phone" withIndex:1];
        self.smsButton = [self createButton:@"09-chat-2" withIndex:2];
    }
    return self;
}

- (UIButton *)createButton:(NSString *)imageName withIndex:(int)index{
    
    CGFloat buttonHeight = 50.0f;
    CGFloat buttonWidth = 102.0f;
    CGFloat topMargin = 8.0f;
    CGFloat leftPosition = (buttonWidth * index) + 5;
    
    UIImage *buttonIcon = [UIImage imageNamed:imageName];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonIcon forState:UIControlStateNormal];
    [button setFrame:CGRectMake(leftPosition, topMargin, buttonWidth, buttonHeight)];
   
    [self addSubview:button];
    return button;
}

-(void)drawRect:(CGRect)rect {
    
    CGFloat bumpHeight = 12.0f;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, 0, bumpHeight);
    CGPathAddLineToPoint(path, NULL, 118.0f, bumpHeight);
    CGPathAddLineToPoint(path, NULL, 138.0f, -bumpHeight);
    CGPathAddLineToPoint(path, NULL, 185.0f, -bumpHeight);
    CGPathAddLineToPoint(path, NULL, 205.0f, bumpHeight);
    CGPathAddLineToPoint(path, NULL, rect.size.width, bumpHeight);
    CGPathAddLineToPoint(path, NULL, rect.size.width, rect.size.height);
    CGPathAddLineToPoint(path, NULL, 0.0f, rect.size.height);

    CGPathCloseSubpath(path);
    CGContextAddPath(context, path);
    
    self.layer.shadowOpacity = 1.0f;
    self.layer.shadowRadius = 2.0f;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    
    UIColor *toolbarColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"dark_matter"]];
    
    CGContextSetFillColorWithColor(context, toolbarColor.CGColor);
    CGContextFillPath(context);
    CGContextSaveGState(context);
    CGPathRelease(path);
}

@end
