#!/bin/bash

# chmod +x
# Code to process benchmarking datasets

command=~/Documents/Projects/OPS/task_label_projection/src/data_processors/process_dataset/config.vsh.yaml

inputdir=~/Documents/Projects/OPS/datasets
outputdir=~/Documents/Projects/OPS/task_label_projection/resources

# List of datasets
datasets=("GTEX_v9.h5ad" "Diabetic_Kidney_Disease.h5ad")

for dataset in "${datasets[@]}"; do
  viash run "$command" -- \
    --input "$inputdir/$dataset" \
    --output_train "$outputdir/${dataset%.h5ad}/train.h5ad" \
    --output_test "$outputdir/${dataset%.h5ad}/test.h5ad" \
    --output_solution "$outputdir/${dataset%.h5ad}/solution.h5ad" \
    --seed 22 \
    --num_test_batches 7
done

