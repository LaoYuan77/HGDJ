#import <UIKit/UIKit.h>

// 欺骗编译器，声明真实的底层类
@interface SSTabBar : UIView
@end

// ==========================================
// 终极模块一：基于 SSTabBar 的无损完美重排
// ==========================================
%hook SSTabBar

- (void)layoutSubviews {
    // 1. 让系统按原样把 4 个按钮画完（绝不破坏系统底层逻辑，防闪退）
    %orig;
    
    NSMutableArray *keepButtons = [NSMutableArray array];
    UIView *welfareBtn = nil;
    
    // 2. 精准点名：遍历寻找名为 SSTabBarTextButton 的按钮
    for (UIView *subview in self.subviews) {
        NSString *className = NSStringFromClass([subview class]);
        if ([className containsString:@"TabBarTextButton"] || 
            [className containsString:@"TabBarButton"]) {
            
            BOOL isWelfare = NO;
            
            // 核心突破：直接读取从 dylib 中破译出的 tabLabel 属性
            if ([subview respondsToSelector:NSSelectorFromString(@"tabLabel")]) {
                UILabel *lbl = [subview valueForKey:@"tabLabel"];
                if ([lbl.text containsString:@"福利"]) {
                    isWelfare = YES;
                }
            }
            
            // 兜底方案：暴力扒皮寻找文字
            if (!isWelfare) {
                for (UIView *v in subview.subviews) {
                    if ([v isKindOfClass:[UILabel class]] && [[(UILabel*)v text] containsString:@"福利"]) {
                        isWelfare = YES;
                    }
                    for (UIView *v2 in v.subviews) {
                        if ([v2 isKindOfClass:[UILabel class]] && [[(UILabel*)v2 text] containsString:@"福利"]) {
                            isWelfare = YES;
                        }
                    }
                }
            }
            
            // 分类
            if (isWelfare) {
                welfareBtn = subview;
            } else {
                [keepButtons addObject:subview];
            }
        }
    }
    
    // 3. 封杀“福利”按钮（只隐藏，不删数组，彻底杜绝闪退 bug）
    if (welfareBtn) {
        welfareBtn.hidden = YES;
        welfareBtn.alpha = 0;
        welfareBtn.userInteractionEnabled = NO; // 物理断绝点击可能
    }
    
    // 4. 完美瓜分地盘：让剩下的 3 个按钮均匀铺满屏幕
    if (welfareBtn && keepButtons.count > 0 && keepButtons.count <= 3) {
        CGFloat screenWidth = self.bounds.size.width;
        CGFloat newWidth = screenWidth / keepButtons.count;
        CGFloat height = self.bounds.size.height;
        
        for (int i = 0; i < keepButtons.count; i++) {
            UIView *btn = keepButtons[i];
            
            // 核心神技：解除 AutoLayout 的束缚，允许我们越权强写坐标
            btn.translatesAutoresizingMaskIntoConstraints = YES;
            
            // 赋予完美等分的新坐标（高度不变，仅拉宽并重新排队）
            btn.frame = CGRectMake(i * newWidth, 0, newWidth, height);
        }
    }
}

%end


// ==========================================
// 模块二：基于 TTVideoEngine 强制 1080P (稳定服役中)
// ==========================================
%hook TTVideoEngine

- (void)configResolution:(NSUInteger)resolution {
    %orig(4); 
}

- (void)configResolutionString:(NSString *)resString {
    %orig(@"1080p");
}

%end
