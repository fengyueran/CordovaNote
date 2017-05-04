#import <Cordova/CDV.h>

@interface FileManager : CDVPlugin

- (void)downloadFile:(CDVInvokedUrlCommand*)command;
- (void)readFile:(CDVInvokedUrlCommand*)command;
- (void)profileLoad:(CDVInvokedUrlCommand*)command;
- (void)storeCaseData:(CDVInvokedUrlCommand*)command;
- (void)shareLink:(CDVInvokedUrlCommand*)command;
- (void)deleteCachedData:(CDVInvokedUrlCommand*)command;
- (void)checkUpdate:(CDVInvokedUrlCommand*)command;
- (void)loadConfig:(CDVInvokedUrlCommand*)command;


@end
