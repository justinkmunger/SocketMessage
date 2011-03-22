//
//  ChatViewController.h
//  SocketMessage
//
//  Created by Justin Munger on 3/19/11.
//  Copyright 2011 Berkshire Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ChatViewController : UIViewController {

    UIButton *_sendButton;
    UITextField *_sendTextField;
    NSNetService *_selectedService;
}
- (IBAction)sendButtonPressed:(id)sender;

@property (nonatomic, retain) IBOutlet UITextField *sendTextField;
@property (nonatomic, retain) IBOutlet UIButton *sendButton;
@property (nonatomic, retain) NSNetService *selectedService;

@end
