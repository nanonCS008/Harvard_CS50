import random

def level():
    while True:
        try:
            level = int(input("Level: "))

            if level <= 0:
                continue
            else:
                return level
        except ValueError:
            pass

def game(level):
    number = random.randint(1, level)

    while True:
        try:
            guess = int(input("Guess: "))

            if guess <= 0:
                continue
            elif guess < number:
                print("Too small!")
            elif guess > number:
                print("Too large!")
            else:
                print("Just right!")
                break
        except ValueError:
            pass

def main():
    game(level())

if __name__ == "__main__":
    main()
