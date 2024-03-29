def main():
    text = input("Input: ")
    print(omittedVowels(text))

def omittedVowels(text):
    finished = ""
    for char in text:
        if char in "aeiouAEIOU":
            continue
        else:
            finished += char

    return finished

main()
