#include "helpers.h"
#include <math.h>

// Convert image to grayscale
void grayscale(int height, int width, RGBTRIPLE image[height][width])
{
    // Loop over each pixel
    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            // Calculate the average of the RGB values
            BYTE average =
                round((image[i][j].rgbtRed + image[i][j].rgbtGreen + image[i][j].rgbtBlue) / 3.0);

            // Set each color component to the average
            image[i][j].rgbtRed = average;
            image[i][j].rgbtGreen = average;
            image[i][j].rgbtBlue = average;
        }
    }
    return;
}

// Reflect image horizontally
void reflect(int height, int width, RGBTRIPLE image[height][width])
{
    // Loop over each row
    for (int i = 0; i < height; i++)
    {
        // Swap pixels from left to right
        for (int j = 0; j < width / 2; j++)
        {
            // Temporary storage for swapping
            RGBTRIPLE temp = image[i][j];
            image[i][j] = image[i][width - 1 - j];
            image[i][width - 1 - j] = temp;
        }
    }
    return;
}

// Blur image
void blur(int height, int width, RGBTRIPLE image[height][width])
{
    // Create a copy of the image to store the new values
    RGBTRIPLE copy[height][width];

    // Loop over each pixel
    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            int redSum = 0, greenSum = 0, blueSum = 0;
            int count = 0;

            // Loop over the 3x3 grid surrounding the pixel
            for (int di = -1; di <= 1; di++)
            {
                for (int dj = -1; dj <= 1; dj++)
                {
                    int ni = i + di;
                    int nj = j + dj;

                    // Check if the neighboring pixel is within bounds
                    if (ni >= 0 && ni < height && nj >= 0 && nj < width)
                    {
                        redSum += image[ni][nj].rgbtRed;
                        greenSum += image[ni][nj].rgbtGreen;
                        blueSum += image[ni][nj].rgbtBlue;
                        count++;
                    }
                }
            }

            // Calculate the average
            copy[i][j].rgbtRed = round(redSum / (float) count);
            copy[i][j].rgbtGreen = round(greenSum / (float) count);
            copy[i][j].rgbtBlue = round(blueSum / (float) count);
        }
    }

    // Copy the blurred values back to the original image
    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            image[i][j] = copy[i][j];
        }
    }
    return;
}

// Detect edges
void edges(int height, int width, RGBTRIPLE image[height][width])
{
    // Sobel kernels for edge detection
    int Gx[3][3] = {{-1, 0, 1}, {-2, 0, 2}, {-1, 0, 1}};

    int Gy[3][3] = {{-1, -2, -1}, {0, 0, 0}, {1, 2, 1}};

    // Create a copy of the image to store the new values
    RGBTRIPLE copy[height][width];

    // Loop over each pixel
    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            float GxRed = 0, GxGreen = 0, GxBlue = 0;
            float GyRed = 0, GyGreen = 0, GyBlue = 0;

            // Loop over the 3x3 grid surrounding the pixel
            for (int di = -1; di <= 1; di++)
            {
                for (int dj = -1; dj <= 1; dj++)
                {
                    int ni = i + di;
                    int nj = j + dj;

                    // Check if the neighboring pixel is within bounds
                    if (ni >= 0 && ni < height && nj >= 0 && nj < width)
                    {
                        GxRed += image[ni][nj].rgbtRed * Gx[di + 1][dj + 1];
                        GxGreen += image[ni][nj].rgbtGreen * Gx[di + 1][dj + 1];
                        GxBlue += image[ni][nj].rgbtBlue * Gx[di + 1][dj + 1];

                        GyRed += image[ni][nj].rgbtRed * Gy[di + 1][dj + 1];
                        GyGreen += image[ni][nj].rgbtGreen * Gy[di + 1][dj + 1];
                        GyBlue += image[ni][nj].rgbtBlue * Gy[di + 1][dj + 1];
                    }
                }
            }

            // Calculate the gradient magnitude
            int red = round(sqrt(GxRed * GxRed + GyRed * GyRed));
            int green = round(sqrt(GxGreen * GxGreen + GyGreen * GyGreen));
            int blue = round(sqrt(GxBlue * GxBlue + GyBlue * GyBlue));

            // Cap the values at 255
            copy[i][j].rgbtRed = (red > 255) ? 255 : red;
            copy[i][j].rgbtGreen = (green > 255) ? 255 : green;
            copy[i][j].rgbtBlue = (blue > 255) ? 255 : blue;
        }
    }

    // Copy the edge-detected values back to the original image
    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            image[i][j] = copy[i][j];
        }
    }
    return;
}
