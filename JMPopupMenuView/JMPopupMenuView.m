//
//  JMPopupMenuView.m
//  JMPopupMenuView
//
//  Created by xzm on 2020/8/11.
//  Copyright © 2020 JMPopupMenuView. All rights reserved.
//

#import "JMPopupMenuView.h"

#define ScreenW UIScreen.mainScreen.bounds.size.width
#define ScreenH UIScreen.mainScreen.bounds.size.height
#define H(v) CGRectGetHeight(v.frame)
#define W(v) CGRectGetWidth(v.frame)
#define L(v) CGRectGetMinX(v.frame)
#define R(v) CGRectGetMaxX(v.frame)
#define T(v) CGRectGetMinY(v.frame)
#define B(v) CGRectGetMaxY(v.frame)
#define EdgeInsetsGetHorizontalValue(insets) insets.left + insets.right
#define EdgeInsetsGetVerticalValue(insets) insets.top + insets.bottom

#pragma mark - 扩展
@interface JMPopupContainerVC : UIViewController

@property (nonatomic, copy) dispatch_block_t touchBeginCallBack;

- (void)dismiss;

@end


@interface JMMenuItem ()

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *separator;

- (void)updateWithMenuView:(JMPopupMenuView *)menuView;
- (void)hideSeparator;

@end


@interface JMPopupMenuView ()

/// 目标视图基于window的rect
@property (nonatomic, assign) CGRect targetRect;
/// 内容视图
@property (nonatomic, strong) UIView *contentView;
/// 滑动视图
@property (nonatomic, strong) UIScrollView *scrollView;
/// 背景图层
@property (nonatomic, strong) CAShapeLayer *backgroundLayer;
/// 容器VC
@property (nonatomic,  weak) JMPopupContainerVC *containerVC;
/// 箭头距离目标边缘的距离
@property (nonatomic, assign) CGFloat distanceBetweenTarget;
/// 阴影颜色
@property (nonatomic, strong) UIColor *shadowColor;
/// 边框宽度
@property (nonatomic, assign) CGFloat borderWidth;

@end


#pragma mark - 实现
@implementation JMPopupContainerVC

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.view.subviews.firstObject.frame = self.view.bounds;
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    !_touchBeginCallBack ? : _touchBeginCallBack();
}

@end


@implementation JMPopupMenuView

