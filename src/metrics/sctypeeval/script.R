library(anndata)
library(scTypeEval)

## VIASH START
par <- list(
  input_solution = "resources_test/task_label_projection/cxg_immune_cell_atlas/solution.h5ad",
  input_prediction = "resources_test/task_label_projection/cxg_immune_cell_atlas/prediction.h5ad",
  output = "output.h5ad"
)

meta <- list(
  name = "sctypeeval"
)
## VIASH END

cat("Reading input files\n")
input_solution <- anndata::read_h5ad(par[["input_solution"]])
input_prediction <- anndata::read_h5ad(par[["input_prediction"]])

# Check that obs_names (i.e., rownames of obs data frame) match
stopifnot(identical(rownames(input_prediction$obs), rownames(input_solution$obs)))

matrix <- input_solution$layers['counts']
metadata <- cbind(input_solution$obs, input_prediction$obs)

cat("Compute metrics\n")
# metric_ids and metric_values can have length > 1
# but should be of equal length
uns_metric_ids <- c("sctypeeval")
uns_metric_values <- c(0.5)

cat("Write output AnnData to file\n")
output <- anndata::AnnData(
  
)
output$write_h5ad(par[["output"]], compression = "gzip")
