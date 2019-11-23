radical.vim
===========

Radical.vim is a Vim plugin that converts between the number
representations encountered when programming, that is in addition to
decimal, hex, octal, and binary representation.

This plugin depends on the [magnum.vim][1] big integer library.

[1]: https://github.com/glts/vim-magnum

Usage
-----

The entire functionality of this plugin can be summarised in two items.

*   `gA` shows the four representations of the number under the cursor
    (or selected in Visual mode).
*   `crd`, `crx`, `cro`, `crb` convert the number under the cursor to
    decimal, hex, octal, binary, respectively.

These mappings accept a count to force the base used to interpret the
targeted number.

Requirements
------------

*   [magnum.vim][1] plugin
*   [repeat.vim][2] plugin (optional)

This plugin has been tested with Vim 7.3 and above.

[2]: https://github.com/tpope/vim-repeat

Installation
------------

Use your preferred installation method.

Keep in mind that radical.vim depends on [magnum.vim][1], so be sure to
install that as well if your plugin manager doesn’t handle dependencies
for you.

For example, with [pathogen.vim][3] the installation goes:

    git clone https://github.com/glts/vim-magnum.git ~/.vim/bundle/magnum
    git clone https://github.com/glts/vim-radical.git ~/.vim/bundle/radical

[3]: http://www.vim.org/scripts/script.php?script_id=2332
