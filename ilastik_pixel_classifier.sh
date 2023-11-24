#!/bin/bash

#SBATCH --job-name=ilastik-pix-class
#SBATCH --time=1:00:00
#SBATCH --array=0-248
#SBATCH --partition=cpu
#SBATCH --mem=128G

files=(/camp/stp/lm/working/barryd/Working_Data/Tybulewicz/Robert/h5_files/*E3*)

srun /home/camp/barryd/working/barryd/hpc/apps/ilastik-1.3.3post3-Linux/run_ilastik.sh --headless --project="/home/camp/barryd/working/barryd/Working_Data/Tybulewicz/Robert/MyProject_pix_pred.ilp" --export_source="Probabilities" --export_dtype="uint16" --pipeline_result_drange="(0.0,1.0)" --export_drange="(0,65535)" --output_format="multipage tiff"  --output_filename_format="/home/camp/barryd/working/barryd/Working_Data/Tybulewicz/Robert/pix_probs/{nickname}_{result_type}.tiff" "${files[$SLURM_ARRAY_TASK_ID]}"