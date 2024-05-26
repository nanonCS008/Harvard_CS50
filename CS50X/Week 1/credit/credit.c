#include <cs50.h>
#include <stdio.h>

bool validCreditCard(long cardNumber);
string creditCardType(long cardNumber);

int main(void)
{
    long cardNumber;

    // Prompt the user for a credit card number
    do
    {
        cardNumber = get_long("Number: ");
    }
    while (cardNumber <= 0);

    // Validate the credit card number using Luhn's Algorithm
    if (validCreditCard(cardNumber))
    {
        printf("%s\n", creditCardType(cardNumber));
    }
    else
    {
        printf("INVALID\n");
    }
}

// Function to check if a credit card number is valid using Luhn's Algorithm
bool validCreditCard(long cardNumber)
{
    int sum = 0;
    int count = 0;

    while (cardNumber > 0)
    {
        // Get the last digit
        int digit = cardNumber % 10;

        if (count % 2 == 0)
        {
            // If the digit is at an even position, add it directly
            sum += digit;
        }
        else
        {
            // If the digit is at an odd position, multiply it by 2 and add the digits of the
            // product
            int temp = 2 * digit;
            int x = 0;
            while (temp > 0)
            {
                x += temp % 10;
                temp /= 10;
            }

            sum += x;
        }

        // Move to the next digit
        cardNumber /= 10;
        count++;
    }

    // Check if the total sum's last digit is 0
    return sum % 10 == 0;
}

string creditCardType(long cardNumber)
{
    string cardType = "";
    long temp = cardNumber;

    // Extract the first digit(s) of the card number
    while (cardNumber >= 100)
    {
        cardNumber /= 10;
    }

    int numDigits = 0;
    while (temp != 0)
    {
        temp /= 10;
        numDigits++;
    }

    // Determine the card type based on the first digit(s)
    if ((numDigits == 13 || numDigits == 16) && (cardNumber >= 40 && cardNumber <= 49))
    {
        cardType = "VISA";
    }
    else if (numDigits == 16 && (cardNumber >= 51 && cardNumber <= 55))
    {
        cardType = "MASTERCARD";
    }
    else if (numDigits == 15 && (cardNumber == 34 || cardNumber == 37))
    {
        cardType = "AMEX";
    }
    else
    {
        cardType = "INVALID";
    }

    return cardType;
}
