#Cordova常见问题

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

- 设置跳转地址

```
<content src="http://10.10.0.5:3000/index.html"/>
<!-- 设置访问权限，*代表可以访问任何src/> -->
<allow-navigation hap-rule="yes" href="*"/>
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
<!-- 远程注入代码插件，插件的js都会自动注入到远程src/> -->
<plugin name="cordova-plugin-remote-injection" />
```
- wkwebview-engine插件
```
<!-- 直接命令创建的ios工程用的是webview，通过添加插件来改为wkwebview/> -->
<plugin name="cordova-plugin-wkwebview-engine" />
```
