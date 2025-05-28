# .dotfiles
This repository contains my personal dotfiles, which are configuration files for various applications and tools I use. The dotfiles are organized in a way that allows easy management and deployment using GNU Stow.

To use this .dotfiles repository, you can follow these steps:
1. **Clone the repository**:
   Open your terminal and run the following command to clone the repository to your local machine:
   ```bash
   git clone https://github.com/avilabss/.dotfiles.git ~/dotfiles
   ```
2. **Ensure GNU Stow is installed**:
   This repository uses GNU Stow to manage dotfiles. Make sure you have it installed on your system. You can install it using your package manager. For example, on Ubuntu, you can run:
   ```bash
   sudo apt install stow
   ```
3. **Navigate to the dotfiles directory**:
   Change your current directory to the cloned dotfiles directory:
   ```bash
   cd ~/dotfiles
   ```
4. **Stow the desired configuration**:
   Use GNU Stow to symlink the desired configuration files to your home directory. For example, if you want to stow the `nvim` configuration, run:
   ```bash
   stow nvim
   ```
   You can replace `nvim` with any other directory in the repository to apply different configurations.

# Directory Structure

To ensure we don't have any conflicts with existing dotfiles, the directory structure is designed to avoid overwriting files that are already present in the home directory. Below are examples of how the directory structure looks for different configurations.

```md
~/.dotfiles/
├── nvim/
│   └── .config/
│       └── nvim/
├── kitty/
│   └── .config/
│       └── kitty/
```

```md
~/.dotfiles/
├── bash/
│   └── .bashrc
├── vim/
│   └── .vimrc
```
