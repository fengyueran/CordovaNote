cordova.define("com.curacloud.fm.fileManager", function(require, exports, module) {
/*global cordova, module*/

var FileManager = function() {

};

FileManager.prototype.downloadFile = function (url, fileId, caseId, userName,fileType,oldFileId, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "FileManager", "downloadFile", [url,fileId,caseId,userName,fileType,oldFileId]);
    }
FileManager.prototype.readFile = function (fileId,fileName,userName,successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "FileManager", "readFile", [fileId,fileName, userName]);
    }
FileManager.prototype.profileLoad = function (userName,successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "FileManager", "profileLoad", [userName]);
    }
FileManager.prototype.storeCaseData = function (data,userName,successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "FileManager", "storeCaseData", [data,userName]);
    }
FileManager.prototype.shareLink = function (link,successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "FileManager", "shareLink", [link]);
    }
FileManager.prototype.deleteCachedData = function (userName,caseId,deleteAll, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "FileManager", "deleteCachedData", [userName,caseId,deleteAll]);
    }
FileManager.prototype.checkUpdate = function (userName,info, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "FileManager", "checkUpdate", [userName,info]);
    }
FileManager.prototype.loadConfig = function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "FileManager", "loadConfig");
    }
module.exports = FileManager;

});
