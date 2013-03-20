//
//  GOHTTPOperation.h
//  GOImageCache
//
//  Created by Samuel Goodwin on 12/30/11.
//

#import <Foundation/Foundation.h>

typedef enum{
    GOHTTPMethodGET,
    GOHTTPMethodPOST
}GOHTTPMethod;

typedef void (^GODataBlock)(NSData* data);

@interface GOHTTPOperation : NSOperation<NSURLConnectionDelegate>

@property (assign, getter=isExecuting) BOOL executing;
@property (assign, getter=isFinished) BOOL finished;
@property (strong) NSMutableData *data;
@property (retain) NSMutableArray *completions;
@property (strong) NSURLRequest *request;

+ (id)operationWithURL:(NSString *)urlString;
+ (id)operationWithURL:(NSString *)urlString method:(GOHTTPMethod)method params:(NSDictionary *)params;
+ (id)POSToperationWithURL:(NSString *)urlString andJSONData:(NSData *)jsonData;

- (void)addCompletion:(GODataBlock)block;
+ (BOOL)hasConnection;

@end
