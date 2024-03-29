import sys
from pyfiglet import Figlet
from random import choice

if len(sys.argv) == 1:
    figlet = Figlet()
    fonts = figlet.getFonts()
    fontName = choice(fonts)
elif len(sys.argv) == 3 and (sys.argv[1] == "-f" or sys.argv[1] == "--font"):
    fontName = sys.argv[2]
else:
    print("Invalid usage")
    sys.exit(1)

figlet = Figlet(font = fontName)
text = input("Input: ")
print("Output:\n", figlet.renderText(text))
