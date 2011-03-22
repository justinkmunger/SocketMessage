//
//  RootViewController.m
//  SocketMessage
//
//  Created by Justin Munger on 3/18/11.
//  Copyright 2011 Berkshire Software, LLC. All rights reserved.
//

#import "RootViewController.h"
#import "MessageServer.h"
#import "ChatViewController.h"

@interface RootViewController ()

@property (nonatomic, retain) MessageServer *messageServer;
@property (nonatomic, retain) MessageConnection *messageConnection;
@property (nonatomic, retain) NSNetServiceBrowser *netServiceBrowser;
@property (nonatomic, retain) NSMutableArray *availableMessageClients;

@end

//static void listenerAcceptCallback(CFSocketRef theSocket, CFSocketCallBackType theType, CFDataRef theAddress, const void *data, void *info) {
//    if (theType == kCFSocketAcceptCallBack) {
//        RootViewController *rvc = (RootViewController *)info;        
//        CFSocketNativeHandle socketHandle = *(CFSocketNativeHandle *)data;
//        uint8_t name[SOCK_MAXADDRLEN];
//        socklen_t namelen = sizeof(name);
//        NSData *peer = nil;
//        if (getpeername(socketHandle, (struct sockaddr *)name, &namelen) == 0) {
//            peer = [NSData dataWithBytes:name length:namelen];
//        }
//        CFReadStreamRef readStream = NULL;
//        CFWriteStreamRef writeStream = NULL;
//        CFStreamCreatePairWithSocket(kCFAllocatorDefault, socketHandle, &readStream, &writeStream);
//        if (readStream && writeStream) {
//            CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
//            CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
//            
//            rvc.inputStream = (NSInputStream *)readStream;
//            rvc.outputStream = (NSOutputStream *)writeStream;
//
//            [rvc.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//            [rvc.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//            
//            rvc.inputStream.delegate = rvc;
//            rvc.outputStream.delegate = rvc;
//                        
//            if ([rvc.inputStream streamStatus] == NSStreamStatusNotOpen)
//                [rvc.inputStream open];
//            
//            if ([rvc.outputStream streamStatus] == NSStreamStatusNotOpen)
//                [rvc.outputStream open];
//            
//            if (readStream)
//                CFRelease(readStream);
//            
//            if (writeStream)
//                CFRelease(writeStream);
//        }
//        
//    }
//}

@implementation RootViewController
//
//@synthesize service = _service;
//@synthesize inputStream = _inputStream;
//@synthesize outputStream = _outputStream;
//@synthesize incomingDataBuffer = _incomingDataBuffer;

@synthesize messageServer = _messageServer;
@synthesize messageConnection = _messageConnection;
@synthesize netServiceBrowser = _netServiceBrowser;
@synthesize availableMessageClients = _availableMessageClients;

#pragma mark -
#pragma mark View Lifecycle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Socket Message";
    
    self.availableMessageClients = [[NSMutableArray alloc] init];
    
    self.messageServer = [[MessageServer alloc] init];
    self.messageServer.delegate = self;
    
    [self.messageServer startServer];
    
    self.netServiceBrowser = [[NSNetServiceBrowser alloc] init];
    self.netServiceBrowser.delegate = self;
    [self.netServiceBrowser searchForServicesOfType:@"_socketmessage._tcp" inDomain:@""];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.netServiceBrowser.delegate = nil;
    [self.netServiceBrowser stop];
    self.netServiceBrowser  = nil;
}

#pragma mark -
#pragma mark UITableViewDataSource methods
// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.availableMessageClients.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = ((NSNetService *)[self.availableMessageClients objectAtIndex:indexPath.row]).name;
    // Configure the cell.
    return cell;
}

#pragma mark - 
#pragma mark UITableViewDelegate methods
// Customize the font size for the text labels in each cell.
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.font = [UIFont systemFontOfSize:12.0];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSNetService *selectedService = [self.availableMessageClients objectAtIndex:indexPath.row];
    selectedService.delegate = self;
    [selectedService resolveWithTimeout:0.0];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    [_messageServer release];
    [_messageConnection release];
    [_netServiceBrowser release];
    [_availableMessageClients release];
    [super dealloc];
}


#pragma mark -
#pragma mark MessageServerDelegate methods
- (void)newConnectionAccepted:(MessageConnection *)newConnection {
    self.messageConnection = newConnection;
    self.messageConnection.delegate = self;
}

#pragma mark -
#pragma mark MessageConnectionDelegate methods
- (void)receivedMessage:(NSDictionary *)message {
        
    NSString *name = [message objectForKey:@"sender"];
    NSString *messageText = [message objectForKey:@"message"];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:name 
                                                    message:messageText 
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK" 
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];    
}

#pragma mark -
#pragma mark NSNetServiceDelegate methods
- (void)netService:(NSNetService *)service didNotResolve:(NSDictionary *)errorDict {
    // If the service has already been resolved, then go ahead and reestablish the connection
    if (service.addresses.count != 0) {
    
        if ([self.navigationController.topViewController isMemberOfClass:[RootViewController class]] == YES) {
            ChatViewController *cvc = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
            cvc.selectedService = service;
            
            [self.navigationController pushViewController:cvc animated:YES];
            [cvc release];                    
        }
    }
}

-(void)netServiceDidResolveAddress:(NSNetService *)service {
        
    if ([self.navigationController.topViewController isMemberOfClass:[RootViewController class]] == YES) {
        ChatViewController *cvc = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
        cvc.selectedService = service;
        
        [self.navigationController pushViewController:cvc animated:YES];
        [cvc release];
    }
}

#pragma mark -
#pragma mark NSNetServiceBrowserDelegate methods
-(void)netServiceBrowser:(NSNetServiceBrowser *)browser didNotSearch:(NSDictionary *)errorDict {
    self.netServiceBrowser.delegate = nil;
    [self.netServiceBrowser stop];
    self.netServiceBrowser = nil;   
}

-(void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser { 
    self.netServiceBrowser.delegate = nil;
    self.netServiceBrowser = nil;
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)netService moreComing:(BOOL)moreComing {
    // Check to see if the connection is already in the array

         
    [self.availableMessageClients addObject:netService];
    if (moreComing == NO) {
        [self.tableView reloadData];
        
        NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        [self.availableMessageClients sortUsingDescriptors:[NSArray arrayWithObject:sd]];
        [sd release];
        
        self.title = [NSString stringWithFormat:@"Available Connections (%i)", [self.availableMessageClients count]];
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didRemoveService:(NSNetService *)netService moreComing:(BOOL)moreComing {
    for (int i = 0; i < self.availableMessageClients.count; i++) {
        if ([((NSNetService *)[self.availableMessageClients objectAtIndex:i]).name isEqualToString:netService.name]) {
            [self.availableMessageClients removeObjectAtIndex:i];
            break;
        }
    }
    if ([self.navigationController.topViewController isMemberOfClass:[ChatViewController class]] == YES) {
        ChatViewController *cvc = (ChatViewController *)self.navigationController.topViewController;
        if ([cvc.selectedService.name isEqualToString:netService.name] == YES) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
    if (moreComing == NO) {
        [self.tableView reloadData];

        NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        [self.availableMessageClients sortUsingDescriptors:[NSArray arrayWithObject:sd]];
        [sd release];
        
        self.title = [NSString stringWithFormat:@"Available Connections (%i)", [self.availableMessageClients count]];        
    }
}
@end
