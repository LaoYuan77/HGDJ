#import <UIKit/UIKit.h>

// ==========================================
// 模块一：UI 视觉层暴力强杀底栏“福利”并强制居中
// ==========================================
%hook BDXTabBar

// layoutSubviews 是 iOS 渲染 UI 时的核心方法，每次界面刷新都会走这里
- (void)layoutSubviews {
    // 1. 先让系统原本的排版逻辑跑完（此时4个按钮都被画出来了）
    %orig; 
    
    NSMutableArray *validButtons = [NSMutableArray array];
    UIView *welfareButton = nil;
    
    // 2. 遍历整个底栏里的所有组件
    for (UIView *subview in self.subviews) {
        // 抓取类名，找出类似于 BDXTabBarButton 的按钮组件
        NSString *className = NSStringFromClass([subview class]);
        if ([className containsString:@"Button"] || [className containsString:@"Item"]) {
            
            BOOL isWelfare = NO;
            
            // 3. 像剥洋葱一样，在按钮内部寻找那个写着“福利”的 UILabel
            for (UIView *deepView in subview.subviews) {
                if ([deepView isKindOfClass:[UILabel class]]) {
                    if ([[(UILabel *)deepView text] isEqualToString:@"福利"]) {
                        isWelfare = YES; break;
                    }
                }
                // 字节的组件嵌套往往比较深，再往下剥一层
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
                subview.hidden = YES;          // 核心：强行隐藏
                subview.frame = CGRectZero;    // 核心：把体积缩成0，彻底抹除存在感
            } else {
                [validButtons addObject:subview]; // 把正常按钮收集起来
            }
        }
    }
    
    // 5. 暴力重排：如果成功干掉了“福利”，就把剩下的按钮均匀铺满屏幕
    if (welfareButton && validButtons.count > 0) {
        // 获取屏幕底栏的总宽度
        CGFloat totalWidth = self.bounds.size.width;
        // 计算剩下按钮应该有多宽（总宽 ÷ 剩下的个数）
        CGFloat newButtonWidth = totalWidth / validButtons.count;
        
        for (NSInteger i = 0; i < validButtons.count; i++) {
            UIView *btn = validButtons[i];
            CGRect frame = btn.frame;
            // 重新分配坐标：第0个在最左边，第1个在中间...
            frame.origin.x = i * newButtonWidth;
            frame.size.width = newButtonWidth;
            btn.frame = frame; // 强行写入新坐标
        }
    }
}

%end


// ==========================================
// 模块二：基于 TTVideoEngine 强制 1080P 
// (已测试成功，稳定运行)
// ==========================================
%hook TTVideoEngine

- (void)configResolution:(NSUInteger)resolution {
    %orig(4); 
}

- (void)configResolutionString:(NSString *)resString {
    %orig(@"1080p");
}

%end
