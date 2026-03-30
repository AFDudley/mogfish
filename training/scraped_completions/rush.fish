
set def """
Replacement strings in commands:
  {}          full data
  {#}         job ID
  {n}         nth field in delimiter-delimited data
  {/}         dirname
  {%}         basename
  {.}         remove the last file extension
  {:}         remove all file extensions.
  {^suffix}   remove suffix
  {@regexp}   capture submatch using regular expression

  Combinations:
    {%.}, {%:}          basename without extension
    {2.}, {2/}, {2%.}   manipulate nth field
"""

complete -c rush -s d -l field-delimiter -d field\ delimiter\ in\ records\ \(default\ \"\\s+\"\)
complete -c rush -s D -l record-delimiter -d record\ delimiter\ \(default\ \"\\n\"\)
complete -c rush -s n -l nrecords -d 'number of records sent to a command (default 1)'
complete -c rush -s J -l records-join-sep -d record\ separator\ for\ joining\ multi-records\ \(default\ \"\\n\"\)
complete -c rush -s T -l trim -d trim\ white\ space\ \(\"\ \\t\\r\\n\"\)\ in\ input
complete -c rush -s v -l assign -d 'strings            assign the value val to the variable var (format: var=val, val also'
complete -c rush -l cleanup-time -d 'int          time to allow child processes to clean up between stop / kill signals'
complete -c rush -s c -l continue -d 'continue jobs. NOTES: 1) successful commands are saved in file (given'
complete -c rush -l dry-run -d 'print command but not run'
complete -c rush -s q -l escape -d 'escape special symbols like $ which you can customize by flag'
complete -c rush -s Q -l escape-symbols -d 'string     symbols to escape (default "$#&`")'
complete -c rush -l eta -d 'show ETA progress bar'
complete -c rush -s d -l field-delimiter -d string\ \ \ \ field\ delimiter\ in\ records,\ support\ regular\ expression\ \(default\ \"\\\\s+\"\)
complete -c rush -s h -l help -d 'help for rush'
complete -c rush -s I -l immediate-output -d 'print output immediately and interleaved, to aid debugging'
complete -c rush -s i -l infile -d 'strings            input data file, multi-values supported'
complete -c rush -s j -l jobs -d 'int                  run n jobs in parallel (default value depends on your device) (default 8)'
complete -c rush -s k -l keep-order -d 'keep output in order of input'
complete -c rush -l no-kill-exes -d 'strings      exe names to exclude from kill signal, example: mspdbsrv.exe; or use'
complete -c rush -l no-stop-exes -d 'strings      exe names to exclude from stop signal, example: mspdbsrv.exe; or use'
complete -c rush -s n -l nrecords -d 'int              number of records sent to a command (default 1)'
complete -c rush -s o -l out-file -d 'string           out file ("-" for stdout) (default "-")'
complete -c rush -l print-retry-output -d 'print output from retry commands (default true)'
complete -c rush -l propagate-exit-status -d 'propagate child exit status up to the exit status of rush (default true)'
complete -c rush -s D -l record-delimiter -d string\ \ \ record\ delimiter\ \(default\ is\ \"\\n\"\)\ \(default\ \"\\n\"\)
complete -c rush -s J -l records-join-sep -d string\ \ \ record\ separator\ for\ joining\ multi-records\ \(default\ is\ \"\\n\"\)\ \(default\ \"\\n\"\)
complete -c rush -s r -l retries -d 'int               maximum retries (default 0)'
complete -c rush -l retry-interval -d 'int        retry interval (unit: second) (default 0)'
complete -c rush -s e -l stop-on-error -d 'stop child processes on first error (not perfect, you may stop it by'
complete -c rush -s C -l succ-cmd-file -d 'string      file for saving successful commands (default "successful_cmds.rush")'
complete -c rush -s t -l timeout -d 'int               timeout of a command (unit: seconds, 0 for no timeout) (default 0)'
complete -c rush -s T -l trim -d string\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ trim\ white\ space\ \(\"\ \\t\\r\\n\"\)\ in\ input\ \(available\ values:\ \"l\"\ for\ left,
complete -c rush -l verbose -d 'print verbose information'
complete -c rush -n __fish_no_arguments -s V -l version -d 'print version information and check for update'
