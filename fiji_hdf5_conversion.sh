#!/bin/bash

#SBATCH --job-name=fiji-conversion
#SBATCH --ntasks=1
#SBATCH --time=1:00:00
#SBATCH --array=0-248
#SBATCH --partition=cpu
#SBATCH --mem=128G

files=(/camp/stp/lm/inputs/tybulewiczv/Robert/iSIM*/220706*/*E3*)

ml Java/1.8
/home/camp/barryd/working/barryd/hpc/java/fiji/ImageJ-linux64 -Xmx128G -- --headless --console -macro "/home/camp/barryd/working/barryd/Working_Data/Tybulewicz/Robert/scripts/HDF5_conversion.ijm" "${files[$SLURM_ARRAY_TASK_ID]},/home/camp/barryd/working/barryd/Working_Data/Tybulewicz/Robert/h5_files"