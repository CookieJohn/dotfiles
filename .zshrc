# shell environment initialization {{{

case "$(uname -s)" in
  Linux)
    source /etc/os-release
    ;;
  Darwin)
    NAME=Darwin
esac

case "$NAME" in
  Ubuntu)
    # for tool (git-extras htop silversearcher-ag tree); do
    #   [[ -z $(dpkg -l | grep $tool) ]] && sudo apt-get install -y $tool
    # done
    ;;
  Darwin)
    eval "$(ssh-agent -s)"
    ssh-add -K ~/.ssh/id_rsa
    # ssh-add -L
  #   for tool (git-extras htop the_silver_searcher); do
  #     [[ -z $(brew list | grep $tool) ]] && brew install $tool
  #   done
    ;;
esac

if [[ ! -d ~/.dotfiles ]]; then
  git clone git@github.com:CookieJohn/dotfiles.git ~/.dotfiles

  ln -sf ~/.dotfiles/.pryrc               ~/.pryrc
  ln -sf ~/.dotfiles/.tmux.conf           ~/.tmux.conf
  ln -sf ~/.dotfiles/.vimrc               ~/.vimrc
  ln -sf ~/.dotfiles/.vimrc.local         ~/.vimrc.local
  ln -sf ~/.dotfiles/.vimrc.bundles.local ~/.vimrc.bundles.local
  ln -sf ~/.dotfiles/.zshrc                ~/.zshrc

  mkdir -p ~/.psql_history
fi

# temporary comment
if [[ ! -d ~/.maximum-awesome ]]; then
  git clone git://github.com/square/maximum-awesome.git ~/.maximum-awesome
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.maximum-awesome/vim/bundle/Vundle.vim

  ln -sf ~/.maximum-awesome/vim ~/.vim
  ln -sf ~/.maximum-awesome/vimrc ~/.vimrc
  ln -sf ~/.maximum-awesome/vimrc.bundles ~/.vimrc.bundles

  vim +BundleInstall +qall
fi
# }}}

# zplug {{{

# install zplug, if necessary
if [[ ! -d ~/.zplug ]]; then
  export ZPLUG_HOME=~/.zplug
  git clone https://github.com/zplug/zplug $ZPLUG_HOME
fi

source ~/.zplug/init.zsh

zplug "plugins/vi-mode", from:oh-my-zsh
# zplug "plugins/chruby",  from:oh-my-zsh
zplug "plugins/asdf",    from:oh-my-zsh
zplug "plugins/bundler", from:oh-my-zsh
zplug "plugins/rails",   from:oh-my-zsh

zplug "b4b4r07/enhancd", use:init.sh
zplug "junegunn/fzf", as:command, hook-build:"./install --bin", use:"bin/{fzf-tmux,fzf}"

zplug "zsh-users/zsh-autosuggestions", defer:3
zplug "zsh-users/zsh-history-substring-search", defer:2
zplug "zsh-users/zsh-syntax-highlighting", defer:2

zplug "zdharma/zsh-diff-so-fancy", as:command, use:bin/git-dsf

# zim {{{
zstyle ':zim:git' aliases-prefix 'g'
zplug "zimfw/zimfw", as:plugin, use:"init.zsh", hook-build:"ln -sf $ZPLUG_REPOS/zimfw/zimfw ~/.zim"
zplug "zimfw/git", as:plugin

zmodules=(directory environment git git-info history input ssh utility \
          prompt completion)

zhighlighters=(main brackets pattern cursor root)

zplug 'dracula/zsh', as:theme
# zplug 'zefei/simple-dark', as:theme
# zplug denysdovhan/spaceship-prompt, use:spaceship.zsh, from:github, as:theme

# if [[ "$NAME" = "Ubuntu" ]]; then
#   zprompt_theme='eriner'
# else
#   zprompt_theme='liquidprompt'
# fi
# }}}

if ! zplug check --verbose; then
  zplug install
fi

zplug load #--verbose

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'

source ~/.zplug/repos/junegunn/fzf/shell/key-bindings.zsh
source ~/.zplug/repos/junegunn/fzf/shell/completion.zsh

export FZF_COMPLETION_TRIGGER=';'
export FZF_TMUX=1

# }}}


# customization {{{

# directory shortcut {{{
p()  { cd ~/proj/$1;}
h()  { cd ~/$1;}
vm() { cd ~/vagrant/$1;}

compctl -W ~/proj -/ p
compctl -W ~ -/ h
compctl -W ~/vagrant -/ vm
# }}}

