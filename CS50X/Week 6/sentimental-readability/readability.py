import re


def count_letters(text):
    # Count letters by filtering out non-letter characters and counting the rest
    letters = re.findall(r'[a-zA-Z]', text)
    return len(letters)


def count_words(text):
    # Count words by splitting the text by whitespace
    words = text.split()
    return len(words)


def count_sentences(text):
    # Count sentences by counting ., !, and ?
    sentences = re.findall(r'[.!?]', text)
    return len(sentences)


def coleman_liau_index(text):
    letters = count_letters(text)
    words = count_words(text)
    sentences = count_sentences(text)

    # Calculate L and S
    L = letters / words * 100
    S = sentences / words * 100

    # Calculate the Coleman-Liau index
    index = 0.0588 * L - 0.296 * S - 15.8
    return index


def main():
    # Get user input
    text = input("Text: ")

    # Calculate the readability grade
    index = round(coleman_liau_index(text))

    # Print the grade level
    if index < 1:
        print("Before Grade 1")
    elif index >= 16:
        print("Grade 16+")
    else:
        print(f"Grade {index}")


if __name__ == "__main__":
    main()
