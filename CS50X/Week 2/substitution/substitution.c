#include <cs50.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define ALPHABET_LENGTH 26

int validKey(const char *key);
void encryptMessage(const char *plaintext, const char *key);

int main(int argc, char *argv[])
{
    // Check for correct number of command-line arguments
    if (argc != 2)
    {
        printf("Usage: %s key\n", argv[0]);
        return 1;
    }

    // Check if the key is valid
    const char *key = argv[1];
    if (!validKey(key))
    {
        printf("Invalid key. Key must be 26 characters long, "
               "contain only alphabetic characters, and each letter exactly once.\n");
        return 1;
    }

    // Get plaintext input from the user
    string plaintext = get_string("plaintext: ");

    // Encrypt the plaintext using the key
    printf("ciphertext: ");
    encryptMessage(plaintext, key);

    return 0;
}

int validKey(const char *key)
{
    if (strlen(key) != ALPHABET_LENGTH)
    {
        return 0;
    }

    // Initialize all counts to 0
    int count[ALPHABET_LENGTH] = {0};
    for (int i = 0; i < ALPHABET_LENGTH; i++)
    {
        if (!isalpha(key[i]))
        {
            // Key contains non-alphabetic character
            return 0;
        }

        // Count occurrences of each letter (uppercase)
        count[toupper(key[i]) - 'A']++;
    }

    for (int i = 0; i < ALPHABET_LENGTH; i++)
    {
        if (count[i] != 1)
        {
            // Key contains duplicate letter(s)
            return 0;
        }
    }

    // Key is valid
    return 1;
}

void encryptMessage(const char *plaintext, const char *key)
{
    for (int i = 0; plaintext[i] != '\0'; i++)
    {
        if (isalpha(plaintext[i]))
        {
            char encryptedChar;
            if (islower(plaintext[i]))
            {
                encryptedChar = tolower(key[tolower(plaintext[i]) - 'a']);
            }
            else
            {
                encryptedChar = toupper(key[toupper(plaintext[i]) - 'A']);
            }
            printf("%c", encryptedChar);
        }
        else
        {
            printf("%c", plaintext[i]);
        }
    }
    printf("\n");
}
