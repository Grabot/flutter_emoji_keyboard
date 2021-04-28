#import "EmojiKeyboardPlugin.h"
#if __has_include(<emoji_keyboard/emoji_keyboard-Swift.h>)
#import <emoji_keyboard/emoji_keyboard-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "emoji_keyboard-Swift.h"
#endif

@implementation EmojiKeyboardPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftEmojiKeyboardPlugin registerWithRegistrar:registrar];
}
@end
