# CSE 190 Project - zDefense

### Group Members

Darren Yang  
Huandari Lopez  
Kyle Buzsaki  
Kyle Huynh  

### Summary

zDefense is an 8-bit tower defense game for the Sinclair ZX Spectrum 48k.
It was developed for the Winter 2017's CSE 190 8-bit demo programming taught by professor Hovav Shacham.

### How to Play

#### Running the Game

Open zdefense.tap in your ZX Spectrum emulator of choice. zDefense was developed using the
[fuse](http://fuse-emulator.sourceforge.net/) emulator for OS X and Windows.

#### Basic Controls

Use WASD to control the menus and cursor. Press enter to select the level from the level select screen.
Once in the game, move the cursor to the yellow build tiles and press one of the 3 tower build buttons
(1, 2, or 3) to build a tower. The input keys are all displayed in magenta in the status pane at the
bottom third of the screen.

#### Towers

Once you have built a tower, it will automatically attack enemies that walk next to it.
You can sell an already built tower by pressing G while the cursor is over it to get a portion of the money
spent back. You can upgrade a tower by pressing R, which will double the damage it deals with each attack.
The "laser" tower attacks a single enemy at a time and does 1 damage to it. The "flame" tower will attack
all of the enemies on one side of it and deal 1 damage to them. The "dark" tower will do 1/8th of an enemy's
current health in damage, rounded down. This won't be much early in the game (it will actually do 0 damage
to the weaker enemies), but it becomes increasingly important as the enemies get stronger).

#### Powerups

While you are waiting for enemies to move through the path, move the cursor around to pick up the
"powerup items" that spawn in the various lakes around the map. Some of these will boost your health
or money. Others represent special "power charges" that you can use by pressing 6, 7, or 8. The "bomb" powerup
can be placed on the enemy path and will instantly kill any enemy that steps on it. The "zap" powerup can be
used at any time and will deal a flat 1 damage to all enemies currently on the path. The "slow" powerup
will cut enemy movement speed in half, giving your towers additional time to deal damage to them.

#### Winning and Losing

If an enemy is killed, you will be awarded a small amount of money for killing it. Use this extra cash
to buy more towers to defend against the more difficult waves to come. If an enemy reaches the end of the
path, it will deal 1 damage to you and subtract a point from your life total. If your life hits 00, you will
lose the game. 

If you successfully defeat all of the enemies in a wave, the next wave will start. Once you have beaten
all of the waves, the game's "level" will go up, all enemies will increase in strength, and the waves
will begin again. Try to see how long you can last!
