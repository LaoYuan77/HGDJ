#import <UIKit/UIKit.h>

// --- 模块一：隐藏福利并居中剧场 ---
%hook UITabBarController

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated {
    NSMutableArray *newControllers = [viewControllers mutableCopy];
    for (UIViewController *vc in viewControllers) {
        if ([vc.tabBarItem.title isEqualToString:@"福利"]) {
            [newControllers removeObject:vc];
            break;
        }
    }
    %orig([newControllers copy], animated);
}

%end

// --- 模块二：强制1080P ---
%hook TTVideoEngine

- (void)setVideoResolution:(NSUInteger)resolution {
    %orig(4); // 假设 4 是 1080P 的枚举值，需根据实际情况调整
}

- (NSUInteger)currentResolution {
    return 4;
}

- (void)configResolution:(NSString *)resString {
    %orig(@"1080p");
}

%end
