#import "FileManager.h"
#import <Social/Social.h>
#import "MediaGroup.h"
#import "DownloadManager.h"

#define Downloaded @0
@interface FileManager ()
@property (strong, nonatomic) NSMutableArray <MediaGroup *>*array;
@end

@implementation FileManager
{
    id _jsonObject;
}


- (NSString *)getDirectory: (NSString *)pathComponent {
    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [caches stringByAppendingPathComponent:pathComponent];
    return path;
}

- (void)downloadFile:(CDVInvokedUrlCommand*)command
{
    
    
    if (!_array) {
        _array = [NSMutableArray array];
        
    }
    
    NSString *fileId = command.arguments[1];
    NSLog(@"fileid=%@",fileId);
    
    
    NSString *caseId = command.arguments[2];
    NSURL *url = [NSURL URLWithString:command.arguments[0]];
    NSString *userName = command.arguments[3];
    userName = [self lowerUserName:userName];
    NSString *fileType = command.arguments[4];
    // NSURL *url1 = [NSURL URLWithString:@"http://archive.apache.org/dist/cordova/cordova-2.9.1-src.zip"];
    
    NSString *oldFileId = command.arguments[5];
    NSString *tmpUnZipFilepath;
    if ([oldFileId isKindOfClass:[NSString class]] ) {
        tmpUnZipFilepath=[NSString stringWithFormat:@"users/%@/%@/",userName,oldFileId];
        [[NSFileManager defaultManager]removeItemAtPath:tmpUnZipFilepath error:nil];
    }
    tmpUnZipFilepath=[NSString stringWithFormat:@"users/%@/%@/",userName,fileId];
    NSString *downloadFileName =[NSString stringWithFormat:@"%@.zip",fileId];
    
    NSString *userFilepath = [self getDirectory:[NSString stringWithFormat:@"users/%@",userName]];
    NSString *unZipFilepath = [self getDirectory:tmpUnZipFilepath];
    if ([[NSFileManager defaultManager]fileExistsAtPath:unZipFilepath]) {
        return;
    }
    NSString *filepath = [userFilepath stringByAppendingPathComponent:downloadFileName];
    DownloadManager *downloadManager= [[DownloadManager alloc]initWithFilepath:filepath
                                                                  userFilepath:userFilepath
                                                                 unZipFilepath:unZipFilepath
                                                                      username:userName
                                                                      fileType:fileType
                                                                        caseId:caseId
                                                                        fileId:fileId
                                                                           URL:url
                                                                            id:self.commandDelegate];
    
    BOOL isDownloaded = NO;
    
    
    for (MediaGroup *mg in _array) {
        for (DownloadManager *dm in mg.mArr) {
            if ([dm.fileId isEqualToString: fileId]) {
                if (!dm.mediaInfo.isDownloadFinish) {
                    if (dm.mediaInfo.isDownloadStop) {
                        [mg.mArr removeObject:dm];
                        [mg.mArr addObject:downloadManager];
                        downloadManager.mediaInfo.isDownloadStop = NO;
                        downloadManager.mGDelegate = mg;
                        [downloadManager startDownload];
                        return;
                    } else {
                        dm.mediaInfo.isDownloadStop = YES;
                        [dm pause];
                        
                    }
                    isDownloaded = YES;
                }
                else {
                    isDownloaded = YES;
                }
                break;
                
            }
        }
    }
    
    if (isDownloaded) {
        return;
    }
    
    BOOL flag = YES;
    
    for (MediaGroup *mg in _array) {
        NSMutableArray *tmpArr = [mg.mArr mutableCopy];
        for (DownloadManager *dm in tmpArr) {
            if ([dm.caseId isEqualToString: caseId]) {
                [mg.mArr addObject:downloadManager];
                downloadManager.mGDelegate = mg;
                flag = NO;
            }
        }
    }
    if (flag) {
        MediaGroup *mediaGroup = [[MediaGroup alloc]init];
        mediaGroup.commandDelegate = self.commandDelegate;
        downloadManager.mGDelegate = mediaGroup;
        [mediaGroup.mArr addObject:downloadManager];
        [_array addObject:mediaGroup];
    }
    //    [_array addObject:downloadManager];
    [downloadManager startDownload];
    
}


