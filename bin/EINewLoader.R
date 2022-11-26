library(utils)
library(EIEvent)
library(jsonlite)


source("/usr/local/share/Proc4/EIini.R")

EI.config <- fromJSON(file.path(config.dir,"config.json"),FALSE)


appStem <- as.character(EI.config$appStem)

apps <- as.character(Proc4.config$apps[appStem])
if (length(apps)==0L || any(apps=="NULL")) {
  stop("Could not find apps for ",appStem)
}


logfile <- (file.path(logpath, sub("<app>","Loader",EI.config$logname)))
if (interactive()) {
  flog.appender(appender.tee(logfile))
} else {
  flog.appender(appender.file(logfile))
}
flog.threshold(EI.config$loglevel)


## Loop over apps
for (app in apps)
  doLoad(app, EI.config, EIeng.local, config.dir)
