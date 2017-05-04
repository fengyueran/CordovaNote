#Cordova常用配置

1.webview设置格外滚动范围为0
配置文件中加入：
```
<preference name="DisallowOverscroll" value="true" />
```
2.自动下载插件
配置文件中加入：
```
<plugin name="cordova-plugin-remote-injection" />

```

3.splash插件

```
<plugin name="cordova-plugin-splashscreen" spec="~3.2.2" />

<feature name="SplashScreen">
   <param name="ios-package" value="CDVSplashScreen" />
   <param name="onload" value="true" />
</feature>
```