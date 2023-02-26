# Scripts
- List of apps for local and development use
- Install scripts
- Ansible playbooks

## Usage
1) Modify the hosts file located in server directory by replacing <ip-address> and <username>
2) Use commands on local machine
```
ansible-playbook ansible-server-start.yml -i hosts --ask-become-pass
```
