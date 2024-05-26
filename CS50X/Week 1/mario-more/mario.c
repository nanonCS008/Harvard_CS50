#include <cs50.h>
#include <stdio.h>

void print_row(int bricks, int row);

int main(void)
{
    // Prompt the user for the pyramid's height
    int n;
    do
    {
        n = get_int("Height: ");
    }
    while (n <= 0);

    // Print a pyramid of that height
    for (int i = 0; i < n; i++)
    {
        // Print row of bricks
        print_row(i, n);
    }
}

void print_row(int bricks, int row)
{
    // Print spaces
    for (int i = 0; i < row - bricks - 1; i++)
    {
        printf(" ");
    }

    // Print bricks
    for (int j = 0; j <= bricks; j++)
    {
        printf("#");
    }

    // Print spaces
    printf("  ");

    // Print bricks
    for (int k = 0; k <= bricks; k++)
    {
        printf("#");
    }

    printf("\n");
}
