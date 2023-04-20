FROM ubuntu

RUN apt update -y && \
    apt upgrade -y && \
    apt install -y --no-install-recommends \
        bat \
        clang \
        clang-format \
        clang-tidy-15 \
        clangd \
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
COPY dedicated/_p10k.zsh /root/.p10k.zsh
COPY dedicated/zshrc.patch /tmp/
RUN patch -u /root/.zshrc /tmp/zshrc.patch && rm /tmp/zshrc.patch

# Install a newer version of nodejs, and enable corepack.
# https://github.com/nodesource/distributions#debinstall
RUN curl -fsSL https://deb.nodesource.com/setup_19.x | bash - && \
    apt install -y --no-install-recommends nodejs && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    corepack enable  # Enable yarn & pnpm.
COPY generic/_npmrc /root/.npmrc

# Install a newer version of neovim, and install configures.
RUN curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage && \
    chmod u+x nvim.appimage && \
    ./nvim.appimage --appimage-extract && \
    cd squashfs-root/usr && \
    find . -type f -exec cp --parents {} /usr/local/ \; && \
    cd ../.. && \
    rm -rf squashfs-root nvim.appimage
RUN pip3 install pynvim && \
    pip3 cache purge && \
    npm install -g neovim && \
    npm cache clean --force
RUN curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
RUN mkdir -p ~/inception ~/.config && \
    git clone https://github.com/AeolusLau/baseline.git ~/inception/baseline && \
    git -C ~/inception/baseline remote set-url origin git@github.com:AeolusLau/baseline.git && \
    ln -s ~/inception/baseline/generic/nvim ~/.config/nvim && \
    mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}"/clangd && \
    ln -s ~/inception/baseline/generic/_clangd "${XDG_CONFIG_HOME:-$HOME/.config}"/clangd/config.yaml && \
    ln -s ~/inception/baseline/generic/_clang-tidy ~/.clang-tidy && \
    ln -s ~/inception/baseline/generic/_clang-format ~/.clang-format
RUN nvim +PlugInstall +qall && \
    nvim +'CocInstall -sync \
             coc-clangd \
             coc-cmake \
             coc-explorer \
             coc-floaterm \
             coc-fzf-preview \
             coc-git \
             coc-java \
             coc-json \
             coc-lists \
             coc-markdownlint \
             coc-marketplace \
             coc-pairs \
             coc-pyright \
             coc-sh \
             coc-snippets \
             coc-vimlsp' \
         +qall && \
    "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/plugged/fzf/install --all --no-bash --no-fish && \
    pnpm store prune && \
    yarn cache clean
# Disable coc-spell-checker, which doesn't work properly on ubuntu image. (Maybe caused by absence of dictionaries?)
RUN sed -i '/^}/c\,\"disabled\":\[\"coc-spell-checker\"\]}' ~/.config/coc/extensions/package.json

# Some convenient configure.
COPY .ssh /root/.ssh
RUN echo '' >> ~/.zshrc && \
    echo 'alias python=python3' >> ~/.zshrc && \
    echo 'alias vi=nvim' >> ~/.zshrc && \
    echo 'alias vim=nvim' >> ~/.zshrc && \
    ln -s /usr/bin/batcat /usr/local/bin/bat && \
    git config --global user.email aeoluslau@gmail.com && \
    git config --global user.name liulichao
ENV MAKEFLAGS=-j6
ENV CPLUS_INCLUDE_PATH=$(CPLUS_INCLUDE_PATH):/usr/include/c++/11:/usr/include/x86_64-linux-gnu/c++/11

WORKDIR /root
CMD [ "zsh" ]
