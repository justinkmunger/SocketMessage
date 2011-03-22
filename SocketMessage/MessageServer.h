//
//  MessageServer.h
//  SocketMessage
//
//  Created by Justin Munger on 3/20/11.
//  Copyright 2011 Berkshire Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageServerDelegate.h"

@interface MessageServer : NSObject <NSNetServiceDelegate> {
    CFSocketRef socket;
    NSNetService *_netService;
    id<MessageServerDelegate> _delegate;
}

@property (nonatomic, assign) id<MessageServerDelegate> delegate;

- (BOOL)startServer;
- (void)stopServer;

@end
