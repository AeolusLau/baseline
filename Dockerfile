FROM ubuntu

RUN apt update -y && \
    apt upgrade -y && \
    apt install -y --no-install-recommends \
        bat \
        clang-15 \
        clang-format-15 \
        clang-tidy-15 \
        clangd-15 \
        cmake \
        curl \
        fd-find \
        gettext \
        git \
        golang \
        less \
        lldb-15 \
        make \
        patch \
        python3 \
        python3-pip \
        ripgrep \
        socat \
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
    /root/.oh-my-zsh/custom/themes/powerlevel10k/gitstatus/install
# The following there instructions is used to mock configure wizard of p10k
COPY dedicated/_p10k.zsh /root/.p10k.zsh
COPY dedicated/zshrc.patch /tmp/
RUN patch -u /root/.zshrc /tmp/zshrc.patch && rm /tmp/zshrc.patch

# Install a newer version of nodejs, and enable corepack.
# https://github.com/nodesource/distributions#debinstall
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt install -y --no-install-recommends nodejs && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    corepack enable  # Enable yarn & pnpm.
#COPY generic/_npmrc /root/.npmrc

# Set envrionmnet variable to build neovim
ENV PATH=$PATH:/usr/lib/llvm-15/bin
ENV MAKEFLAGS=-j6
ENV CPLUS_INCLUDE_PATH=$(CPLUS_INCLUDE_PATH):/usr/include/c++/11:/usr/include/x86_64-linux-gnu/c++/11

# Build neovim from source code.
RUN git clone https://github.com/neovim/neovim.git && \ 
    cd neovim && \
    git checkout stable && \
    (make CMAKE_BUILD_TYPE=Release || true) && \
    cmake -S . -B build -DCMAKE_BUILD_TYPE=Release && \
    cmake --build build && \
    cmake --install build && \
    cd / && \
    rm -rf neovim
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
    ln -s /usr/bin/fdfind /usr/local/bin/fd && \
    ln -s ~/inception/baseline/generic/_gitignore ~/.gitignore && \
    git config --global core.excludesFile ~/.gitignore && \
    git config --global user.email aeoluslau@gmail.com && \
    git config --global user.name liulichao

# Make lldb works in the container. See: https://github.com/llvm/llvm-project/issues/55575
RUN ln -sf /usr/local /usr/lib/ && \
    ln -sf /usr/lib/llvm-15/lib/python3.10/dist-packages/lldb /usr/local/lib/python3.10/dist-packages/

# As docker disabled debugging in containers by default, the arguments: 
#
#   --cap-add=SYS_PTRACE --security-opt seccomp=unconfined
#
# are required for C++ memory profiling and debugging in Docker.

WORKDIR /root
CMD [ "zsh" ]
