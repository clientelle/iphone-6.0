//
//  CTLMessageManager.m
//  Clientelle
//
//  Created by Kevin Liu on 7/19/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "CTLNetworkClient.h"
#import "CTLMessageManager.h"
#import "CTLCDConversation.h"
#import "CTLCDMessage.h"
#import "CTLCDAccount.h"

@implementation CTLMessageManager

+ (CTLMessageManager *) sharedInstance
{
	static CTLMessageManager *shared;
	@synchronized(self)
    {
		if(!shared){
			shared = [[CTLMessageManager alloc] init];
		}
		return shared;
	}
}

- (void)sendMessage:(NSString *)messageText withConversation:(CTLCDConversation *)conversation completionBlock:(CTLMessageCompletionBlock)completionBlock errorBlock:(CTLMessageErrorBlock)errorBlock
{
    NSDictionary *postDict = @{@"message[content]": messageText, @"message[recipient_id]": @(4)};
    
    [[CTLNetworkClient api] signedPost:@"/messages.json" withParams:postDict completionBlock:^(id responseDict){
        conversation.updated_at = [NSDate date];
        conversation.last_sender_uid = conversation.account.user_id;
        conversation.preview_message= messageText;

        CTLCDMessage *message = [CTLCDMessage createEntity];
        message.conversation = conversation;
        message.sender_uid = conversation.account.user_id;
        message.message_text = messageText;
        message.created_at = [NSDate date];

        [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error){
            completionBlock(message, responseDict);            
        }];
    } errorBlock:^(NSError *error){
        errorBlock(error);
    }];
}

@end
