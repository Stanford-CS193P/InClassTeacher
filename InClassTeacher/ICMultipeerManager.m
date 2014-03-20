//
//  ICMultipeerManager.m
//  InClassTeacher
//
//  Created by Johan Ismael on 2/26/14.
//  Copyright (c) 2014 Johan Ismael. All rights reserved.
//

#import "ICMultipeerManager.h"

@interface ICMultipeerManager()<NSStreamDelegate>

@property (nonatomic, strong) MCPeerID *localPeerID;
@property (nonatomic, strong) MCNearbyServiceBrowser *browser;
@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) NSMutableDictionary *peers; //of PeerIds

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

- (NSMutableDictionary *)peers
{
    if (!_peers) _peers = [[NSMutableDictionary alloc] init];
    return _peers;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        static NSString * const XXServiceType = @"InClass-service";
        self.localPeerID = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
        
        self.session = [[MCSession alloc] initWithPeer:self.localPeerID
                                      securityIdentity:nil
                                  encryptionPreference:MCEncryptionNone];
        self.session.delegate = self;
        
        self.browser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.localPeerID serviceType:XXServiceType];
        self.browser.delegate = self;
        NSLog(@"==============> %@", @"started browser");
        
        [self.browser startBrowsingForPeers];
    }
    return self;
}

#define kBufSize 1024
- (void)sendData:(NSData *)data
{
    NSLog(@"==============> %@ %@", @"attempting to send data", self.session.connectedPeers);
    if ([self.session.connectedPeers count] == 0) return;
//    NSError *error;
//    [self.session sendData:data
//                   toPeers:self.session.connectedPeers
//                  withMode:MCSessionSendDataReliable
//                     error:&error];
//    
//    if (error) {
//        NSLog(@"ERROR: ==============> %@", [error localizedDescription]);
//    }
    
    for (MCPeerID *peerID in self.peers) {
        NSOutputStream *stream = [self.peers objectForKey:peerID];
        
        int offset = 0;
        int remainingBytes = [data length];
        const uint8_t *readBytes = [data bytes];
        while (remainingBytes > 0) {
            size_t bufLen = MIN(kBufSize, remainingBytes);
            NSLog(@"remainingBytes: %d  bufLen: %zu", remainingBytes, bufLen);
            
            uint8_t buf[bufLen];
            memcpy(buf, readBytes + offset, bufLen);
            
            offset += bufLen;
            remainingBytes -= bufLen;
            
            [stream write:buf maxLength:bufLen];
        }
    }
}

#pragma mark - Multipeer browser delegate

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    NSLog(@"==============> %@", @"peer found");
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
    if (certificateHandler) certificateHandler(YES);
}

// Remote peer changed state
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    if (state == MCSessionStateConnected) {
        NSLog(@"==============> %@", @"a friend");
        NSError *error;
        NSOutputStream *stream = [session startStreamWithName:@"STREAM" toPeer:peerID error:&error];
        stream.delegate = self;
        [stream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [stream open];
        [self.peers setObject:stream forKey:peerID];
    } else if (state == MCSessionStateNotConnected) {
        NSLog(@"==============> %@", @"peer not connected");
        NSOutputStream *stream = [self.peers objectForKey:peerID];
        [stream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [stream close];
        stream.delegate = nil;
        [self.peers removeObjectForKey:peerID];
        
//        // Try to get them back if disconnect was accidental.
//        [self.browser invitePeer:peerID
//                       toSession:self.session
//                     withContext:nil
//                         timeout:0];
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

- (void)disconnect
{
    [self.session disconnect];
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
