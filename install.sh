#!/usr/bin/env bash

echo "This is from the installation script!"

# Load nix shell env
source $HOME/.nix-profile/etc/profile.d/nix.sh

(
    nix-env -iA nixpkgs.gh \
            nixpkgs.google-cloud-sdk \
            nixpkgs.fzf \
            nixpkgs.bat \
            nixpkgs.fd > /tmp/plog 2>&1
    
    echo "$MY_TOKEN" | gh auth login --with-token

) & disown

(
    sudo apt update
    sudo apt install -yq cowsay sl tmux
) > /tmp/plog 2>&1 & disown

# Restore docker login
mkdir -p $HOME/.docker
echo "$DOCKER_ENCODED_CONFIG" | base64 -d > $HOME/.docker/config.json

# Install omz
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc

# Install powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc

# Symlink dotfiles
current_dir="$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)"
dotfiles_source="${current_dir}/home_files"

while read -r file; do

    relative_file_path="${file#"${dotfiles_source}"/}"
    target_file="${HOME}/${relative_file_path}"
    target_dir="${target_file%/*}"

    if test ! -d "${target_dir}"; then
        mkdir -p "${target_dir}"
    fi

    printf 'Installing dotfiles symlink %s\n' "${target_file}"
    ln -sf "${file}" "${target_file}"

done < <(find "${dotfiles_source}" -type f)