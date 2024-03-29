import inflect

def adieu(names):
    p = inflect.engine()
    count = len(names)

    if count == 1:
        print(f"Adieu, adieu, to {names[0]}")
    elif count == 2:
        print(f"Adieu, adieu, to {names[0]} and {names[1]}")
    else:
        formatted_names = ", ".join(names[:-1])
        formatted_names += f", and {names[-1]}"
        print(f"Adieu, adieu, to {formatted_names}")

def main():
    names = []

    try:
        while True:
            name = input("Name: ")
            names.append(name)
    except EOFError:
        if len(names) > 0:
            adieu(names)
        else:
            print("Nothing")

main()
