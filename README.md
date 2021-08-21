# Spectre Reborn

Inspired by the [1991 video game Spectre][spectre], this is a simple tank action game I'm creating
to learn to use the [Godot game engine](https://godotengine.org).

## Controls

 * `WASD` or `arrow keys` to move
 * `Spacebar` or `left click` to fire
 * `R` or `right click` to reload

While there's no UI yet, you have 3 shots per reload. You can reload any time, but it takes time and
you cannot shoot while you're reloading.

If you die (by being shot or falling off the edge) you'll revert to an overhead camera; to restart you
must close and re-launch the game.

The pill-shaped "bombs" are harmless (and fun to knock around!), but they continually spawn indefinitely
and eventually will tank (no pun intended) your framerate if you don't kick them off the play area.

[spectre]: https://en.wikipedia.org/wiki/Spectre_(1991_video_game)
