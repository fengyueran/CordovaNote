//
//  MediaGroup.h
//  
//
//  Created by xinghun meng on 21/04/2017.
//
//



@class DownloadManager;
#import <Foundation/Foundation.h>
#import <Cordova/CDV.h>
#import "DownloadManager.h"



@interface MediaGroup : NSObject

@property (nonatomic, strong) NSMutableArray<DownloadManager *> *mArr;
@property (nonatomic, strong) id commandDelegate;

@end
