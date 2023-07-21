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
    echo "Generating cards..."
    for colour, data in colours:
        echo "Generating cards coloured " & colour & ":"
        for card in data.cardNames:
            # Create Images:
            var
                image: Image = data.baseImagePath.readImage()
                overlay: Image = readImage(getResourcePath() & colour & "/" & card & ".png")
                font: Font = data.fontPath.readFont()

            # Draw overlay image onto image:
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

            # Render text to image:
            var textImage: Image = newImage(image.width, image.height)
            font.size = globalFontSize.toFloat()
            proc writeText(cardName: string) =
                # Left:
                textImage.fillText(
                    font.typeset(cardName,
                    vec2(
                        toFloat(textImage.width), toFloat(textImage.height)),
                        LeftAlign, TopAlign
                    ),
                    translate(
                        vec2(float globalSafezone, float globalSafezone)
                    )
                )
                # Right:
                textImage.fillText(
                    font.typeset(cardName,
                    vec2(
                        toFloat(textImage.width), toFloat(textImage.height)),
                        RightAlign, TopAlign
                    ),
                    translate(
                        vec2(float -globalSafezone, float globalSafezone)
                    )
                )

            # Write text onto text image:
            for _ in 1..2:
                card.writeText()
                textImage.rotate90()
                textImage.rotate90()


            # Apply shaders to text image:
            if drawShadowOnTextLayer:
                let shadow = textImage.shadow(
                    offset = vec2(2, 2),
                    spread = 2,
                    blur = 10,
                    color = rgba(shadowColours[0], shadowColours[1], shadowColours[2], shadowColours[3])
                )
                image.draw(shadow)

            # Combine text image with image:
            image.draw(textImage)

            let
                outputDir: string = &"{imageOutputDirectory}/{colour}/"
                outputFile: string = outputDir & &"{card}.png"
            echo "\tWriting to " & outputFile
            if not outputDir.dirExists(): outputDir.createDir()
            image.writeFile(outputFile)


