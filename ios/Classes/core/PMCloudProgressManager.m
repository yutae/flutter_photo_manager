//
// Created by Caijinglong on 2019-09-27.
//

#import "PMCloudProgressManager.h"

@implementation PMCloudProgressKey {

}
- (instancetype)initWithId:(NSString *)id size:(CGSize)size {
    self = [super init];
    if (self) {
        self.id = id;
        self.size = size;
    }

    return self;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToKey:other];
}

- (BOOL)isEqualToKey:(PMCloudProgressKey *)key {
    if (self == key)
        return YES;
    if (key == nil)
        return NO;
    if (self.id != key.id)
        return NO;
    if (self.size.width != key.size.width)
        return NO;
    return self.size.height == key.size.height;
}

- (NSUInteger)hash {
    NSUInteger hash = (NSUInteger) self.id;
    hash = hash * 31u + [@(self.size.width) hash];
    hash = hash * 31u + [@(self.size.height) hash];
    return hash;
}


+ (instancetype)progressWithId:(NSString *)id size:(CGSize)size {
    return [[self alloc] initWithId:id size:size];
}


@end

@implementation PMCloudProgressManager {

    NSMutableDictionary<PMCloudProgressKey *, NSNumber *> *progressDict;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        progressDict = [NSMutableDictionary new];
    }

    return self;
}

- (void)setProgress:(PMCloudProgressKey *)key progress:(float)progress {
    progressDict[key] = @(progress);
}

- (void)removeProgress:(PMCloudProgressKey *)key {
    [progressDict removeObjectForKey:key];
}

- (float)getProgress:(PMCloudProgressKey *)key {
    return [progressDict[key] floatValue];
}

@end