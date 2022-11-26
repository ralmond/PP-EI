library(R.utils)
library(EIEvent)
library(jsonlite)

appStem <- cmdArg("app",NULL)
if (FALSE) {
  appStem <- "SummerCamp"
}

source("/usr/local/share/Proc4/EIini.R")

EI.config <- fromJSON(file.path(config.dir,"config.json"),FALSE)

app <- as.character(Proc4.config$apps[appStem])
if (length(app)==0L || any(app=="NULL")) {
  stop("Could not find apps for ",appStem)
}
if (!(appStem %in% EI.config$appStem)) {
  stop("Configuration not set for app ",appStem)
}

logfile <- (file.path(logpath, sub("<app>",appStem,EI.config$logname)))
if (interactive()) {
  flog.appender(appender.tee(logfile))
} else {
  flog.appender(appender.file(logfile))
}
flog.threshold(EI.config$loglevel)

doRunrun(app,EI.config,EIeng.local,config.dir,outdir)

