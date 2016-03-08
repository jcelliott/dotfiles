function vmstatus --description 'get the status of a VirtualBox VM' --argument-names "vmname"
    set -l vmstatus (VBoxManage showvminfo $vmname --machinereadable | sed -n 's/VMState="\(.*\)"/\1/p')
    set -l status_color blue
    switch $vmstatus
        case 'aborted'
            set status_color red
        case 'poweroff'
            set status_color red
        case 'paused'
            set status_color yellow
        case 'running'
            set status_color green
    end
    echo (set_color $status_color)$vmstatus(set_color normal)
end

