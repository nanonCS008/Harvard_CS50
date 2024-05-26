def get_int(prompt):
    while True:
        try:
            value = int(input(prompt))
            if 1 <= value <= 8:
                return value
            else:
                print("Please enter a number between 1 and 8.")
        except ValueError:
            print("Please enter a valid integer.")


def print_half_pyramid(height):
    for i in range(1, height + 1):
        spaces = ' ' * (height - i)
        hashes = '#' * i
        print(spaces + hashes)


def main():
    height = get_int("Height: ")
    print_half_pyramid(height)


if __name__ == "__main__":
    main()
