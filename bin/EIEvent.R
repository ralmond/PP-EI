library(R.utils)
library(EIEvent)

if (interactive()) {
  app <- "ecd://epls.coe.fsu.edu/PhysicsPlayground/Sp2019/userControl"
  loglevel <- "DEBUG"
  cleanFirst <- TRUE
  eventFile <- "/home/ralmond/Projects/EvidenceID/c081c3.core.json"
} else {
  app <- cmdArg("app",NULL)
  if (is.null(app) || !grepl("^ecd://",app))
    stop("No app specified, use '--args app=ecd://...'")
  loglevel <- cmdArg("level","INFO")
  cleanFirst <- as.logical(cmdArg("clean",FALSE))
  eventFile <- cmdArg("events",NULL)
}

source("/usr/local/share/Proc4/EIini.R")

if (interactive()) {
  flog.appender(appender.tee(logfile))
} else {
  flog.appender(appender.file(logfile))
}
flog.threshold(loglevel)

listeners <- lapply(names(EI.listenerSpecs),
                    function (ll) do.call(ll,EI.listenerSpecs[[ll]]))
names(listeners) <- names(EI.listenerSpecs)
if (interactive()) {
  cl <- new("CaptureListener")
  listeners <- c(listeners,cl=cl)
}
eng <- do.call(EIEngine,c(EIeng.params,list(listeners=listeners),
                          EIeng.common))

if (cleanFirst) {
  eng$eventdb()$remove(buildJQuery(app=app(eng)))
  eng$userRecords$clearAll(FALSE)   #Don't clear default
  eng$listenerSet$messdb()$remove(buildJQuery(app=app(eng)))
  for (lis in eng$listenerSet$listeners) {
    if (is(lis,"UpdateListener") || is(lis,"InjectionListener"))
      lis$messdb()$remove(buildJQuery(app=app(eng)))
  }

}
if (!is.null(eventFile)) {
  system2("mongoimport",
          sprintf('-d %s -c Events --jsonArray', eng$dbname),
          stdin=eventFile)
  NN <- eng$eventdb()$count(buildJQuery(app=app(eng),processed=FALSE))
}


if (!is.null(eventFile)) {
  eng$processN <- NN
}


## Activate engine (if not already activated.)
eng$activate()
mainLoop(eng)

## This is for running the loop by hand.
if (interactive() && FALSE) {
  eve <- eng$fetchNextEvent()
  out <- handleEvent(eng,eve)
  eng$setProcessed(eve)
}

## This shows the details of the last message.  If the test script is
## set up properly, this should be the observables.
if (interactive() && TRUE) {
  details(cl$lastMessage())
}

