#!/bin/bash

# get the root of the directory
REPO_ROOT=$(git rev-parse --show-toplevel)

# ensure that the command below is run from the root of the repository
cd "$REPO_ROOT"

# NOTE: depending on the the datasets and components, you may need to launch this workflow
# on a different compute platform (e.g. a HPC, AWS Cloud, Azure Cloud, Google Cloud).
# please refer to the nextflow information for more details:
# https://www.nextflow.io/docs/latest/

set -e

# generate a unique id
RUN_ID="run_$(date +%Y-%m-%d_%H-%M-%S)"
publish_dir="results/${RUN_ID}"

echo "Running benchmark on all data"
echo "  Make sure to have run 'scripts/project/build_all_docker_containers.sh' first!"

# if resources/datasets doesn't exist, tell the user to sync the data
if [ ! -d "resources" ]; then
  echo "Please sync the data before running the benchmark."
  echo "You can do this by running the following command:"
  echo "  scripts/sync_datasets.sh"
  exit 1
fi

# write the parameters to file
# note: uncomment the settings line to include/exclude specific methods
cat > /tmp/params.yaml << HERE
input_states: resources/Diabetic_Kidney_Disease/state.yaml
rename_keys: 'input_train:output_train;input_test:output_test;input_solution:output_solution'
output_state: "state.yaml"
settings: '{"methods_include": ["majority_vote", "random_labels", "true_labels", "knn", "logistic_regression", "seurat_transferdata", "naive_bayes", "singler"]}'
#settings: '{"metrics_include": ["accuracy", "f1", "sctypeeval"]}'
output_scores: "scores.yaml"
output_dataset_info: "dataset_info.yaml"
output_method_configs: "method_configs.yaml"
output_metric_configs: "metric_configs.yaml"
output_task_info: "task_info.yaml"
publish_dir: "$publish_dir"
HERE

# run the benchmark
nextflow run . \
  -main-script target/nextflow/workflows/run_benchmark/main.nf \
  -profile docker \
  -resume \
  -entry auto \
  -c common/nextflow_helpers/labels_ci.config \
  -params-file /tmp/params.yaml
