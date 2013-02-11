//
//  GOHTTPOperation.m
//  GOImageCache
//
//  Created by Samuel Goodwin on 12/30/11.
//

#import "GOHTTPOperation.h"

@interface GOHTTPOperation()
- (void)finish;
- (void)requestOnMainThread;
@end

@implementation GOHTTPOperation

+ (NSString *)addParameters:(NSDictionary *)params toURLString:(NSString *)urlString{
    NSMutableString *mutableURLString = [urlString mutableCopy];
    
    [mutableURLString appendString:@"?"];
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [mutableURLString stringByAppendingFormat:@"%@=%@&", key, [obj description]];
    }];
    return mutableURLString;
}

+ (NSData *)dataFromParams:(NSDictionary*)params{
    NSMutableString *bodyString = [NSMutableString string];
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [bodyString appendFormat:@"%@=%@&", key, [obj description]];
    }];
    return [bodyString dataUsingEncoding:NSUTF8StringEncoding];
}

+ (id)operationWithURL:(NSString *)urlString method:(GOHTTPMethod)method params:(NSDictionary *)params{
    GOHTTPOperation *operation = [[self alloc] init];
    
    if(method == GOHTTPMethodGET) {
        urlString = [self addParameters:params toURLString:urlString];
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    switch(method){
        case GOHTTPMethodGET:
            [request setHTTPMethod:@"GET"];
            break;
        case GOHTTPMethodPOST:
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
            [request setHTTPBody:[self dataFromParams:params]];
            break;
    }
    NSLog(@"Request: %@", [request HTTPBody]);
    [operation setRequest:request];
    [operation setCompletions:[NSMutableArray array]];
    return operation;
}

+ (id)operationWithURL:(NSString *)urlString{
    GOHTTPOperation *operation = [[self alloc] init];
     
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:@"GET"];
    NSLog(@"Request: %@", [request HTTPBody]);
    [operation setRequest:request];
    [operation setCompletions:[NSMutableArray array]];
    return operation;
}

+ (id)POSToperationWithURL:(NSString *)urlString andJSONData:(NSData *)jsonData{
    GOHTTPOperation *operation = [[self alloc] init];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:jsonData];
    
    [operation setRequest:request];
    [operation setCompletions:[NSMutableArray array]];
    return operation;
}

- (BOOL)isConcurrent{
    return YES;
}

- (void)start{
    if(self.isCancelled){
        [self finish];
        return; 
    }
    
    [self performSelectorOnMainThread:@selector(requestOnMainThread) withObject:nil waitUntilDone:NO];
}

- (void)requestOnMainThread{
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:NO];
    
    if(connection){
        [connection start];
    }else{
        [self finish];
        return;
    }
}

- (void)finish{
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    _executing = NO;
    _finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (void)addCompletion:(GODataBlock)block{
    [self.completions addObject:[block copy]];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    if(self.isCancelled){
        [connection cancel];
        [self finish];
        return;
    }
    self.data = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    if(self.isCancelled){
        [connection cancel];
        [self finish];
        return;
    }
    [self.data appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [self finish];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [self.completions enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        GODataBlock block = obj;
        block(self.data);
    }];
    [self finish];
}

@end
