#import <UIKit/UIKit.h>

// 欺骗编译器，声明这是视图
@interface BDXTabBar : UIView
@end
@interface BDXTabBarButton : UIControl
@end

// 声明全局变量存储“福利”按钮的尸体位置
static UIView *g_welfareButton = nil;

// ==========================================
// 模块一：文字级精准暗杀 (监听所有文本赋值)
// ==========================================
%hook UILabel

// 拦截普通文字赋值
- (void)setText:(NSString *)text {
    %orig(text);
    if ([text isEqualToString:@"福利"]) {
        UIView *view = self;
        // 向上层层扒皮，直到找到底栏按钮
        while (view.superview) {
            view = view.superview;
            if ([NSStringFromClass([view class]) isEqualToString:@"BDXTabBarButton"]) {
                g_welfareButton = view;      // 记录目标
                view.hidden = YES;           // 物理隐藏
                view.alpha = 0;              // 视觉隐身
                view.frame = CGRectZero;     // 捏碎体积
                
                // 强制要求它的父级（也就是整个底栏）立刻重新排版！
                if ([view.superview isKindOfClass:NSClassFromString(@"BDXTabBar")]) {
                    [view.superview setNeedsLayout];
                    [view.superview layoutIfNeeded];
                }
                break;
            }
        }
    }
}

// 拦截富文本赋值（防一手字节用富文本渲染）
- (void)setAttributedText:(NSAttributedString *)attributedText {
    %orig(attributedText);
    if ([attributedText.string isEqualToString:@"福利"]) {
        UIView *view = self;
        while (view.superview) {
            view = view.superview;
            if ([NSStringFromClass([view class]) isEqualToString:@"BDXTabBarButton"]) {
                g_welfareButton = view;
                view.hidden = YES;
                view.alpha = 0;
                view.frame = CGRectZero;
                
                if ([view.superview isKindOfClass:NSClassFromString(@"BDXTabBar")]) {
                    [view.superview setNeedsLayout];
                    [view.superview layoutIfNeeded];
                }
                break;
            }
        }
    }
}

%end


// ==========================================
// 模块二：打扫战场并强制居中
// ==========================================
%hook BDXTabBar

- (void)layoutSubviews {
    %orig; // 让字节自己的排版先跑完

    NSMutableArray *activeButtons = [NSMutableArray array];

    // 收集所有还活着的按钮
    for (UIView *subview in self.subviews) {
        if ([NSStringFromClass([subview class]) isEqualToString:@"BDXTabBarButton"]) {
            if (subview == g_welfareButton) {
                // 确保它死透了
                subview.hidden = YES;
                subview.frame = CGRectZero;
            } else {
                [activeButtons addObject:subview];
            }
        }
    }

    // 暴力重排：把剩下的按钮均匀铺满屏幕
    if (g_welfareButton && activeButtons.count > 0) {
        CGFloat totalWidth = self.bounds.size.width;
        CGFloat newWidth = totalWidth / activeButtons.count;

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
// 模块三：基于 TTVideoEngine 强制 1080P (稳定版)
// ==========================================
%hook TTVideoEngine

- (void)configResolution:(NSUInteger)resolution {
    %orig(4); 
}

- (void)configResolutionString:(NSString *)resString {
    %orig(@"1080p");
}

%end
