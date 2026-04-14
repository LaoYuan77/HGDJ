#import <UIKit/UIKit.h>

// ==========================================
// 模块一：移除“福利”并自动重排版居中
// ==========================================
// 字节系App虽然有自定义的 SSTabBar，但其根视图控制器通常依然继承或使用了标准的 UITabBarController 机制
%hook UITabBarController

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated {
    NSMutableArray *newControllers = [viewControllers mutableCopy];
    
    for (UIViewController *vc in viewControllers) {
        // 通过判断 tabBarItem 的 title 来精准定位并移除“福利”页面
        if ([vc.tabBarItem.title isEqualToString:@"福利"]) {
            [newControllers removeObject:vc];
            break;
        }
    }
    
    // 移除后，iOS 系统自带的布局引擎会自动将剩下的 3 个 Tab（首页、剧场、我的）等宽居中对齐
    %orig([newControllers copy], animated);
}

%end


// ==========================================
// 模块二：基于 TTVideoEngine 强制高清晰度
// ==========================================
// 根据提取的头文件，已确认播放器核心为 TTVideoEngine
%hook TTVideoEngine

// 1. 拦截使用数字枚举配置分辨率的方法
// 在字节系的定义中，通常 0-Auto, 1-SD(标清), 2-HD(高清), 3-FHD(超清), 4-1080P, 5-4K
- (void)configResolution:(NSUInteger)resolution {
    // 强制把所有请求都篡改为 4 (1080P)
    %orig(4); 
}

// 2. 拦截使用字符串配置分辨率的方法（新版本可能倾向于用字符串）
- (void)configResolutionString:(NSString *)resString {
    // 强制使用 1080p 字符串
    %orig(@"1080p");
}

// 3. 欺骗上层业务逻辑，告诉它当前播放的就是 1080P
- (NSUInteger)currentResolution {
    return 4;
}

- (NSString *)currentResolutionString {
    return @"1080p";
}

%end
