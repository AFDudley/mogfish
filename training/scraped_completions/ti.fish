# Fish shell completions for ti command

function __fish_titanium_complete_subcommands
    echo bazel
    echo bazel-push
    echo pulumi
    echo build-deploy
    echo build-all-containers
    echo test
    echo gazelle
    echo py-gazelle
    echo py-format
    echo update-go-deps
    echo configure-gcloud
    echo print-components
    echo build-proto
    echo shining-events-v0-gen
    echo auth-gen
    echo tictl
    echo purge-image-digests
    echo component-selector
    echo pin-selector
    echo publish-debs
    echo ti-version
    echo resume-subenv
    echo gen-fpcm-keys
    echo python
    echo dbt
    echo create-venv
    echo pnpm
    echo upgrade-python-packages
    echo db-connect
end

# Top-level titanium command
complete -c ti -n "__fish_use_subcommand" -f -a "(__fish_titanium_complete_subcommands)"
complete -c ti -f -n "__fish_seen_subcommand_from bazel" -d "run bazel"
complete -c ti -f -n "__fish_seen_subcommand_from bazel-push" -d "run bazel with correct options for container_push targets"
complete -c ti -f -n "__fish_seen_subcommand_from pulumi" -d "run pulumi. you should probably run build-deploy first."
complete -c ti -f -n "__fish_seen_subcommand_from build-deploy" -d "run build and deploy quickly. Provide bazel target as arg if you only want to build one target."
complete -c ti -f -n "__fish_seen_subcommand_from build-all-containers" -d "build all image_push targets (mostly for CI)"
complete -c ti -f -n "__fish_seen_subcommand_from test" -d "run tests (see test --help for more options)"
complete -c ti -f -n "__fish_seen_subcommand_from gazelle" -d "run the bazel build file generator. you should run this after every go code change."
complete -c ti -f -n "__fish_seen_subcommand_from py-gazelle" -d "run the bazel build file generator. you should run this after every python code change."
complete -c ti -f -n "__fish_seen_subcommand_from py-format" -d "run the python formatter. you should run this before committing."
complete -c ti -f -n "__fish_seen_subcommand_from update-go-deps" -d "run the bazel build file generator to update go dependencies. you should run anytime you update go.mod/go.sum."
complete -c ti -f -n "__fish_seen_subcommand_from configure-gcloud" -d "sets up gcloud config and components like docker auth and kubernetes"
complete -c ti -f -n "__fish_seen_subcommand_from print-components" -d "print the components enabled for this environment"
complete -c ti -f -n "__fish_seen_subcommand_from build-proto" -d "generate code/openapi for the proto files in api/proto"
complete -c ti -f -n "__fish_seen_subcommand_from shining-events-v0-gen" -d "generate go for shining-events-v0 schema"
complete -c ti -f -n "__fish_seen_subcommand_from auth-gen" -d "generate go, markdown, and typescript source and doc files related to authn/authz within titanium"
complete -c ti -f -n "__fish_seen_subcommand_from tictl" -d "build and run development version of tictl"
complete -c ti -f -n "__fish_seen_subcommand_from purge-image-digests" -d "purge any locally build image digests and fall back to using the primary environment version"
complete -c ti -f -n "__fish_seen_subcommand_from component-selector" -d "interactive prompt to select which component to enable for an environment. Provide environment like -e alex.brainos.dev."
complete -c ti -f -n "__fish_seen_subcommand_from pin-selector" -d "interactive prompt to select which targets to pin for an environment. Provide environment like -e brainos.dev."
complete -c ti -f -n "__fish_seen_subcommand_from publish-debs" -d "upload debian packages to the titanium-integ repo in artifactory (requires jfrog cli set up)"
complete -c ti -f -n "__fish_seen_subcommand_from ti-version" -d "print the current titanium version that is embedded in debian packages"
complete -c ti -f -n "__fish_seen_subcommand_from resume-subenv" -d "scale a subenv back up after the nightly shutdown. provide name the name (alex) as an argument"
complete -c ti -f -n "__fish_seen_subcommand_from gen-fpcm-keys" -d "generate a public and private ECDSA key pair for the fpcm provisioning server hardware json web token"
complete -c ti -f -n "__fish_seen_subcommand_from python" -d "run python command in the titanium virtualenv"
complete -c ti -f -n "__fish_seen_subcommand_from dbt" -d "run dbt in environment"
complete -c ti -f -n "__fish_seen_subcommand_from create-venv" -d "reset virtualenv according to lock files"
complete -c ti -f -n "__fish_seen_subcommand_from pnpm" -d "run the same version of pnpm that bazel uses, but outside of bazel for local development"
complete -c ti -f -n "__fish_seen_subcommand_from upgrade-python-packages" -d "call `bazel run //:gen_requirements_{platform}_{arch}_txt.update ... for each platform/arch"
complete -c ti -f -n "__fish_seen_subcommand_from db-connect" -d "connect to the alloydb database [database] (defaults to: <subenv>_titanium)"
