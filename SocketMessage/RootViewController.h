//
//  RootViewController.h
//  SocketMessage
//
//  Created by Justin Munger on 3/18/11.
//  Copyright 2011 Berkshire Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageServer.h"

@interface RootViewController : UITableViewController <NSStreamDelegate, MessageServerDelegate, MessageConnectionDelegate, NSNetServiceDelegate, NSNetServiceBrowserDelegate> {
//    CFSocketRef socket;
//    NSNetService *_service;
//    NSInputStream *_inputStream;
//    NSOutputStream *_outputStream;
//    
//    NSMutableData *_incomingDataBuffer;
    MessageServer *_messageServer;
    MessageConnection *_messageConnection;
    
    NSNetServiceBrowser *_netServiceBrowser;
    NSMutableArray *_availableMessageClients;
}

//@property (nonatomic, retain) NSNetService *service;
//@property (nonatomic, retain) NSInputStream *inputStream;
//@property (nonatomic, retain) NSOutputStream *outputStream;
//@property (nonatomic, retain) NSMutableData *incomingDataBuffer;

@end
