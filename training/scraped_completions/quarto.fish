# completion for quarto
complete -c quarto

# Main commands
complete -c quarto -n __fish_use_subcommand -xa "render preview create convert inspect tools publish help"

# render command
complete -c quarto -n "__fish_seen_subcommand_from render" -l to -d "Specify output format"
complete -c quarto -n "__fish_seen_subcommand_from render" -l execute -d "Execute code"
complete -c quarto -n "__fish_seen_subcommand_from render" -l no-execute -d "skip code execution"
complete -c quarto -n "__fish_seen_subcommand_from render" -l cache -d "Cache execution output"
complete -c quarto -n "__fish_seen_subcommand_from render" -l no-cache -d "Prevent cache"
complete -c quarto -n "__fish_seen_subcommand_from render" -l cache-refresh -d "Refresh of execution cache"
complete -c quarto -n "__fish_seen_subcommand_from render" -l profile -d "Active project profile(s)"
complete -c quarto -n "__fish_seen_subcommand_from render" -l quiet -d "Suppress console output"

# preview command
complete -c quarto -n "__fish_seen_subcommand_from preview" -l port -d "Suggested port to listen on"
complete -c quarto -n "__fish_seen_subcommand_from preview" -l host -d "Hostname to bind to "
complete -c quarto -n "__fish_seen_subcommand_from preview" -l no-browser -d "Don't open browser to preview the site"
complete -c quarto -n "__fish_seen_subcommand_from preview" -l profile -d "Active project profile(s)"
complete -c quarto -n "__fish_seen_subcommand_from preview" -l quiet -d "Suppress console output"
complete -c quarto -n "__fish_seen_subcommand_from preview" -l render -d "Render to the specified formats before previewing"

# create command
complete -c quarto -n "__fish_seen_subcommand_from create" -a "project extension"

# convert command
complete -c quarto -n "__fish_seen_subcommand_from convert" -l output -d "Write output to PATH"
complete -c quarto -n "__fish_seen_subcommand_from convert" -l quiet -d "Suppress console output"
complete -c quarto -n "__fish_seen_subcommand_from convert" -l profile -d "Active project profile(s)"

# inspect command
complete -c quarto -n "__fish_seen_subcommand_from inspect" -l quiet -d "Suppress console output"

# publish command
complete -c quarto -n "__fish_seen_subcommand_from publish" -a "netlify gh-pages connect quarto-pub posit-cloud confluence huggingface"
complete -c quarto -n "__fish_seen_subcommand_from publish" -l accounts -d "Manage/remove accoutns"
complete -c quarto -n "__fish_seen_subcommand_from publish" -l id -d "Identifier of content to publish"
complete -c quarto -n "__fish_seen_subcommand_from publish" -l server -d "Server to publish to"
complete -c quarto -n "__fish_seen_subcommand_from publish" -l token -d "Access token for publising provider"
complete -c quarto -n "__fish_seen_subcommand_from publish" -l no-browser -d "Don't open a browser after publishing"
complete -c quarto -n "__fish_seen_subcommand_from publish" -l no-prompt -d "Don't prompt to confirm publishing destination"
complete -c quarto -n "__fish_seen_subcommand_from publish" -l no-render -d "Don't render before publishing"
complete -c quarto -n "__fish_seen_subcommand_from publish" -l profile -d "Active project profile(s)"
complete -c quarto -n "__fish_seen_subcommand_from publish" -l quiet -d "Suppress console output"
