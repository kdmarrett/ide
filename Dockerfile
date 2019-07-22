FROM ls12styler/dind:latest

# Install basics (HAVE to install bash for tpm to work)
RUN apk update && apk add -U --no-cache \
	bash zsh git git-perl neovim less curl bind-tools \
	man build-base su-exec shadow openssh-client

# Install tmux
COPY --from=ls12styler/tmux:latest /usr/local/bin/tmux /usr/local/bin/tmux

# Install jQ!
RUN wget https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -O /bin/jq && chmod +x /bin/jq

# In the entrypoint, we'll create a user called `me`
WORKDIR /home/me
ENV HOME /home/me

# Setup my $SHELL
ENV SHELL /bin/zsh
# Install oh-my-zsh
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true
RUN wget https://gist.githubusercontent.com/xfanwu/18fd7c24360c68bab884/raw/f09340ac2b0ca790b6059695de0873da8ca0c5e5/xxf.zsh-theme -O .oh-my-zsh/custom/themes/xxf.zsh-theme
# Copy ZSh config
COPY zshrc .zshrc

# Configure text editor - vim!
RUN curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
# Consult the vimrc file to see what's installed
COPY vimrc .config/nvim/init.vim 
# Clone the git repos of Vim plugins
WORKDIR ~/.config/nvim/plugged/
RUN git clone --depth=1 https://github.com/ctrlpvim/ctrlp.vim
RUN git clone --depth=1 https://github.com/tpope/vim-fugitive
RUN git clone --depth=1 https://github.com/godlygeek/tabular
RUN git clone --depth=1 https://github.com/plasticboy/vim-markdown
RUN git clone --depth=1 https://github.com/vim-airline/vim-airline
RUN git clone --depth=1 https://github.com/vim-airline/vim-airline-themes
RUN git clone --depth=1 https://github.com/vim-syntastic/syntastic
RUN git clone --depth=1 https://github.com/derekwyatt/vim-scala

WORKDIR /home/me
# Install TMUX
COPY tmux.conf .tmux.conf
RUN git clone https://github.com/tmux-plugins/tpm .tmux/plugins/tpm
RUN .tmux/plugins/tpm/bin/install_plugins

# Copy git config over
COPY gitconfig .gitconfig

# Entrypoint script does switches u/g ID's and `chown`s everything
COPY entrypoint.sh /bin/entrypoint.sh

# Set working directory to /workspace
WORKDIR /workspace

# Default entrypoint, can be overridden
CMD ["/bin/entrypoint.sh"]
