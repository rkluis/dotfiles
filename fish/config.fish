if status is-interactive

    function em
        emacsclient -t -a "" $argv
    end

    function nv
        nvim $argv
    end
    # Machine specific settings 
    # 🖼️  Video acceleration
    if test (hostname) = rollylaparch
        set -x LIBVA_DRIVER_NAME iHD
    end

    set -x DOOMDIR $HOME/.config/doom
    set -gx CHROME_EXECUTABLE /usr/local/bin/chromium-wayland

    set -gx PATH $HOME/.emacs.d/bin $PATH

    set -gx PATH $HOME/.local/bin $PATH
    # Flutter
    set -gx PATH $HOME/flutter/bin $PATH

    # Android SDK
    set -gx ANDROID_HOME $HOME/Android/Sdk
    set -gx EDITOR nvim
    set -gx PATH $ANDROID_HOME/platform-tools $PATH
    set -gx PATH $ANDROID_HOME/emulator $PATH
    set -gx PATH $ANDROID_HOME/cmdline-tools/latest/bin $PATH
    set -gx PATH $HOME/.tmux/plugins/tmuxifier/bin $PATH

    eval (tmuxifier init - fish)
    # 🚀 Fast shell intro
    fastfetch
    set -g fish_greeting 'Welcome To the Rolly Arch Machine!'

    # 🌟 Starship prompt
    starship init fish | source

    zoxide init fish | source

    # ⎈ Auto-start tmux (if not already inside)
    if not set -q TMUX
        exec tmuxifier load-session home
    end
end
