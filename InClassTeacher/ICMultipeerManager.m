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
@property (nonatomic, strong) NSMutableArray *peers; //of PeerIds

@end

@implementation ICMultipeerManager

static ICMultipeerManager *peerManager = nil;

+ (ICMultipeerManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        peerManager = [[ICMultipeerManager alloc] init];
    });
    return peerManager;
}

- (NSMutableArray *)peers
{
    if (!_peers) _peers = [[NSMutableArray alloc] init];
    return _peers;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        static NSString * const XXServiceType = @"InClass-service";
        self.localPeerID = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
        
        self.browser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.localPeerID serviceType:XXServiceType];
        self.browser.delegate = self;
        NSLog(@"==============> %@", @"started browser");
        
        [self.browser startBrowsingForPeers];
    }
    return self;
}

- (void)sendData:(NSData *)data
{
    NSLog(@"==============> %@", @"attempting to send data");
    NSError *error;
    [self.session sendData:data
                   toPeers:self.peers
                  withMode:MCSessionSendDataReliable
                     error:&error];
    
    if (error)
        NSLog(@"==============> %@", [error localizedDescription]);
}

#pragma mark - Multipeer browser delegate

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    NSLog(@"==============> %@", @"peer found");
    self.session = [[MCSession alloc] initWithPeer:self.localPeerID
                                  securityIdentity:nil
                              encryptionPreference:MCEncryptionNone];
    self.session.delegate = self;
    [browser invitePeer:peerID
              toSession:self.session
            withContext:nil
                timeout:0];
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    NSLog(@"==============> %@", @"peer lost");
}

- (void)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL))certificateHandler
{
    certificateHandler(YES);
}

// Remote peer changed state
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    if (state == MCSessionStateConnected) {
        NSLog(@"==============> %@", @"a friend");
        [self.peers addObject:peerID];
    }
}

// Received data from remote peer
- (void)session:(MCSession *)session
 didReceiveData:(NSData *)data
       fromPeer:(MCPeerID *)peerID
{
    NSString *message =
    [[NSString alloc] initWithData:data
                          encoding:NSUTF8StringEncoding];
    NSLog(@"%@", message);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDataReceivedFromPeerNotification
                                                        object:self
                                                      userInfo:@{kPeerIDKey: peerID, kDataKey : data}];
}

// Received a byte stream from remote peer
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    
}

// Start receiving a resource from remote peer
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    
}

// Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    
}


@end