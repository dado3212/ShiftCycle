#import <Preferences/Preferences.h>

static NSString *newPath = @"/var/mobile/Library/Preferences/com.hackingdartmouth.shiftcycle-2.plist";

@interface ShiftCycleListController: PSEditableListController {
  NSMutableArray *cycles;
}
@end

static NSMutableArray *getDefaults() {
  NSMutableArray *defaultCycles = [[NSMutableArray alloc] init];

  [defaultCycles addObject:@[@"uppercase", @"Uppercase: SAMPLE TEXT", @(1)]];
  [defaultCycles addObject:@[@"lowercase", @"Lowercase: sample text", @(1)]];
  [defaultCycles addObject:@[@"capitalized", @"Capitalized: Sample Text", @(1)]];
  [defaultCycles addObject:@[@"concatenated", @"Concatenated: SampleText", @(1)]];
  [defaultCycles addObject:@[@"sarcastic", @"Sarcastic Text: SaMpLe TeXt", @(0)]];

  return defaultCycles;
}

@implementation ShiftCycleListController
- (void)viewDidLoad {
  // Just override if you're using the old version (try and squash bugs)
  cycles = [[NSMutableArray alloc] initWithContentsOfFile:newPath];
  if (cycles == nil) {
    cycles = getDefaults();
  }
  // Verify that the data is correct
  if ([cycles count] != 5) {
    cycles = getDefaults();
  } else {
    bool valid = true;
    for (int i = 0; i < 5; i++) {
      if (
        [cycles[i] count] != 3 ||
        ![cycles[i][0] isKindOfClass:[NSString class]] ||
        ![cycles[i][1] isKindOfClass:[NSString class]]
      ) {
        valid = false;
      }
    }
    if (!valid) {
      cycles = getDefaults();
    }
  }

  [cycles writeToFile:newPath atomically:YES];
  cycles = [[NSMutableArray alloc] initWithContentsOfFile:newPath]; // prevents weird crash on saving for the first time

  [super viewDidLoad];
}

- (id)specifiers {
	if (_specifiers == nil) {
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
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.me/alexbeals/5"]];
}

- (void)email {
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:Alex.Beals.18@dartmouth.edu?subject=Cydia%3A%20ShiftCycle"]];
}
@end
