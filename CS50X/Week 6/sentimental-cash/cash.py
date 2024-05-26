from cs50 import get_float


def main():
    # Prompt user for the amount of change owed
    while True:
        change = get_float("Change owed: ")
        if change >= 0:
            break

    # Convert dollars to cents to avoid floating-point imprecision
    cents = round(change * 100)

    # Initialize the count of coins
    coins = 0

    # Calculate the number of quarters
    coins += cents // 25
    cents %= 25

    # Calculate the number of dimes
    coins += cents // 10
    cents %= 10

    # Calculate the number of nickels
    coins += cents // 5
    cents %= 5

    # Calculate the number of pennies
    coins += cents

    # Output the total number of coins
    print(coins)


if __name__ == "__main__":
    main()
