export WORKON_HOME=$HOME/.virtualenvs
source /usr/local/bin/virtualenvwrapper.sh

if [ -f `brew --prefix`/etc/bash_completion ]; then
  . `brew --prefix`/etc/bash_completion
fi

alias remove_pyc='find . -name "*.pyc" -exec rm -rf {} \;'
alias vi='vi -o'

. /Users/vbabiy/Projects/git-projects/django/extras/django_bash_completion

#export PS1="[\u@\[\e[32;1m\]\H \[\e[0m\]\w]\$ "

## The prompt below gets ideas from the following:
# http://briancarper.net/blog/570/git-info-in-your-zsh-prompt
# http://github.com/adamv/dotfiles/blob/master/bashrc
# http://wiki.archlinux.org/index.php/Color_Bash_Prompt
txtred='\[\e[0;31m\]' # Red
txtwht='\[\e[0;37m\]' # White
bldred='\[\e[1;31m\]' # Red
bldgrn='\[\e[1;32m\]' # Green
bldylw='\[\e[1;33m\]' # Yellow
bldwht='\[\e[1;37m\]' # White
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

    PS1="${txtred}\u@\h${end} ${txtred}\w${end}"
    
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
