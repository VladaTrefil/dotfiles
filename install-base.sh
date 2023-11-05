#!/bin/bash

if [ -r "./.secret-env" ]; then
  source ./.secret-env
else
  echo "Please create .secret-env file with credentials"
fi

if [[ -z "$GITHUB_USERNAME" || -z "$GITHUB_PASSWORD" ]]; then
  echo "Please set the GITHUB_USERNAME and GITHUB_PASSWORD environment variables."
  exit 1
fi

if [ ! -r "$(which gh)" ]; then
  github_source="deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main"

  type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)

  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "$github_source" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && sudo apt update \
    && sudo apt install gh -y
fi

if [ ! -r "$(which gh)" ]; then
  echo "GitHub CLI installation failed."
  exit 1
fi

github_key=~/.ssh/github_key_rsa

if [ ! -r "$github_key" ]; then
  ssh-keygen -t rsa -b 4096 -C "$GITHUB_USERNAME@github.com" -N "" -f "$github_key"
  echo "GitHub SSH key generated."
fi

touch ./token && echo "$GITHUB_TOKEN" > ./token
auth=$(gh auth login --with-token < ./token)
rm ./token

if [ -z "$auth" ]; then
  echo "Authentication successful"
else
  echo "Authentication failed"
  exit 1
fi

gh ssh-key add "$github_key" --title "Home PC"

# Add SSH key to ssh-agent
eval "$(ssh-agent -s)"
ssh-add $github_key

echo "GitHub SSH key setup completed."

mkdir -p ~/Development; cd ~/Development || exit "$?"

if [ -d "./dotfiles" ]; then
  echo "Dotfiles already exist."
  cd dotfiles || exit "$?"
else
  git clone git@github.com:VladaTrefil/dotfiles.git && cd dotfiles || exit "$?"
fi
