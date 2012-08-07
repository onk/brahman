## Brahman 0.0.4 (unreleased)
*   remove diff subcommand
*   support mergeinfo_clean subcommand

    mergeinfo_clean will return simple hyphenize mergeinfo
    for many many cherry-picked branches.

    if svn:mergeinfo is

      trunk:1,5,7

    and non-merged revision is [2, 3, 6]

      brahman mergeinfo_clean -r 1:7

    will return

      1,4-5,7

*   support --verbose option
*   use Logger for verbose output

## Brahman 0.0.3 (2012-06-20)
*   brahman merge use --accept postpone for svn merge
*   brahman merge, unnecessary to care order of revisions.
*   Refactored.
*   support subcommand "diff".
*   support subcommand "merge".
    this action need -r option for specific revisions.
*   support subcommand "list".  don't skip subcommand to specify option.

    New command:

        brahman list -r r180565

## Brahman 0.0.2 (2012-05-03)
*   fix error when called without "-r" option
*   Refactored.

## Brahman 0.0.1 (2012-04-28)

*   initial release

