//
//  MessageServer.m
//  SocketMessage
//
//  Created by Justin Munger on 3/20/11.
//  Copyright 2011 Berkshire Software, LLC. All rights reserved.
//

#import "MessageServer.h"
#import "MessageConnection.h"

#import <sys/socket.h>
#import <netinet/in.h>
#import <unistd.h>

@interface MessageServer ()

@property (nonatomic, retain) NSNetService *netService;

@end


@implementation MessageServer

@synthesize netService = _netService;
@synthesize delegate = _delegate;

static void socketAcceptCallback(CFSocketRef theSocket, CFSocketCallBackType theType, CFDataRef theAddress, const void *data, void *info) {
    if (theType == kCFSocketAcceptCallBack) {
        MessageServer *ms = (MessageServer *)info;        
        CFSocketNativeHandle socketHandle = *(CFSocketNativeHandle *)data;
        MessageConnection *connection = [[[MessageConnection alloc] initWithSocketHandle:socketHandle] autorelease];
        
        if (connection == nil) {
            close(socketHandle);
            return;
        }
        
        if ([connection establishConnection] != YES) {
            [connection closeConnection];
            return;
        }
        
        if (ms.delegate != nil && [ms.delegate respondsToSelector:@selector(newConnectionAccepted:)]) {
            [ms.delegate newConnectionAccepted:connection];
        }
    }
}

- (BOOL)startServer {
    
    // Create a socket
    CFSocketContext socketCtxt = {0, self, NULL, NULL, NULL};
    socket = CFSocketCreate(kCFAllocatorDefault, 
                            PF_INET, 
                            SOCK_STREAM, 
                            IPPROTO_TCP, 
                            kCFSocketAcceptCallBack, 
                            (CFSocketCallBack)&socketAcceptCallback, 
                            &socketCtxt);
    
    if (socket == NULL) {
        return NO;
    }
    
    // Configure the socket's address
    struct sockaddr_in addr4;
    memset(&addr4, 0, sizeof(addr4));
    addr4.sin_len = sizeof(addr4);
    addr4.sin_family = AF_INET;
    addr4.sin_port = 0;
    addr4.sin_addr.s_addr = htonl(INADDR_ANY);
    
    // Set the socket's address
    NSData *address4 = [NSData dataWithBytes:&addr4 length:sizeof(addr4)];
    if (CFSocketSetAddress(socket, (CFDataRef)address4)) {
        if (socket)
            CFRelease(socket);
        socket = NULL;
        return NO;
    }
    
    NSData *addr = [(NSData *)CFSocketCopyAddress(socket) autorelease];
    memcpy(&addr4, [addr bytes], [addr length]);
    uint16_t port = ntohs(addr4.sin_port);
    
    CFRunLoopRef cfrl = CFRunLoopGetCurrent();
    CFRunLoopSourceRef source4 = CFSocketCreateRunLoopSource(kCFAllocatorDefault, socket, 0);
    CFRunLoopAddSource(cfrl, source4, kCFRunLoopCommonModes);
    CFRelease(source4);
    
    self.netService = [[NSNetService alloc] initWithDomain:@"" type:@"_socketmessage._tcp." name:[UIDevice currentDevice].name port:port];
    [self.netService scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    self.netService.delegate = self;
    [self.netService publish];
    
    return YES;
}

- (void)stopServer {
    if (socket != NULL) {
        CFSocketInvalidate(socket);
        CFRelease(socket);
        socket = NULL;
    }
    
    if ( self.netService ) {
		[self.netService stop];
		[self.netService removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
		self.netService = nil;
	}
    
}

#pragma mark -
#pragma mark NSNetServiceDelegate Methods
-(void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict {
    NSNumber *errorDomain = [errorDict valueForKey:NSNetServicesErrorDomain];
    NSNumber *errorCode = [errorDict valueForKey:NSNetServicesErrorCode];
    NSLog(@"Unable to publish Bonjour service (Domain: %@, Error Code: %@", errorDomain, errorCode);
    [self.netService stop];
}

-(void)netServiceDidStop:(NSNetService *)netService {
    self.netService.delegate = nil;
    self.netService = nil;
}

@end