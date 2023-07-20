import std/[os, options, tables, strformat]
import pixie
import ./globals

type
    DataForCardColour* = tuple
        baseImagePath, fontPath: string
        cardNames: seq[string]


proc getDataForColour(colourData: CardColourData): DataForCardColour =
    proc getOrDef(option: Option[string], default: string): string =
        if option.isSome(): return option.get()
        else: return default
    proc getOrDef(option, default: Option[string]): string =
        return option.getOrDef(default.get())
    result.baseImagePath = colourData.overrides.baseOverride.getOrDef(resources.baseCard)
    result.fontPath = colourData.overrides.fontOverride.getOrDef(resources.baseFont)
    result.cardNames = colourData.cards


proc generateImagesWith*(cardData: Table[string, CardColourData]) =
    var colours: Table[string, DataForCardColour]

    # Translate data for my sanity:
    for colour, colourData in cardData:
        colours[colour] = colourData.getDataForColour()

    # Generate images:
    echo colours
    echo "Generating cards..."
    for colour, data in colours:
        echo "Generating cards coloured " & colour & ":"
        for card in data.cardNames:
            # Create Images:
            var
                image: Image = data.baseImagePath.readImage()
                overlay: Image = readImage(getResourcePath() & colour & "/" & card & ".png")
                font: Font = data.fontPath.readFont()

            font.size = globalFontSize.toFloat()
            image.draw(
                overlay,
                # Center overlay image:
                translate(
                    vec2(
                        (image.width.toFloat() - overlay.width.toFloat()) / 2,
                        (image.height.toFloat() - overlay.height.toFloat()) / 2
                    )
                )
            )

            proc writeText(cardName: string) =
                # Left:
                image.fillText(
                    font.typeset(cardName, vec2(image.width.toFloat() / 2, image.height.toFloat() / 2), LeftAlign, TopAlign),
                    translate(vec2(globalSafezone.toFloat(), globalSafezone.toFloat()))
                )
                # Right:
                image.fillText(
                    font.typeset(cardName, vec2(image.width.toFloat(), image.height.toFloat()), RightAlign, TopAlign),
                    translate(vec2(globalSafezone.toFloat() * -2, globalSafezone.toFloat()))
                )

            for _ in 1..2:
                card.writeText()
                image.rotate90()
                image.rotate90()

            let
                outputDir: string = &"{imageOutputDirectory}/{colour}/"
                outputFile: string = outputDir & &"{card}.png"
            echo "\tWriting to " & outputFile
            if not outputDir.dirExists(): outputDir.createDir()
            image.writeFile(outputFile)


