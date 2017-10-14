@import ObjectiveC.runtime;
@import UIKit;

@interface MusicTabBarController : UITabBarController
@end
@interface MusicNavigationController : UINavigationController
@end
@interface SKUICrossFadingTabBarButton : UIControl
@property (nonatomic, copy) NSString *title;
@end

typedef NSString * _Nonnull MusicNavigationControllerTitle NS_TYPED_ENUM;
static MusicNavigationControllerTitle MusicNavigationControllerTitleLibrary;
static MusicNavigationControllerTitle MusicNavigationControllerTitleSearch;

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

BOOL isPad() {
    return [(NSString *)UIDevice.currentDevice.model hasPrefix:@"iPad"];
}

/**
 * Removes the "radio" controller identifier, which makes
 *   -[setViewControllers] never use it, and removes the tab.
 */
-(void)_setOrderedViewControllerIdentifiers:(NSArray *)identifiers animated:(BOOL)animated notifyDelegate:(BOOL)notifyDelegate {
    if (!isPad()) {
        %orig;
        return;
    }
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
    if (!isFirstRun || !isPad()) {
        %orig;
        return;
    }

    %orig([self.viewControllers objectAtIndex:kMusicSongsTab]);
    isFirstRun = NO;
}
%end

%hook MusicTabBarControllerSwift
- (void)setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers
animated:(BOOL)animated {
    NSMutableArray *mut = [NSMutableArray<__kindof UIViewController *> new];

    for (MusicNavigationController *vc in viewControllers) {
        if ([vc.title isEqualToString:MusicNavigationControllerTitleLibrary] ||
            [vc.title isEqualToString:MusicNavigationControllerTitleSearch]) {
            [mut addObject:vc];
        }
    }
    %orig(mut, animated);
}
%end

%ctor {
    %init(MusicTabBarControllerSwift = objc_getClass("Music.TabBarController"));
    MusicNavigationControllerTitleLibrary = [NSBundle.mainBundle localizedStringForKey:@"LIBRARY_TAB_TITLE" value:@"Library" table:@"Music"];
    MusicNavigationControllerTitleSearch = [NSBundle.mainBundle localizedStringForKey:@"SEARCH_TAB_TITLE" value:@"Search" table:@"Music"];
}
