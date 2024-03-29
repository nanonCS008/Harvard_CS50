def convert(str):
    str = str.replace(":)", "🙂")
    str = str.replace(":(", "🙁")
    return str

def main():
    sentence = input()
    print(convert(sentence))

main()
