# new shell commands

if [ -x /usr/bin/xset ] && [ "x$DISPLAY" != "x" ]; then
    xset r rate 250 35
fi

if [ `which xmodmap 2>&1 >/dev/null` ] && [ -f $HOME/.Xmodmap ] && [[ $(xmodmap | grep Caps_Lock) ]]; then
    xmodmap $HOME/.Xmodmap
fi

# [colors]
# Reset
Color_Off="\[\033[0m\]"       # Text Reset

# Regular Colors
Black="\[\033[0;30m\]"        # Black
Red="\[\033[0;31m\]"          # Red
Green="\[\033[0;32m\]"        # Green
Yellow="\[\033[0;33m\]"       # Yellow
Blue="\[\033[0;34m\]"         # Blue
Purple="\[\033[0;35m\]"       # Purple
Cyan="\[\033[0;36m\]"         # Cyan
White="\[\033[0;37m\]"        # White

# Bold
BBlack="\[\033[1;30m\]"       # Black
BRed="\[\033[1;31m\]"         # Red
BGreen="\[\033[1;32m\]"       # Green
BYellow="\[\033[1;33m\]"      # Yellow
BBlue="\[\033[1;34m\]"        # Blue
BPurple="\[\033[1;35m\]"      # Purple
BCyan="\[\033[1;36m\]"        # Cyan
BWhite="\[\033[1;37m\]"       # White

# Underline
UBlack="\[\033[4;30m\]"       # Black
URed="\[\033[4;31m\]"         # Red
UGreen="\[\033[4;32m\]"       # Green
UYellow="\[\033[4;33m\]"      # Yellow
UBlue="\[\033[4;34m\]"        # Blue
UPurple="\[\033[4;35m\]"      # Purple
UCyan="\[\033[4;36m\]"        # Cyan
UWhite="\[\033[4;37m\]"       # White

# Background
On_Black="\[\033[40m\]"       # Black
On_Red="\[\033[41m\]"         # Red
On_Green="\[\033[42m\]"       # Green
On_Yellow="\[\033[43m\]"      # Yellow
On_Blue="\[\033[44m\]"        # Blue
On_Purple="\[\033[45m\]"      # Purple
On_Cyan="\[\033[46m\]"        # Cyan
On_White="\[\033[47m\]"       # White

# High Intensty
IBlack="\[\033[0;90m\]"       # Black
IRed="\[\033[0;91m\]"         # Red
IGreen="\[\033[0;92m\]"       # Green
IYellow="\[\033[0;93m\]"      # Yellow
IBlue="\[\033[0;94m\]"        # Blue
IPurple="\[\033[0;95m\]"      # Purple
ICyan="\[\033[0;96m\]"        # Cyan
IWhite="\[\033[0;97m\]"       # White

# Bold High Intensty
BIBlack="\[\033[1;90m\]"      # Black
BIRed="\[\033[1;91m\]"        # Red
BIGreen="\[\033[1;92m\]"      # Green
BIYellow="\[\033[1;93m\]"     # Yellow
BIBlue="\[\033[1;94m\]"       # Blue
BIPurple="\[\033[1;95m\]"     # Purple
BICyan="\[\033[1;96m\]"       # Cyan
BIWhite="\[\033[1;97m\]"      # White

# High Intensty backgrounds
On_IBlack="\[\033[0;100m\]"   # Black
On_IRed="\[\033[0;101m\]"     # Red
On_IGreen="\[\033[0;102m\]"   # Green
On_IYellow="\[\033[0;103m\]"  # Yellow
On_IBlue="\[\033[0;104m\]"    # Blue
On_IPurple="\[\033[10;95m\]"  # Purple
On_ICyan="\[\033[0;106m\]"    # Cyan
On_IWhite="\[\033[0;107m\]"   # White


# [ansible]
# [globals]
_Ansible_dotfiles_path="$HOME/projects/sz-ansible"
if [ -d $_Ansible_dotfiles_path/inventory/ ]; then
    _Ansible_dotfiles_repo=$(ls -x $_Ansible_dotfiles_path/inventory/)
    _Ansible_src_dir=$(ls -x $_Ansible_dotfiles_path/inventory/)
fi


_Ansible_deactivate() {
    deactivate
}

_Ansible_source() {
    venv_dir=$HOME/.virtualenvs/Ansible && \
    virtualenv $venv_dir && \
    source $venv_dir/bin/activate && \
    pip install ansible
}

