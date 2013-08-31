//
//  ViewController.m
//  PeerBrowser
//
//  Created by Luis Abreu on 30/08/2013.
//  Copyright (c) 2013 lmjabreu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) MCNearbyServiceBrowser *nearbyServiceBrowser;
@property (nonatomic, strong) NSArray *nearbyPeers;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Fix UITableView positioning
    [self.tableView setContentInset:UIEdgeInsetsMake(20,
                                                     self.tableView.contentInset.left,
                                                     self.tableView.contentInset.bottom,
                                                     self.tableView.contentInset.right)];
    
    [self setupNearbyPeerBrowser];
    [self.nearbyServiceBrowser startBrowsingForPeers];
}

- (void)setupNearbyPeerBrowser
{
    MCPeerID *peerID = [[MCPeerID alloc] initWithDisplayName:@"Browser 01"];
    
    self.nearbyServiceBrowser = [[MCNearbyServiceBrowser alloc] initWithPeer:peerID serviceType:@"lmjabreu-p2p"];
    
    self.nearbyServiceBrowser.delegate = self;
}

#pragma mark - MCNearbyServiceBrowserDelegate

// Found a nearby advertising peer
- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    NSLog(@"Found peer: %@ with info: %@", peerID, info);
    self.nearbyPeers = @[@{@"peerID": peerID, @"peerInfo": info}];
    MCSession *session = [[MCSession alloc] initWithPeer:peerID];
    NSData *data = [@"Hello!" dataUsingEncoding:NSUTF8StringEncoding];
    [self.nearbyServiceBrowser invitePeer:peerID toSession:session withContext:data timeout:0];
    [self.tableView reloadData];
}

// A nearby peer has stopped advertising
- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    NSLog(@"Lost peer: %@", peerID);
    self.nearbyPeers = @[];
    [self.tableView reloadData];
}

// Browsing did not start due to an error
- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
    NSLog(@"Error starting browsing: %@", error.localizedDescription);
}

#pragma mark - MCSessionDelegate

// Remote peer changed state
- (void)session:(MCSession *)session
           peer:(MCPeerID *)peerID
 didChangeState:(MCSessionState)state
{
    NSLog(@"Session for peer: %@, changed state to: %i", peerID, state);
}

// Received data from remote peer
- (void)session:(MCSession *)session
 didReceiveData:(NSData *)data
       fromPeer:(MCPeerID *)peerID
{
    NSLog(@"Session received data: %@ from peer: %@", data, peerID);
}

// Received a byte stream from remote peer
- (void)session:(MCSession *)session
didReceiveStream:(NSInputStream *)stream
       withName:(NSString *)streamName
       fromPeer:(MCPeerID *)peerID
{
    NSLog(@"Session started receiving stream: %@ with name: %@ from peer: %@", stream, streamName, peerID);
}

// Start receiving a resource from remote peer
- (void)session:(MCSession *)session
didStartReceivingResourceWithName:(NSString *)resourceName
       fromPeer:(MCPeerID *)peerID
   withProgress:(NSProgress *)progress
{
    NSLog(@"Session started receiving resource: %@ from peer: %@", resourceName, peerID);
}

// Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox
- (void)session:(MCSession *)session
didFinishReceivingResourceWithName:(NSString *)resourceName
       fromPeer:(MCPeerID *)peerID
          atURL:(NSURL *)localURL
      withError:(NSError *)error
{
    // NOTE: files are saved in Documents/Inbox, URL should point to some file stored there.
    NSLog(@"Session finished receiving resource: %@ from peer: %@ at URL: %@", resourceName, peerID, localURL);
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.nearbyPeers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView dequeueReusableCellWithIdentifier:@"PeerCell" forIndexPath:indexPath];
}

#pragma mark - UITableViewDataSource

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *peerInfo = [self.nearbyPeers[indexPath.row] valueForKey:@"peerInfo"];
    cell.textLabel.text = [NSString stringWithFormat:@"%i: %@", indexPath.row, [peerInfo valueForKey:@"name"]];
}

@end
