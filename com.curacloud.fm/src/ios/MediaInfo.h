//
//  MediaInfo.h
//  CuraCloudMI
//
//  Created by xinghun meng on 06/04/2017.
//
//

#import <Foundation/Foundation.h>

@interface MediaInfo : NSObject
@property (nonatomic, assign) int progress;
@property (nonatomic, assign) BOOL isDownloadStop;
@property (nonatomic, assign) BOOL isDownloadError;
@property (nonatomic, assign) BOOL isDownloadFinish;
@property (nonatomic, copy) NSString *caseId;
@property (nonatomic, copy) NSString *fileType;

@end