# development shortcut {{{
alias pa!='[[ -f config/puma.rb ]] && RAILS_RELATIVE_URL_ROOT=/`basename $PWD` bundle exec puma -C $PWD/config/puma.rb'
alias pa='[[ -f config/puma.rb ]] && RAILS_RELATIVE_URL_ROOT=/`basename $PWD` bundle exec puma -C $PWD/config/puma.rb -d'
alias kpa='[[ -f tmp/pids/puma.state ]] && bundle exec pumactl -S tmp/pids/puma.state stop'

alias mc='bundle exec mailcatcher --http-ip 0.0.0.0'
alias kmc='pkill -fe mailcatcher'
alias sk='[[ -f config/sidekiq.yml ]] && bundle exec sidekiq -C $PWD/config/sidekiq.yml -d'
alias ksk='pkill -fe sidekiq'

pairg() { ssh -t $1 ssh -o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile=/dev/null' -p $2 -t vagrant@localhost 'tmux attach' }
pairh() { ssh -S none -o 'ExitOnForwardFailure=yes' -R $2\:localhost:22222 -t $1 'watch -en 10 who' }

cop() {
  local exts=('rb,thor,jbuilder')
  local excludes=':(top,exclude)db/schema.rb'
  local extra_options='--display-cop-names --rails'

  if [[ $# -gt 0 ]]; then
    local files=$(eval "git diff $@ --name-only -- \*.{$exts} '$excludes'")
  else
    local files=$(eval "git status --porcelain -- \*.{$exts} '$excludes' | sed -e '/^\s\?[DRC] /d' -e 's/^.\{3\}//g'")
  fi
  # local files=$(eval "git diff --name-only -- \*.{$exts} '$excludes'")

  if [[ -n "$files" ]]; then
    echo $files | xargs bundle exec rubocop `echo $extra_options`
  else
    echo "Nothing to check. Write some *.{$exts} to check.\nYou have 20 seconds to comply."
  fi
}
# }}}

# tmux shortcut {{{
tx() {
  if ! tmux has-session -t work 2> /dev/null; then
    tmux new -s work -d;
    # tmux splitw -h -p 40 -t work;
    # tmux select-p -t 1;
  fi
  tmux attach -t work;
}
txtest() {
  if ! tmux has-session -t test 2> /dev/null; then
    tmux new -s test -d;
  fi
  tmux attach -t test;
}
txpair() {
  SOCKET=/home/share/tmux-pair/default
  if ! tmux -S $SOCKET has-session -t pair 2> /dev/null; then
    tmux -S $SOCKET new -s pair -d;
    # tmux -S $SOCKET send-keys -t pair:1.1 "chmod 1777 " $SOCKET C-m "clear" C-m;
  fi
  tmux -S $SOCKET attach -t pair;
}
fixssh() {
  if [ "$TMUX" ]; then
    export $(tmux showenv SSH_AUTH_SOCK)
  fi
}
# }}}

# aliases {{{
alias px='ps aux'
alias vt='vim -c :CtrlP'
alias v.='vim .'

alias sa='ssh-add'
alias salock='ssh-add -x'
alias saunlock='ssh-add -X'

alias agi='ag -i'
alias agr='ag --ruby'
alias agri='ag --ruby -i'

alias -g G='| ag'
alias -g P='| $PAGER'
alias -g WC='| wc -l'
alias -g RE='RESCUE=1'

alias -g HED='HANAMI_ENV=development'
alias -g HEP='HANAMI_ENV=production'
alias -g HET='HANAMI_ENV=test'

alias va=vagrant
alias vsh='va ssh'
alias vsf='va ssh -- -L 0.0.0.0:8080:localhost:80 -L 1080:localhost:1080'
alias vup='va up'
alias vsup='va suspend'
alias vhalt='va halt'
alias vpro='va provision'

alias gws=gwS
alias gba='gb -a'

alias ha=hanami
alias hac='ha console'
alias had='ha destroy'
alias hag='ha generate'
alias ham='ha generate migration'
alias has='ha server'
alias har='ha routes'
# }}}

# environment variables {{{
export EDITOR=vim
export VISUAL=vim
#}}}

# key bindings {{{
bindkey -M vicmd '^a' beginning-of-line
bindkey -M vicmd '^e' end-of-line

bindkey '^f' vi-forward-word
bindkey '^b' vi-backward-word

bindkey '^o' autosuggest-accept

bindkey '^p' history-substring-search-up
bindkey '^n' history-substring-search-down
# }}}

# }}}
#
# 重啟 puma/unicorn（非 daemon 模式，用於 pry debug）
rpy() {
  if bundle show pry-remote > /dev/null 2>&1; then
    bundle exec pry-remote
  else
    rpu pry
  fi
}


# 重啟 puma/unicorn
#
# - rpu       → 啟動或重啟（如果已有 pid）
# - rpu kill  → 殺掉 process，不重啟
# - rpu xxx   → xxx 參數會被丟給 pumactl（不支援 unicorn）
rpu() {
  emulate -L zsh
  if [[ -d tmp ]]; then
    local action=$1
    local pid
    local animal

    if [[ -f config/puma.rb ]]; then
      animal='puma'
    elif [[ -f config/unicorn.rb ]]; then
      animal='unicorn'
    else
      echo "No puma/unicorn directory, aborted."
      return 1
    fi

    if [[ -r tmp/pids/$animal.pid && -n $(ps h -p `cat tmp/pids/$animal.pid` | tr -d ' ') ]]; then
      pid=`cat tmp/pids/$animal.pid`
    fi

    if [[ -n $action ]]; then
      case "$action" in
        pry)
          if [[ -n $pid ]]; then
            kill -9 $pid && echo "Process killed ($pid)."
          fi
          rserver_restart $animal
          ;;
        kill)
          if [[ -n $pid ]]; then
            kill -9 $pid && echo "Process killed ($pid)."
          else
            echo "No process found."
          fi
          ;;
        *)
          if [[ -n $pid ]]; then
            # TODO: control unicorn
            pumactl -p $pid $action
          else
            echo 'ERROR: "No running PID (tmp/pids/puma.pid).'
          fi
      esac
    else
      if [[ -n $pid ]]; then
        # Alternatives:
        # pumactl -p $pid restart
        # kill -USR2 $pid && echo "Process killed ($pid)."

        # kill -9 (SIGKILL) for force kill
        kill -9 $pid && echo "Process killed ($pid)."
        rserver_restart $animal $([[ "$animal" == 'puma' ]] && echo '-d' || echo '-D')
      else
        rserver_restart $animal $([[ "$animal" == 'puma' ]] && echo '-d' || echo '-D')
      fi
    fi
  else
    echo 'ERROR: "tmp" directory not found.'
  fi
}


