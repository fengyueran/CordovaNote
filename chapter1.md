#Cordova常用配置

#####1.常用配置
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
#####2.常用插件
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
<plugin name="cordova-plugin-remote-injection" />
```

