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
