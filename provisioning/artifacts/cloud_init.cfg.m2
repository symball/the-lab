#cloud-config
# vim: syntax=yaml
#
# ***********************
# 	---- for more examples look at: ------
# ---> https://cloudinit.readthedocs.io/en/latest/topics/examples.html
# ******************************
#
# This is the configuration syntax that the write_files module
# will know how to understand. encoding can be given b64 or gzip or (gz+b64).
# The content will be decoded accordingly and then written to the path that is
# provided.
#
# Note: Content strings here are truncated for example purposes.
growpart:
    mode: auto
    devices: ["/"]
system_info:
   default_user:
      name: {{ MASTER_USER }}
      home: "/home/{{ MASTER_USER }}"
      sudo: "ALL=(ALL) NOPASSWD:ALL"
      ssh_authorized_keys:
         - "{{ SSH_PUBLIC_MASTER_KEY }}"