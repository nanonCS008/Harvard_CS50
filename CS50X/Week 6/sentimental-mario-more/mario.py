def get_int(prompt):
    while True:
        try:
            value = int(input(prompt))
            if 1 <= value <= 8:
                return value
            else:
                print("Height must be a positive integer between 1 and 8.")
        except ValueError:
            print("Invalid input. Please enter a positive integer between 1 and 8.")


def printPyramid(height):
    for i in range(1, height + 1):
        # Print leading spaces for the left pyramid
        print(" " * (height - i), end="")
        # Print the left pyramid
        print("#" * i, end="")
        # Print the gap between the pyramids
        print("  ", end="")
        # Print the right pyramid
        print("#" * i)


def main():
    height = get_int("Height: ")
    printPyramid(height)


if __name__ == "__main__":
    main()