- (void)readFile:(CDVInvokedUrlCommand*)command {
    NSString *userName=command.arguments[2];
    userName = [self lowerUserName:userName];
    NSString *type=command.arguments[0];
    NSString *tmpFilePath=[NSString stringWithFormat:@"users/%@/%@/%@",userName,command.arguments[0],command.arguments[1]];
    
    if ([type isEqualToString:@"readCaseData"]) {
        tmpFilePath=[NSString stringWithFormat:@"users/%@/%@",userName,@"CaseData.json"];
    } else if([type isEqualToString:@"readUserInfo"]) {
        tmpFilePath=[NSString stringWithFormat:@"users/%@/%@",userName,@"userInfo.json"];
    }
    // 创建一个空的文件 到 沙盒中
    NSString *filePath = [self getDirectory:tmpFilePath];
    NSData *data=[NSData dataWithContentsOfFile:filePath];
    CDVPluginResult *pluginResult=nil;
    if (data.length) {
        if ([type isEqualToString:@"readCaseData"]|[type isEqualToString:@"readUserInfo"]) {
            _jsonObject=[NSJSONSerialization JSONObjectWithData:data
                                                        options:NSJSONReadingAllowFragments
                                                          error:nil];
            pluginResult =[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:_jsonObject];
        }else {
            pluginResult =[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArrayBuffer:data];
        }
    }else {
        pluginResult=[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:false];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)profileLoad:(CDVInvokedUrlCommand*)command {
    _jsonObject=nil;
    NSString *userName=command.arguments[0];
    userName = [self lowerUserName:userName];
    _jsonObject = [self readMediaInfo:userName];
    CDVPluginResult *pluginResult = nil;
    if (_jsonObject) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:_jsonObject];
        
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

- (void)storeCaseData:(CDVInvokedUrlCommand*)command {
    NSString* fileName = @"CaseData.json";
    NSString *type=command.arguments[1][@"type"];
    NSString *userName=command.arguments[1][@"userName"];
    userName = [self lowerUserName:userName];
    if ([type isEqualToString:@"storeUserInfo"]) {
        fileName=@"userInfo.json";
    }
    
    NSString *fileDirectory = [self getDirectory:[NSString stringWithFormat:@"users/%@",userName]];
    NSString *filePath = [fileDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",fileName]];
    NSData *serialzedData=nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSFileManager *mgr=[NSFileManager defaultManager];
        [mgr createDirectoryAtPath:fileDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        [mgr createFileAtPath:filePath contents:nil attributes:nil];
        
        if ([type isEqualToString:@"storeUserInfo"]) {
            NSString *password=command.arguments[1][@"password"];
            NSDictionary *account=@{@"username":userName,@"password":password};
            serialzedData=[NSJSONSerialization dataWithJSONObject:account options:0 error:nil];
        } else {
            serialzedData=[NSJSONSerialization dataWithJSONObject:command.arguments[0] options:0 error:nil];
        }
        NSString *accountInfo = [[NSString alloc] initWithBytes:[serialzedData bytes] length:[serialzedData length] encoding:NSUTF8StringEncoding];
        [accountInfo writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}

- (void)deleteCachedData:(CDVInvokedUrlCommand*)command {
    NSString  *username=command.arguments[0];
    NSString  *caseId=command.arguments[1];
    NSArray *mediaInfo=[self readMediaInfo:username];
    NSMutableArray *tmpMediaInfo = [mediaInfo mutableCopy];
    BOOL deleteAll = [command.arguments[2] isEqualToNumber:[NSNumber numberWithBool:YES]];
    
    CDVPluginResult *pluginResult = nil;
    if (deleteAll) {
        NSMutableArray *caseIds = [NSMutableArray array];
        for (id info in mediaInfo) {
            [caseIds addObject:info[@"caseId"]];
        }
        pluginResult =[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:caseIds];
        NSString *filepath = [NSString stringWithFormat:@"%@/%@",@"users",username];
        filepath = [self getDirectory:filepath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:filepath error:nil];
        
        for (MediaGroup *mg in _array) {
            for (DownloadManager *dm in mg.mArr) {
                if (!dm.mediaInfo.isDownloadStop) {
                    [dm pause];
                }
            }
        }
        _array = nil;
        
    } else {
        for (int i = 0; i< mediaInfo.count; i++) {
            id info = mediaInfo[i];
            if ([info[@"caseId"] isEqualToString:caseId] ) {
                NSString*fileId = info[@"fileId"];
                NSString*dicomFileId = info[@"dicomFileId"];
                NSArray *fileIdArr = [NSArray arrayWithObjects:fileId,dicomFileId, nil];
                [self deleteWithUsername:username fileIdArr:fileIdArr];
                [tmpMediaInfo removeObjectAtIndex:i];
            }
        }
        
        pluginResult =[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
        [self saveMediaInfo:username data:tmpMediaInfo];
        
        NSMutableArray * tmpArr = _array;
        for (int i = 0; i < tmpArr.count; i++) {
            MediaGroup *mg = tmpArr[i];
            for (DownloadManager *dm in mg.mArr) {
                if ([dm.caseId isEqualToString: caseId]) {
                    [_array removeObjectAtIndex:i];
                    break;
                }
            }
        }
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

- (void)deleteWithUsername:(NSString *)username fileIdArr:(NSArray *)fileIdArr {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (id fileId in fileIdArr) {
        NSString *filepath = [NSString stringWithFormat:@"users/%@/%@",username,fileId];
        filepath = [self getDirectory:filepath];
        [fileManager removeItemAtPath:filepath error:nil];
    }
    
    
}

- (id)readMediaInfo:(NSString *)username {
    id mediaInfo=nil;
    NSString* tmpJsonPath=[NSString stringWithFormat:@"users/%@/offlineDVFileProgress.json",username];
    NSString* jsonPath = [self getDirectory:tmpJsonPath];
    NSData *data=[NSData dataWithContentsOfFile:jsonPath];
    NSError *error;
    if (data.length) {
        mediaInfo=[NSJSONSerialization JSONObjectWithData:data
                                                  options:NSJSONReadingAllowFragments
                                                    error:&error];
    }
    return mediaInfo;
}


- (void)saveMediaInfo:(NSString *)username data:(NSMutableArray *)data {
    NSString* fileAtPath = [NSString stringWithFormat:@"users/%@/offlineDVFileProgress.json",username];
    fileAtPath = [self getDirectory:fileAtPath];
    
    //now serialize temp data....
    NSData *serialzedData=[NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
    NSString *saveFileStatus = [[NSString alloc] initWithBytes:[serialzedData bytes] length:[serialzedData length] encoding:NSUTF8StringEncoding];
    [saveFileStatus writeToFile:fileAtPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (void)checkUpdate:(CDVInvokedUrlCommand*)command {
    NSString  *username = command.arguments[0];
    NSArray *info = command.arguments[1];
    NSArray *mediaInfo=[self readMediaInfo:username];
    NSMutableArray *tmpMediaInfo = [mediaInfo mutableCopy];
    
    for (id caseInfo in info) {
        NSString *caseId = caseInfo[@"caseId"];
        for (int i = 0; i <mediaInfo.count; i++) {
            id mi= mediaInfo[i];
            if ([mi[@"caseId"] isEqualToString:caseId]) {
                NSMutableDictionary *mutableDic = [tmpMediaInfo[i] mutableCopy];
                if ([caseInfo[@"type"] isEqualToString:@"ffr"]) {
                    mutableDic[@"fileId"] = caseInfo[@"fileId"];
                } else {
                    mutableDic[@"dicomFileId"] = caseInfo[@"fileId"];
                    
                }
                [self removeFileWithName:username fileId:caseInfo[@"fileId"]];
                
                if ([tmpMediaInfo[i][@"offlineDVFileProgress"] integerValue] == 100) {
                    mutableDic[@"offlineDVFileProgress"] = @50;
                } else {
                    mutableDic[@"offlineDVFileProgress"] = @0;
                }
                [tmpMediaInfo removeObjectAtIndex:i];
                [tmpMediaInfo insertObject:mutableDic atIndex:i];
            }
            
        }
        
    }
    
    [self saveMediaInfo:username data:tmpMediaInfo];
    
}

- (void)loadConfig:(CDVInvokedUrlCommand*)command {
    NSString *configPath = [self getDirectory:@"UIConfig.json"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *configTmpPath = [[NSBundle mainBundle]pathForResource:@"UIConfig" ofType:@"json"];
    
    if (![fileManager fileExistsAtPath:configPath]) {
        [fileManager copyItemAtPath:configTmpPath toPath:configPath error:nil];
    }
    
    NSData *data = [NSData dataWithContentsOfFile:configPath];
    
    id config=[NSJSONSerialization JSONObjectWithData:data
                                              options:NSJSONReadingAllowFragments
                                                error:nil];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:config];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)shareLink:(CDVInvokedUrlCommand*)command {
    
    NSString  *linkURL=command.arguments[0];
    NSURL *url=[NSURL URLWithString:linkURL];
    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    UIActivityViewController *avc = [[UIActivityViewController alloc]initWithActivityItems:@[@"Link",url,[UIImage imageNamed:@"icon"]] applicationActivities:nil];
    avc.excludedActivityTypes = @[UIActivityTypeAirDrop,UIActivityTypeCopyToPasteboard,UIActivityTypeAddToReadingList];
    
    [appRootVC presentViewController:avc animated:YES completion:nil];
    
}
- (void)removeFileWithName:(NSString *)username fileId:(NSString *)fileId {
    NSString* fileAtPath = [NSString stringWithFormat:@"users/%@/%@",username,fileId];
    fileAtPath = [self getDirectory:fileAtPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:fileAtPath error:nil];
    
}
- (NSString *)lowerUserName:(NSString *)username {
    NSString *lowerName = [username lowercaseStringWithLocale:[NSLocale currentLocale]];
    return lowerName;
}

@end
