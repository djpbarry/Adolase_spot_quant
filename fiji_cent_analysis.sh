#!/bin/bash

#SBATCH --job-name=fiji_cent
#SBATCH --ntasks=1
#SBATCH --time=0:01:00
#SBATCH --array=0-2946
#SBATCH --partition=cpu
#SBATCH --mem=16G

seg_files=(/camp/stp/lm/working/barryd/Working_Data/Tybulewicz/Robert/segs/*)

ml Java/1.8
/home/camp/barryd/working/barryd/hpc/java/fiji/ImageJ-linux64 -Xmx16G -- --headless --console -macro "/home/camp/barryd/working/barryd/Working_Data/Tybulewicz/Robert/scripts/GetSpotCentroids.ijm" "${seg_files[$SLURM_ARRAY_TASK_ID]}"