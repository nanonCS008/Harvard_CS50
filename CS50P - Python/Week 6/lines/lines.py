import sys

if len(sys.argv) < 2:
    sys.exit("Too few command-line arguments")
elif len(sys.argv) > 2:
    sys.exit("Too many command-line arguments")
elif not sys.argv[1].endswith(".py"):
    sys.exit("Not a Python file")

pyFile = sys.argv[1]

try:
    with open(pyFile, "r") as file:
        count = 0
        for line in file:
            line = line.strip()
            if not line.lstrip().startswith("#") and line.lstrip() != "":
                count += 1
    print(count)
except FileNotFoundError:
    sys.exit("File does not exist")
except ValueError:
    sys.exit(1)

