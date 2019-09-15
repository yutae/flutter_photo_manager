//
//  PMFileCacheManager.h
//  photo_manager
//
//  Created by cjl on 2019/9/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PMFileCacheManager : NSObject

+(NSString *) getFilePathWithAssetId:(NSString*) id;

@end

NS_ASSUME_NONNULL_END
