def main():
    time = input("What time is it? ")
    time = convert(time)

    if 7.0 <= time <= 8.0:
        print("breakfast time")
    elif 12.0 <= time < 18.0:
        print("lunch time")
    elif 18.0 <= time:
        print("dinner time")

def convert(time):
    hours, minutes = time.split(":")
    hours = int(hours)
    minutes = int(minutes)
    hours = hours + (minutes / 60)

    return hours

if __name__ == "__main__":
    main()
