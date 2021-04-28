#import "EmojiKeyboardFlutterPlugin.h"
#if __has_include(<emoji_keyboard_flutter/emoji_keyboard_flutter-Swift.h>)
#import <emoji_keyboard_flutter/emoji_keyboard_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "emoji_keyboard_flutter-Swift.h"
#endif

@implementation EmojiKeyboardFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftEmojiKeyboardFlutterPlugin registerWithRegistrar:registrar];
}
@end
