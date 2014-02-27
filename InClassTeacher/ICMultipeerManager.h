//
//  ICMultipeerManager.h
//  InClassTeacher
//
//  Created by Johan Ismael on 2/26/14.
//  Copyright (c) 2014 Johan Ismael. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface ICMultipeerManager : NSObject<MCNearbyServiceBrowserDelegate, MCSessionDelegate>

#define kDataReceivedFromPeerNotification @"DataReceivedFromPeer"
#define kDataKey @"Data"

@end
