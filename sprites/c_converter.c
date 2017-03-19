#include <stdio.h>
#include "TitlefontCData.c"

int global_block_counter = 0;


unsigned char process_8_bits(int index)
{
    unsigned char pixel_line = 0x0;
    for (int i = 0; i < 8; i++, index++)
    {
        if (new_piskel_data[0][index] == 0x0)
        {
            pixel_line = pixel_line << 1;
        }
        else {
            pixel_line = pixel_line << 1;
            pixel_line |= 0x1;
        }
    }
    return pixel_line;
}

void process_color_cell(FILE *outbuffer, int index)
{
    //  Starts at the current index and figures out next 7 bytes and writes it as a block
    unsigned char cell_lines[8] = {0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0};
    
    int targetIndex = index;
    for (int i = 0; i < 8; i++)
    {
        printf("\tLooking at target index for 8bit read point at %d\n", targetIndex);
        cell_lines[i] = process_8_bits(targetIndex);
        // Increment the index
        targetIndex += 128;
    }

    // At the end, print out bytes as a block

    if (global_block_counter == 32)
    {
        fprintf(outbuffer, "halfway:\n");   
    } 
    for (int i = 0; i < 8; i++) {
        fprintf(outbuffer, "\tdefb %d\n", cell_lines[i]);
    }

    fprintf(outbuffer, "\n\n");

    global_block_counter++;

}

void iterate_array(FILE *outbuffer)
{
    int total_size = NEW_PISKEL_FRAME_WIDTH*NEW_PISKEL_FRAME_HEIGHT;

    int col_counter = 0;

    // Group 8 pixels at a time
    for (int j = 0; j < total_size; )
    {
        printf("Processing color cell at index %d\n", j);
        process_color_cell(outbuffer, j);

        // Update the column counter to go to the next one
        col_counter++;
        if (col_counter < 16) {
            j += 8;
        } else {
            // reset column counter and wind up j to appropriate value
            printf("RESETTING: Current col_c %d j %d\n", col_counter, j);
            col_counter = 0;
            j -= 120;
            j += (NEW_PISKEL_FRAME_WIDTH*8);
            printf("RESETTING: New col_c %d j %d\n", col_counter, j);
            printf("\n\n");
            
        }

    }

}

int main(void)
{
    // Open the file
    FILE *fp = fopen("titlefont_data.txt", "w");

    iterate_array(fp);
    printf("Generated %d blocks\n", global_block_counter);

}