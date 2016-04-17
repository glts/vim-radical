radical.vim
===========

Radical.vim is a Vim plugin that converts between the number
representations encountered when programming, that is in addition to
decimal, hex, octal, and binary representation.

This plugin depends on Google's [Maktaba][1] library and on the
[magnum.vim][2] big integer library.

[1]: https://github.com/google/vim-maktaba
[2]: https://github.com/glts/vim-magnum

Usage
-----

The entire functionality of this plugin can be summarised in two items.

*   `gA` shows the four representations of the number under the cursor.
*   `crd`, `crx`, `cro`, `crb` convert the number under the cursor to
    decimal, hex, octal, binary, respectively.

These are the default mappings. As usual with maktaba plugins, they must
be enabled explicitly.

Requirements
------------

*   [Maktaba][1] plugin
*   [magnum.vim][2] plugin
*   [repeat.vim][3] plugin (optional)

This plugin has been tested with Vim 7.3 and above.

[3]: https://github.com/tpope/vim-repeat

Installation
------------

Use your preferred installation method.

Keep in mind that radical.vim depends on [Maktaba][1] and
[magnum.vim][2], so be sure to install these as well if your plugin
manager doesn't handle dependencies for you.

For example, with [pathogen.vim][4] the installation goes:

    git clone https://github.com/google/vim-maktaba.git ~/.vim/bundle/maktaba
    git clone https://github.com/glts/vim-magnum.git ~/.vim/bundle/magnum
    git clone https://github.com/glts/vim-radical.git ~/.vim/bundle/radical

[4]: http://www.vim.org/scripts/script.php?script_id=2332

