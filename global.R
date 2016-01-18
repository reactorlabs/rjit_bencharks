library(rdrop2)

load_data_dropbox <- function() {
    # load saved dropbox token
    token <- readRDS("droptoken.rds")
    drop_acc(dtoken = token)
    
    # get files and download them to data_path
    if (!dir.exists(data_path)) dir.create(data_path)
    wercker_files <- as.vector(as.matrix(drop_dir('/Apps/rjit_uploader/wercker'))[,1])
    res <- sapply(wercker_files,
                  function(file) {
                      local_file <- file.path(data_path, basename(file))
                      if (!file.exists(local_file)) drop_get(as.character(file), local_file)
                      local_file
                  }
    )
   
    # process downloaded files
    # files are of 2 formats:
    #    * (package)_functions_(commit_id).Rds - with compilation information on per function basis
    #    * (package)_package_(commit_id).Rds - with compilation information for the whole package
    data <- list(base=list(total=list(), functions=list()))
    for (file in res) {
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
    data
}

process_package <- function(pname) {
    package_compilation <- benchmark_data[[pname]]$total
    package_compilation <- package_compilation[order(sapply(package_compilation, `[[`, 1))]
    pc <- package_compilation
    rn <- names(pc)
    rn <- sapply(1:length(rn), function(i) paste(format(as.Date(pc[[i]][[1]]), "%d/%m/%Y"), 
                                                 "(",
                                                 substr(rn[i], 0, 6),
                                                 ")",
                                                 sep=""))
    names(pc) <- rn
    pc
}

process_function <- function(func) {
    funcd <- function_data[[func]]
    funcd <- funcd[order(sapply(funcd, `[[`, 1))]
    fd <- funcd
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

data_path <- "~/rjit_data"
benchmark_data <- load_data_dropbox()
function_data <- list()