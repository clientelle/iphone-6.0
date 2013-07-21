//
//  CTLMessageManager.m
//  Clientelle
//
//  Created by Kevin Liu on 7/19/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "CTLAPI.h"
#import "CTLMessageManager.h"
#import "CTLCDConversation.h"
#import "CTLCDMessage.h"
#import "CTLCDAccount.h"

@implementation CTLMessageManager

+ (void)sendMessage:(NSString *)messageText withConversation:(CTLCDConversation *)conversation completionBlock:(CTLCreateMessageCompletionBlock)completionBlock
{
  NSDictionary *postDict = @{@"message[content]": messageText, @"message[recipient_id]": @(4)};
   
  [[CTLAPI sharedAPI] makeSignedRequest:@"/messages" withUser:conversation.account params:postDict method:GOHTTPMethodPOST withBlock:^(BOOL result, NSDictionary *responseDict) {
    
    if(result){
      conversation.updated_at = [NSDate date];
      conversation.last_sender_uid = conversation.account.user_id;
      conversation.preview_message= messageText;      
   
      CTLCDMessage *message = [CTLCDMessage createEntity];
        message.conversation = conversation;
        message.sender_uid = conversation.account.user_id;
        message.message_text = messageText;
        message.created_at = [NSDate date];    
      
      [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error){
        
        completionBlock(result, error);
        
      }];
    }else{
      NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : NSLocalizedString(@"COULD_NOT_SEND_MESSAGE", nil) };
      NSError *error = [NSError errorWithDomain:@"com.ctl.clientelle.ErrorDomain" code:100 userInfo:userInfo];
      completionBlock(NO, error);
    }
  }];
}

@end
