#!/bin/bash

input_path="$1"

# Column definitions.
row_id_col="\$0"
block_delay_col="\$3"
block_number_col="\$4"
local_timestamp_col="\$5"
block_timestamp_col="\$6"

# This plot subtracts the block timestamp from the timestamp when Parity prints
# the info about that block.
plot_block_delay () {
    output_path="$1"
    gnuplot > "$output_path" << EOF
        set terminal pngcairo
        set datafile separator ' '
    
        # Compute the block number, with the first block 0.
        block_num(b) = ($row_id_col > 0 ? b - first_block : \
                (first_block = b, 0))
    
        # Compute mean by fitting a constant function.
        f(x) = mean_delay
        fit f(x) '$input_path' using ($block_number_col):($block_delay_col) via mean_delay
    
        # Get min/max.
        stats '$input_path' using ($block_delay_col) nooutput
        max_y = STATS_max
    
        # Plot.
        set label 1 gprintf("Mean = %g", mean_delay) at 10, max_y - 10
        set yrange [0:max_y]
        plot '$input_path' using (block_num($block_number_col)): \
                ($block_delay_col) with points pt 2
EOF
}

plot_block_delay "block_delay.png"
