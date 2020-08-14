//
//  JMPopupMenuView.h
//  PopViewDemo
//
//  Created by xzm on 2020/8/11.
//  Copyright © 2020 PopViewDemo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class JMMenuItem;

@interface JMPopupMenuView : UIView

/// 设置目标视图，基于该视图弹出
@property (nonatomic,  weak) UIView *targetView;

/// 设置多个ButtonItem
@property (nonatomic,strong) NSArray <JMMenuItem *>*items;

/// 主题色，默认黑色
@property (nonatomic,strong) UIColor *themeColor;

/// 内容边缘距离 ，默认 (8, 8, 8, 8)
@property (nonatomic,assign) UIEdgeInsets contentEdgeInsets;

/// 外边缘距离，默认(10, 10, 10, 10)
@property(nonatomic, assign) UIEdgeInsets safetyMarginsInsets;

/// 三角箭头的大小，默认 CGSizeMake(16, 8)
@property(nonatomic, assign) CGSize arrowSize;

/// 最大宽度，默认是屏幕宽度
@property (nonatomic,assign) CGFloat maxmunWidth;

/// 最大高度，默认是屏幕高度
@property (nonatomic,assign) CGFloat maxmunHeight;

/// 每个item最小高度，默认为44
@property (nonatomic,assign) CGFloat minmunItemHeight;

/// 显示分割线，默认为NO
@property(nonatomic, assign) BOOL shouldShowSeparator;

/// 边框颜色，默认（198，198，198）
@property (nonatomic, strong) UIColor *borderColor;

/// 文本字体，默认 16常规
@property (nonatomic,strong) UIFont *textFont;

/// 圆角，默认8
@property(nonatomic, assign) CGFloat cornerRadius;

/// 反方向，默认为NO
@property (nonatomic,assign) BOOL directionReverse;

- (void)showWithAnimated:(BOOL)animated;
- (void)hideWithAnimated:(BOOL)animated;

@end


@interface JMMenuItem : UIView

@property (nonatomic,strong) UIImage  *image;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,assign) UIEdgeInsets edgeInsets;
@property (nonatomic,  copy) void (^handler)(JMMenuItem *item);

/// 快速构建
/// @param image 图片
/// @param title 标题
/// @param handler 点击事件回调
+ (instancetype)itemWithImage:(nullable UIImage *)image title:(nullable NSString *)title handler:(nullable void(^)(JMMenuItem *item))handler;

@end

NS_ASSUME_NONNULL_END
