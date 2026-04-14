#import <UIKit/UIKit.h>

@interface BDXTabBar : UIView
@end
@interface BDXTabBarButton : UIView
@end

// ==========================================
// 模块一：针对 BDXTabBarButton 的直接扑杀
// ==========================================
%hook BDXTabBarButton

// layoutSubviews 是它每次在屏幕上绘制自己时必走的方法
- (void)layoutSubviews {
    %orig;
    
    // 每次重绘，都像安检一样查自己肚子里有没有“福利”
    BOOL isWelfare = NO;
    for (UIView *v in self.subviews) {
        if ([v isKindOfClass:[UILabel class]] && [[(UILabel *)v text] isEqualToString:@"福利"]) {
            isWelfare = YES; break;
        }
        // 往下深挖一层
        for (UIView *subV in v.subviews) {
            if ([subV isKindOfClass:[UILabel class]] && [[(UILabel *)subV text] isEqualToString:@"福利"]) {
                isWelfare = YES; break;
            }
        }
    }
    
    // 查出是福利按钮，当场自杀
    if (isWelfare) {
        self.hidden = YES;
        self.alpha = 0;
        // 关键：把宽度设为 0，防止它隐身了还占着茅坑
        CGRect frame = self.frame;
        frame.size.width = 0;
        self.frame = frame;
    }
}

%end

// ==========================================
// 模块二：打扫战场，强制存活的按钮瓜分地盘
// ==========================================
%hook BDXTabBar

- (void)layoutSubviews {
    %orig; // 让字节的烂摊子排版先跑完
    
    NSMutableArray *activeButtons = [NSMutableArray array];
    
    // 把没隐藏的、存活的按钮挑出来
    for (UIView *subview in self.subviews) {
        if ([NSStringFromClass([subview class]) isEqualToString:@"BDXTabBarButton"]) {
            if (!subview.hidden && subview.frame.size.width > 0) {
                [activeButtons addObject:subview];
            }
        }
    }
    
    // 重新瓜分屏幕宽度 (如果有存活按钮，且总数小于4，说明福利被干掉了)
    if (activeButtons.count > 0 && activeButtons.count < 4) {
        CGFloat newWidth = self.bounds.size.width / activeButtons.count;
        for (NSInteger i = 0; i < activeButtons.count; i++) {
            UIView *btn = activeButtons[i];
            CGRect frame = btn.frame;
            frame.origin.x = i * newWidth;
            frame.size.width = newWidth;
            btn.frame = frame;
        }
    }
}

%end

// ==========================================
// 模块三：基于 TTVideoEngine 强制 1080P (保持稳定)
// ==========================================
%hook TTVideoEngine

- (void)configResolution:(NSUInteger)resolution {
    %orig(4); 
}

- (void)configResolutionString:(NSString *)resString {
    %orig(@"1080p");
}

%end
