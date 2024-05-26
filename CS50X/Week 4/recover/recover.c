#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

// Define the block size
#define BLOCK_SIZE 512

// Function to check if a block indicates the start of a JPEG
bool header(uint8_t *buffer)
{
    return buffer[0] == 0xff && buffer[1] == 0xd8 && buffer[2] == 0xff &&
           (buffer[3] & 0xf0) == 0xe0;
}

int main(int argc, char *argv[])
{
    // Ensure proper usage
    if (argc != 2)
    {
        fprintf(stderr, "Usage: ./recover IMAGE\n");
        return 1;
    }

    // Open the forensic image file
    FILE *card = fopen(argv[1], "r");
    if (card == NULL)
    {
        fprintf(stderr, "Could not open %s.\n", argv[1]);
        return 1;
    }

    // Buffer to store a block of data
    uint8_t buffer[BLOCK_SIZE];

    // Variables to keep track of output JPEG file
    FILE *img = NULL;
    char filename[8];
    int file_count = 0;

    // Read through the card image file block by block
    while (fread(buffer, sizeof(uint8_t), BLOCK_SIZE, card) == BLOCK_SIZE)
    {
        // Check if the block is the start of a new JPEG
        if (header(buffer))
        {
            // If already writing a JPEG, close it
            if (img != NULL)
            {
                fclose(img);
            }

            // Create a new file for the new JPEG
            sprintf(filename, "%03d.jpg", file_count++);
            img = fopen(filename, "w");
            if (img == NULL)
            {
                fprintf(stderr, "Could not create output JPEG %s.\n", filename);
                fclose(card);
                return 1;
            }
        }

        // If currently writing to a JPEG file, write the block to it
        if (img != NULL)
        {
            fwrite(buffer, sizeof(uint8_t), BLOCK_SIZE, img);
        }
    }

    // Close any remaining files
    if (img != NULL)
    {
        fclose(img);
    }
    fclose(card);

    return 0;
}
