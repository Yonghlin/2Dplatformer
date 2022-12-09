# Documentation

This game is about a pirate that just wants to unlock some cool moves. He's stuck on some lame island and wants to get off, but he can't swim.

The gameplay is relatively simple: the player just has to move to the right and collect two items that unlock new moves.

- Collecting the boots unlocks the "dash" move.

- Collecting the feather unlocks double-jumping.

Additionally, coins can be collected. Some of them require these moves to be unlocked.

- Small coins add 1 to the player's score

- Large coins add 5 to the player's score.

The hearts in the top right represent hit points.

The bar below that represents the player's sprint ability.

The coin with the number next to it represents the player's score.

Unfortunately, the pirate never learns how to swim because he's not very smart. He's still stuck, but at least now he can impress the ladies.

## Controls

Input | Action             |
------|--------------------|
A     | Move left          |
S     | Move right         |
Space | Jump / double-jump |
Shift | Dash               |
LMB   | Swing sword        |
RMB   | Shoot              |

# Development

There were 2 main things that were kept in mind during the creation of this game:
- A consistent visual appearance
- Well-polished controls 

The former was achieved by both acquiring and creating sprites, then editing them 
to all use the same color palette, which was retrieved from a color palette website.
Additionally, all of the sprites are nearly the same resolution, which looks a lot better
than having the player sprite be, say, 16x16 and each tile on the tilemap be 32x32.

As for the controls, they tend to suck in a lot of 2D games. A lot of them either make it an afterthought, 
or don't think about it at all. The values used for the physics simulation were painstakingly tuned until 
they felt just right. Additionally, some conscious choices were made in the game design process that 
determined how the controls can encourage the player to play the game a certain way. Note that
a lot of these concepts were borrowed from Hollow Knight, a game that's actually pretty good.

- The player's jump has a lot of initial lift off, and releasing the spacebar kills vertical velocity quickly.

- Horizontal velocity is slowed when in mid-air, regardless of whether the player has jumped
or is simply falling. This discourages spamming the spacebar and makes jumping and walking into mostly independent actions.

- Dashing is a fully independent action, meaning that the player has no control when the dash
is in action. However, dashing ignores gravity, allowing for some unique moves and creating
potential for some platforming tricks if the player feels up to it.

- The dash also has a lot of initial velocity, but doesn't rely on gravity or hitting a block
in order to stop. If the player dashes into the terrain, their velocity won't be reset, and 
they'll have to wait for it to slow down so they can move again. In practice, this just
means that they'll be "stuck".

- For the dash to stop, it has a separate constant that is subtracted (or added) to the
player's velocity eack tick. However, instead of ending the dash and returning control to the player when said velocity reaches 0,
it ends when the velocity reaces the movement speed of the player. This design choice serves two purposes:

  - Make the dash feel snappier, and not "glidey", by having a quick release
  - Allow the player to seamlessly transition from dashing to walking

The source code is also heavily commented, so feel free to take a look under the hood if you'd like more
details on how everything works (or if you're hungry for some spaghetti code).

# Credits

Color palette: https://lospec.com/palette-list/endesga-32

Tileset: https://opengameart.org/content/a-platformer-in-the-forest

Ambient waves: https://freesound.org/people/stomachache/sounds/157881/

Dash sound: https://freesound.org/people/qubodup/sounds/59995/

Jump sound: https://freesound.org/people/ShortRecord/sounds/514162/

Wing flap sound: https://freesound.org/people/ani_music/sounds/244976/

Boot sprite is a resprite of the "Hermes Boots" item from Terraria

---

Audio editing done with Audacity

Sprite editing done with Aseprite

Music made by Michael Frank, with Ableton Live

Pirate animations made by Michael Frank, for another project: https://gitlab.com/jmolina2300/metroidvania-month-12
