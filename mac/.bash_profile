# Mac specific
export PATH=$HOME/bin:$PATH

if [ -f `brew --prefix`/etc/bash_completion ]; then
  . `brew --prefix`/etc/bash_completion
fi

. /Users/vbabiy/Projects/git-projects/django/extras/django_bash_completion

###########################################################################

export WORKON_HOME=$HOME/.virtualenvs
source /usr/local/bin/virtualenvwrapper.sh

alias remove_pyc='find . -name "*.pyc" -exec rm -rf {} \;'
alias vi='vi -o'

## The prompt below gets ideas from the following:
# http://briancarper.net/blog/570/git-info-in-your-zsh-prompt
# http://github.com/adamv/dotfiles/blob/master/bashrc
# http://wiki.archlinux.org/index.php/Color_Bash_Prompt

txtblk='\[\e[0;30m\]' # Black - Regular
txtred='\[\e[0;31m\]' # Red
txtgrn='\[\e[0;32m\]' # Green
txtylw='\[\e[0;33m\]' # Yellow
txtblu='\[\e[0;34m\]' # Blue
txtpur='\[\e[0;35m\]' # Purple
txtcyn='\[\e[0;36m\]' # Cyan
txtwht='\[\e[0;37m\]' # White
bldblk='\[\e[1;30m\]' # Black - Bold
bldred='\[\e[1;31m\]' # Red
bldgrn='\[\e[1;32m\]' # Green
bldylw='\[\e[1;33m\]' # Yellow
bldblu='\[\e[1;34m\]' # Blue
bldpur='\[\e[1;35m\]' # Purple
bldcyn='\[\e[1;36m\]' # Cyan
bldwht='\[\e[1;37m\]' # White
unkblk='\[\e[4;30m\]' # Black - Underline
undred='\[\e[4;31m\]' # Red
undgrn='\[\e[4;32m\]' # Green
undylw='\[\e[4;33m\]' # Yellow
undblu='\[\e[4;34m\]' # Blue
undpur='\[\e[4;35m\]' # Purple
undcyn='\[\e[4;36m\]' # Cyan
undwht='\[\e[4;37m\]' # White
bakblk='\[\e[40m\]'   # Black - Background
bakred='\[\e[41m\]'   # Red
badgrn='\[\e[42m\]'   # Green
bakylw='\[\e[43m\]'   # Yellow
bakblu='\[\e[44m\]'   # Blue
bakpur='\[\e[45m\]'   # Purple
bakcyn='\[\e[46m\]'   # Cyan
bakwht='\[\e[47m\]'   # White
end='\[\e[0m\]'    # Text Reset

function parse_git {
    branch=$(__git_ps1 "%s")
    if [[ -z $branch ]]; then
        return
    fi

    local forward="⟰"
    local behind="⟱"
    local dot="•"

    remote_pattern_ahead="# Your branch is ahead of"
    remote_pattern_behind="# Your branch is behind"
    remote_pattern_diverge="# Your branch and (.*) have diverged"

    status="$(git status 2>/dev/null)"

    state=""
    if [[ $status =~ "working directory clean" ]]; then
        state=${bldgrn}${dot}${end}
    else
        if [[ $status =~ "Untracked files" ]]; then
            state=${bldred}${dot}${end}
        fi
        if [[ $status =~ "Changed but not updated" ]]; then
            state=${state}${bldylw}${dot}${end}
        fi
        if [[ $status =~ "Changes to be committed" ]]; then
            state=${state}${bldylw}${dot}${end}
        fi
    fi

    direction=""
    if [[ $status =~ $remote_pattern_ahead ]]; then
        direction=${bldgrn}${forward}${end}
    elif [[ $status =~ $remote_pattern_behind ]]; then
        direction=${bldred}${behind}${end}
    elif [[ $status =~ $remote_pattern_diverge ]]; then
        direction=${bldred}${forward}${end}${bldgrn}${behind}${end}
    fi

    branch=${txtwht}${branch}${end}
    git_bit="${bldred}[${end}${branch}${state}\
${git_bit}${direction}${bldred}]${end}"

    printf "%s" "$git_bit"
}

function set_titlebar {
    case $TERM in
        *xterm*|ansi|rxvt)
            printf "\033]0;%s\007" "$*"
            ;;
    esac
}

function set_prompt {
    git="$(parse_git)"

    PS1="${txtred}\u@\h${end} ${undblu}\W${end}"
    
    # Added support for VIRTUAL_ENV
    if [ -n "$VIRTUAL_ENV" ] ; then
        PS1="${bldgrn}(`basename \"$VIRTUAL_ENV\"`)${end} $PS1"
    fi

    if [[ -n "$git" ]]; then
        PS1="$PS1 $git ${bldcyn}❯❯${end} "
    else
        PS1="$PS1 ${bldcyn}❯❯${end} "
    fi
    export PS1

    set_titlebar "$USER@${HOSTNAME%%.*} $PWD"
}

export PROMPT_COMMAND=set_prompt
export EDITOR='vi'

has_virtualenv() {
    if [ -e .venv ]; then
        workon `cat .venv`
    fi
}
venv_cd () {
    cd "$@" && has_virtualenv
}
alias cd="venv_cd"

# Welcome Message
echo -e ""
echo -ne "Today is "; date
echo -e ""; cal;
echo -ne "Up time: ";uptime | awk /'up/ {print $3,$4}'
echo "";
fortune
