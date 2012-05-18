My vim config
=============

I recently discovered [Janus](https://github.com/carlhuda/janus), an
absolutely awesome vim configuration :-)  So I dumped my vim config, set
up Janus, and started adding my stuff. Since I didn't want to repeat
that on all of my machines, I dumped it here at github.

So in case you want to use this config, here's how to do the...

Setup
-----

1. Set up [Janus](https://github.com/carlhuda/janus)
  * Either clone the Janus repo to $HOME/.vim and run rake within it
  * Or be brave and use the auto installer ;-)
2. Clone [my config](https://github.com/Skyr/vimconfig) to $HOME/.janus
  * Either clone recursively (`git clone --recursive https://github.com/Skyr/vimconfig.git .janus`)
  * Or fetch submodules afterwards (`cd .janus ; git submodule update --init`)
3. Create symlinks to the before and after files:

```bash
ln -s .janus/vimrc.before $HOME/.vimrc.before
ln -s .janus/vimrc.after $HOME/.vimrc.after
```

