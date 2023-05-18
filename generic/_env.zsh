# Replace homebrew source
#export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
#export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
#export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
#export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles

# Enable llvm installed from Homebrew.
export PATH="/usr/local/opt/llvm/bin:$PATH"
# Guide cmake to use llvm installed form Homebrew, not XCode.
export CC=clang
export CXX=clang++

# Make make faster...
export MAKEFLAGS='-j8'

export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

# Used to filter out test file in git commands, e.g.,
#   $ git show HEAD $NT
export NT=':!**/*test*'

alias vi=nvim
alias view='nvim -R'
alias rga="rg --no-config --smart-case --type-add 'cpp:*.ipp' --type c --type cpp --type java --type kotlin --type objc --type objcpp --type swift --type gradle --type cmake"
alias rgn='rg --no-config --smart-case --no-ignore'
alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'

[[ ! -f ~/.env.zsh.local ]] || source ~/.env.zsh.local
