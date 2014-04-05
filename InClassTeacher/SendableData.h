@protocol SendableData <NSObject>

@property (nonatomic, assign) BOOL sent;
- (NSDictionary *)toDictionary;

@end