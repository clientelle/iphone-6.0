//
//  CTLMessageManager.h
//  Clientelle
//
//  Created by Kevin Liu on 7/19/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CTLCDConversation;

@interface CTLMessageManager : NSObject

typedef void (^CTLCreateMessageCompletionBlock)(BOOL success, NSError *error);

+ (void)sendMessage:(NSString *)messageText withConversation:(CTLCDConversation *)conversation completionBlock:(CTLCreateMessageCompletionBlock)completionBlock;

@end
