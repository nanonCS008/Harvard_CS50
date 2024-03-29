import random

def main():
    level = get_level()
    score = 0

    for _ in range(10):
        x = generate_integer(level)
        y = generate_integer(level)
        problem = f"{x} + {y} = "
        correctAnswer = x + y
        tries = 0

        while tries < 3:
            try:
                userAnswer = int(input(problem))
            except ValueError:
                print("EEE")
                tries += 1
                continue

            if userAnswer == correctAnswer:
                score += 1
                break
            else:
                print("EEE")
                tries += 1

        if tries == 3:
            print(f"Correct answer: {correctAnswer}")

    print(f"Score: {score}")


def get_level():
    while True:
        try:
            level = int(input("Level: "))

            if level not in [1, 2, 3]:
                raise ValueError
            else:
                return level
        except ValueError:
            pass


def generate_integer(level):
    if level == 1:
        return random.randint(0 , 9)
    elif level == 2:
        return random.randint(10, 99)
    elif level == 3:
        return random.randint(100, 999)


if __name__ == "__main__":
    main()
