//
//  QYADView.m
//  JingJieBusiness
//
//  Created by wangchengxin on 2017/1/6.
//  Copyright © 2017年 wangchengxin. All rights reserved.
//

#import "QYADView.h"
#import "QYADItem.h"



@interface QYADView ()<CAAnimationDelegate>

@property (nonatomic, strong) UIImageView * adImgView;
@property (nonatomic, strong) UIButton * timerBtn;
@property (nonatomic, strong) NSTimer * timer;
@property (nonatomic, strong) QYADItem *item;
@end

@implementation QYADView
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        //2.广告图
        [self setupADImgView];
        //3.按钮
        [self setupADBtn];
        
        //4.定时器
        [self addTimer];
        
        
    }
    return self;
}
#pragma mark - 2.广告图

- (void)setupADImgView
{
    //1.
    UIImageView * adImg = [[UIImageView alloc] init];
    adImg.frame = CGRectMake(0, 0, QYScreenW, QYScreenH);
    adImg.image = [self changeADImg];
    adImg.userInteractionEnabled = YES;
    [self addSubview:adImg];
    self.adImgView = adImg;
    
    //2.手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [adImg addGestureRecognizer:tap];
}
- (void)tap
{
    // 跳转到界面 => safari
    
    NSString * TapUrl = [[NSUserDefaults standardUserDefaults] objectForKey:QYTapADImgUrlStr];
    if (TapUrl == nil || [TapUrl isEqualToString:@""]) {
        return;
    }
    NSURL * url = [NSURL URLWithString:TapUrl];
    UIApplication * app = [UIApplication sharedApplication];
    if ([app canOpenURL:url]) {
        if ([[[UIDevice currentDevice] systemVersion] doubleValue] < 10.0) {
            [app openURL:url];
        }else{
            [app openURL:url options:@{} completionHandler:^(BOOL success) {
                
            }];
        }
        
    }
}
#pragma mark - 3.按钮
- (void)setupADBtn
{
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.layer.cornerRadius = 20;
    btn.backgroundColor = [UIColor whiteColor];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn setTitle:@"跳转（3）" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    btn.frame = CGRectMake(QYScreenW - 80 - 20, 20, 80, 40);
    [btn addTarget:self action:@selector(clickJump) forControlEvents:UIControlEventTouchUpInside];
    [self.adImgView addSubview:btn];
    self.timerBtn = btn;
}
- (void)clickJump
{
    [self loadAdData];
    
    if (self.delegate  && [self.delegate respondsToSelector:@selector(dissmissADView)]) {
        [self.delegate dissmissADView];
        [self.timer invalidate];
        
        [self removeFromSuperview];
        
    }
}
#pragma mark - 4.定时器
- (void)addTimer
{
    NSTimer * timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timerFire) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    self.timer = timer;
}
- (void)timerFire
{
    static int i = 3;
    if (i == 0) {
        [self clickJump];
    }
    i--;
    [self.timerBtn setTitle:[NSString stringWithFormat:@"跳转（%d）",i] forState:UIControlStateNormal];
}
#pragma mark - 请求数据
- (void)loadAdData
{
    // 1.创建请求会话管理者
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr.requestSerializer.timeoutInterval = 8;
    // 2.拼接参数
    
    NSString * getUrl = [NSString stringWithFormat:@"%@m=User&a=get_splash_ads",QYMainURL];
    
    // 3.发送请求
    [mgr GET:getUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary * _Nullable responseObject) {
        
        int err_code = [responseObject[@"err_code"] intValue];
        if (err_code == 100) {
            // 获取字典
            NSDictionary *adDict = responseObject[@"data"];
            
            // 字典转模型
            _item = [QYADItem mj_objectWithKeyValues:adDict];
            
            // 广告网址
            NSString * urlStr = [NSString stringWithFormat:@"%@%@",QYMainURLImg,_item.pic_src];
            
            //为了缓存到sd里面  方便下次提取使用；
            UIImageView * imggg = [[UIImageView alloc] init];
            imggg.hidden = YES;
            imggg.frame = self.adImgView.frame;
            [self addSubview:imggg];
            [imggg sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (error ==  nil) {
                    //1.必须加载 在缓存
                    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
                    [userDefault setObject:urlStr forKey:QYADImgUrlStr];
                    //                  [userDefault setObject:@"https://github.com" forKey:QYTapADImgUrlStr];
                    [userDefault setObject:_item.url forKey:QYTapADImgUrlStr];
                    [userDefault synchronize];
                    
                    //2.缓存到本地
                    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
                    // 拼接图片名为"currentImage.png"的路径
                    NSString *imageFilePath = [path stringByAppendingPathComponent:@"currentImage.png"];
                    //获取网络请求中的url地址
                    NSData *data = [NSData dataWithContentsOfURL:[NSURL  URLWithString:urlStr]];
                    //转换为图片保存到以上的沙盒路径中
                    UIImage * currentImage = [UIImage imageWithData:data];
                    //其中参数0.5表示压缩比例，1表示不压缩，数值越小压缩比例越大
                    [UIImageJPEGRepresentation(currentImage, 1.0) writeToFile:imageFilePath  atomically:YES];
                    
                }
                
            }];
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"---%@",error);
        
    }];
    
}
// 更改图片
- (UIImage *)changeADImg
{
    UIImage * img;
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString * proImgUrlStr = [defaults objectForKey:QYADImgUrlStr];
    
    if (proImgUrlStr != nil) {
        //1.1  有缓存图片
        
        NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"currentImage.png"];
        UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:fullPath];
        img  = savedImage;
    }else{
        img = [UIImage imageNamed:@"applysystemvc_applyone_bg"];
    }
    
    return img;
}

@end
