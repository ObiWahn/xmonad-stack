# Installation
- Make sure you have stack installed and configured
- Checkout this repository and `git submodule init && git submodule update`
- Run `stack install` in the checkout
- Link the `$repo/config` directory to `~/.xmonad`
- Create a `xmonad.hs` by hand or use one of the prepared `files_.hs` files
- If you want to use stack you need to link `xmonad_build` to `build` in the `config` directory. (update the repo path in this file)
