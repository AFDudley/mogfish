# sinh-x.fish is only meant to be used in interactive mode. If not in interactive mode and not in CI, skip the config to speed up shell startup
if not status is-interactive && test "$CI" != true
    exit
end

# install the default bindings
sinh_configure_bindings

# Doesn't erase autoloaded _sinh_* functions because they are not easily accessible once key bindings are erased
function _sinh_uninstall --on-event sinh-x_uninstall
    _sinh_uninstall_bindings

    functions --erase _sinh_uninstall _sinh_uninstall_bindings sinh_configure_bindings
    complete --erase sinh_configure_bindings

    set_color cyan
    echo "sinh-x.fish uninstalled."
    set_color normal
end
