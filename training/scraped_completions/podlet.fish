# Completions for the `podlet` helper around Podman Quadlet

function __podlet_operations
    printf '%s\n' \
        start \
        stop \
        restart \
        reload \
        status \
        edit \
        cat \
        logs \
        list \
        inspect
end

function __podlet_operations_need_service
    printf '%s\n' \
        start \
        stop \
        restart \
        status \
        edit \
        cat \
        logs \
        inspect
end

function __podlet_needs_operation
    not __fish_seen_subcommand_from (__podlet_operations)
end

function __podlet_needs_service
    __fish_seen_subcommand_from (__podlet_operations_need_service)
end

function __podlet_list_services --description 'List available Quadlet units'
    set -l uid (command id -u 2>/dev/null)

    if test "$uid" = "0"
        set -l search_roots \
            /etc/containers/systemd \
            /usr/share/containers/systemd \
            /run/containers/systemd \
            /run/systemd/generator \
            /etc/systemd/system
    else
        set -l search_roots \
            ~/.config/containers/systemd \
            ~/.local/share/containers/systemd \
            ~/.config/systemd/user
    end

    if set -q PODLET_EXTRA_QUADLET_PATHS
        for extra in (string split ':' -- $PODLET_EXTRA_QUADLET_PATHS)
            if test -n "$extra"
                set search_roots $search_roots $extra
            end
        end
    end

    set -l patterns \
        '*.container' \
        '*.kube' \
        '*.pod' \
        '*.volume' \
        '*.network' \
        '*.image' \
        '*.service'

    set -l services

    for dir in $search_roots
        if test -d $dir
            for pattern in $patterns
                set -l matches (command find $dir -maxdepth 1 -type f -name $pattern 2>/dev/null)
                if test (count $matches) -gt 0
                    for file in $matches
                        set -l base (basename $file)
                        set -l name (string replace -r '\\.(container|kube|pod|volume|network|image|service)$' '' $base)
                        set services $services $name
                    end
                end
            end
        end
    end

    if type -q podman
        set -l running (podman ps --format '{{.Names}}' 2>/dev/null)
        if test (count $running) -gt 0
            for name in $running
                set services $services $name
            end
        end
    end

    if test (count $services) -gt 0
        printf '%s\n' (printf '%s\n' $services | command sort -u)
    end
end

complete -c podlet -f

for op in (__podlet_operations)
    set -l desc ''
    switch $op
        case start
            set desc '启动指定的 Quadlet 服务'
        case stop
            set desc '停止运行中的 Quadlet 服务'
        case restart
            set desc '重启 Quadlet 服务'
        case reload
            set desc '执行 daemon-reload 重新加载 Quadlet 单元'
        case status
            set desc '查看 Quadlet 服务状态'
        case edit
            set desc '编辑 Quadlet 定义文件'
        case cat
            set desc '查看 Quadlet 定义或生成的服务文件'
        case logs
            set desc '查看 Quadlet 服务的日志输出'
        case list
            set desc '列出现有的 Quadlet 单元'
        case inspect
            set desc '检查 Quadlet 服务的详细信息'
        case '*'
            set desc 'Quadlet 操作'
    end

    complete -c podlet -n '__podlet_needs_operation' -a $op -d $desc
end

complete -c podlet -n '__podlet_needs_service' -a '(__podlet_list_services)' -d 'Quadlet 服务'
