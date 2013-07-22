//
//  CTLMessageManager.h
//  Clientelle
//
//  Created by Kevin Liu on 7/19/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTLNetworkClient.h"

@class CTLCDMessage;
@class CTLCDConversation;

@interface CTLMessageManager : NSObject

typedef void (^CTLMessageCompletionBlock)(CTLCDMessage *message, NSDictionary *responseObject);
typedef void (^CTLMessageErrorBlock)(NSError *error);


+ (CTLMessageManager *)sharedInstance;

- (void)sendMessage:(NSString *)messageText withConversation:(CTLCDConversation *)conversation completionBlock:(CTLMessageCompletionBlock)completionBlock errorBlock:(CTLMessageErrorBlock)errorBlock;

@end
