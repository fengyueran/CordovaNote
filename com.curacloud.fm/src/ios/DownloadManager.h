#import <Cordova/CDV.h>
#import <Foundation/Foundation.h>
#import "MediaGroup.h"
#import "MediaInfo.h"

@protocol ConnetWeb <NSObject>

- (void)callBackJs:(CDVPluginResult *)pluginResult;

@end

@interface DownloadManager : CDVPlugin


@property (nonatomic ,strong) MediaInfo *mediaInfo;
@property (nonatomic, copy) NSString *filepath;
@property (nonatomic, copy) NSString *userFilepath;
@property (nonatomic, copy) NSString *unZipFilepath;
@property (nonatomic, copy) NSString *caseId;
@property (nonatomic, copy) NSString *fileId;
@property (nonatomic, copy) NSString *fileType;
@property (nonatomic, copy) NSString *username;

@property (nonatomic, copy) NSURL *url;
@property (nonatomic, weak) id<ConnetWeb> mGDelegate;


- (void)pause;
- (void)startDownload;
- (void)unZipFile:(NSString *)location destinationPath:(NSString *)unZipFilepath;
- (void)deleteFile;
- (instancetype)initWithFilepath:(NSString *)filepath
                    userFilepath:(NSString *)userFilepath
                   unZipFilepath:(NSString *)unZipFilepath
                        username:(NSString *)username
                        fileType:(NSString *)fileType
                          caseId:(NSString *)caseId
                          fileId:(NSString *)fileId
                             URL:(NSURL *)url
                              id:(id)delegate;
@end
