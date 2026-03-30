# Generate GitHub permalinks for vscode-languageserver type definitions
# This file defines the vscode-lsp-types function, completions, and abbreviations

# Main function definition
function vscode-lsp-types -d "Generate GitHub permalink for vscode-languageserver type definition"
    # Parse arguments using argparse
    argparse --name=vscode-lsp-types \
        'h/help' \
        'i/interface' \
        't/type' \
        'c/class' \
        'e/enum' \
        'n/namespace' \
        'o/open' \
        'no-copy' \
        'u/url' \
        -- $argv
    or return
    
    # Show help if requested
    if set -q _flag_help
        echo "Usage: vscode-lsp-types [options] <TypeName[.property]>" >&2
        echo "" >&2
        echo "Options:" >&2
        echo "  -i, --interface   Search only for interfaces" >&2
        echo "  -t, --type        Search only for type aliases" >&2
        echo "  -c, --class       Search only for classes" >&2
        echo "  -e, --enum        Search only for enums" >&2
        echo "  -n, --namespace   Search only for namespaces" >&2
        echo "                    (Multiple type flags can be combined)" >&2
        echo "  -o, --open        Open the permalink in the browser" >&2
        echo "  -u, --url         Output only the URL (no 'open' prefix)" >&2
        echo "      --no-copy     Don't copy the permalink to clipboard" >&2
        echo "  -h, --help        Show this help message" >&2
        echo "" >&2
        echo "Examples:" >&2
        echo "  vscode-lsp-types CompletionItem" >&2
        echo "  vscode-lsp-types LocationLink.targetUri" >&2
        echo "  vscode-lsp-types --interface Hover" >&2
        echo "  vscode-lsp-types -t Range --open" >&2
        echo "  vscode-lsp-types Position --no-copy" >&2
        echo "" >&2
        echo "Abbreviation:" >&2
        echo "  vsc -> vscode-lsp-types" >&2
        return 0
    end
    
    # Collect all specified declaration types
    set -l declaration_types
    for flag in _flag_{interface,type,class,enum,namespace}
        if set -q $flag
            set -a declaration_types (string sub -s (math (string length -- "_flag_") + 1) -- $flag)
        end
    end
    
    # Get type name from remaining arguments
    set -l type_name $argv[1]
    
    # Get the latest commit SHA
    set -l commit_sha (gh api repos/microsoft/vscode-languageserver-node/commits/main --jq .sha 2>/dev/null)
    if test $status -ne 0
        echo "Error: Failed to fetch commit SHA (is gh CLI installed?)" >&2
        return 1
    end

    # If no type name provided, output the base URL
    if test -z "$type_name"
        set -l base_url "https://github.com/microsoft/vscode-languageserver-node/blob/$commit_sha/types/src/main.ts"
        
        # Copy to clipboard unless --no-copy is specified
        if not set -q _flag_no_copy
            echo -n $base_url | fish_clipboard_copy 2>/dev/null
        end
        
        # Open in browser if requested
        if set -q _flag_open
            if command -q open
                open $base_url
            else if command -q xdg-open
                xdg-open $base_url 2>/dev/null &
            else if command -q wslview
                wslview $base_url
            end
        end
        
        # Output the URL
        if set -q _flag_url
            echo $base_url
        else
            echo "open $base_url"
        end
        return 0
    end

    # Handle nested property access (e.g., LocationLink.targetUri)
    set -l property_name ""
    if string match -q "*.*" "$type_name"
        set -l parts (string split "." "$type_name")
        set type_name $parts[1]
        set property_name $parts[2]
    end

    # Build the regex pattern based on declaration types
    set -l pattern
    if test (count $declaration_types) -gt 0
        # Search for specific declaration types
        set -l types_pattern (string join "|" $declaration_types)
        set pattern "^export ($types_pattern) $type_name"'[^a-zA-Z0-9_]'
    else
        # Search for any declaration type
        set pattern "^export (interface|type|class|enum|namespace|declare) $type_name"'[^a-zA-Z0-9_]'
    end

    # Fetch the file content and find the line number
    set -l line_number (gh api repos/microsoft/vscode-languageserver-node/contents/types/src/main.ts --jq .content 2>/dev/null \
        | base64 -d \
        | grep -nE "$pattern" \
        | head -1 \
        | cut -d: -f1)

    if test -z "$line_number"
        # Try without the export prefix
        if test (count $declaration_types) -gt 0
            set -l types_pattern (string join "|" $declaration_types)
            set pattern "^($types_pattern) $type_name"'[^a-zA-Z0-9_]'
        else
            set pattern "^(interface|type|class|enum|namespace) $type_name"'[^a-zA-Z0-9_]'
        end
        
        set line_number (gh api repos/microsoft/vscode-languageserver-node/contents/types/src/main.ts --jq .content 2>/dev/null \
            | base64 -d \
            | grep -nE "$pattern" \
            | head -1 \
            | cut -d: -f1)
    end

    if test -z "$line_number"
        echo "Error: Type definition for '$type_name' not found in main.ts" >&2
        return 1
    end

    # If a property name is specified, search for it within the type definition
    if test -n "$property_name"
        # Get the file content starting from the line after the type definition
        set -l start_line (math $line_number + 1)
        set -l property_line (gh api repos/microsoft/vscode-languageserver-node/contents/types/src/main.ts --jq .content 2>/dev/null \
            | base64 -d \
            | tail -n +$start_line \
            | grep -nE "^[[:space:]]+(readonly[[:space:]]+)?$property_name(\\?)?:" \
            | head -1 \
            | cut -d: -f1)
        
        if test -n "$property_line"
            # Adjust the line number to be relative to the file start
            set line_number (math $line_number + $property_line)
        else
            echo "Warning: Property '$property_name' not found in '$type_name', showing type definition instead" >&2
        end
    end

    # Generate the permalink
    set -l permalink "https://github.com/microsoft/vscode-languageserver-node/blob/$commit_sha/types/src/main.ts#L$line_number"
    
    # Copy to clipboard unless --no-copy is specified
    if not set -q _flag_no_copy
        echo -n $permalink | fish_clipboard_copy 2>/dev/null
    end
    
    # Open in browser if requested
    if set -q _flag_open
        if command -q open
            open $permalink
        else if command -q xdg-open
            xdg-open $permalink 2>/dev/null &
        else if command -q wslview
            wslview $permalink
        else
            echo "Warning: Could not find a command to open the browser" >&2
        end
    end
    
    # Output the URL
    if set -q _flag_url
        echo $permalink
    else
        echo "open $permalink"
    end
