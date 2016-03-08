function vmstart --description 'start a VirtualBox VM in headless mode' --argument-names 'vmname'
    if test -z "$vmname"
        echo "usage: vmstart <vmname|uuid>"
        return 1
    end
    if VBoxManage showvminfo $vmname --machinereadable | grep -q 'VMState="paused"'
        echo "$vmname is paused, resuming..."
        VBoxManage controlvm $vmname resume
    else
        echo "$vmname is stopped, starting..."
        VBoxManage startvm $vmname --type headless
    end
end
