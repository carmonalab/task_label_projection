#!/bin/bash

# Usage: chmod +x script.sh && ./script.sh
# This script runs prediction methods on datasets using Viash.

methoddir=~/Documents/Projects/OPS/task_label_projection/src/
inputdir=~/Documents/Projects/OPS/task_label_projection/resources
outputdir=~/Documents/Projects/OPS/task_label_projection/results/predictions

# List of datasets
datasets=("GTEX_v9" "Diabetic_Kidney_Disease")
# List of methods
methods=("majority_vote" "random_labels" "true_labels" "knn" "logistic_regression" "seurat_transferdata" "naive_bayes" "singler")


for dataset in "${datasets[@]}"; do
  for method in "${methods[@]}"; do

    # Search for config in either folder
    config_file=""
    if [[ -f "$methoddir/methods/$method/config.vsh.yaml" ]]; then
      config_file="$methoddir/methods/$method/config.vsh.yaml"
    elif [[ -f "$methoddir/control_methods/$method/config.vsh.yaml" ]]; then
      config_file="$methoddir/control_methods/$method/config.vsh.yaml"
    else
      echo "Warning: $method not found in either methods/ or control_methods/. Skipping."
      continue
    fi

    output_file="$outputdir/$dataset/prediction_$method.h5ad"

    if [[ -f "$output_file" ]]; then
      echo "Skipping $method on $dataset: output already exists."
      continue
    fi

    echo "Running $method on $dataset..."
    viash run "$config_file" -- \
      --input_train "$inputdir/$dataset/train.h5ad" \
      --input_test "$inputdir/$dataset/test.h5ad" \
      --input_solution "$inputdir/$dataset/solution.h5ad" \
      --output "$output_file"

  done
done