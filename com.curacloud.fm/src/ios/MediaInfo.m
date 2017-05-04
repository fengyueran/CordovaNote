//
//  MediaInfo.m
//  CuraCloudMI
//
//  Created by xinghun meng on 06/04/2017.
//
//

#import "MediaInfo.h"

@implementation MediaInfo

- (instancetype)init {
    self = [super init];
    if (self) {
        _progress = 0;
        _isDownloadStop = NO;
        _isDownloadError = NO;
        _isDownloadFinish = NO;
    }
    return self;
}

@end
