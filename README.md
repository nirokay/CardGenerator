# CardGenerator

CardGenerator generates playing cards from a couple of resources (such as base background, colours, images).

## Resource directory structure

```txt
root_dir
 | > .some_file.txt      # dot-files are ignored!
 |
 | > config.json         # configs in json format
 |
 | > font.ttf            # OPTIONAL: font used on all cards
 | > font.red.ttf        # OPTIONAL: overrides font used on red cards
 |
 | > base_card.png       # image used for the background of all cards
 | > base_card.red.png   # overrides base card ONLY for red
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

```json
// Note: comments are not supported in json, but they are used here for documentation.
{
    "checkCards": ["Ace", "9"]   // OPTIONAL: only treat these files <name>.png as card images,
                                 //           and throw an error, if any are missing for a colour.
}
```
