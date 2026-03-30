# Always provide completions for command line utilities.
#
# Check Fish documentation about completions:
# http://fishshell.com/docs/current/commands.html#complete
#
# If your package doesn't provide any command line utility,
# feel free to remove completions directory from the project.

set -l IONIC_PLATFORMS (ionic platform | grep -oEi "^\ \ ([a-zA-Z0-9\-]*)" | cut -c3-)

# Ionic
complete -c ionic -f -n "__fish_use_subcommand" -d "The top open source framework for building amazing mobile apps."

# Help
complete -c ionic -f -n "__fish_use_subcommand" -a help -d "Provides help for a certain command"

# Start
complete -c ionic -f -n "__fish_use_subcommand" -a start -d "Starts a new Ionic project in the specified PATH"
complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "--appname" -d "Human readable name for the app (Use quotes around the name)"
complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "-a" -d "Human readable name for the app (Use quotes around the name)"
complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "--id" -d "Package name for <widget id> config, ex: com.mycompany.myapp"
complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "-i" -d "Package name for <widget id> config, ex: com.mycompany.myapp"
complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "--skip-npm" -d "Skip npm package installation"
complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "--no-cordova" -d "Create a basic structure without Cordova requirements"
complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "-w" -d "Create a basic structure without Cordova requirements"
complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "--sass" -d "Setup the project to use Sass CSS precompiling"
complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "-s" -d "Setup the project to use Sass CSS precompiling"
complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "--list" -d "List starter templates available"
complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "-l" -d "List starter templates available"
complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "--io-app-id" -d "The Ionic.io app ID to use"
complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "--template" -d "Project starter template"
complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "-t" -d "Project starter template"
complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "--v2" -d "Start a Ionic v2 project"
complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "-v" -d "Start a Ionic v2 project"
complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "--zip-file" -d "URL to download zipfile for starter template"
complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "-z" -d "URL to download zipfile for starter template"

# Serve
complete -c ionic -f -n "__fish_use_subcommand" -a serve -d "Start a local development server for app dev/testing"
complete -c ionic -f -n "__fish_seen_subcommand_from t serve" -a "--consolelogs" -d "Print app console logs to Ionic CLI"
complete -c ionic -f -n "__fish_seen_subcommand_from t serve" -a "-c" -d "Print app console logs to Ionic CLI"
complete -c ionic -f -n "__fish_seen_subcommand_from t serve" -a "--serverlogs" -d "Print dev server logs to Ionic CLI"
complete -c ionic -f -n "__fish_seen_subcommand_from t serve" -a "-s" -d "Print dev server logs to Ionic CLI"
complete -c ionic -f -n "__fish_seen_subcommand_from t serve" -a "--port" -d "Dev server HTTP port (8100 default)"
complete -c ionic -f -n "__fish_seen_subcommand_from t serve" -a "-p" -d "Dev server HTTP port (8100 default)"
complete -c ionic -f -n "__fish_seen_subcommand_from t serve" -a "--livereload-port" -d "Live Reload port (35729 default)"
complete -c ionic -f -n "__fish_seen_subcommand_from t serve" -a "-r" -d "Live Reload port (35729 default)"
complete -c ionic -f -n "__fish_seen_subcommand_from t serve" -a "--nobrowser" -d "Disable launching a browser"
complete -c ionic -f -n "__fish_seen_subcommand_from t serve" -a "-b" -d "Disable launching a browser"
complete -c ionic -f -n "__fish_seen_subcommand_from t serve" -a "--nolivereload" -d "Do not start live reload"
complete -c ionic -f -n "__fish_seen_subcommand_from t serve" -a "-d" -d "Do not start live reload"
complete -c ionic -f -n "__fish_seen_subcommand_from t serve" -a "--noproxy" -d "Do not add proxies"
complete -c ionic -f -n "__fish_seen_subcommand_from t serve" -a "-x" -d "Do not add proxies"
complete -c ionic -f -n "__fish_seen_subcommand_from t serve" -a "--address" -d "Use specific address or return with failure"
complete -c ionic -f -n "__fish_seen_subcommand_from t serve" -a "--all" -d "Have the server listen on all addresses (0.0.0.0)"
complete -c ionic -f -n "__fish_seen_subcommand_from t serve" -a "-a" -d "Have the server listen on all addresses (0.0.0.0)"
complete -c ionic -f -n "__fish_seen_subcommand_from t serve" -a "--browser" -d "Specifies the browser to use (safari, firefox, chrome)"
complete -c ionic -f -n "__fish_seen_subcommand_from t serve" -a "-w" -d "Specifies the browser to use (safari, firefox, chrome)"
complete -c ionic -f -n "__fish_seen_subcommand_from t serve" -a "--browseroption" -d "Specifies a path to open to (/#/tab/dash)"
complete -c ionic -f -n "__fish_seen_subcommand_from t serve" -a "-o" -d "Specifies a path to open to (/#/tab/dash)"
complete -c ionic -f -n "__fish_seen_subcommand_from t serve" -a "--lab" -d "Test your apps on multiple screen sizes and platform types"
complete -c ionic -f -n "__fish_seen_subcommand_from t serve" -a "-l" -d "Test your apps on multiple screen sizes and platform types"
complete -c ionic -f -n "__fish_seen_subcommand_from t serve" -a "--nogulp" -d "Disable running gulp during serve"
complete -c ionic -f -n "__fish_seen_subcommand_from t serve" -a "--platform" -d "Start serve with a specific platform (ios/android)"
complete -c ionic -f -n "__fish_seen_subcommand_from t serve" -a "-t" -d "Start serve with a specific platform (ios/android)"

