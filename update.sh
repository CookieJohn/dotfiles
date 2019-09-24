cp .zshrc ~/.zshrc && echo update zshrc OK || echo update zshrc Failed
cp .vimrc ~/.vimrc && echo update vimrc OK || echo update vimrc Failed
cp .vimrc.local ~/.vimrc.local && echo update vimrc.local OK || echo update vimrc.local Failed
cp .vimrc.bundles.local ~/.vimrc.bundles.local && echo update vimrc.bundles.local OK || echo update vimrc.bundles.local Failed
cp .tmux.conf ~/.tmux.conf && echo update tmux.conf OK || echo update tmux.conf Failed
cp .pryrc ~/.pryrc && echo update pryrc OK || echo update pryrc Failed
cp .ackrc ~/.ackrc && echo update ackrc OK || echo update ackrc Failed
source ~/.zshrc && echo source zshrc done!
