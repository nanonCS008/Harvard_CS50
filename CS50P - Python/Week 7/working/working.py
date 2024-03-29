import re
import sys


def main():
    print(convert(input("Hours: ")))


def convert(s):
    pattern = r"^([0-9][0-2]?):?([0-5][0-9])? (AM|PM)? to ([0-9][0-2]?):?([0-5][0-9])? (AM|PM)?$"

    if match := re.search(pattern, s):
        hour1, minute1, ampm1, hour2, minute2, ampm2 = match.groups()
        hour1 = int(hour1)
        hour2 = int(hour2)

        if 12 < hour1 < 1 or 12 < hour2 < 1:
            raise ValueError

        time1 = formatted(hour1, minute1, ampm1)
        time2 = formatted(hour2, minute2, ampm2)

        return f"{time1} to {time2}"
    else:
        raise ValueError


def formatted(hour, minute, ampm):
    if ampm == "PM":
        if hour == 12:
            hour = 12
        else:
            hour += 12
    else:
        if hour == 12:
            hour = 0

    if minute == None:
        minute = ":00"
        result = f"{hour:02}{minute:02}"
    else:
        result = f"{hour:02}:{minute:02}"

    return result


if __name__ == "__main__":
    main()
