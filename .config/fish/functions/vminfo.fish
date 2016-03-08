function vminfo --description 'get information about a VirtualBox VM' --argument-names 'vmname'
    if test -z "$vmname"
        echo "usage: vminfo <vmname|uuid>"
        return 1
    end
    echo "$vmname ("(vmstatus $vmname)")"
    VBoxManage showvminfo $vmname --machinereadable | grep --color=never 'UUID='
    VBoxManage showvminfo $vmname --machinereadable | grep --color=never 'cpus='
    VBoxManage showvminfo $vmname --machinereadable | grep --color=never 'memory='
end

