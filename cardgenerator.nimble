# Package

version       = "1.0.0"
author        = "nirokay"
description   = "A simple generator for cards."
license       = "GPL-3.0-only"
installExt    = @["nim"]
bin           = @["cardgenerator"]


# Dependencies

requires "nim >= 1.6.10", "pixie"
