### Links

Firebase
* https://wizardwar.firebaseio.com/

Fonts
* http://refactr.com/blog/2012/09/ios-tips-custom-fonts/

Random Build Name Generator
* http://creativitygames.net/random-word-generator/randomwords/2

Multi-resolution support
* http://www.cocos2d-x.org/projects/cocos2d-x/wiki/Multi_resolution_support

Push Notifications
* https://www.parse.com/docs/push_guide#top/iOS



[ ] Lobby: get local lobby working
    [ ] Local Lobby: initial indicator of how many people are in it. 
    [ ] Local Lobby: chat
    [ ] Local Lobby: show ALL the people under the indicator.
    [ ] Local Lobby: issue a challenge
    

[ ] Ready screen so you can see who you are
[ ] Fix wind blast
[ ] Add random "fail" spells (with two elements) any 2 elements triggers a random fail spell
[ ] Add feedback! 
  [ ] Fail sound
  [ ] "Try dragging between elements"
  [ ] Spell cast graphic
[x] Merge and finish lobby code


IDEA: we can have some spells take "more mana", meaning they reduce the size of the indicators used MORE


[x] Make walls and monsters fall
[x] More spells. Fill it up!

BUGS
- pulls you out of a game if you are in one already



SUMMON DEATH: 
  - slow monster who marches out and kills the first living thing he touches
  - counter: monster
  - save as a special? ... might be too hard to counter then. 

TORNADO: 
  - knocks altitude things to the ground
  - fast enough to actually hit
  - does damage if player is levitated

VORTEX
  - sucks things into the middle of the screen. For each thing it sucks in, it gets bigger, until it sucks both players in.
  - depends on the side it is on
  - moves forward. When it hits something / anything, it gets bigger. 
  - gets smaller over time. Won't actually reach them at first. Has to absorb stuff
  - slow moving?

  - if it hits you, it sucks you in and you die. all the way? Seems extreme :) 
  - damages you based on its size I guess. More fun if it sucks you in though. 
  - it has gravity. Sucks things towards it, including players. 

WIND BLAST:
  - slows things down depending on their mass / interaction.
  - pops bubble
  - or speeds things up if in the same direction
  - can't reverse anything's direction though?

ROCKET
  - it sits in front of you
  - hit with fire, it takes off. Altitude
  - it goes a certain distance and loses altitude
  - then it crashes and explodes
