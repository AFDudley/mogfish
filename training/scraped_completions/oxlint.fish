complete -c "oxlint" -s "c" -l "config" -d "Oxlint configuration file (experimental)" -xa "./.oxlintrc.json" # global
complete -c "oxlint" -l "tsconfig" -d "TypeScript `tsconfig.json` path for reading path alias and project references for import plugin" -xa "./tsconfig.json" # global
complete -c "oxlint" -l "init" -d "Initialize oxlint configuration with default values" # global
complete -c "oxlint" -s "A" -l "allow" -d "Allow the rule or category (suppress the lint)" # global
complete -c "oxlint" -s "W" -l "warn" -d "Deny the rule or category (emit a warning)" # global
complete -c "oxlint" -s "D" -l "deny" -d "Deny the rule or category (emit an error)" # global
complete -c "oxlint" -l "disable-unicorn-plugin" -d "Disable unicorn plugin, which is turned on by default" # global
complete -c "oxlint" -l "disable-oxc-plugin" -d "Disable oxc unique rules, which is turned on by default" # global
complete -c "oxlint" -l "disable-typescript-plugin" -d "Disable TypeScript plugin, which is turned on by default" # global
complete -c "oxlint" -l "import-plugin" -d "Enable the experimental import plugin and detect ESM problems." # global
complete -c "oxlint" -l "react-plugin" -d "Enable react plugin, which is turned off by default" # global
complete -c "oxlint" -l "jsdoc-plugin" -d "Enable the experimental jsdoc plugin and detect JSDoc problems" # global
complete -c "oxlint" -l "jest-plugin" -d "Enable the Jest plugin and detect test problems" # global
complete -c "oxlint" -l "vitest-plugin" -d "Enable the Vitest plugin and detect test problems" # global
complete -c "oxlint" -l "jsx-a11y-plugin" -d "Enable the JSX-a11y plugin and detect accessibility problems" # global
complete -c "oxlint" -l "nextjs-plugin" -d "Enable the Next.js plugin and detect Next.js problems" # global
complete -c "oxlint" -l "react-perf-plugin" -d "Enable the React performance plugin and detect rendering performance problems" # global
complete -c "oxlint" -l "promise-plugin" -d "Enable the promise plugin and detect promise usage problems" # global
complete -c "oxlint" -l "node-plugin" -d "Enable the node plugin and detect node usage problems" # global
complete -c "oxlint" -l "regex-plugin" -d "Enable the regex plugin and detect regex usage problems" # global
complete -c "oxlint" -l "vue-plugin" -d "Enable the vue plugin and detect vue usage problems" # global
complete -c "oxlint" -l "fix" -d "Fix as many issues as possible." # global
complete -c "oxlint" -l "fix-suggestions" -d "Apply auto-fixable suggestions. May change program behavior." # global
complete -c "oxlint" -l "fix-dangerously" -d "Apply dangerous fixes and suggestions." # global
complete -c "oxlint" -l "ignore-path" -d "Specify the file to use as your .eslintignore" # global
complete -c "oxlint" -l "ignore-pattern" -d "Specify patterns of files to ignore (in addition to those in .eslintignore)" # global
complete -c "oxlint" -l "no-ignore" -d "Disables excluding of files from .eslintignore files, --ignore-path flags and --ignore-pattern flags" # global
complete -c "oxlint" -l "quiet" -d "Disable reporting on warnings, only errors are reported" # global
complete -c "oxlint" -l "deny-warnings" -d "Ensure warnings produce a non-zero exit code" # global
complete -c "oxlint" -l "max-warnings" -d "Specify a warning threshold, which can be used to force exit with an error status if there are too many warning-level rule violations in your project" -xa "INT" # global
complete -c "oxlint" -s "f" -l "format" -d "Use a specific output format." -xa "checkstyle default github gitlab json junit stylish unix" # global
complete -c "oxlint" -l "silent" -d "Do not display any diagnostics" # global
complete -c "oxlint" -l "threads" -d "Number of threads to use." -xa "INT" # global
complete -c "oxlint" -l "print-config" -d "This option outputs the configuration to be used. When present, no linting is performed and only config-related options are valid." # global
complete -c "oxlint" -l "report-unused-disable-directives" -d "Report directive comments like `// eslint-disable-line` when no errors would have been reported on that line anyway." # global
complete -c "oxlint" -l "report-unused-disable-directives-severity" -d "Same as `--report-unused-disable-directives`, but allows you to specify the severity level of the reported errors. Only one of these two options can be used at a time." -xa "SEVERITY" # global
complete -c "oxlint" -l "rules" -d "List all the rules that are currently registered" # global
complete -c "oxlint" -l "disable-nested-config" -d "Disables the automatic loading of nested configuration files." # global
complete -c "oxlint" -l "type-aware" -d "Enables rules that require type information." # global
complete -c "oxlint" -s "h" -l "help" -d "Prints help information" # global
complete -c "oxlint" -s "V" -l "version" -d "Prints version information" # global