#! /bin/bash

# sets Internal field seprator to only newline
IFS=$'\n'
readonly BASEDIR="$( dirname $( realpath $0 ) )"

readonly COLORRESET='\e[0m'
readonly RED='\e[0;31m'
readonly GREEN='\e[0;32m'
readonly BLUE='\e[0;34m'

function check_error(){
    # Checks if error occurred in previous comamnd displaying message to the user
    error=$?
    if [ $error -ne 0 ];
    then 
        echo -e "$RED[-] $1$COLORRESET";
        exit $error
    fi
}

function install_vim_plug(){
    # install_vim_plug installs the minimalistic plugin manager vim plug
    # Downloads the the file and places it in autoload directory of vim
    if [ ! -f ~/.vim/autoload/plug.vim ];
    then
        curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi

    check_error "An Error Occurred Downloading vim plug. Please check internet connection"
}


function install_fonts(){
    # Adding Font Support for file system exploration
    mkdir -p ~/.local/share/fonts
    check_error "An error occured creating fonts directory. Check permissions"
    cp -r $BASEDIR/fonts/* ~/.local/share/fonts
}

function setup_plugins(){
    # Setup vim plugins to enable new features

    # Ensure .vimrc file exists
    touch ~/.vimrc
    check_error "An error occured creating vimrc. Check permissions"
    if $( grep -q 'call plug#begin()' ~/.vimrc );
    then
        plugins=$( grep -P "Plug .*" $BASEDIR/config/.vimrc )
        autocmds=$( grep -P "autocmd .*" $BASEDIR/config/.vimrc )

        for plugin in $plugins;
        do
            if $( grep -qF "$plugin" ~/.vimrc );
            then 
                continue
            fi

            sed -ie "/call plug#begin()/a $plugin" ~/.vimrc;
        done

        check_error "An error occured when modifying vimrc. Check permissions"
        # Adding autocmd specified in vimrc file
        for autocmd in $autocmds;
        do
            echo $autocmd
            echo just here
            if $( grep -qF "$autocmd" ~/.vimrc );
            then 
                continue
            fi
            echo "$autocmd" >> ~/.vimrc
        done
        echo $'\n' >> ~/.vimrc

    else
        echo $'\n' >> ~/.vimrc
        cat $BASEDIR/config/.vimrc >> ~/.vimrc
        echo $'\n' >> ~/.vimrc

        check_error "An error occured when modifying vimrc. Check permissions"
    fi

}

function install_plugins(){
    # Start Installing of plugin
    vim -c 'PlugInstall | qa'
    check_error "An error installing vim plugins. Check internet connection"
}

function main(){
    # main function to start the installation process

    echo -e "$BLUE[+] Installing vim-plug extension$COLORRESET"
    install_vim_plug
    sleep 1
    echo -e "\n$BLUE[+] Installing fonts for nerd tree$COLORRESET"
    install_fonts
    sleep 1
    echo -e "$BLUE[+] Setting up vim plugins$COLORRESET"
    setup_plugins
    sleep 3
    echo -e "$BLUE[+] Installing vim plugins$COLORRESET"
    install_plugins
    sleep 1.5
    echo -e "\n$GREEN[+] Done. Enjoy$COLORRESET"
}

# Program entry point
main