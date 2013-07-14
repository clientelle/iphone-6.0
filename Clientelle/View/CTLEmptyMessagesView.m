//
//  CTLEmptyMessagesView.m
//  Clientelle
//
//  Created by Kevin Liu on 6/16/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "CTLEmptyMessagesView.h"

@implementation CTLEmptyMessagesView

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"groovepaper"]];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

@end
