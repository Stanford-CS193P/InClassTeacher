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

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.localPeerID = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
        
        self.browser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.localPeerID serviceType:XXServiceType];
        self.browser.delegate = self;
        NSLog(@"==============> %@", @"started browser");
        
        [self.browser startBrowsingForPeers];
    }
    return self;
}

// Based on preliminary testing on the Stanford Visitor network,
// sending large buffers was leading to dropped connections.
// These random disconnects were not seen when using bluetooth.
// So, as a precaution (and because the length of the words we'll
// be broadcasting will be small anyways) we'll keep this buffer
// size small.
// TODO: revisit if this becomes an issue
#define kBufSize 128

- (void)sendData:(NSData *)data
{
    NSLog(@"==============> %@", @"attempting to send data");
    
//    NSMutableString *str = [[NSMutableString alloc] init];
//    for (int i = 0; i < kBufSize; i++) {
//        [str appendString:@"A"];
//    }
//    data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    size_t bufLen = MIN(kBufSize, [data length]);
    NSLog(@"bufLen: %zu", bufLen);
    uint8_t buf[bufLen];
    // NOTE: Ignores beyond kBufSize bytes
    [data getBytes:buf length:bufLen];
    
    for (MCPeerID *peerID in self.peers) {
        NSOutputStream *stream = [[self.peers objectForKey:peerID] valueForKey:@"stream"];
        [stream write:buf maxLength:bufLen];
    }
}

#pragma mark - Multipeer browser delegate

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    if ([[self.peers allKeys] containsObject:peerID]) {
        NSLog(@"Rediscovered peer %@", peerID.displayName);
        [self closeStreamForPeer:peerID];
    }
    
    MCSession *session = [[MCSession alloc] initWithPeer:self.localPeerID
                                        securityIdentity:nil
                                    encryptionPreference:MCEncryptionNone];
    session.delegate = self;
    
    NSLog(@"created session for peer %@", peerID.displayName);
    
    // TODO: clean up the code (make a class for this)
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:session forKey:@"session"];
    [self.peers setObject:dict forKey:peerID];
    
    NSLog(@"==============> %@", @"peer found");
    [browser invitePeer:peerID
              toSession:session
            withContext:nil
                timeout:0];
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    NSLog(@"==============> %@", @"peer lost");
    [self closeStreamForPeer:peerID];
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
        
        NSError *error;
        NSOutputStream *stream = [session startStreamWithName:@"STREAM" toPeer:peerID error:&error];
        stream.delegate = self;
        [stream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [stream open];
        
        [[self.peers objectForKey:peerID] setValue:stream forKey:@"stream"];
        
    } else if (state == MCSessionStateNotConnected) {
        NSLog(@"==============> %@", @"peer not connected");
        [self closeStreamForPeer:peerID];
    }
}

- (void)closeStreamForPeer:(MCPeerID *)peerID
{
    NSMutableDictionary *dict = [self.peers objectForKey:peerID];

    NSOutputStream *stream = [dict valueForKey:@"stream"];
    [stream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [stream close];
    stream.delegate = nil;
    
    NSLog(@"closing session for peer %@", peerID.displayName);
    MCSession *session = [dict valueForKey:@"session"];
    session.delegate = nil;
    // TODO: more closing needed?
    
    [self.peers removeObjectForKey:peerID];
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)streamEvent
{
    if (streamEvent == NSStreamEventHasBytesAvailable) {
        NSLog(@"NSStreamEventHasBytesAvailable");
    } else if (streamEvent == NSStreamEventErrorOccurred) {
        NSLog(@"NSStreamEventErrorOccurred");
    } else if (streamEvent == NSStreamEventEndEncountered) {
        NSLog(@"NSStreamEventEndEncountered");
    } else if (streamEvent == NSStreamEventNone) {
        NSLog(@"NSStreamEventNone");
    } else if (streamEvent == NSStreamEventHasSpaceAvailable) {
        NSLog(@"NSStreamEventHasSpaceAvailable");
    } else if (streamEvent == NSStreamEventOpenCompleted) {
        NSLog(@"NSStreamEventOpenCompleted");
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
    NSLog(@"didReceiveData from peer %@", message);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDataReceivedFromPeerNotification
                                                        object:self
                                                      userInfo:@{kPeerIDKey: peerID, kDataKey : data}];
}

- (void)disconnect
{
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
