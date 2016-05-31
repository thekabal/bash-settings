#!/bin/bash

# Tab completion for ssh hosts
if [ -f ~/.ssh/known_hosts ]; then
#    complete -W "$(cat ~/.ssh/known_hosts | cut -f 1 -d ' ' | sed -e s/,.*//g | uniq | grep -v "\[";)" ssh
#    complete -W "$(cat ~/.ssh/known_hosts | cut -f 1 -d ' ' | sed -e s/,.*//g | uniq)" ssh
    complete -W "$(cut -f 1 -d ' ' ~/.ssh/known_hosts | sed -e s/,.*//g | uniq)" ssh
fi

# Tab completion for sudo & man
complete -cf sudo
complete -cf man

# Random animal saying or thinking something from the fortune file
alias haha='command fortune -a | fmt -80 -s | $(shuf -n 1 -e cowsay cowthink) -$(shuf -n 1 -e b d g p s t w y) -f $(shuf -n 1 -e $(cowsay -l | tail -n +2)) -n'
alias pony='fortune -a | fmt -80 -s |ponysay'

# alias dmesg='dmesg -L'								# Colorize & humanize dmesg -- not available on CentOS 5 :(
t() {  tail -f "$1" | perl -pe "s/$2/\e[1;31;43m$&\e[0;36m/g" ; }				# Tail with search highlight
fancy_sudo() {	sudo -u "$1" -i bash --rcfile /home/psmallwood/.bashrc ;} 		# Build a function that allows us to alias sudo'ing to any user, while keeping my bash prompt
alias wget='wget -c'									# Wget should continue/resume downloads if interrupted
#alias mount='mount |column -t'								# Tabelize mount output to make it pretty
alias grep='grep --color=auto'								# Grep with color highlighting for matches
alias egrep='egrep --color=auto'							# E Grep with color highlighting for matches
alias fgrep='fgrep --color=auto'							# F Grep with color highlighting for matches
alias reload='source $HOME/.bashrc 1>/dev/null'						# Reload bash to import bashrc changes
#alias confcat="sed -e 's/[#;].*//;/^\s*$/d' "$@""					# Show lines in a file that are not commented or blank
alias confcat="perl -ne 'print unless /\h*(#(?!\!)|;).*/ || /^\h*$/'"			# Show lines in a file that are not commented or blank
alias be=fancy_sudo									# Be(come) some other user
alias tree='find . -type d | sed -e "s/[^-][^\/]*\//  |/g" -e "s/|\([^ ]\)/|-\1/"' 	# Directory tree
alias ls='ls -F' 									# Add slashes to directories
alias ll='ls -lF'									# Perform ls with list and add slashes to directories
alias gzcat='zcat'									# Common typo/misunderstanding
alias nano='nano -w' 									# Disable wordwrap for nano and set mouse control if possible
alias ifconfig='/sbin/ifconfig'								# When su'ing to root, this directory (sbin) may not be in the path, but ifconfig is a safe command, so do it anyway.
alias route='/sbin/route'								# When su'ing to root, this directory (sbin) may not be in the path, but route is a (somewhat) safe command, so do it anyway.
alias babi='nano'									# Common typo
alias more='less -QRX' 									# Use less instead of more, make it quiet & colorized.
alias ~='cd ~' 										# Go home
alias ipconfig='ifconfig' 								# Alias for similar windows function
alias df='df -h' 									# Humanize disk free display
alias du='du -ch' 									# Humanize disk usage display & add total

export EDITOR=nano 									# Prefer nano for editing
export LANG=en_US 									# Prefer support for extended characters in English
export HISTTIMEFORMAT="%F %T " 								# Timestamps for history
export HISTCONTROL=erasedups 								# Erase duplicates in history
export LC_ALL=en_US.UTF-8								# Explicitly set LC_ALL to use UTF - Does not work on SunOS
export LANG=en_US.UTF-8									# Explicitly set LANG to use UTF
export LANGUAGE=en_US.UTF-8								# Explicitly set LANGUAGE to use UTF

if [ -z "${MAIL+x}" ]
then
    export MAIL="$HOME/Mail"
fi

# First, we check the number of unread messages.
if [ -f "$MAIL" ]
then
	mailwait=$(grep -c ^Message- "$MAIL")
else
	mailwait='0'
fi

# Now we adjust the prompt to display the mail waiting (if it exists)
if [ "$mailwait" -gt "0" ]
then
        msgwait="\[\e[1;31m\][$mailwait msgs] "
else
        msgwait=""
fi

# Finally, we give the full prompt, and IF the user is root, we color the user name red to warn us!
if [[ $EUID -ne 0 ]]; then
	export PS1="\[\e[0;36m\]# \[\e[0;35m\][\D{%D %I:%M:%S %p}] \[\e[0;32m\][\u@\H] $msgwait\[\e[1;34m\][\W] \[\e[0;36m\]$ "
