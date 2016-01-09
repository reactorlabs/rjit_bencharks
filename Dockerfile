FROM rocker/shiny:latest

MAINTAINER Roman Tsegelskyi "roman.tsegelskyi@gmail.com"

RUN R -e "install.packages(c('rdrop2', 'ggplot2', repos='http://cran.rstudio.com/'))"

RUN rm -rf /srv/shiny-server/* && mkdir /srv/shiny-server/rjit_benchmarks
COPY server.R /srv/shiny-server/rjit_benchmarks/
COPY ui.R /srv/shiny-server/rjit_benchmarks/
COPY global.R /srv/shiny-server/rjit_benchmarks/

CMD ["/usr/bin/shiny-server.sh"]
