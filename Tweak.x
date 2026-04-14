#import <UIKit/UIKit.h>

// 声明真实存在的类，骗过编译器
@interface SSTabBar : UIView
@end
@interface SSTabBarTextButton : UIControl
@end

// 记录被击杀的按钮
static UIView *g_welfareButton = nil;

// ==========================================
// 模块一：针对 SSTabBar 的无损重排版
// ==========================================
%hook SSTabBar

- (void)layoutSubviews {
    // 1. 先让系统原本的排版（AutoLayout）全部跑完，绝不破坏系统底层逻辑
    %orig;
    
    NSMutableArray *activeButtons = [NSMutableArray array];
    
    // 2. 遍历底栏里的所有视图
    for (UIView *subview in self.subviews) {
        // 精准抓取从 dylib 里破译出来的核心类：SSTabBarTextButton
        if ([NSStringFromClass([subview class]) isEqualToString:@"SSTabBarTextButton"]) {
            
            BOOL isWelfare = NO;
            
            // 深度遍历寻找包含“福利”的 UILabel
            for (UIView *deepView in subview.subviews) {
                if ([deepView isKindOfClass:[UILabel class]] && [[(UILabel *)deepView text] isEqualToString:@"福利"]) {
                    isWelfare = YES; break;
                }
                for (UIView *deeperView in deepView.subviews) {
                    if ([deeperView isKindOfClass:[UILabel class]] && [[(UILabel *)deeperView text] isEqualToString:@"福利"]) {
                        isWelfare = YES; break;
                    }
                }
            }
            
            // 3. 发现目标，彻底抹除
            if (isWelfare) {
                g_welfareButton = subview;
                subview.hidden = YES;
                subview.alpha = 0;
                subview.userInteractionEnabled = NO; // 禁止它接收任何点击
                // 把宽度强行捏成 0
                CGRect zeroFrame = subview.frame;
                zeroFrame.size.width = 0;
                subview.frame = zeroFrame;
            } else {
                // 把存活的正常按钮收集起来
                if (!subview.hidden && subview.frame.size.width > 0) {
                    [activeButtons addObject:subview];
                }
            }
        }
    }
    
    // 4. 核心修复：完美瓜分屏幕宽度
    // 如果福利按钮被删了，且剩下的按钮总数少于4个，立刻重新分配领地
    if (g_welfareButton && activeButtons.count > 0 && activeButtons.count < 4) {
        // 获取整个底栏的物理宽度
        CGFloat screenWidth = self.bounds.size.width;
        // 计算剩下的按钮一人该分多宽
        CGFloat newWidth = screenWidth / activeButtons.count;
        
        for (NSInteger i = 0; i < activeButtons.count; i++) {
            UIView *btn = activeButtons[i];
            CGRect frame = btn.frame;
            // 重新分配 X 坐标和宽度，高度和 Y 轴保持原样不变！
            frame.origin.x = i * newWidth;
            frame.size.width = newWidth;
            btn.frame = frame;
        }
    }
}

%end

// ==========================================
// 模块二：基于 TTVideoEngine 强制 1080P (稳定版)
// ==========================================
%hook TTVideoEngine

- (void)configResolution:(NSUInteger)resolution {
    %orig(4); 
}

- (void)configResolutionString:(NSString *)resString {
    %orig(@"1080p");
}

%end