# 啟動／停止 sidekiq
# rsidekiq() {
#   emulate -L zsh
#   if [[ -d tmp ]]; then
#     if [[ -r tmp/pids/sidekiq.pid && -n $(ps h -p `cat tmp/pids/sidekiq.pid` | tr -d ' ') ]]; then
#       case "$1" in
#         restart)
#           bundle exec sidekiqctl restart tmp/pids/sidekiq.pid
#           ;;
#         *)
#           bundle exec sidekiqctl stop tmp/pids/sidekiq.pid
#       esac
#     else
#       echo "Start sidekiq process..."
#       nohup bundle exec sidekiq  > ~/.nohup/sidekiq.out 2>&1&
#       disown %nohup
#     fi
#   else
#     echo 'ERROR: "tmp" directory not found.'
#   fi
# }
rsidekiq() {
  emulate -L zsh
  if [[ -d tmp ]]; then
    local pid=$(ps -ef | grep sidekiq | grep -v grep | awk '{print $2}')
    if [[ -n $pid ]]; then
      kill $pid && echo "Sidekiq process $pid killed."
    fi
    if [[ -r tmp/pids/sidekiq.pid && -n $(ps h -p `cat tmp/pids/sidekiq.pid` | tr -d ' ') ]]; then
      case "$1" in
        restart)
          bundle exec sidekiqctl restart tmp/pids/sidekiq.pid
          ;;
        *)
          bundle exec sidekiqctl stop tmp/pids/sidekiq.pid
      esac
    else
      echo "Start sidekiq process..."
      nohup bundle exec sidekiq  > ~/.nohup/sidekiq.out 2>&1&
      disown %nohup
    fi
  else
    echo 'ERROR: "tmp" directory not found.'
  fi
}


# 啟動／停止 mailcatcher
# rmailcatcher() {
#   local pid=$(ps --no-headers -C mailcatcher -o pid,args | command grep '/bin/mailcatcher --http-ip' | sed 's/^ //' | cut -d' ' -f 1)
#   if [[ -n $pid ]]; then
#     kill $pid && echo "MailCatcher process $pid killed."
#   else
#     echo "Start MailCatcher process..."
#     nohup mailcatcher --http-ip 0.0.0.0 > ~/.nohup/mailcatcher.out 2>&1&
#     disown %nohup
#   fi
# }
rmailcatcher() {
  # local pid=$(ps --no-headers -C mailcatcher -o pid,args | command grep '/bin/mailcatcher --http-ip' | sed 's/^ //' | cut -d' ' -f 1)
  local pid=$(ps -ef | grep mailcatcher | grep -v grep | awk '{print $2}')
  if [[ -n $pid ]]; then
    kill $pid && echo "MailCatcher process $pid killed."
  fi
  echo "Start MailCatcher process..."
  rm /home/vagrant/.nohup/mailcatcher.out
  nohup mailcatcher --http-ip 0.0.0.0 > ~/.nohup/mailcatcher.out 2>&1&
  disown %nohup
}


