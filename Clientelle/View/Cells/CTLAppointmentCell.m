//
//  CTLAppointmentCell.m
//  Clientelle
//
//  Created by Kevin Liu on 3/12/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIColor+CTLColor.h"
#import "CTLAppointmentCell.h"
#import "CTLViewDecorator.h"

@implementation CTLAppointmentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    self.contentView.backgroundColor = [UIColor clearColor];
    CTLViewDecorator *decorator = [[CTLViewDecorator alloc] init];
    CAShapeLayer *dottedLine = [decorator createDottedLine:self.frame];
    [self.contentView.layer addSublayer:dottedLine];
}

@end
