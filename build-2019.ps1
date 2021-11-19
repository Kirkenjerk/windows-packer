
# variable files ending with .auto.pkrvars.hcl are automatically loaded
packer build `
  -var='vsphere_guest_os_type=windows9Server64Guest' `
  -var='vsphere_vm_name=packer-windows-2019-test' `
  -var='autounattend_file=answer_files/2019/en/autounattend.xml' .
