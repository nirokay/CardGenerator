import std/[os, parseopt, strutils, strformat, tables]
import cardgeneratorpkg/[globals, resourceparser]
export globals, resourceparser


when isMainModule:
    # Program information:
    const
        programName: string = "CardGenerator"
        programVersion: string = "0.1.0"
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
        resourcesDirectoryPath = newPath
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
    parseConfigFile()
    parseResourceDirectory()
    let cardData: Table[string, CardColourData] = parseColourDirectories()

    # Generate Images:
    
