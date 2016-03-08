function vmstop --description 'stop a VirtualBox VM' --argument-names 'vmname'
    if test -z "$vmname"
        echo "usage: vmstop <vmname|uuid>"
        return 1
    end
    echo "stopping $vmname..."
    VBoxManage controlvm $vmname acpipowerbutton
end

