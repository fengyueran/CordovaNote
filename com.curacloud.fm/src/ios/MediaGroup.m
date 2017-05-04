//
//  MediaGroup.m
//  
//
//  Created by xinghun meng on 21/04/2017.
//
//

#import "MediaGroup.h"
#import "DownloadManager.h"


@implementation MediaGroup
    
- (instancetype)init {
    self = [super init];
    if (self) {
        _mArr = [NSMutableArray array];
    }
  
    return self;
}




#pragma callback
- (void)callBackJs:(CDVPluginResult *)pluginResult {
    [self.commandDelegate sendPluginResult:pluginResult callbackId:@"_filemanager_updateprogress_"];
}


@end
