#import <UIKit/UIKit.h>

// 欺骗编译器，声明 BDXTabBar 是一个 UIView，使其能够合法调用 bounds 和 subviews
@interface BDXTabBar : UIView
@end

// ==========================================
// 模块一：UI 视觉层暴力强杀底栏“福利”并强制居中
// ==========================================
%hook BDXTabBar

- (void)layoutSubviews {
    // 1. 先让系统原本的排版逻辑跑完
    %orig; 
    
    NSMutableArray *validButtons = [NSMutableArray array];
    UIView *welfareButton = nil;
    
    // 2. 遍历整个底栏里的所有组件
    for (UIView *subview in self.subviews) {
        NSString *className = NSStringFromClass([subview class]);
        if ([className containsString:@"Button"] || [className containsString:@"Item"]) {
            
            BOOL isWelfare = NO;
            
            // 3. 像剥洋葱一样寻找“福利”标签
            for (UIView *deepView in subview.subviews) {
                if ([deepView isKindOfClass:[UILabel class]]) {
                    if ([[(UILabel *)deepView text] isEqualToString:@"福利"]) {
                        isWelfare = YES; break;
                    }
                }
                for (UIView *deeperView in deepView.subviews) {
                    if ([deeperView isKindOfClass:[UILabel class]]) {
                        if ([[(UILabel *)deeperView text] isEqualToString:@"福利"]) {
                            isWelfare = YES; break;
                        }
                    }
                }
            }
            
            // 4. 判断并分类
            if (isWelfare) {
                welfareButton = subview;
                subview.hidden = YES;          // 强行隐藏
                subview.frame = CGRectZero;    // 体积缩成0
            } else {
                [validButtons addObject:subview];
            }
        }
    }
    
    // 5. 暴力重排：把剩下的按钮均匀铺满屏幕
    if (welfareButton && validButtons.count > 0) {
        CGFloat totalWidth = self.bounds.size.width;
        CGFloat newButtonWidth = totalWidth / validButtons.count;
        
        for (NSInteger i = 0; i < validButtons.count; i++) {
            UIView *btn = validButtons[i];
            CGRect frame = btn.frame;
            frame.origin.x = i * newButtonWidth;
            frame.size.width = newButtonWidth;
            btn.frame = frame;
        }
    }
}

%end


// ==========================================
// 模块二：基于 TTVideoEngine 强制 1080P
// ==========================================
%hook TTVideoEngine

- (void)configResolution:(NSUInteger)resolution {
    %orig(4); 
}

- (void)configResolutionString:(NSString *)resString {
    %orig(@"1080p");
}

%end
