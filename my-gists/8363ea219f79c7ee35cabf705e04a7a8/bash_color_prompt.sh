_Prompt() {
  local _rslt=$?
  ## The above line *MUST* be the first line in this function.
  ## Not even a comment line may precede it.
  
  # There are two sections in this function: Generate Prompt, and Save History
  
  ### 1. Generate colorful prompt
  
    # Special username for root (EUID=0) user.
    local _root='■ROOT■'
  
    local _reset='\e[0m'
    
    local _b='\e[1;'
    local _n='\e[0;'

    local  _gray='30m'    
    local   _red='31m'
    local _green='32m'
    local  _pink='35m'
    local  _cyan='36m'
    local _yello='33m'
  
    local _PS1='\n'
    
    # Python virtualenv
    if [[ "$VIRTUAL_ENV" ]]; then
      _PS1+="(${VIRTUAL_ENV##*/}) "
    fi
    
    # Color the datetimestamp according to result of last command
    if [[ $_rslt = "0" ]] ; then
      _PS1+="$_b$_green"
    else
      _PS1+="$_b$_red"
    fi
    
    # ISO8601:2004 compliant timestamp
    _PS1+="\D{%Y-%m-%d %H:%M:%S} "
    
    # Specially highlight the root user
    if [[ $EUID = "0" ]] ; then
      _PS1+="$_b$_pink$_root"
    else
      _PS1+="$_b$_cyan\u"
    fi
    
    # "@ hostname:tty PWD"
    _PS1+="$_reset @ $_n$_yello\h$_reset:\l $PWD"
    
    # The adaptive '$' prompt is on its own line, prepended by history number
    # EDIT: All ANSI formatting characters on the last line have been strip to
    #       prevent 'leftover' characters when using bash command recall (up-
    #       arrow) -- perhaps a bash bug. 
    _PS1+="\n\! \\$ "
  
  export PS1="$_PS1"
  
  ### 2. Save History
  
    history -a 
  
}
 
PROMPT_COMMAND="_Prompt"
