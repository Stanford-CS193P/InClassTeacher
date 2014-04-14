#define kObjectIdKey @"id"
#define kSentKey @"sent"

@protocol SendableData <NSObject>

@property (nonatomic, assign) BOOL sent;
@property (nonatomic, assign) NSString *objectId;
- (NSDictionary *)toDictionary;

@end