requireNamespace("anndata", quietly = TRUE)
suppressPackageStartupMessages({
  library(scTypeEval)
  library(Matrix)
})

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

counts_r <- Matrix::t(input_solution$layers[["counts"]])
# Convert to a regular sparse matrix first and then to dgCMatrix
matrix <- as(as(counts_r, "CsparseMatrix"), "dgCMatrix")
metadata <- cbind(input_solution$obs, input_prediction$obs)

cat("Compute metrics\n")
# annotations to evaluate
annots <- c("label", "label_pred")
# sample id
sample <- "batch"
# black list
data(default_black_list)
bl <- list(black.list$TCR,
          black.list$Immunoglobulins,
          black.list$Ygenes) |> unlist()
# Internal validation metrics
IntVal_metric <- c("silhouette", "NeighborhoodPurity", "ward.PropMatch",
                  "modularity", "ward.NMI", "ward.ARI","GraphConnectivity",
                   "Orbital.centroid", "Orbital.medoid")

cat("Creating scTypeEval object\n")
sceval <- create.scTypeEval(matrix = matrix,
                            metadata = metadata)

cat("Adding HVG gene list\n")
sceval <- add.HVG(sceval,
                  sample = sample,
                  black.list = bl
                  )

consistency_df <- 
  lapply(annots,
        function(annot){
          Run.scTypeEval(scTypeEval = sceval,
                          ident = annot, # annotation method to evaluate
                          sample = sample,
                          IntVal.metric = IntVal_metric,
                          BH.method = c("Mutual.Score", "Mutual.Match"),
                          data.type = c("sc", "pseudobulk", "pseudobulk_1vsall"),
                          black.list = bl,
                          progressbar = F,
                          verbose = F
                          )
    })

consistency_df <- do.call(rbind, consistency_df)

cat(">> Create output data\n")
output <- anndata::AnnData(
  obs = consistency_df,
  uns = list(
    method_id = meta$name,
    dataset_id = input_test$uns[["dataset_id"]],
  ),
  shape = c(input_test$n_obs, 0L)
)

cat(">> Write output to file\n")
output$write_h5ad(par$output, compression = "gzip")


