#import <UIKit/UIKit.h>

// ==========================================
// 模块一：移除“福利”并自动重排版居中 (增强拦截版)
// ==========================================

%hook UITabBarController

// 拦截入口 1：带动画的 Controller 赋值
- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated {
    NSMutableArray *newControllers = [NSMutableArray array];
    for (UIViewController *vc in viewControllers) {
        // 同时判断 title 和 tabBarItem.title，防止漏网
        if (![vc.tabBarItem.title isEqualToString:@"福利"] && ![vc.title isEqualToString:@"福利"]) {
            [newControllers addObject:vc];
        }
    }
    %orig([newControllers copy], animated);
}

// 拦截入口 2：不带动画的 Controller 赋值（大多 App 初始化走这里）
- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers {
    NSMutableArray *newControllers = [NSMutableArray array];
    for (UIViewController *vc in viewControllers) {
        if (![vc.tabBarItem.title isEqualToString:@"福利"] && ![vc.title isEqualToString:@"福利"]) {
            [newControllers addObject:vc];
        }
    }
    %orig([newControllers copy]);
}

%end

// 拦截入口 3：直接操作 UITabBar Item 的底层赋值 (针对字节系的部分自定义情况)
%hook UITabBar

- (void)setItems:(NSArray<UITabBarItem *> *)items animated:(BOOL)animated {
    NSMutableArray *newItems = [NSMutableArray array];
    for (UITabBarItem *item in items) {
        if (![item.title isEqualToString:@"福利"]) {
            [newItems addObject:item];
        }
    }
    %orig([newItems copy], animated);
}

- (void)setItems:(NSArray<UITabBarItem *> *)items {
    NSMutableArray *newItems = [NSMutableArray array];
    for (UITabBarItem *item in items) {
        if (![item.title isEqualToString:@"福利"]) {
            [newItems addObject:item];
        }
    }
    %orig([newItems copy]);
}

%end


// ==========================================
// 模块二：基于 TTVideoEngine 强制高清晰度 (UI 修复版)
// ==========================================
%hook TTVideoEngine

// 只拦截写入操作，强制底层引擎走 1080P
- (void)configResolution:(NSUInteger)resolution {
    %orig(4); 
}

- (void)configResolutionString:(NSString *)resString {
    // 强制把内部请求的字符串改为 1080p
    %orig(@"1080p");
}

// 【关键修复】：已删除了对 currentResolution 等读取方法的拦截。
// UI 读取到的依然是正常的内部状态，所以文字会恢复显示。
// 但实际播放时，底层的数据流已经被上面的 config 方法劫持了。

%end
