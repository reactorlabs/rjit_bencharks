library(rdrop2)
library(ggplot2)

source("execution.R")
source("compilation.R")

data_path <- "~/rjit_data"

load_data_dropbox <- function() {
    # load saved dropbox token
    token <- readRDS("droptoken.rds")
    drop_acc(dtoken = token)
    
    if (!dir.exists(data_path)) dir.create(data_path)

    files <- download_files("compilation")
    processed_compilation_data <- process_compilation_data(files)
    
    files <- download_files("execution")
    processed_execution_data <- process_execution_data(files)
    
    list(compilation=processed_compilation_data, execution=processed_execution_data)
}

download_files <- function(type, ci="wercker") {
    if (!dir.exists(file.path(data_path, type))) dir.create(file.path(data_path, type))
    
    wercker_files_compilation <- as.vector(as.matrix(drop_dir(sprintf('/Apps/rjit_uploader/%s/%s', ci, type)))[,1])
    files <- sapply(wercker_files_compilation,
                    function(file) {
                        local_file <- file.path(data_path, "compilation", basename(file))
                        if (!file.exists(local_file)) drop_get(as.character(file), local_file)
                        local_file
                    }
    )
}

processed_data <- load_data_dropbox()
# this needs to be kept since functions might change with package
function_names <- names(processed_data$compilation$base$functions)