# Setup
complete -c ionic -f -n "__fish_use_subcommand" -a setup -d "Configure the project with a build tool"
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "--appname" -d ""
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "-a" -d ""

# Generate
complete -c ionic -f -n "__fish_use_subcommand" -a generate -d "Generate pages and components"
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "--appname" -d ""
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "-a" -d ""

# Platform
complete -c ionic -f -n "__fish_use_subcommand" -a platform -d "Add platform target for building an Ionic app"
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "--appname" -d ""
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "-a" -d ""

# Run
complete -c ionic -f -n "__fish_use_subcommand" -a run -d "Starts a new Ionic project in the specified PATH"
complete -c ionic -f -n "__fish_seen_subcommand_from t run" -a "$IONIC_PLATFORMS"
complete -c ionic -f -n "__fish_seen_subcommand_from t run" -a "--livereload" -d "Live reload app dev files from the device"
complete -c ionic -f -n "__fish_seen_subcommand_from t run" -a "-l" -d "Live reload app dev files from the device"
complete -c ionic -f -n "__fish_seen_subcommand_from t run" -a "--address" -d "Use specific address (livereload req.)"
complete -c ionic -f -n "__fish_seen_subcommand_from t run" -a "--port" -d "Dev server HTTP port (8100 default, livereload req.)"
complete -c ionic -f -n "__fish_seen_subcommand_from t run" -a "-p" -d "Dev server HTTP port (8100 default, livereload req.)"
complete -c ionic -f -n "__fish_seen_subcommand_from t run" -a "--livereload-port" -d "Live Reload port (35729 default, livereload req.)"
complete -c ionic -f -n "__fish_seen_subcommand_from t run" -a "-r" -d "Live Reload port (35729 default, livereload req.)"
complete -c ionic -f -n "__fish_seen_subcommand_from t run" -a "--consolelogs" -d "Print app console logs to Ionic CLI (livereload req.)"
complete -c ionic -f -n "__fish_seen_subcommand_from t run" -a "-c" -d "Print app console logs to Ionic CLI (livereload req.)"
complete -c ionic -f -n "__fish_seen_subcommand_from t run" -a "--serverlogs" -d "Print dev server logs to Ionic CLI (livereload req.)"
complete -c ionic -f -n "__fish_seen_subcommand_from t run" -a "-s" -d "Print dev server logs to Ionic CLI (livereload req.)"
complete -c ionic -f -n "__fish_seen_subcommand_from t run" -a "--debug" -d "Debug"
complete -c ionic -f -n "__fish_seen_subcommand_from t run" -a "--release" -d "Release"
complete -c ionic -f -n "__fish_seen_subcommand_from t run" -a "--device" -d "Device"
complete -c ionic -f -n "__fish_seen_subcommand_from t run" -a "--emulator" -d "Emulator"
complete -c ionic -f -n "__fish_seen_subcommand_from t run" -a "--target=" -d "target=FOO"

# Emulate
complete -c ionic -f -n "__fish_use_subcommand" -a emulate -d "Emulate an Ionic project on a simulator or emulator"
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "--appname" -d ""
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "-a" -d ""

