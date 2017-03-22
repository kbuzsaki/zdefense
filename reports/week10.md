## Week 10 Report

Mar 13 - Mar 21

### Group Members

Darren Yang  
Huandari Lopez  
Kyle Buzsaki  
Kyle Huynh  

### Progress
- Implemented tier 3 towers (dark towers) that deal percentage rather than flat damage
- Implemented tower selling, returning half the cost of the tower to the player
- Implemented tower upgrading, doubling the damage of the tower and changing its sprite
- Implemented an enemy counter showing how many enemies are live on the map
- Implemented "wave" system for enemies with increasingly difficult spawn scripts
- Implemented "level" system when the final wave is completed, wrapping around to the first
  wave but with differently colored enemies that have twice as much health
- Implemented zap, bomb, and slow powerups and their visual effects
- Implemented lose condition with death screen
- Implemented level select screen with map previews, letting the player choose between the 4 maps,
  as well as a visual demo of the primary mechanics
- Added "blood splatters" indicating enemy death
- Plugged in sound effect engine and sound effect queues with 3 channel audio and a priority system
  for playing the different sound effects that are active on that cycle
- Added sound effects for various tower attacks, enemy death, player damage, item pickup, and item use
- Improved RNG for powerup generation by using a combination of the r register and a pointer into ROM
- Added music to the title screen / level select screen, playing every other pair of frames (00110011)
- Added music to the main game loop, playing 3.5 out of 4 frames (0000-111)

### Ideas that we had but didn't get to
- A wave or game length timer showing how long you've been playing
- A buff / boost tower that doesn't attack but boosts nearby towers
- Some kind of win condition (though we think the "endless" nature is also cool)
- Additional map variety (we could optimize our tape space usage to add ~2ish additional maps)
- Maps with paths that intersect, loop back on themselves, or fork
- Paths with discontinuities where enemies walk part way, enter a "portal", and then warp to another
  part of the screen and continue walking
- Music on the death screen
- Attack sprites for each tower type that draw a "zap line" or flame line from the tower to the enemy,
  rather than simply highlighting the tower and enemy in time with the attack/music
- Improved effects for slow powerup, especially using 1-pixel movement
  Our normal movement is 2 pixels per frame, which looks fine at a higher frame rate, but looks much
  choppier when reduced to half speed during the slow powerup
- Optimize / reorganize input checking to improve the responsiveness of the controls
- Make the enemies loop on the level select screen (they just have a really long wave)
- Allowing the player to choose their difficulty and health/money handicaps from the title screen
- Making enemies do more damage on the later levels
- Add additional "sprite pallete swaps" for the enemies so that they look different in different levels
- Add a "boss enemy" that has *substantially* more health than other enemies but is in a wave of its own
