//
//  CTLTooltipView.m
//  Clientelle
//
//  Created by Kevin Liu on 4/27/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "CTLTooltipView.h"

const CGFloat CTLTOOLTIP_TRIANGLE_WIDTH = 20.0f;
const CGFloat CTLTOOLTIP_TRIANGLE_HEIGHT = 10.0f;

const CGFloat CTLTOOLTIP_STROKE_WIDTH = 2.0f;
const CGFloat CTLTOOLTIP_BORDER_RADIUS = 5.0f;

@implementation CTLTooltipView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
         NSLog(@"initWithFrame");
        
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.textView = [[UITextView alloc] initWithFrame:CGRectMake(3, 8, frame.size.width, frame.size.height)];
        [self.textView setBackgroundColor:[UIColor clearColor]];
        [self.textView setTextColor:[UIColor whiteColor]];
        [self.textView setFont:[UIFont fontWithName:@"System" size:13]];
        [self.textView setEditable:NO];
        
        [self addSubview:self.textView];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [tap setNumberOfTapsRequired:1];
        [tap setDelegate:self];
        [self addGestureRecognizer:tap];
    }
    
    return self;
}

- (void)handleTapGesture:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateRecognized) {
        [self removeFromSuperview];
        NSLog(@"remove from superview");
    }
}

- (void)setTipText:(NSString *)message
{
    self.textView.text = message;
   // [self fadeIn:1];
    [self autoResize];
}

- (void)fadeIn:(NSTimeInterval)seconds
{
   NSLog(@"fadingIn");
    //self.hidden = NO;
    [self setAlpha:1.0];
     [self setNeedsDisplay];
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:seconds];
//    [self setAlpha:1.0];
//    [UIView commitAnimations];
}

- (void)fadeOut:(NSTimeInterval)seconds
{
    NSLog(@"fadeOut");
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:seconds];
    [UIView setAnimationDelegate:self];
    self.alpha = 0.0f;
    [UIView commitAnimations];
}

- (void)autoResize
{
    //resize textview
    CGRect resizedFrame = self.textView.frame;
    resizedFrame.size.height = [self.textView contentSize].height;
    self.textView.frame = resizedFrame;
    
    //resize tooltip
    resizedFrame = self.frame;
    resizedFrame.size.height = self.textView.frame.size.height + CTLTOOLTIP_TRIANGLE_HEIGHT;
    self.frame = resizedFrame;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
     NSLog(@"drawRect");
    
    CGRect currentFrame = self.bounds;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineWidth(context, CTLTOOLTIP_STROKE_WIDTH);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    
    // Draw and fill the bubble
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, CTLTOOLTIP_BORDER_RADIUS + CTLTOOLTIP_STROKE_WIDTH + 0.5f, CTLTOOLTIP_STROKE_WIDTH + CTLTOOLTIP_TRIANGLE_HEIGHT);
    
