## CardGenerator documentation
## ===========================
##
## This cli program generates playing-cards from the minimal amount of
## resources:
##
## * card background image (refered here as base-card)
## * at least one base font file
## * your illustrations for the cards
##
##
## Directory names
## ===============
##
## Each directory in the resources dir is a seperate colour. You can have as
## many colours as you wish.
##
##   **For example:**
##
##   The directories `blue`, `red`, `some_other_name` will all be
##   interpreted as different colours.
##
## Inside these directories you put your card images (see 'File names' for that)
##
##
## File names
## ==========
##
## Colour-specific files
## ---------------------
##
## These are files inside the colour directories (such as `./blue/`, `./red/`).
## You can put your own illustrations on here, that will be placed onto the
## middle of your finished card.
##
## Simply name them, what you want the card to say at the end.
##
##   **For example:**
##
##   A file called `Ace.png` will have `Ace` written in each cornor of the card.
##   This makes silly stuff like config files for every card obsolete!
##
## "Global" files
## --------------
##
## These include your standard stuff, like the base card, fonts, etc.
##
## File names have to be as is, otherwise the program gets confused, and that
## is not nice towards the program...
##
## **Reserved file names:**
##
## * `base_card.png`
## * `font.ttf` / `font.otf`
##
## Each colours' base card and/or font can be overridden. Just add a
## `.[colour name]` between the identifier (`base_card`) and the file extention
## (`.png`) -> `base_card.red.png`.
##
## This will override the base card for every red card!
##
## The same works with font files -> `font.red.ttf`
##
##
## Detailed documentation on usage
## ===============================
##
## For a more detailed deocumentation on usage, please refer to the [README on github](https://github.com/nirokay/CardGenerator#readme)

import std/[os, parseopt, strutils, strformat, tables]
import cardgeneratorpkg/[globals, resourceparser, imagegenerator]
export globals, resourceparser, imagegenerator


when isMainModule:
    # Program information:
    const
        programName: string = "CardGenerator"
        programVersion: string = "1.0.0"
        programAuthors: seq[string] = @["nirokay"]
        programSource: string = "https://github.com/nirokay/CardGenerator"


    # Commandline commands:
    var commands: seq[tuple[nameShort, nameLong, desc: string, call: proc(_: string) {.closure.}]]
    proc newCommand(names: tuple[short: char, long: string], desc: string, call: proc(_: string)) =
        commands.add((
            nameShort: $names.short,
            nameLong: names.long,
            desc: desc,
            call: call
        ))

    newCommand(('h', "help"), "Displays this help message and quits.", proc(_: string) =
        var cmdText: seq[string]
        for command in commands:
            cmdText.add(alignLeft(&"-{command.nameShort}, --{command.nameLong}", 24, ' ') & command.desc)

        echo:
            &"{programName} - v{programVersion} by " & programAuthors.join(", ") & "\n" &
            &"Source: {programSource}\n\n" &
            cmdText.join("\n")

        quit(0)
    )

    newCommand(('v', "version"), "Displays the program version and quits.", proc(_: string) =
        echo &"{programName} - v{programVersion}"
        quit(0)
    )

    newCommand(('d', "directory"), "Sets the resource directory.", proc(newPath: string) =
        if not newPath.dirExists():
            echo &"Resource directory '{newPath}' does not exist!"
            quit(1)
        resourcesDirectoryPath = newPath
    )

    newCommand(('o', "output"), "Sets the output directory for final cards.", proc(newOutputPath: string) =
        if not newOutputPath.dirExists():
            try:
                newOutputPath.createDir()
            except OSError:
                echo &"Could not create directory '{newOutputPath}'!"
                quit(1)
        imageOutputDirectory = newOutputPath
    )

    newCommand(('f', "fontsize"), "Sets the global font size for card images.", proc(newSize: string) =
        try:
            globalFontSize = newSize.parseInt()
        except ValueError:
            echo "Font size has to be an integer!"
            quit(1)
    )

    newCommand(('z', "safezone"), "Sets the pixels-indents from the corners.", proc(newSafezone: string) =
        try:
            globalSafezone = newSafezone.parseInt()
        except ValueError:
            echo "Safezone has to be an integer!"
            quit(1)
    )

    newCommand(('s', "shadow"), "Toggles if the text should have shadows (slow).", proc(_: string) =
        drawShadowOnTextLayer = true
    )

    newCommand(('c', "shadowcolour"), "Sets the shadow colour. Four values (rgba) seperated by commas (example: '255,255,255,255').", proc(values: string) =
        var valuesAsStrings: seq[string] = values.split(',')

        # Populate array, if needed:
        while valuesAsStrings.len() < 3:
            valuesAsStrings.add("0")
        if valuesAsStrings.len() < 4:
            valuesAsStrings.add("255")

        for i, value in valuesAsStrings:
            var shadowInt: uint8
            try:
                shadowInt = uint8 valuesAsStrings[i].parseInt()
            except ValueError:
                echo &"Passed shadow value of '{valuesAsStrings[i]}' is not a valid unsigned 8-bit integer! Using '0' instead"
                shadowInt = 0
            finally:
                shadowColours[i] = shadowInt
        echo &"Using rgba({shadowColours[0]}, {shadowColours[1]}, {shadowColours[2]}, {shadowColours[3]}) as shadow colour!"
    )


    # Parse and interpret commandline arguments:
    var p = initOptParser(commandLineParams())
    for kind, key, value in p.getopt():
        case kind:
        of cmdEnd: break
        of cmdArgument: discard

        of cmdLongOption, cmdShortOption:
            for cmd in commands:
                if key == cmd.nameShort or key == cmd.nameLong: cmd.call(value)

    # Parse resources:
    parseResourceDirectory()
    let cardData: Table[string, CardColourData] = parseColourDirectories()

    # Generate Images:
    generateImagesWith(cardData)
