# CardGenerator

CardGenerator generates playing cards from a couple of resources (such as base background, colours, images).

## Usage

```
-h, --help              Displays this help message and quits.
-v, --version           Displays the program version and quits.
-d, --directory         Sets the resource directory.
-o, --output            Sets the output directory for final cards.
-f, --fontsize          Sets the global font size for card images.
-s, --safezone          Sets the pixels-indents from the corners.
```



## Resource directory structure

### Files

* `base_card.png`

* `font.ttf` / `font.otf`

You can override these on a by-colour basis. For example, you want to have one base card for red and another for all other colours:

Create these files:

* `base_card.png` for all colours

* `base_card.red.png` to override the base card for red

The same is true for font files!

### Directories

Each directory you create in the resource directory is a colour. You can name the directories anything you want - they do not have to be colours.

For example: `./69/`, `./purple/`, `./amongus` are all valid.

Inside these directories you can put your overlay images. Name them like you want the cards to appear as: `A.png -> "A"`, `9.png -> "9"`, `Ace.png -> "Ace"`

These overlay images will be centered and drawn directly onto the base card.

**Note:** Overlay images should always be smaller than the base card, as then the overlay would be bigger than the "background"!

### Example

```txt
root: ./
 |
 | > .some_file.txt      # dot-files are ignored!
 |
 | > config.json         # configs in json format
 |
 | > font.ttf            # font used on all cards
 | > font.red.ttf        # OPTIONAL: overrides font used on red cards
 |
 | > base_card.png       # image used for the background of all cards
 | > base_card.red.png   # OPTIONAL: overrides base card ONLY for red
 |
 | > red/                # contains card images for red cards
 |    | > 9.png          # card image for card '9'; '9' will be printed onto the card
 |    | > Ace.png        # 'Ace' will be printed onto the card
 |
 | > blue/               # same as red, but only for blue
     | > 9.png
     | > Ace.png
```

## JSON config file structure

Not yet implemented! Use command line arguments instead.

```json
// Note: comments are not supported in json, but they are used here for documentation purposes.
{
    "checkCards": ["Ace", "9"],  // OPTIONAL: only treat these files <name>.png as card images,
                                 //           and throw an error, if any are missing for a colour.

    "fontsize": 20               // OPTIONAL: font size used on all cards
}
```
