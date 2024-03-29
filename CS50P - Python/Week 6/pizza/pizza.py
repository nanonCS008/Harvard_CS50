import sys
import csv
from tabulate import tabulate

if len(sys.argv) < 2:
    print("Too few command-line arguments")
    sys.exit(1)
elif len(sys.argv) > 2:
    print("Too many command-line arguments")
    sys.exit(1)

csvFile = sys.argv[1]

if not csvFile.endswith(".csv"):
    print("Not a CSV file")
    sys.exit(1)

try:
    with open(csvFile) as file:
        reader = csv.DictReader(file)
        pizzas = [row for row in reader]

    table = tabulate(pizzas, headers = "keys", tablefmt =  "grid")
    print(table)
except FileNotFoundError:
    print("File does not exist")
    sys.exit(1)
except ValueError:
    sys.exit(1)
