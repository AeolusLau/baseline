FROM ubuntu

#RUN apt update 
RUN apt update 

# common tools
RUN apt install -y bat curl fzf ripgrep tree zsh 
RUN ln -s /usr/bin/batcat /usr/local/bin/bat

# programing tools
RUN apt install -y clang clangd clang-format cmake git python3

# Install on-my-zsh & powerlevel10k
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
RUN curl -fsSL https://deb.nodesource.com/setup_19.x | bash - && apt-get install -y nodejs && corepack enable

# Install a newer version of neovim, and install configures.
RUN curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage && chmod u+x nvim.appimage && ./nvim.appimage --appimage-extract && cd squashfs-root/usr && find . -type f -exec cp --parents {} /usr/local/ \; && cd ../.. && rm -rf squashfs-root nvim.appimage
RUN apt install -y python3-neovim
RUN curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
RUN mkdir -p ~/inception ~/.config && git clone https://github.com/AeolusLau/vim-script.git ~/inception/vim-script && ln -s ~/inception/vim-script/nvim ~/.config/nvim
RUN nvim +PlugInstall +qall
# FIXME: Here we need a `RUN nvim +CocUpdateSync +qall`. However, it doesn't do what it means to, for the reason that it quits immediately.

RUN echo '' >> ~/.zshrc && echo 'alias python=python3' >> ~/.zshrc

WORKDIR /root
CMD [ "zsh" ]
