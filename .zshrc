zstyle ':zim:git' aliases-prefix 'g'
. ~/.zplugin

# customization {{{

if [[ "`uname -s`" == "Darwin" ]]; then
  export LANG=C
fi

# directory shortcut {{{
p()  { cd ~/proj/$1;}
h()  { cd ~/$1;}
vm() { cd ~/vagrant/$1;}
cdpath=(~ ~/proj)

compctl -W ~/proj -/ p
compctl -W ~ -/ h
compctl -W ~/vagrant -/ vm
# }}}

# development shortcut {{{
# alias pa!='[[ -f config/puma.rb ]] && RAILS_RELATIVE_URL_ROOT=/`basename $PWD` bundle exec puma -C $PWD/config/puma.rb'
# alias pa='[[ -f config/puma.rb ]] && RAILS_RELATIVE_URL_ROOT=/`basename $PWD` bundle exec puma -C $PWD/config/puma.rb -d'
alias kpa='[[ -f tmp/pids/puma.state ]] && bundle exec pumactl -S tmp/pids/puma.state stop'
# alias kpa='[[ -f tmp/pids/puma.pid ]] && kill `cat tmp/pids/puma.pid`'

alias mc='mailcatcher --http-ip 0.0.0.0'
alias kmc='pkill -fe mailcatcher'
alias sk='[[ -f config/sidekiq.yml ]] && bundle exec sidekiq -C $PWD/config/sidekiq.yml -d'
alias ksk='pkill -fe sidekiq'

