function _freespace
    set -l disks (string split "\n" (df | awk '/^\/dev\/disk/{ printf $1 ":"; for (i=9; i<=NF; i++) printf $i FS; print "" }'))
    for disk in $disks
        echo $disk
    end
end

complete -f -c freespace -n _freespace
