import std/[tables, options]

var
    # Resources:
    resourcesDirectoryPath*: string = "./resources/"
    resourceTable*: Table[string, string]

    # Cards:
    resources*: tuple[
        baseCard, baseFont: Option[string]
    ]

    # Options:
    checkCardValidity*: bool
    checkCardsCards*: seq[string]


# File procs:

proc getResourcePath*(): string =
    ## Gets the resource path; appends '/' or '\' to the end, if none is provided.
    result = resourcesDirectoryPath
    if result[^1] != '/' or result[^1] != '\\': result.add('/')

proc getConfigFilePath*(): string =
    ## Gets the config file path
    return getResourcePath() & "config.json"

