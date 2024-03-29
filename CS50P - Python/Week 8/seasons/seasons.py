from datetime import date
import inflect
import sys


def main():
    birthday = input("Date of Birth: ")
    print(calculateMinuteAsWords(birthday))


def calculateMinuteAsWords(birth):
    try:
        year, month, day = birth.split("-")
        birth = date(int(year), int(month), int(day))
    except ValueError:
        sys.exit("Invalid date")

    p = inflect.engine()
    age = (date.today() - birth).days * 24 * 60
    return p.number_to_words(age, andword="").capitalize() + " minutes"


if __name__ == "__main__":
    main()
