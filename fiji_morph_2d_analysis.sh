#!/bin/bash

#SBATCH --job-name=fiji_morph_2d
#SBATCH --ntasks=1
#SBATCH --time=0:01:00
#SBATCH --array=0-896
#SBATCH --partition=cpu
#SBATCH --mem=16G

seg_files=(/nemo/stp/lm/working/barryd/Working_Data/Tybulewicz/Robert/segs/*cell*)

ml Java/1.8
/nemo/stp/lm/working/barryd/hpc/java/fiji/ImageJ-linux64 -Xmx16G -- --headless --console -macro "/nemo/stp/lm/working/barryd/Working_Data/Tybulewicz/Robert/scripts/analyse_cell_morph.ijm" "${seg_files[$SLURM_ARRAY_TASK_ID]}"