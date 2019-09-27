//
// Created by Caijinglong on 2019-09-27.
//

#import <Foundation/Foundation.h>

@class PMCloudProgressKey;

@interface PMCloudProgressManager : NSObject
- (void)setProgress:(PMCloudProgressKey *)key progress:(float)progress;

- (void)removeProgress:(PMCloudProgressKey *)key;

- (float)getProgress:(PMCloudProgressKey *)key;
@end


@interface PMCloudProgressKey : NSObject
@property(nonatomic, copy) NSString *id;
@property(nonatomic, assign) CGSize size;

- (instancetype)initWithId:(NSString *)id size:(CGSize)size;

+ (instancetype)progressWithId:(NSString *)id size:(CGSize)size;

- (BOOL)isEqual:(id)other;

- (BOOL)isEqualToKey:(PMCloudProgressKey *)key;

- (NSUInteger)hash;

@end
