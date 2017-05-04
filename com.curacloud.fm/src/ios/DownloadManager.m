#import "DownloadManager.h"
#import <Social/Social.h>
#import "SSZipArchive.h"
#import "FileManager.h"
#import "MediaInfo.h"


@interface DownloadManager()<NSURLSessionDataDelegate>
@property (nonatomic ,strong) NSURLSession *session;
@property (nonatomic ,strong) NSURLSessionDataTask *dataTask;


@property (nonatomic , strong) NSData *resumeData;
@property (nonatomic, assign) int percent;
@property (nonatomic, assign) int tmpPercent;
@property (nonatomic, assign) long long totalLength;
@property (nonatomic, assign) long long currentLength;
@property (nonatomic, assign) long long downloadedBytes;

@end

#define Downloaded @100
@implementation DownloadManager
{
//    id _delegate;
    double _endTime;
}
-(NSURLSession *)session
{
    if (_session == nil) {
        NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

- (void)releaseSession {
    self.dataTask = nil;
    if (_session != nil) {
        [_session invalidateAndCancel];
        _session = nil;
    }
}

- (instancetype)initWithFilepath:(NSString *)filepath userFilepath:(NSString *)userFilepath unZipFilepath:(NSString *)unZipFilepath  username:(NSString *)username fileType:(NSString *)fileType caseId:(NSString *)caseId fileId:(NSString *)fileId URL:(NSURL *)url id:(id)delegate
{
    self = [super init];
    
    if (self) {
        _filepath = [filepath copy];
        _url = [url copy];
        _userFilepath = [userFilepath copy];
        _unZipFilepath = unZipFilepath;
        _caseId = caseId;
        _fileId = fileId;
        _fileType = fileType;
//        _delegate =delegate;
        _tmpPercent = 0;
        _username= username;
        _mediaInfo = [[MediaInfo alloc]init];

        _endTime = 0;
        
    }
//    [self writeJsonToFile:@0];
    
    return self;
}

- (void)startDownload {
    id progressInfo = [self profileLoad];
    BOOL isShouldWrite  = YES;
    for (id info in progressInfo) {
        if ([info[@"caseId"] isEqualToString:_caseId] ) {
            isShouldWrite = NO;
            break;
        }
    }
    if (isShouldWrite) {
         [self writeJsonToFile:@0];
    }
  
 
    self.mediaInfo.caseId = _caseId;
    self.mediaInfo.fileType = _fileType;
    self.mediaInfo.isDownloadError = NO;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_url];
    self.downloadedBytes = 0;
    if ([[NSFileManager defaultManager] fileExistsAtPath:_filepath]) {
        //获取已下载的文件长度
        _downloadedBytes = [self fileSizeForPath:_filepath];

        if (self.downloadedBytes > 0) {
            NSMutableURLRequest *mutableURLRequest = [request mutableCopy];
            NSString *requestRange = [NSString stringWithFormat:@"bytes=%llu-", _downloadedBytes];
            [mutableURLRequest setValue:requestRange forHTTPHeaderField:@"Range"];
            request = mutableURLRequest;
        }
    }

    self.dataTask=[self.session dataTaskWithRequest:request];
    [self.dataTask resume];
    
  }


- (void)pause {
    if (self.dataTask) {
         [self.dataTask cancel];
    }
   
    [self callBackJs];
}

#pragma dataTask delegate methods
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    	NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    if (httpResponse.statusCode != 200 && httpResponse.statusCode != 206) {
        completionHandler(NSURLSessionResponseCancel);
        [self releaseSession];
        return;
    }
    
    NSFileManager *mgr = [NSFileManager defaultManager];
    [mgr createDirectoryAtPath:_userFilepath withIntermediateDirectories:YES attributes:nil error:nil];
    if (self.downloadedBytes == 0){
        [mgr createFileAtPath:_filepath contents:nil attributes:nil];
    }

    // 获得文件的总大小
    if (self.downloadedBytes>0) {
        self.totalLength = self.downloadedBytes+response.expectedContentLength;
    }else {
        self.totalLength = response.expectedContentLength;
    }
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    NSOutputStream* stream = [NSOutputStream outputStreamToFileAtPath:_filepath append:YES];
    [stream open];
    [stream write:[data bytes] maxLength:[data length]];
    self.downloadedBytes += [data length];
    [stream close];

    _percent = (int)((double)self.downloadedBytes/ _totalLength*100);
    NSLog(@"percent = %%%d",_percent);


    
    double startTime = CFAbsoluteTimeGetCurrent();
    
    double dt = (startTime - _endTime)*1000;//ms

    if (dt > 50) {
        if(_tmpPercent == 0) {
            if (_percent > 0) {
                _tmpPercent = _percent;
                self.mediaInfo.progress = _percent;
                [self callBackJs];
            }
        } else if (_percent > _tmpPercent) {
            _tmpPercent = _percent;
            if (_percent != 100) {
                self.mediaInfo.progress = _percent;
                [self callBackJs];
            }
        }
    }
    
    _endTime = startTime;
 
    
}

/**
 *  加载完毕后调用（服务器的数据已经完全返回后）
 */

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        self.mediaInfo.isDownloadStop = YES;
        [self callBackJs];
        return;
    }
    [self releaseSession];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self unZipFile:_filepath destinationPath:_unZipFilepath];
    });
    
}

