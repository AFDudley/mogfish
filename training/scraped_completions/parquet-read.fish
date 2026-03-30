complete -c parquet-read -s n -l num-records -d '<NUM_RECORDS>  Number of records to read. When not provided or 0, all records are read [default: 0]'
complete -c parquet-read -s j -l json -d 'Print Parquet file in JSON lines format'
complete -c parquet-read -s h -l help -d 'Print help'
complete -c parquet-read -n __fish_no_arguments -s V -l version -d 'Print version'
