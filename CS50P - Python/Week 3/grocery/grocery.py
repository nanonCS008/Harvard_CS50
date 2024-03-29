groceryList = {}

while True:
    try:
        item = input().strip().lower()
        groceryList[item] = groceryList.get(item, 0) + 1
    except EOFError:
        print("")
        break
    except KeyError:
        pass

sortedList = sorted(groceryList)

for key in sortedList:
    count = groceryList[key]
    print(f"{count} {key.upper()}")
