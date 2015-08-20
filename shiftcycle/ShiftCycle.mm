#import <Preferences/Preferences.h>

@interface ShiftCycleListController: PSListController {
}
@end

@implementation ShiftCycleListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"ShiftCycle" target:self] retain];
	}
	return _specifiers;
}
@end

// vim:ft=objc
