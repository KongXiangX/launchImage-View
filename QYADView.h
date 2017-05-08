//
//  QYADView.h
//  JingJieBusiness
//
//  Created by wangchengxin on 2017/1/6.
//  Copyright © 2017年 wangchengxin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  QYADViewDelegate<NSObject>
@required
/** 隐藏广告页面*/
- (void)dissmissADView;
@end

@interface QYADView : UIView
@property (nonatomic, weak) id<QYADViewDelegate> delegate;
@end