//    CGContextAddLineToPoint(context, round(currentFrame.size.width / 2.0f - CTLTOOLTIP_TRIANGLE_WIDTH / 2.0f) + 0.5f, CTLTOOLTIP_TRIANGLE_HEIGHT + CTLTOOLTIP_STROKE_WIDTH + 0.5f);
//    CGContextAddLineToPoint(context, round(currentFrame.size.width / 2.0f) + 0.5f, CTLTOOLTIP_STROKE_WIDTH + 0.5f);
//    CGContextAddLineToPoint(context, round(currentFrame.size.width / 2.0f + CTLTOOLTIP_TRIANGLE_WIDTH / 2.0f) + 0.5f, CTLTOOLTIP_TRIANGLE_HEIGHT + CTLTOOLTIP_STROKE_WIDTH + 0.5f);
    
    CGFloat pos = (currentFrame.size.width - CTLTOOLTIP_TRIANGLE_WIDTH) - 8.0f;
    
    CGContextAddLineToPoint(context, round(pos - CTLTOOLTIP_TRIANGLE_WIDTH / 2.0f) + 0.5f, CTLTOOLTIP_TRIANGLE_HEIGHT + CTLTOOLTIP_STROKE_WIDTH + 0.5f);
    CGContextAddLineToPoint(context, round(pos) + 0.5f, CTLTOOLTIP_STROKE_WIDTH + 0.5f);
    
    CGContextAddLineToPoint(context, round(pos + CTLTOOLTIP_TRIANGLE_WIDTH / 2.0f) + 0.5f, CTLTOOLTIP_TRIANGLE_HEIGHT + CTLTOOLTIP_STROKE_WIDTH + 0.5f);

    
    CGContextAddArcToPoint(context, currentFrame.size.width - CTLTOOLTIP_STROKE_WIDTH - 0.5f, CTLTOOLTIP_STROKE_WIDTH + CTLTOOLTIP_TRIANGLE_HEIGHT + 0.5f, currentFrame.size.width - CTLTOOLTIP_STROKE_WIDTH - 0.5f, currentFrame.size.height - CTLTOOLTIP_STROKE_WIDTH - 0.5f, CTLTOOLTIP_BORDER_RADIUS - CTLTOOLTIP_STROKE_WIDTH);
    
    CGContextAddArcToPoint(context, currentFrame.size.width - CTLTOOLTIP_STROKE_WIDTH - 0.5f, currentFrame.size.height - CTLTOOLTIP_STROKE_WIDTH - 0.5f, round(currentFrame.size.width / 2.0f + CTLTOOLTIP_TRIANGLE_WIDTH / 2.0f) - CTLTOOLTIP_STROKE_WIDTH + 0.5f, currentFrame.size.height - CTLTOOLTIP_STROKE_WIDTH - 0.5f, CTLTOOLTIP_BORDER_RADIUS - CTLTOOLTIP_STROKE_WIDTH);
    CGContextAddArcToPoint(context, CTLTOOLTIP_STROKE_WIDTH + 0.5f, currentFrame.size.height - CTLTOOLTIP_STROKE_WIDTH - 0.5f, CTLTOOLTIP_STROKE_WIDTH + 0.5f, CTLTOOLTIP_TRIANGLE_HEIGHT + CTLTOOLTIP_STROKE_WIDTH + 0.5f, CTLTOOLTIP_BORDER_RADIUS - CTLTOOLTIP_STROKE_WIDTH);
    CGContextAddArcToPoint(context, CTLTOOLTIP_STROKE_WIDTH + 0.5f, CTLTOOLTIP_STROKE_WIDTH + CTLTOOLTIP_TRIANGLE_HEIGHT + 0.5f, currentFrame.size.width - CTLTOOLTIP_STROKE_WIDTH - 0.5f, CTLTOOLTIP_TRIANGLE_HEIGHT + CTLTOOLTIP_STROKE_WIDTH + 0.5f, CTLTOOLTIP_BORDER_RADIUS - CTLTOOLTIP_STROKE_WIDTH);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    // Draw a clipping path for the fill
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, CTLTOOLTIP_BORDER_RADIUS + CTLTOOLTIP_STROKE_WIDTH + 0.5f, round((currentFrame.size.height + CTLTOOLTIP_TRIANGLE_HEIGHT) * 0.50f) + 0.5f);
    CGContextAddArcToPoint(context, currentFrame.size.width - CTLTOOLTIP_STROKE_WIDTH - 0.5f, round((currentFrame.size.height + CTLTOOLTIP_TRIANGLE_HEIGHT) * 0.50f) + 0.5f, currentFrame.size.width - CTLTOOLTIP_STROKE_WIDTH - 0.5f, currentFrame.size.height - CTLTOOLTIP_STROKE_WIDTH - 0.5f, CTLTOOLTIP_BORDER_RADIUS - CTLTOOLTIP_STROKE_WIDTH);
    CGContextAddArcToPoint(context, currentFrame.size.width - CTLTOOLTIP_STROKE_WIDTH - 0.5f, currentFrame.size.height - CTLTOOLTIP_STROKE_WIDTH - 0.5f, round(currentFrame.size.width / 2.0f + CTLTOOLTIP_TRIANGLE_WIDTH / 2.0f) - CTLTOOLTIP_STROKE_WIDTH + 0.5f, currentFrame.size.height - CTLTOOLTIP_STROKE_WIDTH - 0.5f, CTLTOOLTIP_BORDER_RADIUS - CTLTOOLTIP_STROKE_WIDTH);
    CGContextAddArcToPoint(context, CTLTOOLTIP_STROKE_WIDTH + 0.5f, currentFrame.size.height - CTLTOOLTIP_STROKE_WIDTH - 0.5f, CTLTOOLTIP_STROKE_WIDTH + 0.5f, CTLTOOLTIP_TRIANGLE_HEIGHT + CTLTOOLTIP_STROKE_WIDTH + 0.5f, CTLTOOLTIP_BORDER_RADIUS - CTLTOOLTIP_STROKE_WIDTH);
    CGContextAddArcToPoint(context, CTLTOOLTIP_STROKE_WIDTH + 0.5f, round((currentFrame.size.height + CTLTOOLTIP_TRIANGLE_HEIGHT) * 0.50f) + 0.5f, currentFrame.size.width - CTLTOOLTIP_STROKE_WIDTH - 0.5f, round((currentFrame.size.height + CTLTOOLTIP_TRIANGLE_HEIGHT) * 0.50f) + 0.5f, CTLTOOLTIP_BORDER_RADIUS - CTLTOOLTIP_STROKE_WIDTH);
    CGContextClosePath(context);
    CGContextClip(context);
    
//    self.layer.shadowOpacity = 0.5f;
//    self.layer.shadowRadius = 1.0f;
//    self.layer.shadowColor = [UIColor blackColor].CGColor;
//    self.layer.shadowOffset = CGSizeMake(0, 1);
    
    [self setAlpha:0.8];
}


@end
