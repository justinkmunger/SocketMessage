//
//  ChatViewController.m
//  SocketMessage
//
//  Created by Justin Munger on 3/19/11.
//  Copyright 2011 Berkshire Software, LLC. All rights reserved.
//

#import "ChatViewController.h"


@implementation ChatViewController
@synthesize sendTextField = _sentTextField;
@synthesize sendButton = _sendButton;
@synthesize selectedService = _selectedService;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [_sendButton release];
    [_sendTextField release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.selectedService.name;
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setSendButton:nil];
    [self setSendTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)sendButtonPressed:(id)sender {
    // Establish connection to the message server
    NSInputStream *inputStream = [[NSInputStream alloc] init];
    NSOutputStream *outputStream = [[NSOutputStream alloc] init];
    
    [self.selectedService getInputStream:&inputStream outputStream:&outputStream];
    
    // If this connection was going to be opened for a longer period of time,
    // it would be necessary to schedule the streams in a run loop to allow for
    // asynchronous processing. 
    [inputStream open];
    [outputStream open];
    
    // Package the pieces of the message up
    NSDictionary *packetDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[UIDevice currentDevice].name, @"sender", self.sendTextField.text, @"message", nil];

    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:packetDictionary];
    NSMutableData *packetData = [[NSMutableData alloc] init];
    
    int packetLength = archivedData.length;
    
    [packetData appendBytes:&packetLength length:sizeof(int)];
    [packetData appendData:archivedData];

    [outputStream write:packetData.bytes maxLength:packetData.length];

    [packetData release];
    
    // Disconnect from the message server
    [inputStream close];
    [outputStream close];
    
    // Clear the text out from the text field
    self.sendTextField.text = @"";

    [inputStream release];
    [outputStream release];
}

#pragma - 
#pragma mark UITextFieldDelegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
@end
