@interface MusicTabBarController : UITabBarController
@end
@interface MusicNavigationController : UINavigationController
@end

// @note This integer is after modification of the identifiers array
#define kMusicSongsTab 2

%hook MusicTabBarController
BOOL isFirstRun = YES;
BOOL shouldRun = NO;

/**
 * Removes the "radio" controller identifier, which makes
 *   -[setViewControllers] never use it, and removes the tab.
 */
-(void)_setOrderedViewControllerIdentifiers:(NSArray *)identifiers animated:(BOOL)animated notifyDelegate:(BOOL)notifyDelegate {
    if (!shouldRun) {
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
    if (!shouldRun || !isFirstRun) {
        %orig;
        return;
    }

    %orig([self.viewControllers objectAtIndex:kMusicSongsTab]);
    isFirstRun = NO;
}
%end

%ctor {
    shouldRun = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}
