library(R.utils)
library(EIEvent)
library(jsonlite)

if (interactive()) {
  ## Edit these for the local application
  app <- "ecd://epls.coe.fsu.edu/PhysicsPlayground/Sp2019/userControl"
  app <- "ecd://epls.coe.fsu.edu/P4test"
  loglevel <- "DEBUG"
  cleanFirst <- TRUE
  purge <- TRUE
  replay <- TRUE
} else {
  app <- cmdArg("app",NULL)
  if (is.null(app) || !grepl("^ecd://",app))
    stop("No app specified, use '--args app=ecd://...'")
  loglevel <- cmdArg("level","INFO")
  cleanFirst <- as.logical(cmdArg("clean",TRUE))
  purge <- as.logical(cmdArg("purge",FALSE))
  replay <- as.logical(cmdArg("replay",TRUE))
}
eventFile <- NULL
if (FALSE) {
eventFile <- "/home/ralmond/ownCloud/Projects/NSFCyberlearning/FSUSSp2019Data/TestEvents.json"

eventDir <- "/home/ralmond/ownCloud/Projects/NSFCyberlearning/EvidenceID/c081c3Tests"
eventFile <-file.path(eventDir,paste("c081c3",
   c("AroundTheTree","DivingBoard","DownHill","Ed","SpiderWeb",
     "CloudyDay","Cornfield","DivingBoard","Freefall","GetOverIt",
     "Leprechaun", "Lever","Lightning", "LittleMermaid","MrGree",
     "NewtonsCradle", "NotTooFar", "OnTheUpswing", "Pendulum"
    ), "json",sep="."))

eventFile <-file.path(eventDir,paste("c081c3",
     c("AirResistance","BlockedByBlocks","Dominoes","Gravity",
       "Lighthouse", "Mass", "NeedforSpeed"
      ),"json",sep="."))

eventFile <- "/home/ralmond/ownCloud/Projects/NSFCyberlearning/FSUSSp2019Data/LStest1.json"

}
## Adjust the path here as necessary
source("/usr/local/share/Proc4/EIini.R")

## Setup logging
if (interactive()) {
  flog.appender(appender.tee(logfile))
} else {
  flog.appender(appender.file(logfile))
}
flog.threshold(loglevel)

## Setup Listeners
listeners <- lapply(names(EI.listenerSpecs),
                    function (ll) do.call(ll,EI.listenerSpecs[[ll]]))
names(listeners) <- names(EI.listenerSpecs)
if (interactive()) {
  cl <- new("CaptureListener")
  listeners <- c(listeners,cl=cl)
}

flist <- c(uid = "character", context = "character",timestamp="character",
           blowerManip="numeric", BouncinessRun="logical",
           Agent="factor(Lever,Pendulum,Ramp,Springboard)",
           ApplicableAgent="logical",ObjectCount="numeric",
           TrophyLevel="ordered(none,silver,gold)",
           NumberAttempts="numeric",
           PufferClicks="numeric", massManip="numeric",
           airManip="numeric",gravityManip="numeric",Duration="difftime",
           SliderAdjust="numeric",
           AppropriateSlider="ordered(almostAlways,mostly,mostlyNot,almostNever)",
           bankBalance="numeric",helpBClicked="numeric",
           LeftBlower="numeric",RightBlower="numeric",TopBlower="numeric",
           BottomBlower="numeric")
flistls <- c(uid = "character", context = "character",timestamp="character",
           currentMoney="numeric",
           appId = "numeric", mess = "character",
           money = "numeric", onWhat = "character", LS_duration = "difftime",
           learningSupportType = "character")
tl <- TableListener(name=paste("ppObs",basename(app),sep="."),
                    flist,"New Observables")
tlls <- TableListener(name=paste("ppLS",basename(app),sep="."),
                    flistls,c("Coins Earned","Coins Spent", "LS Watched"))
listeners <- c(listeners,tl=tl,tlls=tlls)

## Make the EIEngine
eng <- do.call(EIEngine,c(EIeng.params,list(listeners=listeners),
                          EIeng.common))


## Process Event file if supplied
if (!is.null(eventFile)) {
  eng$eventdb()$remove(buildJQuery(app=app(eng)))
  for (ef in eventFile) {
    system2("mongoimport",
            sprintf('-d %s -c Events --jsonArray', eng$dbname),
            stdin=ef)
  }
}

## Purge Unusued events
if (purge) {
  eng$eventdb()$remove(buildJQuery(app=app(eng),
                                   verb="nudged", object="game object"))
  eng$eventdb()$remove(buildJQuery(app=app(eng),
                                  verb="initialized", object="game object"))
  ## eng$eventdb()$remove(buildJQuery(app=app(eng),
  ##                                  verb="completed", object="game object"))
  eng$eventdb()$remove(buildJQuery(app=app(eng),
                                   verb="snapshot", object="game object"))
}

if (replay) {
  eng$eventdb()$update(buildJQuery(app=app(eng)),
                       '{"$set":{"processed":false}}',
                       multiple=TRUE)
}

## Clean out old records from the database.
if (cleanFirst) {
  eng$userRecords$clearAll(FALSE)   #Don't clear default
  eng$listenerSet$messdb()$remove(buildJQuery(app=app(eng)))
  for (lis in eng$listenerSet$listeners) {
    if (is(lis,"UpdateListener") || is(lis,"InjectionListener"))
      lis$messdb()$remove(buildJQuery(app=app(eng)))
    if (is(lis,"TableListener"))
      lis$initDF()
  }
}



## This can be set to a different number to process only a subset of events.
NN <- eng$eventdb()$count(buildJQuery(app=app(eng),processed=FALSE))
eng$processN <- NN

cat("Processing ",NN," records for application ",app(eng),".\n")

if (FALSE) {
  eng$processN <- 10
}

## Activate engine (if not already activated.)
cat ("Running ",eng$processN, "of", NN, "events from ",
     ifelse(is.null(eventFile),"database",basename(eventFile)), "\n")
eng$activate()
mainLoop(eng)

## This is for running the loop by hand.
if (interactive() && FALSE) {
  eve <- eng$fetchNextEvent()
  eve

  st <- eng$getStatus(uid(eve))

  out <- handleEvent(eng,eve)
  eng$setProcessed(eve)
  eve <- eng$fetchNextEvent()
  eve
}
if (FALSE) {
  targetVerb <- "play"
  targetObj <- "params"
  NN <- 100
  for (n in 1:NN) {
    eve <- eng$fetchNextEvent()
    eve
    if (is.na(targetVerb) || targetVerb == verb(eve)) {
      if (is.na(targetObj) || targetobj == object(eve)) {
        st <- eng$getStatus(uid(eve))
        break
      }
    }
    out <- handleEvent(eng,eve)
    eng$setProcessed(eve)
  }
}




## This shows the details of the last message.  If the test script is
## set up properly, this should be the observables.
ppObs <- tl$returnDF()
fname <- paste(name(tl),"csv",sep=".")
write.csv(ppObs,file.path("/home/ralmond/PhysicsPlayground",fname))
file.copy(file.path("/home/ralmond/PhysicsPlayground",fname),
          file.path("/www1/www/https_docs/PhysicsPlayground",fname),
          overwrite=TRUE)

ppLS <- tlls$returnDF()
fname <- paste(name(tlls),"csv",sep=".")
write.csv(ppLS,file.path("/home/ralmond/PhysicsPlayground",fname))
file.copy(file.path("/home/ralmond/PhysicsPlayground",fname),
          file.path("/www1/www/https_docs/PhysicsPlayground",fname),
          overwrite=TRUE)


