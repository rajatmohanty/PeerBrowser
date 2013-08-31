//
//  ViewController.h
//  PeerBrowser
//
//  Created by Luis Abreu on 30/08/2013.
//  Copyright (c) 2013 lmjabreu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface ViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, MCNearbyServiceBrowserDelegate, MCSessionDelegate>

@end
