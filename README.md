# sz-ansible
My personal project I use to deploy my dotfiles, install packages, and configure my workstations for development.

# Roles
Roles in the `roles-installed` are roles that are downloaded using the `--install` CLI argument on Ansible-playbook.

Roles in the `roles` directory are older roles that I consider to be *legacy* roles. These typically require a `-e global_do_install=1` or `-e role-name_do_install=1` to perform any tasks.

Roles in the `roles-next` directory have been converted from `roles` with best practices in mind.

## Roles Next (`roles-next`)
Best Practices used in `roles-next`:

### General
- [ ] The role is standalone. It does not require any variables set at the environment or command line in order to run successfully

### Variables
- [ ] All variables required to use the role are defined in either `defaults/main.yml` or `vars/main.yml`
- [ ] All variable names start with the name of the role. i.e. for the *development* role, variable names are `development_environments`, `development_php_bin`, etc.
- [ ] All variables needing the flexibility of value changes, but have *sane* defaults should be defined in `defaults/main.yml`
- [ ] All variables not requiring customization should be defined in `vars/main.yml`

### Install/Uninstall
- [ ] A `tasks/main.yml` file exists with the sole purpose to use `import_tasks` on an *install* task file or an *uninstall/remove* task file
  - For example, use a *when* condition of `not desktop_do_remove` in `tasks/main.yml` of the *desktop* role to install and `desktop_do_remove` in `tasks/main.yml` of the *desktop* role to uninstall.
- [ ] The default behavior for a role is to run the tasks in the `tasks/do_install.yml`
- [ ] The tasks in `tasks/do_remove.yml` should 100% reverse the behaviour in the `tasks/do_install.yml`

### Tasks
- [ ] Each task in the `tasks/main.yml` should have at least a *tag* with the same name as the role
- [ ] Each task runs without any deprecation warnings
- [ ] Avoid using default variable values in a task's *when* condition and instead define the default in `defaults/main.yml`
- [ ] Each task is written in the true yaml format and avoid using the `>` to define task arguments
  - For example:
    ```
    # Use this
    - name: show debug info
      debug:
        msg: "This is my debug message"

    # Not this
    - name: show debug info
      debug: >
        msg="This is my debug message"
    ```
- [ ] Every task requiring *sudo* privileges should expilicitly have the `become: True` argument

### Role Dependencies
- [ ] If the role depends on other roles to be run first, these roles must be defined in `meta/main.yml` as dependencies.

# TODO
- [ ] Add a script for starting wireless device
- [ ] development - install npm installer