end

# Completions for vscode-lsp-types
complete -c vscode-lsp-types -n 'not __fish_contains_opt -s i interface' -s i -l interface  -d "Search only for interfaces"
complete -c vscode-lsp-types -n 'not __fish_contains_opt -s t type'      -s t -l type       -d "Search only for type aliases"
complete -c vscode-lsp-types -n 'not __fish_contains_opt -s c class'     -s c -l class      -d "Search only for classes"
complete -c vscode-lsp-types -n 'not __fish_contains_opt -s e enum'      -s e -l enum       -d "Search only for enums"
complete -c vscode-lsp-types -n 'not __fish_contains_opt -s n namespace' -s n -l namespace  -d "Search only for namespaces"
complete -c vscode-lsp-types -n 'not __fish_contains_opt -s o open'      -s o -l open       -d "Open the permalink in the browser"
complete -c vscode-lsp-types -n 'not __fish_contains_opt -s u url'       -s u -l url        -d "Output only the URL (no 'open' prefix)"
complete -c vscode-lsp-types -n 'not __fish_contains_opt no-copy'             -l no-copy    -d "Don't copy the permalink to clipboard"
complete -c vscode-lsp-types -s h -l help -d "Show help message"

# Function to provide dynamic completions from the actual vscode-languageserver-node repository
function __vscode_lsp_types_completions -d 'Fetch type names from vscode-languageserver-node repository'
    # Cache the types to avoid repeated API calls
    set -g __vscode_lsp_types_cache_time 2>/dev/null
    set -g __vscode_lsp_types_cache 2>/dev/null
    
    # Only refresh cache if it's empty or older than 1 hour
    set -l current_time (date +%s)
    if test -z "$__vscode_lsp_types_cache_time"; or test (math $current_time - $__vscode_lsp_types_cache_time) -gt 3600
        # Fetch all exported type names from the repository
        set -g __vscode_lsp_types_cache (gh api repos/microsoft/vscode-languageserver-node/contents/types/src/main.ts --jq .content 2>/dev/null \
            | base64 -d \
            | grep -oE "^export (interface|type|class|enum|namespace) [A-Z][A-Za-z0-9_]+" \
            | awk '{print $3}' \
            | sort -u)
        set -g __vscode_lsp_types_cache_time $current_time
    end
    
    # Return the cached types
    printf '%s\n' $__vscode_lsp_types_cache
end

# Function to provide property completions for Type.property syntax
function __vscode_lsp_types_property_completions -d 'Provide property completions for Type.property syntax'
    # Get the current token being completed
    set -l current_token (commandline -ct)
    
    # Check if current token contains a dot (e.g., "CompletionItem." or "CompletionItem.lab")
    if string match -q "*.*" -- "$current_token"
        set -l parts (string split "." "$current_token")
        set -l type_name $parts[1]
        
        # Fetch the file content and extract properties for this type
        # Use awk to extract the interface/type body and grep for properties
        set -l properties (gh api repos/microsoft/vscode-languageserver-node/contents/types/src/main.ts --jq .content 2>/dev/null \
            | base64 -d \
            | awk "/^export (interface|type|class) $type_name \{/,/^}/" \
            | grep -oE "^\s+[a-zA-Z_][a-zA-Z0-9_]*\?*:" \
            | sed 's/^\s*//; s/[?:].*//')
        
        # Return properties with the type name prefix
        for prop in $properties
            echo "$type_name.$prop"
        end
    end
end

# Add dynamic completions for type names (only when no dot present)
complete -c vscode-lsp-types -n "not string match -q '*.*' -- (commandline -ct)" -xa "(__vscode_lsp_types_completions)"

# Add property completions when a dot is present
complete -c vscode-lsp-types -n "string match -q '*.*' -- (commandline -ct)" -xa "(__vscode_lsp_types_property_completions)"

# Abbreviation
abbr -a vsc vscode-lsp-types
