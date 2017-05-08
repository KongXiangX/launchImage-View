#import "AppDelegate.h"
#import "QYLoginVC.h"               //登录界面
#import "QYMainViewController.h"    //tabbarVC
#import "QYADView.h"                //广告页面


@interface AppDelegate ()<QYADViewDelegate>
@property (nonatomic, strong) QYADView * adView;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //1. 创建窗口
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = QYGlobalColor;
   
    
    //2.广告页面
    //!!! xcode 7.0 /ios10.0 测试 会崩溃，原因是 苹果调整了 显示顺序，必须加一个rootViewController
    UIViewController * temVC = [[UIViewController alloc] init];
    self.window.rootViewController = temVC;
    
    self.adView = [[QYADView alloc] initWithFrame:CGRectMake(0, 0, QYScreenW, QYScreenH)];
    self.adView.delegate = self;
    [self.window.rootViewController.view addSubview:self.adView];
    

    // 3.显示窗口
    [self.window makeKeyAndVisible];
    return YES;
}

#pragma mark -- QYADViewDelegate
- (void)dissmissADView
{
    sleep(0.5f);
    //2. 判断是否登录过   设置根控制器 合伙人、商户、登录页面
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString * logined = [defaults objectForKey:QYLogined];
    if (![logined isEqualToString:@"YES"]) {
        //1.未登录
        UINavigationController * loginNav = [[UINavigationController alloc] initWithRootViewController:[[QYLoginVC alloc] init]];
        self.window.rootViewController = loginNav;
    }else{
        //2.登录
        self.window.rootViewController = [[QYMainViewController alloc] init];
    }
 
}

