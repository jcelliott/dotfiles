function vmpause --description 'pause a VirtualBox VM' --argument-names 'vmname'
    if test -z "$vmname"
        echo "usage: vmpause <vmname|uuid>"
        return 1
    end
    echo "pausing $vmname..."
    VBoxManage controlvm $vmname pause
end