#pragma mark - life circle
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.themeColor = UIColor.blackColor;
        self.contentEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
        self.safetyMarginsInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        self.maxmunWidth = ScreenW - self.safetyMarginsInsets.left - self.safetyMarginsInsets.right;
        self.maxmunHeight = ScreenH - self.safetyMarginsInsets.top - self.safetyMarginsInsets.bottom;
        self.minmunItemHeight = 44;
        self.textFont = [UIFont systemFontOfSize:16];
        self.distanceBetweenTarget = 5;
        self.arrowSize = CGSizeMake(16, 8);
        self.borderWidth = 1.f / UIScreen.mainScreen.scale;
        self.borderColor = [UIColor colorWithRed:198 / 255.0 green:198 / 255.0 blue:198 / 255.0 alpha:1];
        self.shadowColor = [UIColor colorWithRed:0 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.1];
        self.cornerRadius = 8;
        self.contentView.layer.cornerRadius = self.cornerRadius;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    //内容高度
    CGFloat contentHeight = MIN(self.maxmunHeight, self.scrollView.contentSize.height + self.contentEdgeInsets.top + self.contentEdgeInsets.bottom + self.arrowSize.height + self.borderWidth * 2);
    //内容宽度
    CGFloat contentWidth = self.scrollView.contentSize.width + self.contentEdgeInsets.left + self.contentEdgeInsets.right + self.borderWidth * 2;
    //方向是否朝下
    BOOL isBelow;
    if (CGRectGetMaxY(self.targetRect) + contentHeight + self.distanceBetweenTarget + self.arrowSize.height > ScreenH) {
        isBelow = NO;
    } else if (CGRectGetMinY(self.targetRect) - contentHeight - self.distanceBetweenTarget - self.arrowSize.height < self.getStatusBarHight) {
        isBelow = YES;
    } else {
        isBelow = !self.directionReverse;
    }
    //内容x坐标
    CGFloat contentX = CGRectGetMidX(self.targetRect) - contentWidth / 2.f;
    contentX = MAX(self.safetyMarginsInsets.left, contentX);
    contentX = MIN(ScreenW - self.safetyMarginsInsets.right - contentWidth, contentX);
    //内容y坐标
    CGFloat contentY = isBelow ? CGRectGetMaxY(self.targetRect) + self.distanceBetweenTarget : CGRectGetMinY(self.targetRect) - self.distanceBetweenTarget - contentHeight;
    self.contentView.frame = CGRectMake(contentX, contentY, contentWidth, contentHeight);

    //滑动菜单x坐标
    CGFloat scrollX = self.contentEdgeInsets.left + self.borderWidth;
    //滑动菜单y坐标
    CGFloat scrollY = self.contentEdgeInsets.top + (isBelow ? self.arrowSize.height : 0) + self.borderWidth;
    //滑动菜单宽度
    CGFloat scrollW = self.scrollView.contentSize.width;
    //滑动菜单高度
    CGFloat scrollH = contentHeight - self.arrowSize.height - self.contentEdgeInsets.top - self.contentEdgeInsets.bottom - self.borderWidth * 2;
    self.scrollView.frame = CGRectMake(scrollX, scrollY, scrollW, scrollH);

    //菜单item
    __block CGFloat itemY = 0;
    [_items enumerateObjectsUsingBlock:^(JMMenuItem *_Nonnull item, NSUInteger idx, BOOL *_Nonnull stop) {
        item.frame = CGRectMake(0, itemY, scrollW, MAX(self.minmunItemHeight, H(item)));
        itemY = B(item);
    }];

    //气泡相关
    CGRect roundedRect = CGRectMake(self.borderWidth / 2.f, (isBelow ? self.arrowSize.height : 0) + self.borderWidth / 2.f, contentWidth - self.borderWidth, contentHeight - self.borderWidth - self.arrowSize.height);
    CGPoint arrowPoint = CGPointMake(CGRectGetMidX(self.targetRect) - contentX - self.arrowSize.width / 2.f, isBelow ? self.borderWidth / 2.f : contentHeight - self.borderWidth / 2.f);
    CGFloat cornerRadius = self.cornerRadius;
    CGPoint leftTopArcCenter = CGPointMake(CGRectGetMinX(roundedRect) + cornerRadius, CGRectGetMinY(roundedRect) + cornerRadius);
    CGPoint leftBottomArcCenter = CGPointMake(leftTopArcCenter.x, CGRectGetMaxY(roundedRect) - cornerRadius);
    CGPoint rightTopArcCenter = CGPointMake(CGRectGetMaxX(roundedRect) - cornerRadius, leftTopArcCenter.y);
    CGPoint rightBottomArcCenter = CGPointMake(rightTopArcCenter.x, leftBottomArcCenter.y);
    //绘制气泡，从左上角顺时针绘制
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(CGRectGetMinX(roundedRect), leftTopArcCenter.y)];
    [path addArcWithCenter:leftTopArcCenter radius:cornerRadius startAngle:M_PI endAngle:M_PI * 1.5 clockwise:YES];
    if (isBelow) {
        //绘制向上箭头
        [path addLineToPoint:CGPointMake(arrowPoint.x, CGRectGetMinY(roundedRect))];
        [path addLineToPoint:CGPointMake(arrowPoint.x + self.arrowSize.width / 2.f, arrowPoint.y)];
        [path addLineToPoint:CGPointMake(arrowPoint.x + self.arrowSize.width, CGRectGetMinY(roundedRect))];
    }
    [path addLineToPoint:CGPointMake(rightTopArcCenter.x, CGRectGetMinY(roundedRect))];
    [path addArcWithCenter:rightTopArcCenter radius:cornerRadius startAngle:M_PI * 1.5 endAngle:M_PI * 2 clockwise:YES];
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(roundedRect), rightBottomArcCenter.y)];
    [path addArcWithCenter:rightBottomArcCenter radius:cornerRadius startAngle:0 endAngle:M_PI_2 clockwise:YES];
    if (!isBelow) {
        //绘制向下箭头
        [path addLineToPoint:CGPointMake(arrowPoint.x + self.arrowSize.width, CGRectGetMaxY(roundedRect))];
        [path addLineToPoint:CGPointMake(arrowPoint.x + self.arrowSize.width / 2.f, arrowPoint.y)];
        [path addLineToPoint:CGPointMake(arrowPoint.x, CGRectGetMaxY(roundedRect))];
    }
    [path addLineToPoint:CGPointMake(leftBottomArcCenter.x, CGRectGetMaxY(roundedRect))];
    [path addArcWithCenter:leftBottomArcCenter radius:cornerRadius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    [path closePath];
    self.backgroundLayer.path = path.CGPath;
    self.backgroundLayer.shadowPath = path.CGPath;
    self.backgroundLayer.frame = self.contentView.frame;
}

