# Fast Full Game

This test tests an entire game (until the snake reaches full length).

The games tickrate is no longer coupled to the VGA display refresh rate and instead uses a timer with a much shorter interval.
This then allows for much longer tests including a full run of an entire successful game that ends with the snake filling the entire area.

```sh
make
```
