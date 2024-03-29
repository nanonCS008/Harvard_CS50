def main():
    plate = input("Plate: ")
    if is_valid(plate):
        print("Valid")
    else:
        print("Invalid")


def is_valid(s):
    if begin(s) and length(s) and marks(s) and numbersInMiddle(s) and firstDigit(s):
        return True

    return False


def begin(x):
    return x[0:2].isalpha()

def length(y):
    return len(y) >= 2 and len(y) <= 6

def marks(z):
    return z.isalnum()

def numbersInMiddle(w):
    valid = False
    i = 2
    while i < len(w):
        if w[i].isdigit():
            break
        i += 1

    if i < len(w):
        for char in w [i:-1]:
            if char.isdigit():
                valid = True
            else:
                return False
    else:
        return True

    return valid

def firstDigit(g):
    second = False
    i = 2
    while i < len(g):
        if g[i].isdigit():
            break
        i += 1

    if i < len(g):
        for char in g[i:-1]:
            if char != '0' or second:
                return True
            else:
                return False
    else:
        return True

main()
