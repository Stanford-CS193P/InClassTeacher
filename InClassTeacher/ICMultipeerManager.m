//
//  ICMultipeerManager.m
//  InClassTeacher
//
//  Created by Johan Ismael on 2/26/14.
//  Copyright (c) 2014 Johan Ismael. All rights reserved.
//

#import "ICMultipeerManager.h"

@interface ICMultipeerManager()

@property (nonatomic, strong) MCPeerID *localPeerID;
@property (nonatomic, strong) MCNearbyServiceBrowser *browser;
@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) NSMutableDictionary *peers;

@end

@implementation ICMultipeerManager

static NSString * const XXServiceType = @"InClass-service";

static ICMultipeerManager *peerManager = nil;

+ (ICMultipeerManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        peerManager = [[ICMultipeerManager alloc] init];
    });
    return peerManager;
}

- (NSMutableDictionary *)peers
{
    if (!_peers) _peers = [[NSMutableDictionary alloc] init];
    return _peers;
}

- (MCPeerID *)localPeerID
{
    if (!_localPeerID) {
        _localPeerID = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
    }
    return _localPeerID;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.browser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.localPeerID serviceType:XXServiceType];
        self.browser.delegate = self;
        [self browse];
    }
    return self;
}

- (void)sendData:(NSData *)data
{
    NSLog(@"==============> %@", @"attempting to send data");
    
    dispatch_queue_t queue = dispatch_queue_create("peer send data queue", NULL);
    for (MCPeerID *peerID in self.peers) {
        dispatch_async(queue, ^{
            MCSession *session = [self.peers objectForKey:peerID];
            NSError *error = nil;
            if(![session sendData:data
                          toPeers:@[peerID]
                         withMode:MCSessionSendDataReliable
                            error:&error]) {
                NSLog(@"[Error] %@", error);
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:kRawDataSentToPeers
                                                                    object:self
                                                                  userInfo:@{kRawDataSentToPeersDataKey : data}];
            }
        });
    }
}

#pragma mark - Multipeer browser delegate

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    NSLog(@"==============> %@", @"peer found");
    
    if ([[self.peers allKeys] containsObject:peerID]) {
        NSLog(@"Rediscovered peer %@", peerID.displayName);
        [self disconnectPeer:peerID];
    }
    
    MCSession *session = [[MCSession alloc] initWithPeer:self.localPeerID
                                        securityIdentity:nil
                                    encryptionPreference:MCEncryptionNone];
    session.delegate = self;
    [self.peers setObject:session forKey:peerID];
    NSLog(@"created session for peer %@", peerID.displayName);
    
    [browser invitePeer:peerID
              toSession:session
            withContext:nil
                timeout:0];
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    NSLog(@"==============> %@", @"peer lost");
    [self disconnectPeer:peerID];
}

- (void)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL))certificateHandler
{
    if (certificateHandler) certificateHandler(YES);
}

// Remote peer changed state
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    if (state == MCSessionStateConnected) {
        NSLog(@"==============> %@", @"a friend");
        assert([[self.peers allKeys] containsObject:peerID]);
    } else if (state == MCSessionStateNotConnected) {
        NSLog(@"==============> %@", @"peer not connected");
        [self disconnectPeer:peerID];
    }
}

// Received data from remote peer
- (void)session:(MCSession *)session
 didReceiveData:(NSData *)data
       fromPeer:(MCPeerID *)peerID
{
    NSDictionary *dict = (NSDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSLog(@"didReceiveData from peer %@", dict);
    
    // TODO: incorporate incoming data.
    // sample of incoming data:
    //    {
    //        peerIDDisplayName = "Loaner 5";
    //        rating = 3;
    //        text = TESTING;
    //        time = "2014-03-20 11:32:24 +0000";
    //        type = PeerRating;
    //        uuid = "D7F1D237-79DC-4340-A1D9-0A23D6E6AE67";
    //    }
    
    if (dict[@"text"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kTopicDataReceivedFromPeerNotification
                                                            object:self
                                                          userInfo:@{kDataKey : dict}];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kGeneralDataReceivedFromPeerNotification
                                                            object:self
                                                          userInfo:@{kDataKey : dict}];
    }
}

- (void)browse
{
    NSLog(@"==============> %@", @"started browser");
    [self.browser startBrowsingForPeers];
}

- (void)disconnect
{
    NSLog(@"disconnecting teacher app...");
    [self.browser stopBrowsingForPeers];
    
    for (MCPeerID *peerID in [self.peers allKeys]) {
        [self disconnectPeer:peerID];
    }
}

- (void)disconnectPeer:(MCPeerID *)peerID
{
    NSLog(@"closing session for peer %@", peerID.displayName);
    MCSession *session = [self.peers objectForKey:peerID];
    [session disconnect];
    session.delegate = nil;
    
    [self.peers removeObjectForKey:peerID];
}

// Received a byte stream from remote peer
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID { }

// Start receiving a resource from remote peer
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress { }

// Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error { }

@end
