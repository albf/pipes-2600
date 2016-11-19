# Pipes 2600

A homebrew game for atari 2600 inspired by the dos classic Pipe Dreams.

![Alt Text](https://github.com/albf/pipes-2600/raw/master/path/to/sample.gif)

## How to Play

The game is separated by levels and, to complete each one, it's necessary to connect with pipes both start and end points. The start have a marker with a different color, and it's where the "water" will begin to flow. There is some initial time before it actually begin to flow, and the level is only completed when the water reach the final pipe. The next pipes are shown below the main grid, and a marker indicates its current position.

As many 2600 games, the game is score based, once the game is finished a new one with random positions will be created. The commands:

* Move player selection: up/down/left/right

* Put pipe: fire when selecting a free zone (empty or not yet with water)

* Fast forward: fire three times on a locked zone (not empty or start/finish)

## Starting

If you only want to test the game, you only need pipes-2600.bin file, and start with your favorite emulator (tested with stella and z26). If you have a Harmony or a Krokodile cart, you should be able to run the game (it uses the SuperChip ram, but those carts should be compatible).

## Compiling

The game was coded using batari basic. If, for some reason, you want to compile and use the code as a reference, you will need:

* [Batari Basic 1.1d](http://atariage.com/forums/topic/214909-bb-with-native-64k-cart-support-11dreveng/)
* [optional] - git and make
* [Batari dependency] - lex and x86 compatible linux distro

Once batari version 1.1d is downloaded, unzip and compile it (comes with a makefile), and put its dir on bB variable:

```
unzip bB.1.1d.reveng38.zip
cd bB.1.1d.reveng38/
make
export bB=$(pwd)
```

Having bB correctly set, it's just a matter of cloning the repo and making it.

```
git clone https://github.com/albf/pipes-2600
cd pipes-2600
make
```

You should see information regarding rom space remaining and a "build complete" message.

## Technical notes

Being atari 2600 limited as it is, the code have to take that into consideration. It should be easy to identify the main loop and, when possible, some well structured subroutines were used. Yet, for such game, the simpler approach wasn't enough at some parts. Some details if someone tries to actually understand the code:

* **Input**: A restrainer was used for every button. That's why it's possible to move field by field, it's on the init of the main loop.
* **Objects**: Atari can't display 6 player objects (5 pipes + selector) in a row, so the playfield was used to actually display the pipes.
* **Playfield size**: As you know, batari basic has a limited playfield size. SuperChip, pfres and no_blank_lines was used to make the game possible.
* **Calculating water flow**: It's too expensive, but only happens at most once each 5 frames. It was splitted in 3 functions, called in sequence during overscan.
* **Drawing new pipes**: Again, too expensive and, since it could happen at the same time as water flow, it had to be moved to vblank. It was splitted in, not 3, but 5 parts, executed as a pipeline. Step one do some validations, steps 2-4 draw the new pipe, step5 draw a new mini pipe.
* **Sound**: not much to say, it has very simple sound effects and has a small portion of the code handling it.

## Special Thanks

* RandomTerrain for an amazing [tutorial](http://www.randomterrain.com/atari-2600-memories-batari-basic-commands.html)
* [AtariAge forums](http://atariage.com/forums/forum/65-batari-basic/) for samples and for batari basic
