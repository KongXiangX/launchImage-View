参考网址 

http://note.youdao.com/noteshare?id=23d1430a1ad994cfa9ffad7d71d711a7
思路：
1.时机判定
1.在每次启动应用的时候 显示 广告
2. 因为每次启动应用都会调用
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {}
方法所以在它里面添加  广告视图
2.广告视图里面要有图片 与跳过按钮（定时器）
1.断网的时候获取sdwebimage  里面缓存的图片
2.内部实现思路
正确思路
1.给一张默认的 广告图片 （本地）用于第一次显示 ，没有跳转的网址
2.每次点击跳过按钮  /   3秒后销毁  广告页的时候 调用 请求新广告页的的数据
并且用userDefault 存储 记录显示图片的网址（方便SDWebImageManager获取
缓存图片）、与 显示图片的跳转网址
3.第二次 启动应用 初始化广告页的 时候，通过userDefault存储的数据 直接更换
显示图片为 第一次网络获取的 图片与 网址
4.注意点
将图片图片存入sdwebImage 中必须将该图片addSubView 
  1.  [self addSubview:imggg];
到父视图中 负责
否则 
  1. - (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock
completedBlock 代码块不会回调


  2.  UIImageView * imggg = [[UIImageView alloc] init];
  3.             imggg.hidden = YES;
  4.             imggg.frame = self.adImgView.frame;
  5.             [self addSubview:imggg];
  6.          [imggg sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
  7.              if (error ==  nil) {
  8.                  //必须加载 在缓存
  9.                  NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
  10.                  [userDefault setObject:urlStr forKey:QYADImgUrlStr];
  11. //                  [userDefault setObject:@"https://github.com" forKey:QYTapADImgUrlStr];
  12.                  [userDefault setObject:_item.url forKey:QYTapADImgUrlStr];
  13.                  [userDefault synchronize];
  14.                  
  15.                  QYLog(@"---%@",error);
  16.              }
  17.              QYLog(@"wwwww---%@",error);
  18.             
  19.          }];


错误思路
1.不要再初始化广告view 的时候 调用 请求新广告页的连接，那样会在你点击
广告页的时候跳转网址 不是上一次的图片网址，而是现在请求的广告图片的 
跳转连接
原因：userDefault 实时同步的原因 ，初始化  里面请求获取广告 替换掉了
上次图片的连接，而 此时显示的图片 是上次缓存的图片

2.没有在
  2. - (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock
完成的方法中 userDefault存储图片、与图片网址
否则 如果网络不稳定 显示的图片为window 图层

原因：如果网络不稳定 ，图片没有缓存到sdwebImage 中无法从中提取上次的图片
  所以显示的为window图层


