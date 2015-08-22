#import <UIKit/UIKit.h>
#import <UIKit/UIKeyboardLayoutStar.h>
#import <UIKit/UIKeyboardInput.h>
#import <UIKit/UITextInput.h>

@interface UIKeyboardImpl : UIView
	+ (UIKeyboardImpl*)activeInstance;
	- (void)insertText:(id)text;

	@property (readonly, assign, nonatomic) UIResponder <UITextInputPrivate> *privateInputDelegate;
	@property (readonly, assign, nonatomic) UIResponder <UITextInput> *inputDelegate;
	@property(readonly, nonatomic) id <UIKeyboardInput> legacyInputDelegate;
@end

@interface UIKBKey : NSObject
	@property(copy) NSString * representedString;
@end

@interface WKContentView : UITextView
	- (id)selectedText;
	-(void)moveByOffset:(NSInteger)offset;
@end

@interface UIPhysicalKeyboardEvent : NSObject
	@property (nonatomic,readonly) BOOL _isKeyDown; 
	@property (nonatomic,readonly) long long _keyCode;    
	- (void*)_hidEvent;     
@end

NSMutableArray *variants = [[NSMutableArray alloc] init];
int variant = 0;
bool change = false;
static NSString *prefPath = @"/var/mobile/Library/Preferences/com.hackingdartmouth.shiftcycle.plist";

static void fillArray(NSString *original) {
	NSLog(@"Filling with variants of %@", original);

	NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:prefPath];

	NSNumber *uppercaseS = [settings objectForKey:@"uppercase"];
	NSNumber *lowercaseS = [settings objectForKey:@"lowercase"];
	NSNumber *capitalizedS = [settings objectForKey:@"capitalized"];
	NSNumber *concatS = [settings objectForKey:@"concatenated"];

	BOOL upper = (uppercaseS == nil || uppercaseS.integerValue == 1);
	BOOL lower = (lowercaseS == nil || lowercaseS.integerValue == 1);
	BOOL capital = (capitalizedS == nil || capitalizedS.integerValue == 1);
	BOOL conc = (concatS == nil || concatS.integerValue == 1);

	if ([original length] != 0) {
		variants = [[NSMutableArray alloc] init];
		[variants addObject:original]; // original
		NSString *uppercase = [[original stringByReplacingOccurrencesOfString:@"ß" withString:@"ẞ"] uppercaseString];
		NSString *lowercase = [original lowercaseString];
		NSString *capitalized = [original capitalizedString];
		NSString *concat = [[original capitalizedString] stringByReplacingOccurrencesOfString:@" " withString:@""];
		if (![variants containsObject:uppercase] && upper)
			[variants addObject:uppercase];
		if (![variants containsObject:lowercase] && lower)
			[variants addObject:lowercase];
		if (![variants containsObject:capitalized] && capital)
			[variants addObject:capitalized];
		if (![variants containsObject:concat] && conc)
			[variants addObject:concat];
		variant = 0;
	} else {
		variants = [[NSMutableArray alloc] init];
	}
}

static void textReplace() {
	UIKeyboardImpl *impl = [%c(UIKeyboardImpl) activeInstance];

	id delegate = impl.privateInputDelegate ?: impl.inputDelegate;

	variant = (variant + 1) % (int)[variants count];

	change = true;
	if ([NSStringFromClass([delegate class]) isEqualToString:@"WKContentView"]) { // Safari's broken Input
		// Goddamnit.  No idea how to do this.
		/*NSString *text = [variants objectAtIndex:variant];
		[delegate insertText:text];*/
	} else {
		NSString *selectedString = [delegate textInRange:[delegate selectedTextRange]];
		if ([selectedString length] > 0) {
			NSInteger offset = [delegate offsetFromPosition:[delegate beginningOfDocument] toPosition:[[delegate selectedTextRange] start]];
			NSString *text = [variants objectAtIndex:variant];
			[delegate insertText:text];
			UITextPosition *from = [delegate positionFromPosition:[delegate beginningOfDocument] offset:offset];
			UITextPosition *to = [delegate positionFromPosition:from offset:text.length];
			[delegate setSelectedTextRange:[delegate textRangeFromPosition:from toPosition:to]];
		}
	}
	change = false;
}

%hook UIKeyboardLayoutStar
	- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
		UITouch *touch = [touches anyObject];
		NSString *key = [[[self keyHitTest:[touch locationInView:touch.view]] representedString] lowercaseString];

		if ([key isEqualToString:@"shift"] && (int)[variants count] > 0) {
			textReplace();
		}
		%orig;
	}
%end

%hook WKContentView 
	-(void)_selectionChanged {
		%orig;

		if (!change) {
			UIKeyboardImpl *impl = [%c(UIKeyboardImpl) activeInstance];

			id delegate = impl.privateInputDelegate ?: impl.inputDelegate;

			if ([NSStringFromClass([delegate class]) isEqualToString:@"WKContentView"]) { // Safari's broken Input
				NSString *selectedString = (NSString *)[(WKContentView *)delegate selectedText];

				fillArray(selectedString);
			}
		}
	}
%end

%hook UIKeyboardImpl
	-(void)updateForChangedSelection {
		%orig;

		if (!change) {
			id inpd = self.privateInputDelegate ?: self.inputDelegate;

			NSString *selectedString;

			if ([NSStringFromClass([inpd class]) isEqualToString:@"WKContentView"]) { // Safari's broken Input
				selectedString = (NSString *)[(WKContentView *)inpd selectedText];
			} else {
				UITextRange *selRange = [inpd selectedTextRange];

				if ([selRange isEmpty]) {
					variants = [[NSMutableArray alloc] init];
					return;
				} else {
					selectedString = [inpd textInRange:[inpd selectedTextRange]];
				}
			}

			fillArray(selectedString);
		}
	}

	-(void)handleKeyEvent:(id)arg1 {
		UIPhysicalKeyboardEvent *key = (UIPhysicalKeyboardEvent *)arg1;
		if ([key _isKeyDown]) { // trigger on keydown not keyup
			if ([key _hidEvent]) { // if this is nil (whenever a press is made on the built in keyboard), the call to _keyCode will fail
				if ([key _keyCode] == 57  && (int)[variants count] > 0) // caps-lock
					textReplace();
			}
		}
		%orig;
	}
%end
