//
// Created by Caijinglong on 2019-09-06.
//

#import <Photos/Photos.h>
#import "PMPlugin.h"
#import "PMManager.h"
#import "ResultHandler.h"
#import "ConvertUtils.h"
#import "PMAssetPathEntity.h"
#import "PMLogUtils.h"
#import "PMNotificationManager.h"


@implementation PMPlugin {
    PMNotificationManager *_notificationManager;
}

- (void)registerPlugin:(NSObject <FlutterPluginRegistrar> *)registrar {
    [self nitNotificationManager:registrar];

    FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:@"top.kikt/photo_manager" binaryMessenger:[registrar messenger]];
    PMPlugin *plugin = [PMPlugin new];
    [plugin setManager:[PMManager new]];
    [channel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
        [plugin onMethodCall:call result:result];
    }];
}

- (void)nitNotificationManager:(NSObject <FlutterPluginRegistrar> *)registrar {
    _notificationManager = [PMNotificationManager managerWithRegistrar:registrar];
}

- (void)onMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    ResultHandler *handler = [ResultHandler handlerWithResult:result];
    PMManager *manager = self.manager;

    if ([call.method isEqualToString:@"requestPermission"]) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            BOOL auth = PHAuthorizationStatusAuthorized == status;
            [manager setAuth:auth];
            if (auth) {
                [handler reply:@1];
            } else {
                [handler reply:@0];
            }
        }];
    } else if (manager.isAuth) {
        [self onAuth:call result:result];
    } else {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            BOOL auth = PHAuthorizationStatusAuthorized == status;
            [manager setAuth:auth];
            if (auth) {
                [self onAuth:call result:result];
            } else {
                [handler replyError:@"need permission"];
            }
        }];
    }
}

- (void)onAuth:(FlutterMethodCall *)call result:(FlutterResult)result {
    ResultHandler *handler = [ResultHandler handlerWithResult:result];
    PMManager *manager = self.manager;

    if ([call.method isEqualToString:@"getGalleryList"]) {

        int type = [call.arguments[@"type"] intValue];
        unsigned long timestamp = [self getTimestamp:call];
        BOOL hasAll = [call.arguments[@"hasAll"] boolValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp / 1000];
        NSArray<PMAssetPathEntity *> *array = [manager getGalleryList:type date:date hasAll:hasAll];
        NSDictionary *dictionary = [ConvertUtils convertPathToMap:array];
        [handler reply:dictionary];

    } else if ([call.method isEqualToString:@"getAssetWithGalleryId"]) {

        NSString *id = call.arguments[@"id"];
        int type = [call.arguments[@"type"] intValue];
        NSUInteger page = [call.arguments[@"page"] unsignedIntValue];
        NSUInteger pageCount = [call.arguments[@"pageCount"] unsignedIntValue];
        unsigned long timestamp = [self getTimestamp:call];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp / 1000];

        NSArray<PMAssetEntity *> *array = [manager getAssetEntityListWithGalleryId:id type:type page:page pageCount:pageCount date:date];
        NSDictionary *dictionary = [ConvertUtils convertAssetToMap:array];
        [handler reply:dictionary];

    } else if ([call.method isEqualToString:@"getAssetListWithRange"]) {

        NSString *galleryId = call.arguments[@"galleryId"];
        NSUInteger type = [call.arguments[@"type"] unsignedIntegerValue];
        NSUInteger start = [call.arguments[@"start"] unsignedIntegerValue];
        NSUInteger end = [call.arguments[@"end"] unsignedIntegerValue];

        unsigned long timestamp = [call.arguments[@"timestamp"] unsignedLongValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp / 1000];
        NSArray<PMAssetEntity *> *array = [manager getAssetEntityListWithRange:galleryId type:type start:start end:end date:date];
        NSDictionary *dictionary = [ConvertUtils convertAssetToMap:array];
        [handler reply:dictionary];

    } else if ([call.method isEqualToString:@"getThumb"]) {

        NSString *id = call.arguments[@"id"];
        NSUInteger width = [call.arguments[@"width"] unsignedIntegerValue];
        NSUInteger height = [call.arguments[@"height"] unsignedIntegerValue];

        [manager getThumbWithId:id width:width height:height resultHandler:handler];

    } else if ([call.method isEqualToString:@"getFileSize"]) {
        
        NSString *id = call.arguments[@"id"];
        [manager getFileSize:id resultHandler:handler];
        
    } else if ([call.method isEqualToString:@"getFullFile"]) {

        NSString *id = call.arguments[@"id"];
        BOOL isOrigin = [call.arguments[@"isOrigin"] boolValue];

        [manager getFullSizeFileWithId:id resultHandler:handler];

    } else if ([call.method isEqualToString:@"releaseMemCache"]) {

        [manager clearCache];

    } else if ([call.method isEqualToString:@"log"]) {

        PMLogUtils.sharedInstance.isLog = (BOOL) call.arguments;

    } else if ([call.method isEqualToString:@"fetchPathProperties"]) {

        NSString *id = call.arguments[@"id"];
        int requestType = [call.arguments[@"type"] intValue];
        unsigned long timestamp = [call.arguments[@"timestamp"] unsignedLongValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp / 1000];

        PMAssetPathEntity *pathEntity = [manager fetchPathProperties:id type:requestType date:date];
        if (pathEntity) {
            NSDictionary *dictionary = [ConvertUtils convertPathToMap:@[pathEntity]];
            [handler reply:dictionary];
        } else {
            [handler reply:nil];
        }

    } else if ([call.method isEqualToString:@"openSetting"]) {
        [PMManager openSetting];
    } else if ([call.method isEqualToString:@"notify"]) {
        BOOL notify = [call.arguments[@"notify"] boolValue];
        if (notify) {
            [_notificationManager startNotify];
        } else {
            [_notificationManager stopNotify];
        }

    } else if ([call.method isEqualToString:@"isNotifying"]) {
        BOOL isNotifying = [_notificationManager isNotifying];
        [handler reply:@(isNotifying)];

    } else if ([call.method isEqualToString:@"deleteWithIds"]) {
        NSArray<NSString *> *ids = call.arguments[@"ids"];
        [manager deleteWithIds:ids changedBlock:^(NSArray<NSString *> *array) {
            [handler reply:array];
        }];

    } else if ([call.method isEqualToString:@"saveImage"]) {
        NSData *data = [call.arguments[@"image"] data];
        NSString *title = call.arguments[@"title"];
        NSString *desc = call.arguments[@"desc"];

        [manager saveImage:data title:title desc:desc block:^(PMAssetEntity *asset) {
            NSDictionary *resultData = [ConvertUtils convertPMAssetToMap:asset];
            [handler reply:@{@"data": resultData}];
        }];

    } else if ([call.method isEqualToString:@"saveVideo"]) {
        NSString *videoPath = call.arguments[@"path"];
        NSString *title = call.arguments[@"title"];
        NSString *desc = call.arguments[@"desc"];

        [manager saveVideo:videoPath title:title desc:desc block:^(PMAssetEntity *asset) {
            NSDictionary *resultData = [ConvertUtils convertPMAssetToMap:asset];
            [handler reply:@{@"data": resultData}];
        }];

    }
}

- (unsigned long)getTimestamp:(FlutterMethodCall *)call {
    unsigned long timestamp = [call.arguments[@"timestamp"] unsignedLongValue];
    return timestamp;
}

@end
