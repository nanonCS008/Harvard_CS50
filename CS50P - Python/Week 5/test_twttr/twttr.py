def main():
    word = input("Input: ")
    print(shorten(word))


def shorten(word):
    finished = ""
    for char in word:
        if char not in "aeiouAEIOU":
            continue
        else:
            finished += char

    return finished

if __name__ == "__main__":
    main()
