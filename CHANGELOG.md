## [1.7.0] 04-07-2025

Added a emoji popup option along with the emoji keyboard. This is, for instance, 
for emoji reactions to messages in a chat app. The example has been changed to reflect 
this usage with some mock messages that you can react to.
The popup will have a curated selection of the most used emojis and after that it will 
hold your most recent emojis. A "+" button is always visible and it will trigger a button event
on the callback function so you can implement your own logic for that.
The Emoji Keyboard has been given a function callback option, `onEmojiChanged`, which will 
return whenever an emoji is pressed with the emoji value that was pressed. 
You can also only use this option and leave the controller empty. One of the two has to be used.

## [1.6.5] 28-04-2025

There were still linting issues listed.

## [1.6.4] 28-04-2025

Missed some linting issues

## [1.6.3] 28-04-2025

Fixed an issue where the search mode would not be exited when the user clicked on the back button.
This is because it would hide the regular keyboard and then not hide the search keyboard.
We solved this by listening to keyboard visibility. If the keyboard was visible and is being hidden
while the emoji keyboard is visible, it must mean that the search mode was being used and the back
button was pressed. In this case we set the search mode to false and rebuild the keyboard. This will
hide the search keyboard and show the emoji keyboard, the regular keyboard was already being hidden.
Also applied a bunch of linting improvements. Added typing and return values.

## [1.6.2] 22-02-2025

Applied consistent dart formatting to the project.

## [1.6.1] 22-02-2025

Fixed some issue with context loading.

## [1.6.0] 22-02-2025

Reworked how the emojis are shown, they appear slightly bigger in the grid. There is also a 
more prominent ripple when the user clicks on an emoji.
Changed the drawing of the keyboard to include the bottom notch. This will allow the emojis to be 
visible and clickable in this area. The bottom bar, when visible, will be drawn above this notch.
Added tablet support. For tablets the default amount on a emoji row is 16 to make use of the larger 
size of the tablet. When using landscape mode the amount of emojis on a row will be 32.
Restructured some of the old code, removed some variable placements and usages for a more clean
and understandable codebase.
The `back_button_interceptor` dependency is removed from this plugin. This is no longer used. For 
the `sqflite` and `path` dependencies The versions are loosened up. The most recent version of 
these package is recommended but lower versions should have been allowed.

## [1.5.3] 25-01-2025

Applied dart formatting

## [1.5.2] 25-01-2025

Added LICENCE and applied flutter linting to the project

## [1.5.1] 25-01-2025

Fixed the readme file

## [1.5.0] 25-01-2025

Resolved issues with the search on Android. Applied all the unicode v16.0 emojis.
Changed the TextController of the keyboard from `emotionController` to `emojiController`.

## [1.4.2] 25-01-2025

Added all the emojis up to unicode v16.0.

## [1.4.1] 24-01-2025

Fixed the ios version of the package

## [1.4.0] 24-01-2025

Updated the versions of the dependencies to the latest versions.

## [1.3.1] 03-05-2022

Found an issue where the IOS would not have the components available.

## [1.3.0] 06-04-2022

Added all the emojis up to unicode v14.0.0.
Added skin components to people emojis. A corner indicator is placed on the emoji and you can access
the skin component options by long press. This gives a popup window containing the components.
Improved the search slightly to also include multiple search word options.
Resolved some minor issues.

## [1.2.8] 02-03-2022

Since the keyboard is conventionally placed on the bottom I have added a SafeArea on the bottom,
which would allow the keyboard to not interfer with bottom bars.
And added padding to categories, if the bottom bar is visible the lowest emojis are still clickable.

## [1.2.7] 02-12-2021

When there are no 'recent' emojis in the db it will default on the smile category.

## [1.2.5] 02-12-2021

changed the channel name of the android emoji check.

## [1.2.4] 02-12-2021

resolved more minor issues

## [1.2.3] 02-12-2021

added correct Dart formatting

## [1.2.2] 02-12-2021

resolved some minor issues

## [1.2.1] 02-12-2021

resolved some minor issues

## [1.2.0] 02-12-2021

Changed the recent emojis to be stored using a local db.
It will also keep track of the amount of times an emoji is used.
The ordering of the recent emoji tab will always be the most used to the least used.

Also implemented the function that determines if the current Android version can show the emoji.
This can be seen in the Android project of the example project.


## [1.1.3] 24-08-2021

Some emoji updates

## [1.1.2] 24-08-2021

When the back button is pressed and there is only 1 (emoji) character in the text field
it will remove that one regardless of where the selection cursor is pointing.

## [1.1.1] 12-08-2021

In the search mode you will not automatically go back when an emoji has been selected.
A back icon is added before the textfield which will behave like pressing the back button

## [1.1.0] 06-06-2021

Improved on the orientation

## [1.0.4] 06-06-2021

Fixed styling issues

## [1.0.3] 05-06-2021

The phone can now be rotated between orientation and landscape.
The emoji keyboard will respond accordingly.

## [1.0.2] 27-05-2021

Fixed an issue where the keyboard wouldn't hide when in search mode.

## [1.0.1] 26-05-2021

Fix that search mode was permanently in DarkMode
The TextField in DarkMode now has white text (and black when not in DarkMode) so that it is readable

## [1.0.0] 19-05-2021

Official first release.
Made some slight formatting changes

## [0.1.4] 19-05-2021

Added null safety to the package
Improved styling and added Dark mode for the keyboard. Also updated the screenshots
replaced an outdated package for seeing keyboard triggers with an updated one and maintained one.

## [0.1.3] 28-04-2021

Fixed some issues with documentation and added some dart code conventions

## [0.1.2] 28-04-2021

Resolved an issue with naming conventions

## [0.1.1] 28-04-2021

Some restructuring of the project and some minor improvements

## [0.1.0] 28-04-2021

This plugin allows you to easily implement a keyboard where you can only type with emojis!
Smooth and intuitive keyboard layout with over 1800 emojis in 8 categories with an added 'recent chosen' tab.
You can easily switch between categories by swiping or selecting the category from the top bar.
You can even search for your emoji by using the search functionality available in the bottom bar.
From this keyboard you can also delete an emoji from the position of the cursor or add a space.

It's a keyboard the way you expect it and more!
