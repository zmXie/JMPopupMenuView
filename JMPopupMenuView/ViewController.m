//
//  ViewController.m
//  JMPopupMenuView
//
//  Created by xzm on 2020/8/11.
//  Copyright © 2020 JMPopupMenuView. All rights reserved.
//

#import "ViewController.h"
#import "JMPopupMenuView.h"

@interface ViewController () <UITableViewDelegate,UITableViewDataSource>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];  
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 50;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView dequeueReusableCellWithIdentifier:@"cell"];
}

- (IBAction)buttonAction:(UIButton *)sender
{
    JMPopupMenuView *menuView = [JMPopupMenuView new];
    menuView.targetView = sender;
    if (sender.tag == 1) {
        menuView.backgroundColor = [UIColor.grayColor colorWithAlphaComponent:0.1];
        menuView.items = @[
            [JMMenuItem itemWithImage:[UIImage imageNamed:@"circleHome_icon_Appmanage"] title:@"德玛西亚" handler:^(JMMenuItem * _Nonnull item) {
                NSLog(@"%@",item.title);
            }],
            [JMMenuItem itemWithImage:[UIImage imageNamed:@"circleHome_icon_doctorsAndpatientsHome"] title:@"诺克萨斯" handler:^(JMMenuItem * _Nonnull item) {
                NSLog(@"%@",item.title);
            }],
            [JMMenuItem itemWithImage:[UIImage imageNamed:@"circleHome_icon_PayInfo"] title:@"黑色玫瑰" handler:^(JMMenuItem * _Nonnull item) {
                NSLog(@"%@",item.title);
            }]
        ];
    } else if (sender.tag == 2) {
        menuView.directionReverse = YES;
        menuView.maxmunWidth = 200;
        menuView.themeColor = [UIColor darkGrayColor];
        menuView.textFont = [UIFont systemFontOfSize:13];
        menuView.minmunItemHeight = 30;
        menuView.items = @[
            [JMMenuItem itemWithImage:nil title:@"弹出一个气泡，内容大小自适应，也可自定义宽高，会根据当前屏幕自动控制方向" handler:^(JMMenuItem * _Nonnull item) {
                NSLog(@"%@",item.title);
            }],
        ];
    } else {
        menuView.shouldShowSeparator = YES;
        menuView.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 15);
        menuView.items = @[
            [JMMenuItem itemWithImage:nil title:@"德玛西亚" handler:^(JMMenuItem * _Nonnull item) {
                NSLog(@"%@",item.title);
            }],
            [JMMenuItem itemWithImage:nil title:@"诺克萨斯" handler:^(JMMenuItem * _Nonnull item) {
                NSLog(@"%@",item.title);
            }],
            [JMMenuItem itemWithImage:nil title:@"黑色玫瑰" handler:^(JMMenuItem * _Nonnull item) {
                NSLog(@"%@",item.title);
            }]
        ];
    }
    [menuView showWithAnimated:YES];
}

@end
