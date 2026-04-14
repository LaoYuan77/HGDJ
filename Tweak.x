#import <UIKit/UIKit.h>

// ==========================================
// 辅助函数：精准过滤“福利”页面
// ==========================================
static NSArray* filterWelfare(NSArray *viewControllers) {
    if (!viewControllers || viewControllers.count == 0) return viewControllers;
    
    NSMutableArray *newControllers = [NSMutableArray array];
    for (UIViewController *vc in viewControllers) {
        // 尝试获取各种可能存在的标题
        NSString *title = vc.tabBarItem.title;
        if (!title) {
            title = vc.title;
        }
        
        // 只要标题不是“福利”，就保留
        if (![title isEqualToString:@"福利"]) {
            [newControllers addObject:vc];
        }
    }
    return [newControllers copy];
}

// ==========================================
// 模块一：精准狙击红果的真实底层大管家
// ==========================================
%hook HGMainTabBarController

// 拦截初始化和赋值方法，在这个源头把包含“福利”的控制器剔除
- (void)setViewControllers:(NSArray *)viewControllers {
    %orig(filterWelfare(viewControllers));
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
    %orig(filterWelfare(viewControllers), animated);
}

%end

// ==========================================
// 模块二：基于 TTVideoEngine 强制高清晰度 
// (已测试成功，保持原样)
// ==========================================
%hook TTVideoEngine

- (void)configResolution:(NSUInteger)resolution {
    %orig(4); 
}

- (void)configResolutionString:(NSString *)resString {
    %orig(@"1080p");
}

%end
