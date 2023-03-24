FROM ubuntu

RUN apt update -y && \
    apt install -y --no-install-recommends bat clang clangd clang-format cmake curl fzf git golang make patch python3 python3-pip ripgrep tree unzip zsh && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Configure zsh: on-my-zsh & powerlevel10k
ARG TERM COLORTERM
ENV TERM=$TERM COLORTERM=$COLORTERM LC_ALL=C.UTF-8
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
RUN sed -i '/^ZSH_THEME=/c\ZSH_THEME="powerlevel10k\/powerlevel10k"' ~/.zshrc
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
# It seems nvim can't hold a long arugment (perhaps 256?), so we break it to 2 commands.
RUN nvim -c 'CocInstall -sync coc-clangd coc-cmake coc-cspell-dicts coc-dictionary coc-emoji coc-explorer coc-floaterm coc-format-json coc-fzf-preview coc-git coc-html coc-java|q' && \
    nvim -c 'CocInstall -sync coc-json coc-lists coc-markdownlint coc-marketplace coc-protobuf coc-pyright coc-sh coc-snippets coc-spell-checker coc-sql coc-tsserver coc-vimlsp coc-word|q'

# Some convenient configure.
RUN echo '' >> ~/.zshrc && \
    echo 'alias python=python3' >> ~/.zshrc && \
    echo 'alias vi=nvim' >> ~/.zshrc && \
    echo 'alias vim=nvim' >> ~/.zshrc
RUN ln -s /usr/bin/batcat /usr/local/bin/bat

ENV MAKEFLAGS=-j6

WORKDIR /root
CMD [ "zsh" ]
