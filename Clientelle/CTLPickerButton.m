//
//  CTLPickerButton.m
//  Clientelle
//
//  Created by Kevin Liu on 3/12/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "CTLPickerButton.h"

int const CTLPickerButtonHeight = 40.0f;
int const CTLPickerButtonWidth = 210.0f;
int const CTLPickerButtonPadding = 20.0f;

@implementation CTLPickerButton

- (id)initWithTitle:(NSString *)title
{
    //size of title bar in portrait view
    self = [super initWithFrame:CGRectMake(0, 0, CTLPickerButtonWidth, CTLPickerButtonHeight)];
    if (self) {
        [self.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
        [self setTitle:title forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"wht-down-arw"] forState:UIControlStateNormal];
        [self positionIndicator];
    }
    return self;
}

- (void)updateTitle:(NSString *)title
{
    [self setTitle:title forState:UIControlStateNormal];
    [self positionIndicator];
}

- (void)positionIndicator
{
    CGSize titleSize = [[self titleForState:UIControlStateNormal] sizeWithFont:self.titleLabel.font];
    self.imageEdgeInsets = UIEdgeInsetsMake(self.imageView.frame.size.height, (titleSize.width + CTLPickerButtonPadding), 0, -titleSize.width);
}

@end
