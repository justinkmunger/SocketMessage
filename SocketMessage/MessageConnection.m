//
//  MessageConnection.m
//  SocketMessage
//
//  Created by Justin Munger on 3/20/11.
//  Copyright 2011 Berkshire Software, LLC. All rights reserved.
//

#import "MessageConnection.h"

#import <sys/socket.h>

@interface MessageConnection ()

@property (nonatomic, assign) CFSocketNativeHandle socketHandle;
@property (nonatomic, retain) NSInputStream *inputStream;
@property (nonatomic, retain) NSOutputStream *outputStream;
@property (nonatomic, retain) NSMutableData *incomingDataBuffer;
@property (nonatomic, retain) NSMutableData *outgoingDataBuffer;

@end



@implementation MessageConnection

@synthesize socketHandle = _socketHandle;
@synthesize inputStream = _inputStream;
@synthesize outputStream = _outputStream;
@synthesize incomingDataBuffer = _incomingDataBuffer;
@synthesize outgoingDataBuffer = _outgoingDataBuffer;
@synthesize delegate = _delegate;


- (id)init {
    self.incomingDataBuffer = [[NSMutableData alloc] init];
    self.outgoingDataBuffer = [[NSMutableData alloc] init];

    return self;
}

- (id)initWithSocketHandle:(CFSocketNativeHandle)socketHandle {

    self = [self init];
    
    self.socketHandle = socketHandle;  

    return self;
}

- (BOOL)establishConnection {
    
    // Map input and output streams to socket
    CFReadStreamRef readStream = NULL;
    CFWriteStreamRef writeStream = NULL;
    CFStreamCreatePairWithSocket(kCFAllocatorDefault, self.socketHandle, &readStream, &writeStream);
    
    if (readStream && writeStream) {
    
        // Set stream properties
        CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
        CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
        
        // Assign streams to higher level abstraction
        self.inputStream = (NSInputStream *)readStream;
        self.outputStream = (NSOutputStream *)writeStream;
        
        // Schedule the streams in the run loop
        [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        
        // Set the delegate objects for the streams
        self.inputStream.delegate = self;
        self.outputStream.delegate = self;
        
        // Open the streams if not already opened
        if ([self.inputStream streamStatus] == NSStreamStatusNotOpen)
            [self.inputStream open];
        if ([self.outputStream streamStatus] == NSStreamStatusNotOpen)
            [self.outputStream open];
    } else {
        return NO;
    }

    return YES;
}

- (void)closeConnection {
    [self.inputStream close];
    [self.inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    self.inputStream.delegate = nil;
    self.inputStream = nil;
    
    [self.outputStream close];
    [self.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    self.outputStream.delegate = nil;
    self.outputStream = nil;

    self.incomingDataBuffer = nil;
    self.outgoingDataBuffer = nil;
}

#pragma mark -
#pragma mark NSStreamDelegate Methods
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) {
        case NSStreamEventOpenCompleted:

            break;
        case NSStreamEventErrorOccurred:

            break;
        case NSStreamEventEndEncountered:

            break;
        case NSStreamEventHasBytesAvailable:
            if (aStream == self.inputStream) {
                NSInputStream *inputStream = (NSInputStream *)aStream;
                uint8_t buffer[1024];
                
                // Read data from stream
                NSInteger bytesRead = [inputStream read:buffer maxLength:1024];
                if (bytesRead == -1) {
                    NSError *error = [inputStream streamError];
                    NSLog(@"Error reading data: %@", [error localizedDescription]);
                } else {
                    // Append data to incoming data buffer
                    [self.incomingDataBuffer appendBytes:buffer length:bytesRead];
                    if (self.incomingDataBuffer.length > 0) {

                        // Obtain the length portion of the data packet
                        int length;
                        int bufferLength = self.incomingDataBuffer.length;
                        [self.incomingDataBuffer getBytes:&length length:sizeof(int)];
                        
                        // If the entire packet has now been received
                        if (length == self.incomingDataBuffer.length - sizeof(int)) {
                            uint8_t packetData[length];
                            
                            // Extract the packet
                            [self.incomingDataBuffer getBytes:packetData range:NSMakeRange(sizeof(int), length)];
                            
                            // Deserialize the data object
                            NSDictionary *packet = [NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithBytes:packetData length:length]];
                            
                            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(receivedMessage:)]) {
                                [self.delegate receivedMessage:packet];
                            }                                                    
                            self.incomingDataBuffer.length = 0;
                        }
                    }
                }
            } else if (aStream == self.outputStream) {
                // In more complex, non-sample application, this is where you'd process data 
                // to be sent to the peer from the output stream. Instead, in this code, 
                // the NSNetService object is used to retrieve the streams from a 
                // resolved service.
            }
            break;
        case NSStreamEventHasSpaceAvailable:

            break;
    }
}

@end

