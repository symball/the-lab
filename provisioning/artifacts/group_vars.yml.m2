---
#
# Ansible controller variables
#
ansible_project_name: the-lab
ansible_working_path: ~/.ansible-projects/{{ OPEN }} ansible_project_name {{ CLOSE }}
# A placeholder that will leave a fingerprint on the device upon running certain
# tasks. This is primarily used for defining linkage between a separate CI system
# such as Jenkins
setup_job_number: develop
#
# Common Low Privilege user options
#
common_user_create: true
common_user: {{ COMMON_USER }}
common_group: {{ COMMON_USER }}
common_user_home: /home/{{ COMMON_USER }}
remote_state_path: "{{ OPEN }} common_user_home {{ CLOSE }}/.ansible-state"
# Either file or URL
common_user_key_type: file
common_user_key_location: {{ SSH_KEY_COMMON_PATH }}.pub
# When creating Nginx sites, whether or not to use letsencrypyt
nginx_facade_use_certbot: false
nginx_use_internal_certificate_authority: true
nginx_facade_admin_email: contact@simonball.me
#
#
#
desktop: false
rich_shell: false
certificate_authority_trust_chain: true
#
# ARCH AUR HELPER
#
yay_install: true
aur_build_user: aurbuilder
#
# Ansible management flags
# The following flags will completely enable / disable aspects of Ansible operations
#
role_management_enabled: true
include_certificate_authority_management: "{{ OPEN }} role_management_enabled {{ CLOSE }}"
include_common_management: "{{ OPEN }} role_management_enabled {{ CLOSE }}"
include_desktop_management: "{{ OPEN }} role_management_enabled {{ CLOSE }}"
include_developer_management: "{{ OPEN }} role_management_enabled {{ CLOSE }}"
include_docker_management: "{{ OPEN }} role_management_enabled {{ CLOSE }}"
include_docker_container_registry_management: "{{ OPEN }} role_management_enabled {{ CLOSE }}"
include_forgejo_management: "{{ OPEN }} role_management_enabled {{ CLOSE }}"
include_go_management: "{{ OPEN }} role_management_enabled {{ CLOSE }}"
include_jenkins_management: "{{ OPEN }} role_management_enabled {{ CLOSE }}"
include_home_assistant_management: "{{ OPEN }} role_management_enabled {{ CLOSE }}"
include_kvm_management: "{{ OPEN }} role_management_enabled {{ CLOSE }}"
include_mariadb_management: "{{ OPEN }} role_management_enabled {{ CLOSE }}"
include_nginx_management: "{{ OPEN }} role_management_enabled {{ CLOSE }}"
include_nvm_management: "{{ OPEN }} role_management_enabled {{ CLOSE }}"
include_postgresql_management: "{{ OPEN }} role_management_enabled {{ CLOSE }}"
include_python_management: "{{ OPEN }} role_management_enabled {{ CLOSE }}"
include_rabbitmq_management: "{{ OPEN }} role_management_enabled {{ CLOSE }}"
include_redis_management: "{{ OPEN }} role_management_enabled {{ CLOSE }}"
include_terraform_management: "{{ OPEN }} role_management_enabled {{ CLOSE }}"
include_vagrant_management: "{{ OPEN }} role_management_enabled {{ CLOSE }}"
include_virtualbox_management: "{{ OPEN }} role_management_enabled {{ CLOSE }}"