#pragma file handle
//解压下载zip文件
- (void)unZipFile:(NSString *)filePath destinationPath:(NSString *) destinationPath {
    [SSZipArchive unzipFileAtPath:filePath toDestination: destinationPath];
    [self deleteFile];
}

//删除下载的zip文件
- (void)deleteFile{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL res=[fileManager removeItemAtPath:_filepath error:nil];
    if (res) {
        id progressInfo = [self profileLoad];
        for (id info in progressInfo) {
            NSInteger offlineDVFileProgress = [info[@"offlineDVFileProgress"] intValue];
            if (offlineDVFileProgress == 50 && [info[@"caseId"] isEqualToString:_caseId] ) {
                self.mediaInfo.isDownloadFinish = YES;
                [self callBackJs];
                 [self writeJsonToFile:@100];
                return;
            }
        }
      
        [self callBackJs];
        self.mediaInfo.progress = 100;
        
        [self writeJsonToFile:@50];
       
        NSLog(@"文件删除成功");
    }else
        NSLog(@"文件删除失败");
    NSLog(@"文件是否存在: %@",[fileManager isExecutableFileAtPath:_filepath]?@"YES":@"NO");
}

//获取已下载的文件大小
- (unsigned long long)fileSizeForPath:(NSString *)path {
    signed long long fileSize = 0;
    NSFileManager *fileManager = [NSFileManager new]; // default is not thread safe
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        if (!error && fileDict) {
            fileSize = [fileDict fileSize];
        }
    }
    return fileSize;
}

- (void)writeJsonToFile:(NSNumber *)fileStatus {
    NSString* fileName = @"offlineDVFileProgress.json";
    NSString* fileAtPath = [_userFilepath stringByAppendingPathComponent:fileName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
        NSFileManager *mgr=[NSFileManager defaultManager];
        [mgr createDirectoryAtPath:_userFilepath withIntermediateDirectories:YES attributes:nil error:nil];
        [mgr createFileAtPath:fileAtPath contents:nil attributes:nil];
    }
    
    NSData *content = [[NSData alloc] initWithContentsOfFile:fileAtPath];
    NSArray *jsonFile=[NSArray array];
    if (content) {
        jsonFile=[NSJSONSerialization JSONObjectWithData:content options:0 error:nil];
    }
    
    //this contains array's of dictionary....
    
    NSDictionary *newFileSatus=@{@"caseId":_caseId,@"offlineDVFileProgress":fileStatus,@"fileId":_fileId,@"dicomFileId":_fileId};
    NSArray *temp=[[NSArray alloc]initWithArray:jsonFile];
    NSMutableArray *mutableArr = [temp mutableCopy];
    BOOL flag =true;
    for (int i = 0; i < temp.count; i++) {
        if ([temp[i][@"caseId"]isEqualToString:_caseId]) {
            NSMutableDictionary *mutableDic = [temp[i] mutableCopy];
            mutableDic[@"offlineDVFileProgress"] = fileStatus;
            if ([_fileType isEqualToString:@"ffr"]) {
                mutableDic[@"fileId"] = _fileId;
            } else {
                mutableDic[@"dicomFileId"] = _fileId;
            }
            [mutableArr removeObjectAtIndex:i];
            [mutableArr insertObject:mutableDic atIndex:i];
            flag = false;
        }
    }
    if (flag) {
        [mutableArr insertObject:newFileSatus atIndex:mutableArr.count];
    }
    
    //now serialize temp data....
    NSData *serialzedData=[NSJSONSerialization dataWithJSONObject:mutableArr options:0 error:nil];
    NSString *saveFileStatus = [[NSString alloc] initWithBytes:[serialzedData bytes] length:[serialzedData length] encoding:NSUTF8StringEncoding];
    [saveFileStatus writeToFile:fileAtPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (id)profileLoad {
    id jsonObject=nil;
    NSString* tmpJsonPath=[NSString stringWithFormat:@"users/%@/offlineDVFileProgress.json",_username];
    NSString* jsonPath = [self getDirectory:tmpJsonPath];
    NSData *data=[NSData dataWithContentsOfFile:jsonPath];
    NSError *error;
    if (data.length) {
        jsonObject=[NSJSONSerialization JSONObjectWithData:data
                                                   options:NSJSONReadingAllowFragments
                                                     error:&error];
    }
    return jsonObject;
}

- (NSString *)getDirectory: (NSString *)pathComponent {
    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [caches stringByAppendingPathComponent:pathComponent];
    return path;
}

//#pragma callback
- (void)callBackJs {
    NSMutableArray *arr = [NSMutableArray array];
    [arr addObject: [NSNumber numberWithInt:self.mediaInfo.progress]];
    [arr addObject:self.mediaInfo.caseId];
    [arr addObject:self.mediaInfo.fileType];
    [arr addObject:[NSNumber numberWithInt:self.mediaInfo.isDownloadStop]];
    [arr addObject: [NSNumber numberWithBool:self.mediaInfo.isDownloadError]];
    [arr addObject: [NSNumber numberWithBool:self.mediaInfo.isDownloadFinish]];
    
    CDVPluginResult *pluginResult =[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:arr];
    pluginResult.keepCallback = @1;//keep _callBackId can callback many times
    [self.mGDelegate callBackJs:pluginResult];
//    [_delegate sendPluginResult:pluginResult callbackId:@"_filemanager_updateprogress_"];
}

@end
