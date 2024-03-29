import sys
import csv

if len(sys.argv) < 2:
    sys.exit("Too few command-line arguments")
elif len(sys.argv) > 3:
    sys.exit("Too many command-line arguments")

csvFile1 = sys.argv[1]
csvFile2 = sys.argv[2]
beforeFile = []

try:
    with open(sys.argv[1], "r") as rfile, open(sys.argv[2], "w") as wfile:
        reader = csv.DictReader(rfile)
        for row in reader:
            splited = row["name"].split(",")
            beforeFile.append({"first": splited[1].lstrip(), "last": splited[0], "house": row["house"]})

        writer = csv.DictWriter(wfile, fieldnames=["first", "last", "house"])
        writer.writerow({"first": "first", "last": "last", "house": "house"})
        for row in beforeFile:
            writer.writerow({"first": row["first"], "last": row["last"], "house": row["house"]})
except FileNotFoundError:
    sys.exit(f"Could not read {csvFile1}")
