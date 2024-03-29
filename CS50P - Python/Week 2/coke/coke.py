totalInsert = 0

while totalInsert < 50:
    coin = int(input("Insert Coin: "))

    if coin == 25 or coin == 10 or coin == 5:
        totalInsert += coin
        if totalInsert < 50:
            print("Amount Due:", 50 - totalInsert)
    else:
        print("Amount Due:", 50 - totalInsert)

changeOwed = totalInsert - 50
print("Change Owed:", changeOwed)