else
	export PS1="\[\e[0;36m\]# \[\e[0;35m\][\D{%D %I:%M:%S %p}] \[\e[0;32m\][\[\e[0;31m\]\u\[\e[0;32m\]@\H] $msgwait\[\e[1;34m\][\W] \[\e[0;36m\]# "
fi
export LS_COLORS='no=00:fi=00:di=94:ln=94:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=41;33;01:ex=01;31:*.cmd=01;31:*.exe=01;31:*.com=01;31:*.bat=01;31:*.btm=01;31:*.dll=01;31:*.tar=00;32:*.tbz=00;32:*.tgz=00;32:*.iso=00;32:*.rar=00;32:*.txt=00;93:*.php=01;35:*.sh=01;35:*.rpm=00;32:*.deb=00;32:*.arj=00;32:*.taz=00;32:*.lzh=00;32:*.zip=00;32:*.zoo=00;32:*.z=00;32:*.Z=00;32:*.gz=00;32:*.bz2=00;32:*.tb2=00;32:*.tz2=00;32:*.tbz2=00;32:*.avi=01;35:*.bmp=01;35:*.fli=01;35:*.gif=01;35:*.jpg=01;35:*.jpeg=01;35:*.mng=01;35:*.mov=01;35:*.mpg=01;35:*.pcx=01;35:*.pbm=01;35:*.pgm=01;35:*.png=01;35:*.ppm=01;35:*.tga=01;35:*.tif=01;35:*.xbm=01;35:*.xpm=01;35:*.dl=01;35:*.gl=01;35:*.wmv=01;35:*.aiff=00;32:*.au=00;32:*.mid=00;32:*.mp3=00;32:*.ogg=00;32:*.voc=00;32:*.wav=00;32:'

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Ignore upper/lower case
shopt -s nocaseglob

# Fix spelling mistakes
shopt -s cdspell

# Auto cd when entering just a path - not available on Centos 5 :(
#shopt -s autocd

# Color man pages
export LESS_TERMCAP_mb=$'\E[01;31m'      # begin blinking
export LESS_TERMCAP_md=$'\E[01;31m'      # begin bold
export LESS_TERMCAP_me=$'\E[0m'          # end mode
export LESS_TERMCAP_se=$'\E[0m'          # end standout-mode
export LESS_TERMCAP_so=$'\E[01;44;33m'   # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\E[0m'          # end underline
export LESS_TERMCAP_us=$'\E[01;32m'      # begin underline

calc(){ echo "${1}"|bc -l; }  # Quick calculator

function ff { find / -name "$1" -print; }  # Similar to dir /s from dos

function ping-a # Similar to ping -a from dos
{
	dig -x "$1" +short;
	ping -c 4 "$1";
}

ex() # Extract common file extensions
{
	if [ -f "$1" ] ; then
	case $1 in

	*.tar.bz2) tar xjf "$1" ;;
	*.tar.gz) tar xzf "$1" ;;
	*.bz2) bunzip2 "$1" ;;
	*.rar) rar x "$1" ;;
	*.gz) gunzip "$1" ;;
	*.tar) tar xf "$1" ;;
	*.tbz2) tar xjf "$1" ;;
	*.tgz) tar xzf "$1" ;;
	*.zip) unzip "$1" ;;
	*.xz) unxz "$1" ;;
	*.exe) cabextract "$1" ;;
	*.Z) uncompress "$1" ;;
	*.7z) 7z x "$1" ;;
	*) echo "'$1' cannot be extracted via ex()" ;;
esac
else
echo "'$1' is not a valid file"
fi
}

note () {
    # if file doesn't exist, create it
    if [[ ! -f $HOME/.notes ]]; then
        touch "$HOME/.notes"
    fi

    if ! (($#)); then
        # no arguments, print file
        cat "$HOME/.notes"
    elif [[ "$1" == "-c" ]]; then
        # clear file
        > "$HOME/.notes"
    else
        # add all arguments to file
        printf "%s\n" "$*" >> "$HOME/.notes"
    fi
}

man() {
    env LESS_TERMCAP_mb=$'\E[01;31m' \
    LESS_TERMCAP_md=$'\E[01;38;5;74m' \
    LESS_TERMCAP_me=$'\E[0m' \
    LESS_TERMCAP_se=$'\E[0m' \
    LESS_TERMCAP_so=$'\E[38;5;246m' \
    LESS_TERMCAP_ue=$'\E[0m' \
    LESS_TERMCAP_us=$'\E[04;38;5;146m' \
    man "$@"
}

