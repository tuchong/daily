##图虫日报

####Platform

OS X 10.10.4, Xcode 6.4, iOS SDK 8.4

####Config
1. Edit `apiUrl`, `tokenKey`, `weiboAppKey` and `wechatAppId` at `daily-Prefix.pch`
2. Adding custom URL schema of Weibo and Wechat

####Build
```bash
cd daily
pod install
```

####Dependency
- [AFNetworking](https://github.com/AFNetworking/AFNetworking)
- [Masonry](https://github.com/SnapKit/Masonry)
- [MJExtension](https://github.com/CoderMJLee/MJExtension)
- [SDWebImage](https://github.com/rs/SDWebImage)
- [VIPhotoView](https://github.com/vitoziv/VIPhotoView)
- [WeiboSDK](https://github.com/sinaweibosdk/weibo_ios_sdk)

###License
The [MIT License](LICENSE).
