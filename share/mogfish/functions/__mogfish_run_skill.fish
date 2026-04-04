# __mogfish_run_skill — retrieve a cached Mog skill, compile, and execute.
#
# The skill cache (managed by the skill-cache Rust crate) stores skills as
# JSON files at $MOGFISH_DATA_DIR/skills/{slug}.json. Each contains a
# mog_script field with the Mog source. This function:
#   1. Reads the skill JSON via jq
#   2. Compiles the Mog source with mogc (caching the binary)
#   3. Executes the compiled binary
#
# Slugify must match Rust: crates/skill-cache/src/lib.rs slugify()
# Requires: jq, mogc on PATH. Fails fast if either is missing.

function __mogfish_run_skill --argument-names intent
    # Resolve data directory
    set -l data_dir
    if set -q MOGFISH_DATA_DIR
        set data_dir $MOGFISH_DATA_DIR
    else
        set data_dir $HOME/.mogfish
    end

    # Slugify intent — must match Rust slugify() in skill-cache/src/lib.rs:
    # non-alphanumeric → '-', lowercase
    set -l slug (echo $intent | string replace -ra '[^a-zA-Z0-9]' '-' | string lower)

    set -l skill_file $data_dir/skills/$slug.json
    if not test -f $skill_file
        echo "mogfish: skill not found: $intent ($skill_file)" >&2
        return 1
    end

    # Extract mog_script from skill JSON
    if not command -q jq
        echo "mogfish: jq required but not found" >&2
        return 1
    end

    set -l mog_script (jq -r '.mog_script' $skill_file)
    if test -z "$mog_script"; or test "$mog_script" = "null"
        echo "mogfish: empty mog_script in $skill_file" >&2
        return 1
    end

    # Check compiled binary cache
    set -l compiled_dir $data_dir/compiled
    mkdir -p $compiled_dir
    set -l binary $compiled_dir/$slug
    set -l hash_file $compiled_dir/$slug.hash

    # Hash the mog_script to detect changes
    set -l current_hash (echo $mog_script | sha256sum | string split ' ')[1]

    set -l needs_compile 1
    if test -f $binary; and test -f $hash_file
        set -l cached_hash (cat $hash_file)
        if test "$cached_hash" = "$current_hash"
            set needs_compile 0
        end
    end

    if test $needs_compile -eq 1
        if not command -q mogc
            echo "mogfish: mogc compiler required but not found" >&2
            return 1
        end

        # Write mog source to temp file, compile
        set -l tmpfile (mktemp /tmp/mogfish-skill-XXXXXX.mog)
        echo $mog_script > $tmpfile
        mogc $tmpfile -o $binary 2>&1
        set -l compile_status $status
        rm -f $tmpfile

        if test $compile_status -ne 0
            echo "mogfish: compilation failed for skill '$intent'" >&2
            return 1
        end

        # Cache the hash
        echo $current_hash > $hash_file
    end

    # Execute the compiled skill binary
    $binary
    return $status
end
