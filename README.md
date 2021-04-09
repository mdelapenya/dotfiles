# mdelapenya’s dotfiles

> A clone of https://github.com/v1v/dotfiles.git

## Installation

### Using Git and the bootstrap script

```bash
git clone https://github.com/mdelapenya/dotfiles.git .dotfiles && cd .dotfiles && source bootstrap.sh
```

To update, `cd` into your local `dotfiles` repository and then:

```bash
source bootstrap.sh
```

Alternatively, to update while avoiding the confirmation prompt:

```bash
set -- -f; source bootstrap.sh
```

### Install Homebrew formulas

```bash
./brew.sh
```