Ansible_gdi() {
    inv_type=$1
    do_reboot=$2
    inv_types=$_Ansible_dotfiles_repo

    if [[ -z $inv_type ]]; then
        cat <<EOF
Ansible_upgrade inv_type [ do_reboot ]
inv_types: $result
do_reboot: bool
EOF
        return 1
    fi

    _Ansible_source

    pushd $_Ansible_dotfiles_path

    if [[ $do_reboot = "-r" ]]; then
        Ansible-playbook -i inventory/$inv_type localhost.yml \
        --vault-password-file=$HOME/.vault_dotfiles_$inv_type \
        -e global_do_install=1 \
        -e apt_get_upgrade_do_reboot=1 \
        -K \
        ${@:3:255}
    else
        Ansible-playbook -i inventory/$inv_type localhost.yml \
        --vault-password-file=$HOME/.vault_dotfiles_$inv_type \
        -e global_do_install=1 \
        -K \
        ${@:2:255}
    fi

    popd

    _Ansible_deactivate
}

Ansible_mr() {
    if [[ -n $1 ]]; then
        mkdir -p $_Ansible_dotfiles_path/roles/$1/{tasks,defaults,handlers,templates}
        cat > $_Ansible_dotfiles_path/roles/$1/tasks/main.yml <<EOF
---

- include: do_install.yml
  when: $1_do_install |default(False) |bool == true or global_do_install |default(False) |bool == True

- include: do_remove.yml
  when: $1_do_remove |default(False) |bool == true
EOF
        touch $_Ansible_dotfiles_path/roles/$1/tasks/do_install.yml
        touch $_Ansible_dotfiles_path/roles/$1/tasks/do_remove.yml

    else
        cat <<EOF
Ansible_mr name_of_role
name_of_role: str to make
EOF
        return 1
    fi

}

# [bash]
function eba {
    vim $_Ansible_dotfiles_path/roles/term/files/.bash_aliases
}

function sba {
    source $_Ansible_dotfiles_path/roles/term/files/.bash_aliases
}

# [dba]
function sqitch {
    docker run -v $(pwd):/src -w /src --rm docteurklein/sqitch:pgsql "$@"
}

# [docker]
alias dco='docker-compose'

# [git]
alias g='git'
alias gl='git log --stat'

alias gpom='git pull --rebase origin master'
alias gpum='git pull --rebase upstream master'
alias gpud='git pull --rebase upstream develop'

alias gpuom='git push origin master'
alias gpuod='git push origin develop'

gpuocb() {
    git push origin $(git br | grep --color=never '* ' | awk '{ print $2 }') $@
}

alias grmmerged='git branch -D `git branch --merged | grep -v \* | xargs`'
alias grrmmerged='git branch -D `git branch --merged | grep -v \* | xargs`'

# [lxc]
alias lxc-ls='sudo lxc-ls --fancy'
alias lxc-start='sudo lxc-start -d'

Lxc_da() {
    for i in $(sudo lxc-ls); do sudo lxc-stop -n $i; sudo lxc-destroy -n $i; done
}

Lxc_create() {
    name=$1
    if [[ -z $name ]]; then
        cat <<EOF
Lxc_create container_name
default is to use ubuntu template
EOF
else
    container_template=ubuntu
    auth_keys=".ssh/authorized_keys"
    default_packages="python,git,curl,bash-completion,ca-certificates"
    sudo lxc-create -t $container_template -n $name -- -u $USER -S $HOME/$auth_keys --packages $default_packages
    echo "%$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee /var/lib/lxc/$name/rootfs/etc/sudoers.d/$USER
    sudo lxc-start -d -n $name
fi

}

# [ssh]
#alias ssh='ssh -i $HOME/.ssh/id_ed25519 $1'
alias ssh="TERM=xterm ssh"
alias ssh_onshift='ssh -i $HOME/.ssh/id_onshift $1'

SSH_ENV="$HOME/.ssh/env"
start_agent() {
    echo "Initialising new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    echo succeeded
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add;
}

# Source SSH settings, if applicable
if [ -f "${SSH_ENV}" ]; then
    . "${SSH_ENV}" > /dev/null
    ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
        start_agent;
    }
else
    start_agent;
fi

# [sysadmin]
Sysadmin_au() {
    u=$1
    if [[ -z $u ]]; then
        cat <<EOF
Sysadmin_au user
user: username to add
EOF
    else
        sudo useradd -m -s /bin/bash $u && \
        sudo -u $u mkdir -p /home/$u/.ssh && \
        curl https://github.com/$u.keys | sudo -u $u tee /home/$u/.ssh/authorized_key
    fi

}

start_wicd() {
    sudo service wicd restart
    wicd-curses
}

disconnect_laptop() {
    sudo service wicd restart
    ~/bin/xrandr_laptop.sh
}

