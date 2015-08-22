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

- (void)source {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/dado3212/ShiftCycle"]];
}

- (void)donate {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=GA2FFF2GUMMQ2&lc=US&item_name=Alex%20Beals&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHosted"]];
}

- (void)email {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:Alex.Beals.18@dartmouth.edu?subject=Cydia%3A%20ShiftCycle"]];
}
@end
