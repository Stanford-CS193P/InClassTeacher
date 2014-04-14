//
//  ICMultipeerManager.h
//  InClassTeacher
//
//  Created by Johan Ismael on 2/26/14.
//  Copyright (c) 2014 Johan Ismael. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface ICSRemoteClient : NSObject

#define kServer @"cs193p.herokuapp.com"
#define kServerPort 80

#define kMaxNumRetries 3
#define kRetryIntervalInSecs 10

#define kRawDataSentToPeers @"RawDataSentToPeers"
#define kRawDataSentToPeersDataKey @"Data"
#define kGeneralDataReceivedFromPeerNotification @"GeneralDataReceivedFromPeer"
// No longer used w/latest iteration...
#define kTopicDataReceivedFromPeerNotification @"TopicDataReceivedFromPeer"
#define kQuestionResponseReceived @"QuestionResponseReceived"
#define kDataKey @"Data"

+ (ICSRemoteClient *)sharedManager;
- (void)sendEvent:(NSString *)event
         withData:(NSDictionary *)data
         callback:(void (^)(id response))callback;
- (void)connect;
- (void)disconnect;

@end
