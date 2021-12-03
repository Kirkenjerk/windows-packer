
# variable files ending with .auto.pkrvars.hcl are automatically loaded
packer build `
  -var='vsphere_guest_os_type=windows9_64Guest' `
  -var='vsphere_vm_name=tpl-windows-10-eval' `
  -var='autounattend_file=answer_files/10/en/autounattend.xml' .
