# Pre-work - ios-tip-calculator
The obligatory first iOS app


**TipCalc** is a tip calculator application for iOS.

Submitted by: **Michael Cordover**

Time spent: **16** hours spent in total

## User Stories

The following **required** functionality is complete:

* [x] User can enter a bill amount, choose a tip percentage, and see the tip and total values.
* [x] Settings page to change the default tip percentage.

The following **optional** features are implemented:
* [x] UI animations (_very basic; invalid settings_)
* [x] Remembering the bill amount across app restarts (if <10mins)
* [x] Using locale-specific currency and currency thousands separators.
* [x] Making sure the keyboard is always visible and the bill amount is always the first responder. This way the user doesn't have to tap anywhere to use this app. Just launch the app and start typing.

The following **additional** features are implemented:

- [x] Tip or total can be rounded by double tapping on the relevant item
- [x] User can set the minimum and maximum values for the tip percentage slider
- [x] User can set what amount to round to, and whether to always round up or round to nearest
- [x] Settings screen includes revert and reset to default

## Video Walkthrough 

Here's a walkthrough of implemented user stories:

<img src='http://i.imgur.com/link/to/your/gif/file.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes

- I don't really have any naming conventions for variables or methods, because I was learning as I went
- I haven't put together any unit tests, though a fair amount of functionality would be very amenable to unit testing
- A lot of documentation on Stack Overflow/easily found by Googling is out of date ¯\\_(ツ)\_/¯
- There's still a lot about Swift I don't know
- It took me a surprisingly long time to figure out how to get a Table View to work; it has to be in the right kind of view controller apparently
- I found refactoring annoyingly difficult, in particular changing the names of things which had been linked from the interface builder
- I was surpsied that `FloatingPointRoundingRule` vaues can't be natively stored in `UserDefaults`, so I had to do my own ugly serialization 

## License

    Copyright 2017 Michael Cordover

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
