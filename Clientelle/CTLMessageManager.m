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
#import "CTLCDContact.h"

@implementation CTLMessageManager

+ (CTLMessageManager *) sharedInstance
{
	static CTLMessageManager *shared;
	@synchronized(self) {
		if(!shared){
			shared = [[CTLMessageManager alloc] init];
		}
		return shared;
	}
}

- (void)sendMessage:(NSString *)messageText withConversation:(CTLCDConversation *)conversation completionBlock:(CTLMessageCompletionBlock)completionBlock errorBlock:(CTLMessageErrorBlock)errorBlock
{    
    NSDictionary *postDict = @{@"message[content]": messageText, @"message[recipient_id]": conversation.contact.userId};    
    [[CTLNetworkClient api] signedPost:@"/messages.json" params:postDict completionBlock:^(id responseDict){
        [self saveConversation:responseDict messageText:messageText withConversation:conversation onComplete:completionBlock];    
    } errorBlock:^(NSError *error){
        errorBlock(error);
    }];
}

- (void)sendInviteMessage:(NSString *)messageText withConversation:(CTLCDConversation *)conversation completionBlock:(CTLMessageCompletionBlock)completionBlock errorBlock:(CTLMessageErrorBlock)errorBlock
{    
    NSDictionary *postDict = @{@"message[content]": messageText, @"message[record_id]": conversation.contact.recordID};    
    [[CTLNetworkClient api] signedPost:@"/invite/new_user.json" params:postDict completionBlock:^(id responseDict){        
        [self saveConversation:responseDict messageText:messageText withConversation:conversation onComplete:completionBlock];
    } errorBlock:^(NSError *error){
        errorBlock(error);
    }];
}

- (void)saveConversation:(NSDictionary *)responseDict messageText:(NSString *)messageText withConversation:(CTLCDConversation *)conversation onComplete:(CTLMessageCompletionBlock)completionBlock
{
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
}

@end
