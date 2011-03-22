//
//  MessageConnection.h
//  SocketMessage
//
//  Created by Justin Munger on 3/20/11.
//  Copyright 2011 Berkshire Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageConnectionDelegate.h"

@interface MessageConnection : NSObject <NSStreamDelegate> {

    CFSocketNativeHandle _socketHandle;
    NSInputStream *_inputStream;
    NSOutputStream *_outputStream;
    NSMutableData *_incomingDataBuffer;
    NSMutableData *_outgoingDataBuffer;
    id<MessageConnectionDelegate> _delegate;
}

@property (nonatomic, assign) id<MessageConnectionDelegate> delegate;

- (id)initWithSocketHandle:(CFSocketNativeHandle)socketHandle; 
- (BOOL)establishConnection;
- (void)closeConnection;

@end
