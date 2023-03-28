FROM ubuntu

RUN apt update -y && \
    apt install -y --no-install-recommends bat \
                                           clang \
                                           clangd \
                                           clang-format \
                                           cmake \
                                           curl \
                                           git \
                                           golang \
                                           less \
                                           make \
                                           patch \
                                           python3 \
                                           python3-pip \
                                           ripgrep \
                                           ssh \
                                           tree \
                                           unzip \
                                           zsh && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Configure zsh: on-my-zsh & powerlevel10k
ARG TERM COLORTERM
ENV TERM=$TERM COLORTERM=$COLORTERM LC_ALL=C.UTF-8
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k && \
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    sed -i '/^ZSH_THEME=/c\ZSH_THEME="powerlevel10k\/powerlevel10k"' ~/.zshrc && \
    sed -i '/^plugins=(git)/c\plugins=(git z zsh-autosuggestions)' ~/.zshrc && \
    mkdir -p ~/.cache/gitstatus && \
    cd ~/.cache/gitstatus && \
    curl -fsSL https://github.com/romkatv/gitstatus/releases/download/v1.5.4/gitstatusd-linux-x86_64.tar.gz | tar zxv
# The following there instructions is used to mock configure wizard of p10k
COPY .p10k.zsh /root/
COPY zshrc.patch /tmp/
RUN patch -u /root/.zshrc /tmp/zshrc.patch && rm /tmp/zshrc.patch

# Install a newer version of nodejs, and enable yarn.
# https://github.com/nodesource/distributions#debinstall
RUN curl -fsSL https://deb.nodesource.com/setup_19.x | bash - && \
    apt install -y --no-install-recommends nodejs && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    corepack enable
COPY .npmrc /root/

# Install a newer version of neovim, and install configures.
RUN curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage && \
    chmod u+x nvim.appimage && \
    ./nvim.appimage --appimage-extract && \
    cd squashfs-root/usr && \
    find . -type f -exec cp --parents {} /usr/local/ \; && \
    cd ../.. && \
    rm -rf squashfs-root nvim.appimage
RUN pip3 install pynvim && \
    npm install -g neovim
RUN curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
RUN mkdir -p ~/inception ~/.config && \
    git clone https://github.com/AeolusLau/vim-script.git ~/inception/vim-script && \
    ln -s ~/inception/vim-script/nvim ~/.config/nvim
RUN nvim +PlugInstall +qall
# It seems nvim can't hold a long arugment (perhaps 256?), so we break it into 2 commands.
RUN nvim -c 'CocInstall -sync coc-clangd coc-cmake coc-cspell-dicts coc-explorer coc-floaterm coc-fzf-preview coc-git coc-java coc-json coc-lists coc-markdownlint coc-marketplace coc-pyright coc-sh coc-snippets coc-spell-checker coc-vimlsp|q' && \
    "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/plugged/fzf/install --all --no-bash --no-fish && \
    pnpm store prune 

# Some convenient configure.
COPY .ssh /root/.ssh
RUN echo '' >> ~/.zshrc && \
    echo 'alias python=python3' >> ~/.zshrc && \
    echo 'alias vi=nvim' >> ~/.zshrc && \
    echo 'alias vim=nvim' >> ~/.zshrc && \
    ln -s /usr/bin/batcat /usr/local/bin/bat
ENV MAKEFLAGS=-j6
ENV CPLUS_INCLUDE_PATH=$(CPLUS_INCLUDE_PATH):/usr/include/c++/11:/usr/include/x86_64-linux-gnu/c++/11

WORKDIR /root
CMD [ "zsh" ]
