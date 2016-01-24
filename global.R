library(rdrop2)

source("run_bench.R")
data_path <- "~/rjit_data"

load_data_dropbox <- function() {
    # load saved dropbox token
    token <- readRDS("droptoken.rds")
    drop_acc(dtoken = token)
    
    # get files and download them to data_path
    if (!dir.exists(data_path)) dir.create(data_path)
    if (!dir.exists(file.path(data_path, "compilation"))) dir.create(file.path(data_path, "compilation"))
    if (!dir.exists(file.path(data_path, "execution"))) dir.create(file.path(data_path, "execution"))
                                                                   
    wercker_files_compilation <- as.vector(as.matrix(drop_dir('/Apps/rjit_uploader/wercker/compilation'))[,1])
    files <- sapply(wercker_files_compilation,
                  function(file) {
                      local_file <- file.path(data_path, "compilation", basename(file))
                      if (!file.exists(local_file)) drop_get(as.character(file), local_file)
                      local_file
                  }
    )
    
    processed_compilation_data <- process_compilation_data(files)
    
    wercker_files_execution <- as.vector(as.matrix(drop_dir('/Apps/rjit_uploader/wercker/execution'))[,1])
    files <- sapply(wercker_files_execution,
                  function(file) {
                      local_file <- file.path(data_path, "execution", basename(file))
                      if (!file.exists(local_file)) drop_get(as.character(file), local_file)
                      local_file
                  }
    )
    
    processed_execution_data <- process_execution_data(files)
    list(compilation=processed_compilation_data, execution=processed_execution_data)
}

process_compilation_data <- function(files) {
    # process downloaded files
    # files are of 2 formats:
    #    * (package)_functions_(commit_id).Rds - with compilation information on per function basis
    #    * (package)_package_(commit_id).Rds - with compilation information for the whole package
    data <- list(base=list(total=list(), functions=list()))
    for (file in files) {
        commit <- gsub(".*_([0-9a-f]{5,40})\\.Rds$", "\\1", file)
        package <- gsub(".*/(.*)_(.*)_([0-9a-f]{5,40})\\.Rds$", "\\1", file)
        if (grepl("functions", file)) {
            d <- readRDS(file)
            lapply(names(d), function(n) if (is.null(data[[package]][["functions"]][[n]])) data[[package]][["functions"]][[n]] <<- list())
            data[[package]][["functions"]] <- mapply(c, 
                                                     data[[package]][["functions"]], 
                                                     readRDS(file),
                                                     SIMPLIFY = FALSE)
        } else {
            d <- readRDS(file)
            data[[package]][["total"]] <- c(data[[package]][["total"]], d)
        }
    }
    processed_data <- list()
    for (pname in names(data)) {
        processed_data[[pname]]$total <- process_package(data[[pname]]$total)
        for (fname in names(data[[pname]]$functions)) {
            processed_data[[pname]]$functions[[fname]] <- 
                process_function(data[[pname]]$functions[[fname]])
        }
    }
    processed_data
}

process_package <- function(pc) {
    # pc - package compilation
    # rn - rownames
    pc <- pc[order(sapply(pc, `[[`, 1))]
    rn <- names(pc)
    rn <- sapply(1:length(rn), function(i) paste(format(as.Date(pc[[i]][[1]]), "%d/%m/%Y"), 
                                                 "(",
                                                 substr(rn[i], 0, 6),
                                                 ")",
                                                 sep=""))
    names(pc) <- rn
    pc
}

process_function <- function(fd) {
    # funcd - function data
    # rn - rownames
    fd <- fd[order(sapply(fd, `[[`, 1))]
    rn <- names(fd)
    rn <- sapply(1:length(rn), function(i) paste(format(as.Date(fd[[i]][[1]]), "%d/%m/%Y"),
                                                 "(",
                                                 substr(rn[i], 0, 6),
                                                 ")",
                                                 sep=""))
    names(fd) <- rn
    fd <- fd[order(names(fd))]
    fd
}

processed_data <- load_data_dropbox()
function_names <- names(processed_data$compilation$base$functions)