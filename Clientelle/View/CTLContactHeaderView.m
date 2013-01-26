//
//  CTLContactHeaderView.m
//  Clientelle
//
//  Created by Kevin Liu on 9/22/12.
//  Copyright (c) 2012 Clientelle Leads LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIColor+CTLColor.h"
#import "NSString+CTLString.h"

#import "CTLContactHeaderView.h"
#import "CTLABPerson.h"

CGFloat const CTLContactViewHeaderHeight = 68.0f;

@implementation CTLContactHeaderView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor whiteColor]];
        
        CGFloat padding = 10.0f;
        CGSize viewSize = self.bounds.size;
        
        UIImageView *pictureView = [[UIImageView alloc] initWithFrame:CGRectMake(padding, padding, 45.0f, 45.0f)];
        [pictureView setImage:[UIImage imageNamed:@"default-pic.png"]];
        [pictureView setBackgroundColor:[UIColor colorFromUnNormalizedRGB:240.0f green:240.0f blue:240.0f alpha:1.0f]];
        [pictureView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
        [pictureView.layer setBorderWidth: 2.0];
        [pictureView.layer setShadowOpacity:0.55f];
        [pictureView.layer setShadowRadius:1.0f];
        [pictureView.layer setShadowOffset:CGSizeMake(0.5f, 0.5f)];
        
        CGFloat leftMargin = pictureView.frame.size.width + 20;
        CGFloat labelWidth = viewSize.width - (pictureView.frame.size.width + 50);
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftMargin, padding, labelWidth, 20.0f)];
        [nameLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:16]];
        [nameLabel setTextColor:[UIColor darkGrayColor]];
                
        UILabel *phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftMargin, nameLabel.frame.size.height + 10, labelWidth, 20.0f)];
        [phoneLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
        [phoneLabel setTextColor:[UIColor darkGrayColor]];
        
        UIButton *editProfileButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [editProfileButton setFrame:CGRectMake(0, 0, viewSize.width, viewSize.height)];
        [editProfileButton addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
        
        CGFloat indicatorPositionX = self.bounds.size.width - 20;
        CGFloat indicatorPositionY = (CTLContactViewHeaderHeight/2) - (13.0f/2);
        
        UIImageView *editIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(indicatorPositionX,  indicatorPositionY, 10, 13)];
        [editIndicator setImage:[UIImage imageNamed:@"cell-indicator.png"]];
        
        [self addSubview:pictureView];
        [self addSubview:nameLabel];
        [self addSubview:phoneLabel];
        [self addSubview:editProfileButton];
        [self addSubview:editIndicator];
                               
        self.pictureView = pictureView;
        self.nameLabel = nameLabel;
        self.phoneLabel = phoneLabel;
        self.editButton = editProfileButton;
    }
    return self;
}

- (void)populateViewData:(CTLABPerson *)abPerson {
    NSString *nameStr = [abPerson compositeName];
    if([abPerson organization]){
        nameStr = [nameStr stringByAppendingFormat:@", %@", [abPerson organization]];
    }
    self.nameLabel.text = nameStr;
    self.phoneLabel.text = ([abPerson phone]) ? [abPerson phone] : [abPerson email];
    
    self.nameLabel.text = [abPerson compositeName];
    self.pictureView.image = [abPerson picture];
    
    if([[abPerson phone] length] > 0){
        self.phoneLabel.text = [abPerson phone];//[self formatPhoneNumber:[abPerson phone]];
    }else if([[abPerson email] length] > 0){
        self.phoneLabel.text = [abPerson email];
    }
}

-(void)drawRect:(CGRect)rect {
       
    
    self.layer.shadowOpacity = 0.75f;
    self.layer.shadowRadius = 2.0f;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    
}

@end