swap_procs() {
    for file in /proc/*/status; do
        awk '/VmSwap|Name|Pid/{printf $2 " " $3}END{ print ""}' $file ;
    done | sort -k 2 -n -r | less
}

# [ovs]
Ovs_del_brs() {
    for i in $(sudo ovs-vsctl show | grep Bridge | awk '{ print $2}'| tr -d \");
        do sudo ovs-vsctl del-br $i ;
    done
}

# [known_hosts]
function forget_known_host() {
    h=$1
    p=$2
    i=`gethostip $h | awk '{print $2}'`
    f=`readlink -f ~/.ssh/known_hosts`
    if [ -n "$p" ]; then
        keygen_h="[$h]:$p"
        keygen_i="[$i]:$p"
    else
        keygen_h="$h"
        keygen_i="$i"
    fi
    ssh-keygen -f "$f" -R $keygen_h
    if [ "x$i" != "x" ]; then
        ssh-keygen -f "$f" -R $keygen_i
    fi
}

# [tmux]
alias tmux='tmux -2'
alias ltmux='if tmux has; then tmux attach; else tmux new; fi'

# [passman]
function passman_mount {
    truecrypt $_Ansible_dotfiles_path/roles/passman/files/.passman $HOME/mnt/truecrypt_passman
}

# [func]
function check_ulimits {
    for USER in `ps -ef | egrep -v '^UID' | awk '{ print $1 }' | sort -u`; do echo -n "$USER: "; ps -u $USER -L | wc -l; done | sort -rn -k2  
}

function check_sockets {
    ss -f link -n -l -p
}

function gen_passwd_az {
    if [ -z "$1" ]; then
        passlen=16
    else
        passlen=$1
    fi
    cat /dev/urandom| tr -dc 'a-zA-Z0-9' | fold -w $passlen | head -n 4
}

function gen_passwd_safe {
    if [ -z "$1" ]; then
        passlen=24
    else
        passlen=$1
    fi
    cat /dev/urandom| tr -dc 'a-zA-Z0-9!@#$%^&*(){}?><-_' | fold -w $passlen | head -n 4
}

# allows us to run a command in the background
null_command() {
    $1 >> /dev/null 2>&1 &
}

function upgrade_all {
    sudo apt-get update && sudo apt-get upgrade
}

function check_upgrades {
    echo "Updating Apt Sources" && sudo apt-get update >/dev/null && echo "Getting List of Packages to Update" && sudo apt-get dist-upgrade -s | grep "^Inst" | sort && if [ -f /var/run/reboot-required ]; then echo "reboot required"; fi
}

function ifrestart {
    sudo ifdown $1 && sudo ifup $1
}

# [projects]
alias workon_docker='source ~/.virtualenvs/docker/bin/activate'
alias workon_dotfiles='cd ~/projects/sz-ansible && source ~/.virtualenvs/sz-Ansible-playbook/bin/activate'
alias workon_utils='source ~/.virtualenvs/utils/bin/activate'

# import aliases specific to this host
if [ -f ~/.bash_aliases.local ]; then
    . ~/.bash_aliases.local
fi

# Custom $PS1
if [ -x /bin/hostname ]; then
    TERM_HOST=`/bin/hostname`
else
    TERM_HOST='\h'
fi

# Various variables you might want for your PS1 prompt instead
Time12h="\T"
Time12a="\@"
PathShort="\w"
PathFull="\W"
NewLine="\n"
Jobs="\j"

# This PS1 snippet was adopted from code for MAC/BSD I saw from: http://allancraig.net/index.php?option=com_content&view=article&id=108:ps1-export-command-for-git&catid=45:general&Itemid=96
# I tweaked it to work on UBUNTU 11.04 & 11.10 plus made it mo' better
#       - some guy on the internet
#
if [ -f $HOME/.git-prompt.sh ]; then
    source $HOME/.git-prompt.sh
fi

export PS1="$Cyan[$Color_Off \u@$TERM_HOST":'$(git branch &>/dev/null;\
if [ $? -eq 0 ]; then \
  echo "$(echo `git status` | grep "nothing to commit" > /dev/null 2>&1; \
  if [ "$?" -eq "0" ]; then \
    # @4 - Clean repository - nothing to commit
    echo "'$IGreen'"$(__git_ps1 " (%s)"); \
  else \
    # @5 - Changes to working tree
    echo "'$IRed'"$(__git_ps1 " {%s}"); \
  fi) '$Color_Off$PathShort$Cyan' ]'$Color_Off'\n\$ "; \
else \
  # @2 - Prompt when not in GIT repo
  echo " '$Color_Off$PathShort$Cyan' ]'$Color_Off'\n\$ "; \
fi)'

if ! echo $PATH | grep -q "$HOME/bin"; then
    export PATH=$PATH:$HOME/bin
fi

if ! echo $PATH | grep -q "$HOME/.composer/vendor/bin"; then
    export PATH=$PATH:$HOME/.composer/vendor/bin
fi
