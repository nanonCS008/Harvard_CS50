def main():
    x, y = fraction()
    percentage = round((x / y) * 100)

    if percentage <= 1:
        print("E")
    elif percentage >= 99:
        print("F")
    else:
        print(f"{percentage}%")


def fraction():
    while True:
        try:
            fraction = input("Fraction: ")
            x, y = fraction.split("/")
            x = int(x)
            y = int(y)

            if x <= 0 or y <= 0 or x > y:
                raise ValueError
            return x, y
        except (ValueError, ZeroDivisionError):
            pass

main()
