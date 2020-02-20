# PP-EI

## Evidence Identification Model for _Physics Playground_


This project contains the following data files that are used for
_Physics Playground_:

1. The Context Description Files.
2. The Rules files (json) text.
3. The default Student Record attributes.

It also contains a list of bin files and R script files that are used
to perform the various operations.

Here are the steps that need to be done to do a scoring run.

1. Do a git pull to bring server up to date with repository.
2. Do a git branch to put server on correct version of setup for this
   run.
3. Run the `EILoader` script to load the configuration into the
   database.
   This needs a `config.json` file that specifies:
   * The names of the context description csv files.
   * The names of the rules files.
   * The fields to be set in the default student record.
4. If running in server mode, run the EIEvent script to start the
   server.
5. In running in rerun mode, run a query to mark appropriate events as
   unprocessed. 
6. Run the EIEventRerun script to do the rerun process.