# Build
complete -c ionic -f -n "__fish_use_subcommand" -a build -d "Build (prepare + compile) an Ionic project for a given platform."
complete -c ionic -f -n "__fish_seen_subcommand_from t build" -a "$IONIC_PLATFORMS"
complete -c ionic -f -n "__fish_seen_subcommand_from t build" -a "--nohooks" -d "Do not add default Ionic hooks for Cordova"
complete -c ionic -f -n "__fish_seen_subcommand_from t build" -a "-n" -d "Do not add default Ionic hooks for Cordova"

# Plugin
complete -c ionic -f -n "__fish_use_subcommand" -a plugins -d "Manage Cordova plugins"
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "--appname" -d ""
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "-a" -d ""

# Resources
complete -c ionic -f -n "__fish_use_subcommand" -a resources -d "Automatically create icon and splash screen resources"
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "--appname" -d ""
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "-a" -d ""

# Upload
complete -c ionic -f -n "__fish_use_subcommand" -a upload -d "Upload an app to your Ionic account"
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "--appname" -d ""
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "-a" -d ""

# Share
complete -c ionic -f -n "__fish_use_subcommand" -a share -d "Share an app with a client, co-worker, friend, or customer"
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "--appname" -d ""
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "-a" -d ""

# Lib
complete -c ionic -f -n "__fish_use_subcommand" -a lib -d "Gets Ionic library version or updates the Ionic library"
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "--appname" -d ""
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "-a" -d ""

# Login
complete -c ionic -f -n "__fish_use_subcommand" -a login -d "Login to your Ionic account"
complete -c ionic -f -n "__fish_seen_subcommand_from t login" -a "--email" -d "Ionic account email"
complete -c ionic -f -n "__fish_seen_subcommand_from t login" -a "-e" -d "Ionic account email"
complete -c ionic -f -n "__fish_seen_subcommand_from t login" -a "--password" -d "Ionic account password"
complete -c ionic -f -n "__fish_seen_subcommand_from t login" -a "-p" -d "Ionic account password"

# IO
complete -c ionic -f -n "__fish_use_subcommand" -a io -d "Integrate your app with Ionic Cloud services"
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "--appname" -d ""
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "-a" -d ""

# Security
complete -c ionic -f -n "__fish_use_subcommand" -a security -d "Store your app's credentials for the Ionic Cloud"
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "--appname" -d ""
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "-a" -d ""

# Push
complete -c ionic -f -n "__fish_use_subcommand" -a push -d "Upload APNS and GCM credentials to Ionic Push"
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "--appname" -d ""
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "-a" -d ""

# Package
complete -c ionic -f -n "__fish_use_subcommand" -a package -d "Use Ionic Package to build your app"
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "--appname" -d ""
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "-a" -d ""

# Config
complete -c ionic -f -n "__fish_use_subcommand" -a config -d "Set configuration variables for your ionic app"
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "--appname" -d ""
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "-a" -d ""

# Service
complete -c ionic -f -n "__fish_use_subcommand" -a service -d "Ionic service package commands"
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "--appname" -d ""
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "-a" -d ""

# Add
complete -c ionic -f -n "__fish_use_subcommand" -a add -d "Add an Ion, bower component, or addon to the project"
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "--appname" -d ""
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "-a" -d ""

# Remove
complete -c ionic -f -n "__fish_use_subcommand" -a remove -d "Remove an Ion, bower component, or addon from the project"
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "--appname" -d ""
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "-a" -d ""

# List
complete -c ionic -f -n "__fish_use_subcommand" -a list -d "List Ions, bower components, or addons in the project"
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "--appname" -d ""
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "-a" -d ""

# Info
complete -c ionic -f -n "__fish_use_subcommand" -a info -d "List information about the users runtime environment"
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "--appname" -d ""
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "-a" -d ""

# Link
complete -c ionic -f -n "__fish_use_subcommand" -a link -d "Sets your Ionic App ID for your project"
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "--appname" -d ""
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "-a" -d ""

# Hooks
complete -c ionic -f -n "__fish_use_subcommand" -a hooks -d "Manage your Ionic Cordova hooks"
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "--appname" -d ""
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "-a" -d ""

# State
complete -c ionic -f -n "__fish_use_subcommand" -a state -d "Saves or restores state of your Ionic Application using the package.json file"
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "--appname" -d ""
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "-a" -d ""

# Docs
complete -c ionic -f -n "__fish_use_subcommand" -a docs -d "Opens up the documentation for Ionic"
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "--appname" -d ""
# complete -c ionic -f -n "__fish_seen_subcommand_from t start" -a "-a" -d ""
