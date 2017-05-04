#Cordova常见问题

#####1.常用命令
- 新建cordova工程
```objc
//workshop:工程文件夹的名字，com.yourname.workshop:工程的identifier，Workshop:ios工程名
cordova create workshop com.yourname.workshop Workshop
```

- 新建相关平台，如ios/android/
```
cordova platform add ios  ->在根目录下生成平台相关文件platforms/ios
```
- 移除平台，如ios/android/
```
cordova platform remove ios ->根目录下平台相关文件platforms/ios会全部删除
```
- 添加插件
```
cordova plugin add pluginName ->插件资源会保存在根目录plugins下，同时在所有平台生成插件相关资源
```
- 移除插件
```
cordova plugin remove pluginName ->移除所有平台相关插件
```
- 保存插件
```
cordova plugin add pluginName -save ->会在根目录配置文件中保存插件信息，配置文件中若包含插件信息，在进行命令2新建平台时会自动安装相应插件。
```

#####2.常用配置
- webview设置格外滚动范围为0
```
<preference name="DisallowOverscroll" value="true" />
```
- 自动下载插件
```
<plugin name="cordova-plugin-remote-injection" />
```
- 去除web的交互(长按复制,放大镜等)
```
<style type="text/css">
 *:not(input,textarea) {
     -webkit-user-select: none; /* Disable selection/Copy of UIWebView */
     -webkit-touch-callout: none;
 }
 </style>
```

- 设置跳转地址

```
<content src="http://10.10.0.5:3000/index.html"/>
<!-- 设置访问权限，*代表可以访问任何src/> -->
<allow-navigation hap-rule="yes" href="*"/>
```

#####3.常用插件

- splash插件
```
<plugin name="cordova-plugin-splashscreen" spec="~3.2.2" />
<!-- 解决splash出现白色闪一下的bug/> -->
<feature name="SplashScreen">
   <param name="ios-package" value="CDVSplashScreen" />
   <param name="onload" value="true" />
</feature>
```
- remote-injection插件
```
<!-- 远程注入代码插件，插件的js都会自动注入到远程src/> -->
<plugin name="cordova-plugin-remote-injection" />
<!--将www/js/cordova.js注入到远程src/> -->
  <preference name="CRIInjectFirstFiles" value="www/js/cordova.js" />
```
- wkwebview-engine插件
```
<!-- 直接命令创建的ios工程用的是webview，通过添加插件来改为wkwebview/> -->
<plugin name="cordova-plugin-wkwebview-engine" />
```
#####4.Pod的使用
要在cordova工程中使用pod必须先把工程配置设置为none再在ios工程目录下运行pod install，如下：
![](/assets/pic1.gif)

