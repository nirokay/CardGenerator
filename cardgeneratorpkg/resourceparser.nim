## Description
## ===============
##
## This module parses the resource directory and converts files into
## data used further on.

import std/[os, tables, options, strutils, strformat]
import ./globals

var cardColours: Table[string, CardColour]


proc init(name: string) =
    ## Inits a card colour by creating a table key.
    if not cardColours.hasKey(name):
        cardColours[name] = CardColour()


proc parseResourceDirectory*() =
    ## Parses the resource directory and writes values to vars.
    let seperator: char =
        when defined(windows): '\\'
        else: '/'
    var files: seq[tuple[kind: PathComponent, path: string]]
    for obj in getResourcePath().walkDir():
        let name: string = obj.path.split(seperator)[^1]
        # Skip dot-files:
        if name[0] == '.': continue

        # Init directory colours and cache files:
        case obj.kind:
        of pcFile, pcLinkToFile: files.add(obj)
        of pcDir, pcLinkToDir: name.init()

    # Overriding:
    type OverrideType = enum
        baseCard, baseFont

    proc hasOverride(splitName: seq[string]): bool =
        ## Checks if this is a valid file used for overriding.
        if splitName[1] notin ["", "png", "ttf", "otf", "svg"]: return true

    proc attemptOverride(colour: string, what: OverrideType, with: tuple[kind: PathComponent, path: string]) =
        if not cardColours.hasKey(colour):
            echo &"Colour '{colour}' does not have a directory, yet attempted to override '{$what}'! Skipping..."
            return
        case what:
        of baseCard: cardColours[colour].baseOverride = some with.path
        of baseFont: cardColours[colour].fontOverride = some with.path

    # Handle files:
    for obj in files:
        let
            name: string = obj.path.split(seperator)[^1]
            splitName: seq[string] = name.split('.')
            identifier: string = splitName[0]
            colour: string = splitName[1]

        # (Over-)write base values: (why did i write this)
        case identifier:
        of "base_card":
            if not splitName.hasOverride():
                resources.baseCard = some obj.path
            else:
                colour.attemptOverride(baseCard, obj)
        of "font":
            if not splitName.hasOverride():
                resources.baseFont = some obj.path
            else:
                colour.attemptOverride(baseFont, obj)

    # Die if required resources are not found:
    var shouldDie: bool
    for value in @[resources.baseCard, resources.baseFont]:
        if value.isNone(): shouldDie = true
    if shouldDie:
        echo $resources & "\n^^^ Required values were not set! Quitting."
        quit(1)


proc parseColourDirectories*(): Table[string, CardColourData] =
    ## Parses all colour directories and saves stuff to object, ready for
    ## the image generator to take over! :)
    ##
    ## Only call after at least calling `parseResourceDirectory()`!
    for colour, overrides in cardColours:
        var data: CardColourData
        data.overrides = overrides

        for obj in walkDir(getResourcePath() & colour):
            if obj.kind in [pcDir, pcLinkToDir]: continue
            let
                seperator: char =
                    when defined(windows): '\\'
                    else: '/'
                fullName: string = obj.path.split(seperator)[^1]
                cardName: string = fullName.split('.')[0]
            data.cards.add(cardName)
        result[colour] = data

