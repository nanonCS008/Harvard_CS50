#include <cs50.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>

bool only_digits(string s);
char rotate(char c, int n);

int main(int argc, string argv[])
{
    // Check for correct number of command-line arguments
    if (argc != 2)
    {
        printf("Usage: ./caesar key\n");
        return 1;
    }

    // Check if key is composed of only digits
    if (!only_digits(argv[1]))
    {
        printf("Usage: ./caesar key\n");
        return 1;
    }

    // Convert key to integer
    int key = atoi(argv[1]);

    // Get plaintext from user
    string plaintext = get_string("plaintext: ");

    // Encrypt and print ciphertext
    printf("ciphertext: ");
    for (int i = 0; plaintext[i] != '\0'; i++)
    {
        printf("%c", rotate(plaintext[i], key));
    }

    printf("\n");
    return 0;
}

bool only_digits(string s)
{
    for (int i = 0; s[i] != '\0'; i++)
    {
        if (!isdigit(s[i]))
        {
            return false;
        }
    }

    return true;
}

char rotate(char c, int n)
{
    if (isalpha(c))
    {
        char base = isupper(c) ? 'A' : 'a';
        return ((c - base + n) % 26) + base;
    }

    return c;
}
