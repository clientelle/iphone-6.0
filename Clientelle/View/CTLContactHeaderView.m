//
//  CTLContactHeaderView.m
//  Clientelle
//
//  Created by Kevin Liu on 9/22/12.
//  Copyright (c) 2012 Clientelle Leads LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIColor+CTLColor.h"
#import "UILabel+CTLLabel.h"
#import "NSString+CTLString.h"
#import "CTLContactHeaderView.h"
#import "CTLCDContact.h"

NSString *const CTLFontName = @"HelveticaNeue";
NSString *const CTLFontNameBold = @"HelveticaNeue-Bold";

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
        
        [self setBackgroundColor:[UIColor ctlOffWhite]];
          
        CGFloat padding = 10.0f;
        CGSize viewSize = self.bounds.size;
        
        UIImageView *pictureView = [[UIImageView alloc] initWithFrame:CGRectMake(padding, padding, 45.0f, 45.0f)];
        [pictureView setImage:[UIImage imageNamed:@"default-pic"]];
        [pictureView setBackgroundColor:[UIColor colorFromUnNormalizedRGB:240.0f green:240.0f blue:240.0f alpha:1.0f]];
        [pictureView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
        [pictureView.layer setBorderWidth: 2.0];
        [pictureView.layer setShadowOpacity:0.55f];
        [pictureView.layer setShadowRadius:1.0f];
        [pictureView.layer setShadowOffset:CGSizeMake(0.5f, 0.5f)];
        
        CGFloat leftMargin = pictureView.frame.size.width + 20;
        CGFloat labelWidth = viewSize.width - (pictureView.frame.size.width + 50);
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftMargin, padding, labelWidth, 20.0f)];
        [nameLabel setFont:[UIFont fontWithName:CTLFontNameBold size:16]];
        [nameLabel setTextColor:[UIColor darkGrayColor]];
        [nameLabel setUserInteractionEnabled:YES];
        nameLabel.tag = CTLNameLabelTag;
        
        UILabel *phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftMargin, nameLabel.frame.size.height + 10, labelWidth, 20.0f)];
        [phoneLabel setFont:[UIFont fontWithName:CTLFontName size:15]];
        [phoneLabel setTextColor:[UIColor darkGrayColor]];
        [phoneLabel setUserInteractionEnabled:YES];
        phoneLabel.tag = CTLPhoneLabelTag;
        
        CALayer *border1 = [CALayer layer];
        border1.borderColor = [UIColor ctlGray].CGColor;
        border1.borderWidth = 1;
        border1.frame = CGRectMake(0, 0, 1.0f, viewSize.height);
        
        CALayer *border2 = [CALayer layer];
        border2.borderColor = [UIColor whiteColor].CGColor;
        border2.borderWidth = 1;
        border2.frame = CGRectMake(1.0f, 0, 1.0f, viewSize.height);
        
        [self addSubview:pictureView];
        [self addSubview:nameLabel];
        [self addSubview:phoneLabel];
                               
        self.pictureView = pictureView;
        self.nameLabel = nameLabel;
        self.phoneLabel = phoneLabel;
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
    UIMenuItem *copy = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"COPY", nil) action:@selector(copyContactInfo)];
      
    if([[touch view] isKindOfClass:[UILabel class]]){
        UILabel *label = (UILabel *)[touch view];
        if(label.tag == CTLNameLabelTag){
            [self showMenuPopupForLabel:label menuItems:@[copy]];
            return;
        }
    }
    
    UIMenuItem *share = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"SHARE", nil) action:@selector(shareContact)];
    [self showMenuPopupForLabel:self.phoneLabel menuItems:@[copy, share]];
    
}

- (void)showMenuPopupForLabel:(UILabel *)label menuItems:(NSArray *)menuItems
{
    label.backgroundColor = [UIColor iOSHighlightedTextColor];
    
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

-(void)drawRect:(CGRect)rect {
    self.layer.shadowOpacity = 0.75f;
    self.layer.shadowRadius = 2.0f;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
}

- (void)reset{
    self.nameLabel.backgroundColor = [UIColor clearColor];
    self.phoneLabel.backgroundColor = [UIColor clearColor];
}

@end