pairg() { ssh -t $1 ssh -o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile=/dev/null' -p $2 -t ${3:-vagrant}@localhost 'tmux attach' }
pairh() { ssh -S none -o 'ExitOnForwardFailure=yes' -R $2\:localhost:22 -t $1 'watch -en 10 who' }

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
    tmux -u new -s work -d;
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
alias g='git'

if [[ "`uname -s`" == "Darwin" ]]; then
  alias vi='nvim'
  alias vim='nvim'
  # if [ `whence gls` > /dev/null ]; then
  #   alias ls='gls --group-directories-first --color=auto'
  # fi
fi

alias ls='exa --group-directories-first'
alias l='ls -la'

alias px='ps aux'
alias vt='vi -c :CtrlP'
alias vl='vi -c :CtrlPMRU'
alias v.='vi .'

alias sa='ssh-add'
alias salock='ssh-add -x'
alias saunlock='ssh-add -X'

alias agi='ag -i'
alias agiw='ag -i -w'
alias agr='ag --ruby'
alias agri='ag --ruby -i'

alias rgi='rg -i'
alias rgiw='rg -iw'

alias -g G='| rg'
alias -g P='| $PAGER'
alias -g WC='| wc -l'
alias -g RE='RESCUE=1'

alias rc='bin/rails console'
alias rr='bin/rake routes'
alias rdm='bin/rake db:migrate'
alias rdr='bin/rake db:rollback'
alias rdms='bin/rake db:migrate:status'

alias va=vagrant
# alias vsh='va ssh'
# alias vsf='va ssh -- -L 0.0.0.0:8080:localhost:80 -L 1080:localhost:1080'
alias vsh='ssh gko.abagile.aws.kr'
alias vsf='vsh -L 0.0.0.0:8080:localhost:80 -L 1080:localhost:1080'
alias vup='va up'
alias vsup='va suspend'
alias vhalt='va halt'

alias zshrc='vi ~/.zshrc'
alias vimrc='vi ~/.config/nvim/init.vim'

alias cat=bat

alias apb=ansible-playbook
# }}}

# environment variables {{{
if [ `whence nvim` > /dev/null ]; then
  export EDITOR=nvim
  export VISUAL=nvim
else
  export EDITOR=vi
  export VISUAL=vi
fi
#}}}

# key bindings {{{
bindkey -M vicmd '^a' beginning-of-line
bindkey -M vicmd '^e' end-of-line

bindkey '^[f' vi-forward-word
bindkey '^[b' vi-backward-word

bindkey '^o' autosuggest-accept

bindkey '^p' history-substring-search-up
bindkey '^n' history-substring-search-down
# }}}

# export fpath=(~/.config/exercism/functions $fpath)
# autoload -U compinit && compinit

# export PATH=$PATH:/usr/local/opt/ansible@2.9/bin:/usr/local/opt/erlang@23/bin:/usr/local/sbin:~/bin:/snap/bin
# }}}

if [[ "`uname -s`" == "Darwin" ]]; then
  [ -f $(brew --prefix)/etc/profile.d/autojump.sh ] && . $(brew --prefix)/etc/profile.d/autojump.sh
  [ -f $(brew --prefix asdf)/libexec/asdf.sh ] && . $(brew --prefix asdf)/libexec/asdf.sh
else
  [ -f ~/.asdf/asdf.sh ] && source ~/.asdf/asdf.sh && source "$HOME/.asdf/completions/asdf.bash"
  [ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

[ -f ~/.ssh/id_pair ] && ssh-add ~/.ssh/id_pair 2> /dev/null

export _git_log_fuller_format='%C(bold yellow)commit %H%C(auto)%d%n%C(bold)Author: %C(blue)%an <%ae> %C(reset)%C(cyan)%ai (%ar)%n%C(bold)Commit: %C(blue)%cn <%ce> %C(reset)%C(cyan)%ci (%cr)%C(reset)%n%+B'
export _git_log_oneline_format='%C(bold yellow)%h%C(reset) %s%C(auto)%d%C(reset)'
export _git_log_oneline_medium_format='%C(bold yellow)%h%C(reset) %<(50,trunc)%s %C(bold blue)<%an> %C(reset)%C(cyan)(%ar)%C(auto)%ad%C(reset)'

git-current-branch() {
  git symbolic-ref -q --short HEAD
}

git-branch-delete-interactive() {
  local -a remotes
  if (( ${*[(I)(-r|--remotes)]} )); then
    remotes=(${^*:#-*})
  else
    remotes=(${(f)"$(command git rev-parse --abbrev-ref ${^*:#-*}@{u} 2>/dev/null)"}) || remotes=()
  fi
  if command git branch --delete ${@} && \
      (( ${#remotes} )) && \
      read -q "?Also delete remote branch(es) ${remotes} [y/N]? "; then
    print
    local remote
    for remote (${remotes}) command git push ${remote%%/*} :${remote#*/}
  fi
}

# HSTR configuration - add this to ~/.zshrc
# alias hh=hstr                    # hh to be alias for hstr
# setopt histignorespace           # skip cmds w/ leading space from history
export HSTR_CONFIG=hicolor       # get more colors
bindkey -s "\C-r" "\C-a hstr -- \C-j"     # bind hstr to Ctrl-r (for Vi mode check doc)

# export FZF_DEFAULT_COMMAND='rg --files --no-ignore-vcs --hidden'
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# john
export PATH="/opt/homebrew/opt/postgresql@10/bin:$PATH"

alias db_dump="DEV_PASSWORD='ie6sucks' ~/vm/scripts/db_dump.rb"

puma() {
  local folder_path
  [[ $PWD =~ '(.*nerv_ck|.*nerv_sg|.*nerv|.*amoeba|.*cam|.*angel)' ]] && folder_path=$match[1]
  cd $folder_path && [[ -f config/puma.rb ]] && RAILS_RELATIVE_URL_ROOT=/`basename $PWD` bundle exec puma -C $PWD/config/puma.rb $1
}

nrw() {
  local folder_path
  local folder_name
  local asuka_path

  [[ $PWD =~ '(.*nerv_ck|.*nerv_sg|.*nerv)' ]] && folder_path=$match[1]
  [[ $folder_path =~ '.*(nerv_ck|nerv_sg|nerv)$' ]] && folder_name=$match[1]

  asuka_path="$folder_path/clojure/projects/asuka"

  cd $asuka_path && NERV_BASE=/${=folder_name} DEV_DARK_MODE=true npm run watch
}

repl() {
  local folder_path
  local adam_path

  [[ $PWD =~ '(.*nerv_ck|.*nerv_sg|.*nerv)' ]] && folder_path=$match[1]
  adam_path="$folder_path/clojure/projects/adam"
  cd $adam_path && clj -M:dev:nrepl
}

ct() {
  local folder_path
  local adam_path

  [[ $PWD =~ '(.*nerv_ck|.*nerv_sg|.*nerv)' ]] && folder_path=$match[1]
  adam_path="$folder_path/clojure/projects/adam"
  if [[ $1 ]]; then
    cd $adam_path && clj -M:test:runner --watch --focus $1
  else
    cd $adam_path && clj -M:test:runner --watch
  fi
}


# ---reset amoeba db
resetadb() {
  bundle exec rake db:drop RAILS_ENV=test
  bundle exec rake db:create RAILS_ENV=test
  bundle exec rake db:schema:load RAILS_ENV=test
  bundle exec rake db:seed RAILS_ENV=test
  bundle exec rake test:prepare
}

resetadbd() {
  psql postgres -c "drop database if exists amoeba_development"
  psql postgres -c "drop database if exists amoeba_test"
  bundle exec rake db:create RAILS_ENV=development
  # bundle exec rake db:schema:load RAILS_ENV=development
}

# --- spring
alias sspring='spring stop & spring binstub --all'
# --- rake
alias rc='bundle exec rails c'
alias rcs='bundle exec rails c --sandbox'
# --- rake
alias rdrt='bundle exec rake db:reset RAILS_ENV=test'
alias rdmskip="bundle exec rake db:migrate SKIP_PATCHING_MIGRATION='skip_any_patching_related_migrations'"
# --- git
alias gpc='git config --global push.default current && gp'
alias gfrm='git pull origin master --rebase'
alias gclean='gco master && gfm && gf -p && git branch --merged | egrep -v "(^\*|master)" | xargs git branch -d'
# --- scripts
alias db_dump="DEV_PASSWORD='ie6sucks' ~/vm/scripts/db_dump.rb"
alias dump_db='/vagrant/scripts/dump_db.zsh'
alias idump_db='/vagrant/scripts/dump_db.zsh i'
alias mydump_db='zsh ~/Downloads/my_dump_db_m1.zsh'
alias form_fetch='thor form:fetch'
# --- amoeba / cam
alias site='thor setup:site'
# --- tmux
alias tmux='tmux -u'
alias ktmux='pkill -f tmux'
# --- yarn
alias ys='yarn start'
# --- npm
# alias nw='cd ~/nerv/eva/asuka/ && npm run watch'
alias nrd='npm run dev'
# --- clojure
alias cljkeva='clj-kondo --lint clojure/projects/asuka/src --config clojure/projects/asuka/.clj-kondo/config.edn --cache false'
alias cljkadam='clj-kondo --lint clojure/projects/adam/src --config clojure/projects/adam/.clj-kondo/config.edn --cache false'
alias cljk='cljkeva && cljkadam'
# alias nrepl='cd ~/nerv/clojure/adam && clj -M:dev:nrepl'
# --- homebrew
# --- postgresql
alias bs='brew services'
alias bu='brew upgrade'
alias bunormal='bu libreoffice libreoffice-language-pack notion wkhtmltopdf'
alias dbrestart='rm /opt/homebrew/var/postgresql@10/postmaster.pid && bs restart postgresql@10 && bs'
# alias tig='TERM=xterm-256color tig'
alias python='python3'
alias sed=gsed
alias punchin='cd ~/nerv && gss && gco `john/test` && cd e2e && npx cypress run --spec cypress/integration/abagile_punch_in.spec.js'
alias punchout='cd ~/nerv && gss && gco `john/test` && cd e2e && npx cypress run --spec cypress/integration/abagile_punch_out.spec.js'

# Manual checking before mina deploy
#
# minav [site branch]
#
# - Show latest deployed revision on server (default: ck_production)
# - Show short git diff to branch (default: master)
# - Copy the revisoin to tmux paste-buffer (if within tmux session)
function minav(){
  local rev
  local branch='master'
  local site='ck_production'
  [[ $# -gt 0 ]] && site=$1
  [[ $# -gt 1 ]] && branch=$2

  rev=$(bundle exec mina $site branch=$branch git:revision | head -3 | sed -e 's/ //g' | grep -e '^[a-z]' -m 1 | cut -c 1-10)

  git show --date=format:'%y/%m/%d %H:%M' \
    --pretty='%C(yellow)%h%Creset %s %C(black bold)%cd (%cr)%Creset %C(blue bold)%cn%Creset' \
    $rev

  [[ -n $TMUX ]] && tmux set-buffer $rev

  echo "git diff --stat $rev..$branch"
  git diff --stat $rev..$branch
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

deployhk() {
  # ps aux | grep -E "cljs" | awk '{print $2}' | xargs kill -9 &&
  # bundle exec mina hk_production cljs:build_and_upload &&
  bundle exec mina hk_production deploy
}

deployck() {
  # ps aux | grep -E "cljs" | awk '{print $2}' | xargs kill -9 &&
  # bundle exec mina ck_production cljs:build_and_upload &&
  bundle exec mina ck_production deploy
}

deployadam() {
  cd clojure/projects/adam && ./bin/deploy
}

deployafs() {
  bundle exec mina afs_production deploy && cd face && REACT_APP_VENDOR_API_TOKEN=dbca219310ae6b27cf2b24fadf7b38c0 npx shipit production deploy -b master
}

deployipc() {
  bundle exec mina ipc_production deploy && cd face && REACT_APP_VENDOR_API_TOKEN=dbca219310ae6b27cf2b24fadf7b38c0 npx shipit ipc_production deploy -b master
}

ssh-add ~/.ssh/id_pair
export PATH="/opt/homebrew/opt/ansible@2.9/bin:$PATH"
