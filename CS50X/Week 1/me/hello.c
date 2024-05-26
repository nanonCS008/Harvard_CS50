#include <cs50.h>
#include <stdio.h>

int main(void)
{
    // Input the user
    string name = get_string("What's your name? ");
    // Print hello with the user's name
    printf("hello, %s\n", name);
}
