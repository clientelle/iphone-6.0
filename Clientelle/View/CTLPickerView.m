//
//  CTLPickerView.m
//  Clientelle
//
//  Created by Kevin Liu on 3/12/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "CTLPickerView.h"
#import "UIColor+CTLColor.h"

int const CTLPickerHeight = 162.0f;

@implementation CTLPickerView

- (id)initWithWidth:(CGFloat)width
{
    self = [super initWithFrame:CGRectMake(0, -179.0f, width, CTLPickerHeight)];
    
    if (self) {
        self.isVisible = NO;
        self.showsSelectionIndicator = YES;
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidePicker)]];
    }
    return self;
}

- (void)showPicker
{
    CGRect pickerFrame = self.frame;
    pickerFrame.origin.y = 0;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = pickerFrame;
    } completion:^(BOOL finished){
        self.isVisible = YES;
    }];
}

- (void)hidePicker
{
    if(!self.isVisible){
        return;
    }
    
    CGRect pickerFrame = self.frame;
    pickerFrame.origin.y = -pickerFrame.size.height - 10.0f;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = pickerFrame;
    } completion:^(BOOL finished) {
        self.isVisible = NO;
    }];
}

- (void)drawRect:(CGRect)rect
{
    //add a footer and drop shadow
    CALayer *pickerFooterView = [CALayer layer];//
    pickerFooterView.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, 7.0f);
    pickerFooterView.backgroundColor = [UIColor colorFromUnNormalizedRGB:43.0f green:44.0f blue:57.0f alpha:1.0f].CGColor;
    pickerFooterView.shadowOpacity = 1.0f;
    pickerFooterView.shadowRadius = 3.0f;
    pickerFooterView.shadowOffset = CGSizeMake(0,0);
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, self.bounds.size.height-1.0f, pickerFooterView.frame.size.width, 1.0f);
    bottomBorder.backgroundColor = [UIColor colorFromUnNormalizedRGB:27.0f green:27.0f blue:27.0f alpha:1.0f].CGColor;
    
    [self.layer addSublayer:pickerFooterView];
    [self.layer addSublayer:bottomBorder];
}


@end
