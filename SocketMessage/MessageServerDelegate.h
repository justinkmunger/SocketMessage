//
//  MessageServerDelegate.h
//  SocketMessage
//
//  Created by Justin Munger on 3/20/11.
//  Copyright 2011 Berkshire Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MessageConnection.h"

@protocol MessageServerDelegate <NSObject>

- (void)newConnectionAccepted:(MessageConnection *)newConnection;

@end
