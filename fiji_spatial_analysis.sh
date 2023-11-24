#!/bin/bash

#SBATCH --job-name=fiji_spatial
#SBATCH --ntasks=1
#SBATCH --time=0:20:00
#SBATCH --array=0-579
#SBATCH --partition=cpu
#SBATCH --mem=16G

raw_files=(/camp/stp/lm/inputs/tybulewiczv/Robert/iSIM*/220706*/*)
prob_files=(/camp/stp/lm/working/barryd/Working_Data/Tybulewicz/Robert/pix_probs/*)

ml Java/1.8
/home/camp/barryd/working/barryd/hpc/java/fiji/ImageJ-linux64 -Xmx16G -- --headless --console -macro "/home/camp/barryd/working/barryd/Working_Data/Tybulewicz/Robert/scripts/spatial_analysis.ijm" "${prob_files[$SLURM_ARRAY_TASK_ID]},${raw_files[$SLURM_ARRAY_TASK_ID]}"