import re


def get_card_type(number):
    # Return the type of credit card based on the card number.
    if re.match(r'^3[47][0-9]{13}$', number):
        return "AMEX"
    elif re.match(r'^5[1-5][0-9]{14}$', number):
        return "MASTERCARD"
    elif re.match(r'^4[0-9]{12}(?:[0-9]{3})?$', number):
        return "VISA"
    else:
        return "INVALID"


def luhnAlgorithm(number):
    # Use the Luhn algorithm to validate the credit card number.
    total = 0
    num_digits = len(number)
    parity = num_digits % 2

    for i, digit in enumerate(number):
        digit = int(digit)
        if i % 2 == parity:
            digit *= 2
        if digit > 9:
            digit -= 9
        total += digit

    return total % 10 == 0


def main():
    card_number = input("Number: ").strip()

    if not card_number.isdigit():
        print("INVALID")
        return

    card_type = get_card_type(card_number)

    if card_type != "INVALID" and luhnAlgorithm(card_number):
        print(card_type)
    else:
        print("INVALID")


if __name__ == "__main__":
    main()
