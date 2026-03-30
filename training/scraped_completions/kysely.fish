complete -c "kysely" -s "h" -l "help" -d "Show help information" # global
complete -c "kysely" -s "v" -l "version" -d "Show version number" # global
complete -f -c "kysely" -n "__fish_use_subcommand" -a "init" -d "Create a sample kysely.config file" # sub
complete -f -c "kysely" -n "__fish_use_subcommand" -a "migrate" -d "down|latest|list|make|rollback|up" # sub
complete -f -c "kysely" -n "__fish_use_subcommand" -a "migratedown" -d "Undo the last/specified migration that was run" # sub
complete -f -c "kysely" -n "__fish_use_subcommand" -a "migratelatest" -d "Update the database schema to the latest version" # sub
complete -f -c "kysely" -n "__fish_use_subcommand" -a "migratelist" -d "List both completed and pending migrations" # sub
complete -f -c "kysely" -n "__fish_use_subcommand" -a "migratemake" -d "Create a new migration file" # sub
complete -f -c "kysely" -n "__fish_use_subcommand" -a "migraterollback" -d "Rollback all the completed migrations" # sub
complete -f -c "kysely" -n "__fish_use_subcommand" -a "migrateup" -d "Run the next migration that has not yet been run" # sub
complete -f -c "kysely" -n "__fish_use_subcommand" -a "seed" -d "list|make|run" # sub
complete -f -c "kysely" -n "__fish_use_subcommand" -a "seedmake" -d "Create a new seed file" # sub
complete -f -c "kysely" -n "__fish_use_subcommand" -a "seedrun" -d "Run seed files" # sub
complete -f -c "kysely" -n "__fish_use_subcommand" -a "sql" -d "Execute SQL queries" # sub
complete -c "kysely" -n "__fish_seen_subcommand_from 'init'" -l "cwd" -d "The current working directory to use for relative paths." # global
complete -c "kysely" -n "__fish_seen_subcommand_from 'init'" -l "debug" -d "Show debug information." # global
complete -c "kysely" -n "__fish_seen_subcommand_from 'init'" -l "no-outdated-check" -d "Will not check for latest kysely/kysely-ctl versions and notice newer versions exist." # global
complete -c "kysely" -n "__fish_seen_subcommand_from 'init'" -s "x" -l "extension" -d "The file extension to use." -xa "ts mts cts js mjs cjs" # global
complete -f -c "kysely" -n "__fish_seen_subcommand_from 'migrate'" -a "down" -d "Undo the last/specified migration that was run" # sub
complete -f -c "kysely" -n "__fish_seen_subcommand_from 'migrate'" -a "latest" -d "Update the database schema to the latest version" # sub
complete -f -c "kysely" -n "__fish_seen_subcommand_from 'migrate'" -a "list" -d "List both completed and pending migrations" # sub
complete -f -c "kysely" -n "__fish_seen_subcommand_from 'migrate'" -a "make" -d "Create a new migration file" # sub
complete -f -c "kysely" -n "__fish_seen_subcommand_from 'migrate'" -a "rollback" -d "Rollback all the completed migrations" # sub
complete -f -c "kysely" -n "__fish_seen_subcommand_from 'migrate'" -a "up" -d "Run the next migration that has not yet been run" # sub
complete -c "kysely" -n "__fish_seen_subcommand_from 'migratedown'" -s "h" -l "help" -d "Show help information" # global
complete -c "kysely" -n "__fish_seen_subcommand_from 'migratedown'" -s "v" -l "version" -d "Show version number" # global
complete -c "kysely" -n "__fish_seen_subcommand_from 'migratelatest'" -s "h" -l "help" -d "Show help information" # global
complete -c "kysely" -n "__fish_seen_subcommand_from 'migratelatest'" -s "v" -l "version" -d "Show version number" # global
complete -c "kysely" -n "__fish_seen_subcommand_from 'migratelist'" -s "h" -l "help" -d "Show help information" # global
complete -c "kysely" -n "__fish_seen_subcommand_from 'migratelist'" -s "v" -l "version" -d "Show version number" # global
complete -c "kysely" -n "__fish_seen_subcommand_from 'migratemake'" -s "h" -l "help" -d "Show help information" # global
complete -c "kysely" -n "__fish_seen_subcommand_from 'migratemake'" -s "v" -l "version" -d "Show version number" # global
complete -c "kysely" -n "__fish_seen_subcommand_from 'migraterollback'" -s "h" -l "help" -d "Show help information" # global
complete -c "kysely" -n "__fish_seen_subcommand_from 'migraterollback'" -s "v" -l "version" -d "Show version number" # global
complete -c "kysely" -n "__fish_seen_subcommand_from 'migrateup'" -s "h" -l "help" -d "Show help information" # global
complete -c "kysely" -n "__fish_seen_subcommand_from 'migrateup'" -s "v" -l "version" -d "Show version number" # global
complete -f -c "kysely" -n "__fish_seen_subcommand_from 'seed'" -a "list" -d "List seeds" # sub
complete -f -c "kysely" -n "__fish_seen_subcommand_from 'seed'" -a "make" -d "Create a new seed file" # sub
complete -f -c "kysely" -n "__fish_seen_subcommand_from 'seed'" -a "run" -d "Run seed files" # sub
complete -c "kysely" -n "__fish_seen_subcommand_from 'seedmake'" -s "h" -l "help" -d "Show help information" # global
complete -c "kysely" -n "__fish_seen_subcommand_from 'seedmake'" -s "v" -l "version" -d "Show version number" # global
complete -c "kysely" -n "__fish_seen_subcommand_from 'seedrun'" -s "h" -l "help" -d "Show help information" # global
complete -c "kysely" -n "__fish_seen_subcommand_from 'seedrun'" -s "v" -l "version" -d "Show version number" # global
complete -c "kysely" -n "__fish_seen_subcommand_from 'sql'" -s "c" -l "config" -d "Path to the config file." # global
complete -c "kysely" -n "__fish_seen_subcommand_from 'sql'" -l "cwd" -d "The current working directory to use for relative paths." # global
complete -c "kysely" -n "__fish_seen_subcommand_from 'sql'" -l "debug" -d "Show debug information." # global
complete -c "kysely" -n "__fish_seen_subcommand_from 'sql'" -s "e" -l "environment" -d "Apply environment-specific overrides to the configuration. See https://github.com/unjs/c12#environment-specific-configuration for more information." -xa "production development test ..." # global
complete -c "kysely" -n "__fish_seen_subcommand_from 'sql'" -l "experimental-resolve-tsconfig-paths" -d "Attempts to resolve path aliases using your tsconfig.json file/s." # global
complete -c "kysely" -n "__fish_seen_subcommand_from 'sql'" -s "f" -l "format" -d "The format to output the result in." -xa "csv json" # global
complete -c "kysely" -n "__fish_seen_subcommand_from 'sql'" -l "no-filesystem-caching" -d "Will not write cache files to disk. See https://github.com/unjs/jiti#fscache for more information." # global
complete -c "kysely" -n "__fish_seen_subcommand_from 'sql'" -l "no-outdated-check" -d "Will not check for latest kysely/kysely-ctl versions and notice newer versions exist." # global