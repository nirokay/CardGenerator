import std/[os, parseopt, strutils, strformat]


when isMainModule:
    # Program information:
    const
        programName: string = "CardGenerator"
        programVersion: string = "0.1.0"
        programAuthors: seq[string] = @["nirokay"]
        programSource: string = "https://github.com/nirokay/CardGenerator"


    # Commandline commands:
    var commands: seq[tuple[nameShort, nameLong, desc: string, call: proc()]]
    proc newCommand(names: tuple[short: char, long: string], desc: string, call: proc()) =
        commands.add((
            nameShort: $names.short,
            nameLong: names.long,
            desc: desc,
            call: call
        ))

    newCommand(('h', "help"), "Displays this help message.", proc() =
        var cmdText: seq[string]
        for command in commands:
            cmdText.add(alignLeft(&"-{command.nameShort}, --{command.nameLong}", 24, ' ') & command.desc)

        echo:
            &"{programName} - v{programVersion} by " & programAuthors.join(", ") & "\n" &
            &"Source: {programSource}\n\n" &
            cmdText.join("\n")

        quit(0)
    )

    newCommand(('v', "version"), "Displays the program version.", proc() =
        echo &"{programName} - v{programVersion}"
        quit(0)
    )


    # Parse and interpret commandline arguments:
    var p = initOptParser(commandLineParams())
    for kind, key, value in p.getopt():
        case kind:
        of cmdEnd: break
        of cmdArgument: discard

        of cmdLongOption, cmdShortOption:
            for cmd in commands:
                if key == cmd.nameShort or key == cmd.nameLong: cmd.call()


