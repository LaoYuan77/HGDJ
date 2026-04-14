#import <UIKit/UIKit.h>

// ==========================================
// 辅助函数：通用的“福利”过滤机制
// 兼顾 ViewController 和 自定义 Item 模型
// ==========================================
static NSArray* filterWelfare(NSArray *items) {
    if (!items || items.count == 0) return items;
    
    NSMutableArray *newItems = [NSMutableArray array];
    for (id item in items) {
        NSString *title = @"";
        // 如果数组里装的是 UIViewController
        if ([item respondsToSelector:@selector(tabBarItem)]) {
            title = [[item tabBarItem] title];
        } 
        // 兜底：如果数组里装的是某种直接带有 title 属性的自定义配置模型
        if (!title && [item respondsToSelector:@selector(title)]) {
            title = [item title];
        }
        
        // 只要标题不是“福利”，就放行
        if (![title isEqualToString:@"福利"]) {
            [newItems addObject:item];
        }
    }
    return [newItems copy];
}

// ==========================================
// 模块一：精准狙击字节自定义底栏大管家
// ==========================================
%hook BDXTabBarController

// 拦截初始化和赋值方法
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