#pragma mark - publish
- (void)showWithAnimated:(BOOL)animated
{
    JMPopupContainerVC *vc = [JMPopupContainerVC new];
    vc.touchBeginCallBack = ^{
        [self hideWithAnimated:YES];
    };
    self.containerVC = vc;
    [vc.view addSubview:self];
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext | UIModalPresentationFullScreen;
    [self.keyWindow.rootViewController presentViewController:vc animated:NO completion:^{
        if (animated) {
            self.alpha = 0;
            self.contentView.layer.transform = CATransform3DMakeScale(0.98, 0.98, 1);
            [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.3 initialSpringVelocity:12 options:UIViewAnimationOptionCurveLinear animations:^{
                self.contentView.layer.transform = CATransform3DMakeScale(1, 1, 1);
            } completion:nil];
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                self.alpha = 1;
            } completion:nil];
        } else {
            self.alpha = 1;
        }
    }];
}

- (void)hideWithAnimated:(BOOL)animated
{
    [UIView animateWithDuration:animated ? 0.2 : 0 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self.containerVC dismiss];
    }];
}

#pragma mark - setter
- (void)setTargetView:(UIView *)targetView
{
    _targetView = targetView;
    self.targetRect = [targetView.superview convertRect:targetView.frame toView:nil];
}

- (void)setItems:(NSArray<JMMenuItem *> *)items
{
    _items = items;
    __block CGFloat w = 0;
    __block CGFloat h = 0;
    [items enumerateObjectsUsingBlock:^(JMMenuItem *_Nonnull item, NSUInteger idx, BOOL *_Nonnull stop) {
        [item updateWithMenuView:self];
        CGSize maxContentSize = CGSizeMake(self.maxmunWidth - self.contentEdgeInsets.left - self.contentEdgeInsets.right - self.borderWidth * 2, self.maxmunHeight - self.arrowSize.height - self.contentEdgeInsets.top - self.contentEdgeInsets.bottom - self.borderWidth * 2);
        CGSize itemSize = [item sizeThatFits:maxContentSize];
        w = MAX(itemSize.width, w);
        h += MAX(itemSize.height, self.minmunItemHeight);
        [self.scrollView addSubview:item];
        if (idx == items.count - 1) {
            [item hideSeparator];
        }
    }];
    self.scrollView.contentSize = CGSizeMake(w, h);
}

- (void)setShadowColor:(UIColor *)shadowColor
{
    _shadowColor = shadowColor;
    self.backgroundLayer.shadowColor = shadowColor.CGColor;
    if (shadowColor) {
        _backgroundLayer.shadowOffset = CGSizeMake(0, 2);
        _backgroundLayer.shadowOpacity = 1;
        _backgroundLayer.shadowRadius = 10;
    } else {
        _backgroundLayer.shadowOpacity = 0;
    }
}

- (void)setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor;
    self.backgroundLayer.strokeColor = borderColor.CGColor;
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    _borderWidth = borderWidth;
    self.backgroundLayer.lineWidth = _borderWidth;
}

#pragma mark - getter
- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [UIView new];
        _contentView.clipsToBounds = YES;
        [self addSubview:_contentView];
    }
    return _contentView;
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [UIScrollView new];
        [self.contentView addSubview:_scrollView];
    }
    return _scrollView;
}

- (CAShapeLayer *)backgroundLayer
{
    if (!_backgroundLayer) {
        _backgroundLayer = [CAShapeLayer layer];
        _backgroundLayer.fillColor = UIColor.whiteColor.CGColor;
        [self.layer insertSublayer:_backgroundLayer atIndex:0];
    }
    return _backgroundLayer;
}

