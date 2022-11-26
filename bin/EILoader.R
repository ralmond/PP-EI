###
## These are R functions for loading the contexts and rules into the Eng

library(EIEvent)
library(jsonlite)
flog.threshold(INFO)
cl <- new("CaptureListener")

config.dir <- "/home/ralmond/PhysicsPlayground"

engTest <- EIEngine(app="ecd://epls.coe.fsu.edu/P4test",
                    listeners=list(capture=cl))
engUser <- EIEngine(app="ecd://epls.coe.fsu.edu/PhysicsPlayground/Sp2019/userControl",
                    listeners=list(capture=cl))
engLin <- EIEngine(app="ecd://epls.coe.fsu.edu/PhysicsPlayground/Sp2019/linear",
                    listeners=list(capture=cl))
engAdapt <- EIEngine(app="ecd://epls.coe.fsu.edu/PhysicsPlayground/Sp2019/adaptive",
                    listeners=list(capture=cl))


sketchCon <- read.csv(file.path(config.dir,"ContextSketching.csv"))
manipCon <- read.csv(file.path(config.dir,"ContextManipulation.csv"))
initCon <- data.frame(CID="*INITIAL*",Name="*INITIAL*",Number=0)



engTest$clearContexts()
engTest$addContexts(initCon)
engTest$addContexts(sketchCon)
engTest$addContexts(manipCon)

engLin$clearContexts()
engLin$addContexts(initCon)
engLin$addContexts(sketchCon)
engLin$addContexts(manipCon)

engUser$clearContexts()
engUser$addContexts(initCon)
engUser$addContexts(sketchCon)
engUser$addContexts(manipCon)

engAdapt$clearContexts()
engAdapt$addContexts(initCon)
engAdapt$addContexts(sketchCon)
engAdapt$addContexts(manipCon)

allRules <- lapply(fromJSON(file.path(config.dir, "Rules",
                                    "AllLevelRules.json"),FALSE),
                 parseRule)
skRules <- lapply(fromJSON(file.path(config.dir, "Rules",
                                    "SketchingRules.json"),FALSE),
                 parseRule)
manipRules <- lapply(fromJSON(file.path(config.dir, "Rules",
                                    "ManipulationRules.json"),FALSE),
                 parseRule)
tRules <- lapply(fromJSON(file.path(config.dir, "Rules",
                                    "TrophyHallRules.json"),FALSE),
                 parseRule)
## hRules <- lapply(fromJSON(file.path(config.dir, "Rules",
##                                     "LS-HelpB-rules1.json"),FALSE),
##                  parseRuleTest)
mRules <- lapply(fromJSON(file.path(config.dir, "Rules",
                                    "MoneyRules.json"),FALSE),
                 parseRule)
lRules <- lapply(fromJSON(file.path(config.dir, "Rules",
                                    "LS-Events.json"),FALSE),
                 parseRule)
mbRules <- lapply(fromJSON(file.path(config.dir, "Rules",
                                    "MultipleBlowerRules.json"),FALSE),
                 parseRule)

engTest$rules$clearAll()
engTest$loadRules(allRules)
engTest$loadRules(skRules)
engTest$loadRules(manipRules)
engTest$loadRules(tRules)
## engTest$loadAndTest(file.path(config.dir, "Rules",
##                                      "LS-HelpB-rules1.json"))
engTest$loadRules(mRules)
engTest$loadRules(lRules)
engTest$loadRules(mbRules)

engUser$rules$clearAll()
engUser$loadRules(allRules)
engUser$loadRules(skRules)
engUser$loadRules(manipRules)
engUser$loadRules(tRules)
## engUser$loadAndTest(file.path(config.dir, "Rules",
##                                      "LS-HelpB-rules1.json"))
engUser$loadRules(mRules)
engUser$loadRules(lRules)
engUser$loadRules(mbRules)

engLin$rules$clearAll()
engLin$loadRules(allRules)
engLin$loadRules(skRules)
engLin$loadRules(manipRules)
engLin$loadRules(tRules)
## engLin$loadAndTest(file.path(config.dir, "Rules",
##                                      "LS-HelpB-rules1.json"))
engLin$loadRules(mRules)
engLin$loadRules(lRules)
engLin$loadRules(mbRules)


engAdapt$rules$clearAll()
engAdapt$loadRules(allRules)
engAdapt$loadRules(skRules)
engAdapt$loadRules(manipRules)
engAdapt$loadRules(tRules)
## engAdapt$loadAndTest(file.path(config.dir, "Rules",
##                                      "LS-HelpB-rules1.json"))
engAdapt$loadRules(mRules)
engAdapt$loadRules(lRules)
engAdapt$loadRules(mbRules)


## ## Load default student records.
## system2("mongoimport",args=sprintf("-d EIRecords -c States --jsonArray %s",
##                                    file.path(config.dir,"defaultSR.json")))

defaultRec <- engTest$newUser("*DEFAULT*")
obs(defaultRec,"bankBalance") <- 0
obs(defaultRec,"trophyHall") <- list()
engTest$saveStatus(defaultRec)

defaultRec <- engUser$newUser("*DEFAULT*")
obs(defaultRec,"bankBalance") <- 0
obs(defaultRec,"trophyHall") <- list()
engUser$saveStatus(defaultRec)

defaultRec <- engLin$newUser("*DEFAULT*")
obs(defaultRec,"bankBalance") <- 0
obs(defaultRec,"trophyHall") <- list()
engLin$saveStatus(defaultRec)

defaultRec <- engAdapt$newUser("*DEFAULT*")
obs(defaultRec,"bankBalance") <- 0
obs(defaultRec,"trophyHall") <- list()
engAdapt$saveStatus(defaultRec)

