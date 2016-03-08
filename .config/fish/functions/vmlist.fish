function vmlist --description 'list VirtualBox VMs and their status'
    for vmname in (VBoxManage list vms | sed -n 's/^"\(.*\)".*/\1/p')
        echo $vmname "("(vmstatus $vmname)")"
    end
end