- (UIWindow *)keyWindow
{
    UIWindow *window = nil;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *windowScene in [UIApplication sharedApplication].connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                window = windowScene.windows.firstObject;
                break;
            }
        }
    } else {
       #pragma clang diagnostic push
       #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        window = [UIApplication sharedApplication].keyWindow;
       #pragma clang diagnostic pop
    }
    return window;
}

- (CGFloat)getStatusBarHight
{
    float statusBarHeight = 0;
    if (@available(iOS 13.0, *)) {
        UIStatusBarManager *statusBarManager = [UIApplication sharedApplication].windows.firstObject.windowScene.statusBarManager;
        statusBarHeight = statusBarManager.statusBarFrame.size.height;
    } else {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        #pragma clang diagnostic pop
    }
    return statusBarHeight;
}

@end


@implementation JMMenuItem

/// 快速构建
/// @param image 图片
/// @param title 标题
/// @param handler 点击事件回调
+ (instancetype)itemWithImage:(nullable UIImage *)image title:(nullable NSString *)title handler:(nullable void (^)(JMMenuItem *item))handler
{
    JMMenuItem *item = [JMMenuItem new];
    item.image = image;
    item.title = title;
    item.handler = handler;
    [item setupUI];
    return item;
}

- (void)setupUI
{
    self.edgeInsets = UIEdgeInsetsZero;
    _imgView = [[UIImageView alloc]initWithImage:self.image];
    [_imgView sizeToFit];
    [self addSubview:_imgView];

    _titleLabel = [UILabel new];
    _titleLabel.text = self.title;
    _titleLabel.font = [UIFont systemFontOfSize:16];
    _titleLabel.numberOfLines = 0;
    [self addSubview:_titleLabel];

    _separator = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 1.f / UIScreen.mainScreen.scale)];
    _separator.backgroundColor = [UIColor colorWithRed:222 / 255.0 green:224 / 255.0 blue:226 / 255.0 alpha:1];
    _separator.hidden = YES;
    [self addSubview:_separator];
}

- (CGFloat)safeImageTitleSpace
{
    return self.image ? 6 : 0;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize imgSize = [_imgView sizeThatFits:size];
    CGFloat exceptTextW = imgSize.width + self.safeImageTitleSpace + EdgeInsetsGetHorizontalValue(self.edgeInsets);
    CGSize textSize = [_titleLabel sizeThatFits:CGSizeMake(size.width - exceptTextW, size.height - EdgeInsetsGetVerticalValue(self.edgeInsets))];
    CGFloat w = textSize.width + exceptTextW;
    CGFloat h = MAX(imgSize.height, textSize.height) + EdgeInsetsGetVerticalValue(self.edgeInsets);
    self.titleLabel.bounds = CGRectMake(0, 0, textSize.width, textSize.height);
    self.bounds = CGRectMake(0, 0, w, h);
    return CGSizeMake(w, h);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imgView.frame = CGRectMake(self.edgeInsets.left, (H(self) - H(_imgView)) / 2.f, W(_imgView), H(_imgView));
    self.titleLabel.frame = CGRectMake(W(self) - W(_titleLabel) - self.edgeInsets.right, (H(self) - H(_titleLabel)) / 2.f, W(_titleLabel), H(_titleLabel));
    self.separator.frame = CGRectMake(self.edgeInsets.left, H(self) - H(_separator), W(self) - EdgeInsetsGetHorizontalValue(self.edgeInsets), H(_separator));
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.alpha = 0.5;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    self.alpha = 1;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.18 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.alpha = 1;
    });
    UIResponder *responder = self.nextResponder;
    while (![responder isKindOfClass:JMPopupMenuView.class])
        responder = responder.nextResponder;
    if ([responder isKindOfClass:JMPopupMenuView.class]) {
        [(JMPopupMenuView *)responder hideWithAnimated:YES];
    }
    !_handler ? : _handler(self);
}

- (void)updateWithMenuView:(JMPopupMenuView *)menuView
{
    _titleLabel.textColor = menuView.themeColor;
    _titleLabel.font = menuView.textFont;
    _separator.hidden = !menuView.shouldShowSeparator;
}

- (void)hideSeparator
{
    _separator.hidden = YES;
}

@end
