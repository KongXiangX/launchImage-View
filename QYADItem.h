//
//  QYADItem.h
//  JingJieBusiness
//
//  Created by wangchengxin on 2017/1/6.
//  Copyright © 2017年 wangchengxin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
// w_picurl,ori_curl:跳转到广告界面,w,h

@interface QYADItem : NSObject

/** 广告地址 */
@property (nonatomic, strong) NSString *pic_src;
/** 点击广告跳转的界面 */
@property (nonatomic, strong) NSString *url;

@property (nonatomic, assign) CGFloat width;

@property (nonatomic, assign) CGFloat height;

@end
