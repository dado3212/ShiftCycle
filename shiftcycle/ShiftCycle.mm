#import <Preferences/Preferences.h>

static NSString *oldPath = @"/var/mobile/Library/Preferences/com.hackingdartmouth.shiftcycle.plist";
static NSString *newPath = @"/var/mobile/Library/Preferences/com.hackingdartmouth.shiftcycle-2.plist";

@interface ShiftCycleListController: PSEditableListController {
    NSMutableArray *cycles;
}
@end

@implementation ShiftCycleListController
- (void)viewDidLoad {
  // Handle switching over to the new storage method
  cycles = [[NSMutableArray alloc] initWithContentsOfFile:newPath];
  if (cycles == nil) {
    cycles = [[NSMutableArray alloc] init];

    // If there's current information in the other format, then use it
    if ([[NSFileManager defaultManager] fileExistsAtPath:oldPath]) {
      NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:oldPath];

      NSNumber *uppercaseS = [settings objectForKey:@"uppercase"];
      NSNumber *lowercaseS = [settings objectForKey:@"lowercase"];
      NSNumber *capitalizedS = [settings objectForKey:@"capitalized"];
      NSNumber *concatS = [settings objectForKey:@"concatenated"];

      // Append to array in default order
      [cycles addObject:@[@"uppercase", @"Uppercase: SAMPLE TEXT", uppercaseS]];
      [cycles addObject:@[@"lowercase", @"Lowercase: sample text", lowercaseS]];
      [cycles addObject:@[@"capitalized", @"Capitalized: Sample Text", capitalizedS]];
      [cycles addObject:@[@"concatenated", @"Concatenated: SampleText", concatS]];
    } else { // default info
      [cycles addObject:@[@"uppercase", @"Uppercase: SAMPLE TEXT", @(1)]];
      [cycles addObject:@[@"lowercase", @"Lowercase: sample text", @(1)]];
      [cycles addObject:@[@"capitalized", @"Capitalized: Sample Text", @(1)]];
      [cycles addObject:@[@"concatenated", @"Concatenated: SampleText", @(1)]];
    }
  }
  [cycles writeToFile:newPath atomically:YES];
  cycles = [[NSMutableArray alloc] initWithContentsOfFile:newPath]; // prevents weird crash on saving for the first time
  
  [super viewDidLoad];
}

- (id)specifiers {
	if(_specifiers == nil) {
    NSMutableArray *specs = [NSMutableArray array];

    PSSpecifier* group = [PSSpecifier preferenceSpecifierNamed:@"Cycle Options"
      target:self
      set:NULL
      get:NULL
      detail:Nil
      cell:PSGroupCell
      edit:Nil];
    [specs addObject:group];

    for (int i = 0; i < [cycles count]; i++) {
      PSSpecifier* tempSpec = [PSSpecifier preferenceSpecifierNamed:cycles[i][1]
                          target:self
                           set:@selector(setPreferenceValue:specifier:)
                           get:@selector(readPreferenceValue:)
                          detail:NULL
                          cell:PSSwitchCell
                          edit:Nil];
      [tempSpec setProperty:@(i) forKey:@"arrayIndex"];
      [specs addObject:tempSpec];
    }

    //initialize about
    group = [PSSpecifier preferenceSpecifierNamed:@"About"
      target:self
      set:NULL
      get:NULL
      detail:Nil
      cell:PSGroupCell
      edit:Nil];
    [specs addObject:group];

    PSSpecifier* button = [PSSpecifier preferenceSpecifierNamed:@"Donate to Developer"
      target:self
      set:NULL
      get:NULL
      detail:Nil
      cell:PSButtonCell
      edit:Nil];
    [button setButtonAction:@selector(donate)];
    [button setProperty:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/ShiftCycle.bundle/paypal.png"] forKey:@"iconImage"];
    [specs addObject:button];

    button = [PSSpecifier preferenceSpecifierNamed:@"Source Code on Github"
      target:self
      set:NULL
      get:NULL
      detail:Nil
      cell:PSButtonCell
      edit:Nil];
    [button setButtonAction:@selector(source)];
    [button setProperty:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/ShiftCycle.bundle/github.png"] forKey:@"iconImage"];
    [specs addObject:button];

    button = [PSSpecifier preferenceSpecifierNamed:@"Email Developer"
      target:self
      set:NULL
      get:NULL
      detail:Nil
      cell:PSButtonCell
      edit:Nil];
    [button setButtonAction:@selector(email)];
    [button setProperty:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/ShiftCycle.bundle/mail.png"] forKey:@"iconImage"];
    [specs addObject:button];

    group = [PSSpecifier emptyGroupSpecifier];

    // Get the current year
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSString *yearString = [formatter stringFromDate:[NSDate date]];

    [group setProperty:[NSString stringWithFormat: @"© 2015-%@ Alex Beals", yearString] forKey:@"footerText"];
    [group setProperty:@(1) forKey:@"footerAlignment"];
    [specs addObject:group];

    _specifiers = [[NSArray arrayWithArray:specs] retain];
  }
  return _specifiers;
}

// Handle toggling with new system
-(id)readPreferenceValue:(PSSpecifier*)specifier {
  return cycles[[specifier.properties[@"arrayIndex"] intValue]][2];
}

-(void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
  NSLog(@"Trying to set: %@, %d", cycles, [specifier.properties[@"arrayIndex"] intValue]);
  cycles[[specifier.properties[@"arrayIndex"] intValue]][2] = value;
  [cycles writeToFile:newPath atomically:YES];
}

// Set up table changes
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return (indexPath.section == 0);
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath.section == 0);
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

// Handle reordering
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
  id cycle = [[[cycles objectAtIndex:sourceIndexPath.row] retain] autorelease];
  [cycles removeObjectAtIndex:sourceIndexPath.row];
  [cycles insertObject:cycle atIndex:destinationIndexPath.row];
  [cycles writeToFile:newPath atomically:YES];
  [self reloadSpecifiers];
  return;
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
