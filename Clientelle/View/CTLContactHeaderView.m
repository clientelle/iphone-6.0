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

NSString *const CTLShareContactNotification = @"com.clientelle.com.notifications.shareContact";
CGFloat const CTLContactViewHeaderHeight = 68.0f;
int CTLNameLabelTag = 664;
int CTLPhoneLabelTag = 602;

@implementation CTLContactHeaderView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        _menuIsVisible = NO;
        _menuController = [UIMenuController sharedMenuController];
        
        [self setBackgroundColor:[UIColor whiteColor]];
        // Initialization code
        //[self setBackgroundColor:[UIColor colorFromUnNormalizedRGB:218.0f green:218.0f blue:218.0f alpha:1.0f]];
        //[self setBackgroundColor:[UIColor ctlGreen]];
        
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
        [nameLabel setUserInteractionEnabled:YES];
        nameLabel.tag = CTLNameLabelTag;
        
        
        UILabel *phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftMargin, nameLabel.frame.size.height + 10, labelWidth, 20.0f)];
        [phoneLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
        [phoneLabel setTextColor:[UIColor darkGrayColor]];
        [phoneLabel setUserInteractionEnabled:YES];
        phoneLabel.tag = CTLPhoneLabelTag;
        
        CGFloat editButtonWidth = 50.0f;
        CGFloat rightOffset = viewSize.width - editButtonWidth;
        UIButton *editProfileButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [editProfileButton setFrame:CGRectMake(rightOffset, 0, editButtonWidth, viewSize.height)];
        [editProfileButton addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
                        
        CALayer *border1 = [CALayer layer];
        border1.borderColor = [UIColor colorFromUnNormalizedRGB:200.0f green:200.0f blue:200.0f alpha:1.0f].CGColor;
        border1.borderWidth = 1;
        border1.frame = CGRectMake(0, 0, 1.0f, viewSize.height);
        
        [editProfileButton.layer addSublayer:border1];
        
        /*
        CALayer *border2 = [CALayer layer];
        border2.borderColor = [UIColor whiteColor].CGColor;
        border2.borderWidth = 1;
        border2.frame = CGRectMake(1.0f, 0, 1.0f, viewSize.height);
        [editProfileButton.layer addSublayer:border2];
        */
         
        CGFloat indicatorPositionX = self.bounds.size.width - 30;
        CGFloat indicatorPositionY = (CTLContactViewHeaderHeight/2) - (19.0f/2);
        
        UIImageView *editIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(indicatorPositionX,  indicatorPositionY, 19.0f, 19.0f)];
        [editIndicator setImage:[UIImage imageNamed:@"cell-arrow.png"]];
        
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


-(BOOL)canBecomeFirstResponder
{
	return  YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    [self reset];
    
    if(_menuIsVisible == YES){
        [_menuController setMenuVisible:NO animated:YES];
        [self reset];
        [self resignFirstResponder];
        _menuIsVisible = NO;
        return;
    }
        
    UITouch *touch = [touches anyObject];
    UIMenuItem *copy = [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(copyContactInfo)];
      
    if([[touch view] isKindOfClass:[UILabel class]]){
        UILabel *label = (UILabel *)[touch view];
        if(label.tag == CTLNameLabelTag){
            [self showMenuPopupForLabel:label menuItems:@[copy]];
            return;
        }
    }
    
    UIMenuItem *share = [[UIMenuItem alloc] initWithTitle:@"Share" action:@selector(shareContact)];
    [self showMenuPopupForLabel:self.phoneLabel menuItems:@[copy, share]];
    
}

- (void)showMenuPopupForLabel:(UILabel *)label menuItems:(NSArray *)menuItems
{
    [self decorateLabel:label];
    [_menuController setMenuItems:menuItems];
    
    if([self canBecomeFirstResponder]){
        [self becomeFirstResponder];
        CGPoint point = label.frame.origin;
        point.x += 45.0f;
        [_menuController setTargetRect:CGRectMake(point.x, point.y + 15, 0, 0) inView:self];
        [_menuController setMenuVisible:YES animated:YES];
        _menuIsVisible = YES;
    }
}

-(void)copyContactInfo
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.phoneLabel.text;
}


-(void)shareContact
{
	[[NSNotificationCenter defaultCenter] postNotificationName:CTLShareContactNotification object:nil];
}

- (void)populateViewData:(CTLABPerson *)abPerson {
    
    [self reset];
    
    NSString *nameStr = [abPerson compositeName];
    if([abPerson organization]){
        nameStr = [nameStr stringByAppendingFormat:@", %@", [abPerson organization]];
    }
    self.nameLabel.text = nameStr;
    self.phoneLabel.text = ([abPerson phone]) ? [abPerson phone] : [abPerson email];
    
    self.nameLabel.text = [abPerson compositeName];
    self.pictureView.image = [abPerson picture];
    
    if([[abPerson phone] length] > 0){
        self.phoneLabel.text = [abPerson phone];
    }else if([[abPerson email] length] > 0){
        self.phoneLabel.text = [abPerson email];
    }
    
    CGSize nameLabelSize = [self.nameLabel.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:16]];
    [self.nameLabel.text sizeWithFont:self.nameLabel.font];
    
    CGRect nameLabelFrame = self.nameLabel.frame;
    nameLabelFrame.size.width = nameLabelSize.width;
    self.nameLabel.frame = nameLabelFrame;
    
    CGSize phoneLabelSize = [self.phoneLabel.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
    [self.phoneLabel.text sizeWithFont:self.phoneLabel.font];
    
    CGRect phoneLabelFrame = self.phoneLabel.frame;
    phoneLabelFrame.size.width = phoneLabelSize.width;
    self.phoneLabel.frame = phoneLabelFrame;
}

-(void)drawRect:(CGRect)rect {
    self.layer.shadowOpacity = 0.75f;
    self.layer.shadowRadius = 2.0f;
    self.layer.shadowOffset = CGSizeMake(0, 0);
}

- (void)decorateLabel:(UILabel *)label
{
    label.backgroundColor = [UIColor colorFromUnNormalizedRGB:208 green:220 blue:236 alpha:1.0f];
}

- (void)reset{
    self.nameLabel.backgroundColor = [UIColor clearColor];
    self.phoneLabel.backgroundColor = [UIColor clearColor];
}

@end
