months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
]

while True:
    try:
        date = input("Date: ")

        parts = date.split()

        if len(parts) == 3:
            if "," in parts[1]:
                month = months.index(parts[0]) + 1
                day = int(parts[1].rstrip(","))
                year = int(parts[2])
            else:
                raise ValueError
        else:
            parts = date.split("/")
            month = int(parts[0])
            day = int(parts[1])
            year = int(parts[2])

        if month < 1 or month > 12 or day < 1 or day > 31 or year < 1:
            raise ValueError
        else:
            break
    except (ValueError, IndexError):
        pass

print(f"{year:04d}-{month:02d}-{day:02d}")
