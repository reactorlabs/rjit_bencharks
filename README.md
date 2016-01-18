Shiny app for rjit benchmarks
===

This [Shiny](http://shiny.rstudio.com/) application is a part of rjit project CI pipeline and is meant to display benchmark results in real-time.

Actual application is available at [here](https://romantsegelskyi.shinyapps.io/rjit_benchmarks).

By default the data will be stored in ~/rjit_data.

Running locally with docker
---

Clone the repository

```
git clone https://github.com/reactorlabs/rjit_benchmarks
```

Build docker container

```
docker build -t reactorl/rjit_shiny .
```

Run docker container

```
docker run --rm --dns 8.8.8.8 -p 3838:3838 reactorl/rjit_shiny
```

To replace files inside the container with local files use `--volume`

```
docker run --rm  --dns 8.8.8.8 -p 3838:3838 --volume=/$(pwd)/://srv/shiny-server/ --volume=/$(pwd)/../logs://var/log/ reactorl/rjit_shiny
```

To run command line inside the container - detach from container and use `exec`

```
docker run -d --dns 8.8.8.8 -p 3838:3838 --volume=/$(pwd)/://srv/shiny-server/ --volume=/$(pwd)/../logs://var/log/ reactorl/rjit_shiny
docker exec -i -t reactorl/rjit_shiny bash
```