# 這是 rpu 會用到的 helper function
rserver_restart() {
  local app=${$(pwd):t}
  [[ ! $app =~ '^(amoeba|cam|angel|perv)' ]] && app='nerv' # support app not named 'nerv' (e.g., nerv2)

  case "$1" in
    puma)
      shift
      RAILS_RELATIVE_URL_ROOT=/$app bundle exec puma -C config/puma.rb config.ru $*
      ;;
    unicorn)
      shift
      RAILS_RELATIVE_URL_ROOT=/$app bundle exec unicorn -c config/unicorn.rb $* && echo 'unicorn running'
      ;;
    *)
      echo 'invalid argument'
  esac
}

# custom
# asdf update
update_asdf() {
  asdf update
  asdf plugin-list-all
  asdf plugin-update --all
  asdf reshim && echo 'asdf reshim done.'
}
# set git config
john_git() {
  git config user.email 'johnwu2613@gmail.com'
  git config user.name 'John'
  git config user.email
  git config user.name
}
abagile_git() {
  git config user.email 'john.wu@abagile.com'
  git config user.name 'John Wu'
  git config user.email
  git config user.name
}
# ---set up vm
set_up_vm() {
  vagrant halt
  vagrant up
  vagrant ssh
}
# ---fetch master and return current branch
gfrwc() {
  $ORI_BR="$(git-branch-current 2> /dev/null)"
  gss
  gco master
  gfr
  gco $ORI_BR
}
# ---reset amoeba db
resetadb() {
  bundle exec rake db:drop RAILS_ENV=test
  bundle exec rake db:create RAILS_ENV=test
  bundle exec rake db:schema:load RAILS_ENV=test
  bundle exec rake db:seed RAILS_ENV=test
  bundle exec rake test:prepare
}
# key-agent
setup_key_agent() {
  eval "$(ssh-agent -s)"
  ssh-add -K ~/.ssh/id_rsa
  ssh-add -L
}
# --- spring
alias sspring='spring stop & spring binstub --all'
# --- rake
alias rc='bundle exec rails c'
alias rcs='bundle exec rails c --sandbox'
# --- rake
alias rdrt='rake db:reset RAILS_ENV=test'
alias rdmskip="rake db:migrate SKIP_PATCHING_MIGRATION='skip_any_patching_related_migrations'"
# --- git
alias gfrm='git pull origin master --rebase'
alias gclean='gco . && gco master && gfm && gf -p && git branch --merged | egrep -v "(^\*|master)" | xargs git branch -d'
# --- scripts
alias dump_db='/vagrant/scripts/dump_db.zsh'
alias idump_db='/vagrant/scripts/dump_db.zsh i'
alias mdump_db='/vagrant/scripts/my_dump_db.zsh'
alias form_fetch='thor form:fetch'
# --- amoeba / cam
alias site='thor setup:site'
# --- yarn
alias ys='yarn start'
# --- npm
alias nw='npm run watch'

alias ll='ls -al'
alias gpc='git push --set-upstream origin "$(git symbolic-ref -q --short HEAD 2> /dev/null)"'
alias hk_pdf_checker='thor gen:pdf_preview --bps \
  r01:R01006422 \
  s01:S01001086:schedule_docs \
  r01_kr:R01992335 \
  pro_r:PR1043111:no-abf \
  pro_r:PR1958183:no-abf,pro-conv:schedule_docs \
  pro_r:PR1340170 \
  pro_r:PR1975092:no-abf \
  pro_r_v1_upop:PR1512249 \
  pro_r_kr:PR1875129 \
  pro_r_v3:PR1803442:no-abf \
  pro_r_v3:PR1717446 \
  pro_s:PS1067670 \
  ps_r:R01003906 \
  ps_pro:PR1958183 \
  ps_pro_kr:PR1257183 \
  mail_booklet:PR1958183'
alias ck_pdf_checker='thor gen:pdf_preview --bps \
  r01:CR0131546:schedule_docs'
  # s01:CS0101002 \
  # r01_kr:CR0184153 \
  # ct:CT0182922 \
  # cr21_cca:CR2190705 \
  # cs21:CS2125686 \
  # mail_booklet_ck:CR0184153'
alias pdf_diff='thor gen:pdf_diff'

# git diff-highlight
if [[ ! -d ~/bin ]]; then
  mkdir -p ~/bin

  sudo ln -sf /usr/share/doc/git/contrib/diff-highlight/diff-highlight ~/bin/diff-highlight
fi

path=($path "$HOME/bin")
alias python='python3'
