import std/[tables, options]

type
    CardColour* = object
        baseOverride*: Option[string]
        fontOverride*: Option[string]

    CardColourData* = object
        cards*: seq[string]
        overrides*: CardColour

var
    # Resources:
    resourcesDirectoryPath*: string = "./resources/"
    resourceTable*: Table[string, string]

    # Cards:
    resources*: tuple[
        baseCard, baseFont: Option[string]
    ]

    # Idk what to write in this comment... "Stuff"?... :
    validImageFormats*: seq[string] = @["png", "svg"]

    # Options:
    checkCardValidity*: bool
    checkCardsCards*: seq[string]
    imageOutputDirectory*: string = "./cards_output/"
    globalFontSize*: int = 20
    globalSafezone*: int = 0
    widthOffset*: int = 50

    # Shaders:
    drawShadowOnTextLayer*: bool
    shadowColours*: array[4, uint8]


# File procs:

proc getResourcePath*(): string =
    ## Gets the resource path; appends '/' or '\' to the end, if none is provided.
    result = resourcesDirectoryPath
    if result[^1] != '/' or result[^1] != '\\': result.add('/')

proc getConfigFilePath*(): string =
    ## Gets the config file path
    return getResourcePath() & "config.json"

