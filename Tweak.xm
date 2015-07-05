#import <UIKit/UIKit.h>

@interface MusicTabBarController : UITabBarController
@end
@interface MusicNavigationController : UINavigationController
@end
@interface SKUICrossFadingTabBarButton : UIControl
@property (nonatomic, copy) NSString *title;
@end

// @note This integer is after modification of the identifiers array
#define kMusicSongsTab 2

// For iOS 8.4 (Apple Music)
%hook SKUICrossFadingTabBar
- (void)setTabBarButtons:(NSArray *)origTabs {
    NSMutableArray *tabs = [origTabs mutableCopy];
    NSUInteger radioIndex = [origTabs indexOfObjectPassingTest:^BOOL (id obj, NSUInteger idx, BOOL *stop) {
        SKUICrossFadingTabBarButton *btn = (SKUICrossFadingTabBarButton *)obj;
        if ([btn.title isEqualToString:NSLocalizedString(@"Radio", nil)]) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];

    [tabs removeObjectAtIndex:radioIndex];
    %orig(tabs);
}
%end

// For iOS 8.3, iPad only
%hook MusicTabBarController
BOOL isFirstRun = YES;

/**
 * Removes the "radio" controller identifier, which makes
 *   -[setViewControllers] never use it, and removes the tab.
 */
-(void)_setOrderedViewControllerIdentifiers:(NSArray *)identifiers animated:(BOOL)animated notifyDelegate:(BOOL)notifyDelegate {
    NSMutableArray *replacement = [NSMutableArray arrayWithCapacity:[identifiers count] - 1];
    for (NSString *s in identifiers) {
        if ([s isEqualToString:@"radio"]) {
            continue;
        }
        [replacement addObject:s];
    }
    %orig(replacement, animated, notifyDelegate);
}

/**
 * Makes the Music app start at the Songs tab on first launch.
 */
- (void)_setSelectedViewController:(MusicNavigationController *)vc {
    if (!isFirstRun) {
        %orig;
        return;
    }

    %orig([self.viewControllers objectAtIndex:kMusicSongsTab]);
    isFirstRun = NO;
}
%end
