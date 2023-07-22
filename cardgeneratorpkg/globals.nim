import std/[options]

type
    CardColour* = object
        baseOverride*: Option[string] ## Override for base card
        fontOverride*: Option[string] ## Override for font

    CardColourData* = object
        cards*: seq[string]    ## card names/values
        overrides*: CardColour ## stores information about overrides for the specific colour

var
    # Resources:
    resourcesDirectoryPath*: string = "./resources/" ## Path to the resource directory.

    # Cards:
    resources*: tuple[
        baseCard, baseFont: Option[string]
    ] ## Base resources, which are parsed from the root directory. If any of these remains `None`, program will abort.

    # Options:
    imageOutputDirectory*: string = "./cards_output/" ## Output directory for finished cards
    globalFontSize*: int = 20 ## Font size used for writing card value into each corner.
    globalSafezone*: int = 0 ## Amount of pixels indented from the corners the text should be rendered.

    # Shaders:
    drawShadowOnTextLayer*: bool ## Toggles if a shadow should be drawn (for card value).
    shadowColours*: array[4, uint8] ## Shadow colour usef for shadow on card values.


# File procs:

proc getResourcePath*(): string =
    ## Gets the resource path; appends '/' or '\' to the end, if none is provided.
    ##
    ## This is just to make me write less code.
    result = resourcesDirectoryPath
    if result[^1] != '/' or result[^1] != '\\': result.add('/')
