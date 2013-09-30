Wizard War
----------

[Wizard War][appstore] is an open-source multiplayer iOS game: http://appstore.com/wizardwar

[<img src="http://i.imgur.com/y2FlmUJ.png">][appstore]

Contributors
------------

### Creators

- [Sean Hess](http://seanhess.github.com)
- [Jesse Harding](http://jesseharding.com)
- [Orbital Labs](http://orbit.al)

### Contributors

- Kimball Wireg
- Dallin Skinner
- Chase Anderson
- Sariah Burdge
- Jacob Gundersen
- Clayton Ferris
- Seth Jenks


Technologies and Services Used
------------------------------

- We use [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa), a [Functional Reactive Programming](http://stackoverflow.com/questions/1028250/what-is-functional-reactive-programming) library for Cocoa
- The multiplayer uses [Firebase](http://firebase.com/), a real-time service with state syncing. It's a great match with Core Data. 
- [Cocos2d](http://www.cocos2d-iphone.org/)
- [TexturePacker](http://www.codeandweb.com/texturepacker)
- [Parse](https://parse.com/)
- [TestFlight](testflightapp.com)
- [CocoaPods](http://cocoapods.org/)

Setup and Compiling
-------------------

### Dependencies

1. Install [Cocoa Pods](http://cocoapods.org/)
2. `pod install`
3. Use WizardWar.xcworkspace to run the project

### Sprite Textures

This is only required if you add a sprite to the sprite folders and need to re-publish the spritesheet. The compiled spritesheets are committed to the repository and should be good to go. 

If you have Texture Packer pro: run `make` to compile the images in the spritesheet directories into spritesheets. If you only have the free version, open the .tps files and hit publish. 

### A library is missing

If you get an error saying something is missing, run `pod install` again. 




License
-------

Copyright (c) 2013 Orbital Labs LLC

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

The final work shall not compete directly with Wizard War, in any mobile app store or on the web. 

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.







[appstore]: http://appstore.com/wizardwar

