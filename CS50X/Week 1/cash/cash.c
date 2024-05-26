#include <cs50.h>
#include <stdio.h>

int main(void)
{
    int change;
    // Define coin values
    int quarter = 25;
    int dime = 10;
    int nickel = 5;
    int penny = 1;
    // Calculate the minimum coins needed
    int coins = 0;

    // Prompt user for input until a valid positive integer is given
    do
    {
        change = get_int("Change: ");
    }
    while (change < 1);

    // Calculate the minimum coins needed
    coins += change / quarter;
    // Remaining change after using quarters
    change %= quarter;

    // Number of dimes
    coins += change / dime;
    // Remaining change after using dimes
    change %= dime;

    // Number of nickels
    coins += change / nickel;
    // Remaining change after using nickels
    change %= nickel;

    // Number of pennies
    coins += change;

    printf("%d\n", coins);
}
