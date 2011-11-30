manbook --  produces an eBook from man pages
============================================

## SYNOPSIS

    manbook <MANPAGE>
    manbook <MANPAGE1> [<MANPAGE2> ...]
    manbook <MANPAGE> --output <DIRECTORY>
    manbook <MANPAGE1> [<MANPAGE2> ...] --output <DIRECTORY>
    manbook --all --output <DIRECTORY>

    mktoc <DIRECTORY>

## DESCRIPTION

The `manbook` command can be used to produce an eBook from one or more
man pages. 

`mktoc` produces table-of-content files, suitable for MOBI files (Kindle,
etc) from the HTML files in a directory.

## QUICKSTART

    gem install manbook
    manbook --help
    mktoc --help

## MANPAGE

`manbook` expects to be passed the name of one or more man pages. It will
use the MANPATH environment variable to find the man page and convert it to
HTML.

If more than one man page was passed, an additional index page will be 
created. If the man pages are from different sections, `manbook` will create 
separate indexes by section together with an index file for each section.

## OPTIONS

You can specify an individual man page or a list of man pages using a few 
options.

  * `-o`, `--output`:
    Specifies the output file (when operating on a single man page) or
    the output directory (when operating on multiple man pages) where
    the HTML files will be written to.

  * `-a`, `--all`:
    Produce a book with all man pages found.

See `manbook --help` to view the options at any time.

## INSTALL

    gem install manbook

## EXAMPLES

    manbook ls
    manbook ls grep bash --output ./my-favorite-pages/
    manbook -a -o ./manpages/

# HISTORY #
After I bought a Kindle, the idea was born to put the man pages of my Mac onto my Kindle. My requirements are:

1. Input should be exactly the man pages on /my/ system, not someone else's FreeBSD or whathever
1. Should respect my MANPATH (not just look in /usr/share/man)
1. Pages should be as plain-text as possible (no PDF).
1. eBook should provide an index with a list of all man pages by section and by name

When I looked around for an existing solution, all I found was:

* http://askubuntu.com/questions/21903/man-pages-offline-for-e-reader
* http://www.macgeekery.com/tips/cli/pretty-print_manual_pages_as_ps_pdf_or_html

and a few other, not-quite-complete scripts. None of them satisfied my requirements, so I decided to write my own tool. Thus, `manbook` was born.

## BUGS

Requires the `groff` script to be in your path and executable. 

Requires Ruby and RubyGems.

Please report other bugs at <http://github.com/nerab/manbook/issues>

## CONTRIBUTING
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## COPYRIGHT

manbook is Copyright (C) 2011 Nicolas E. Rabenau. See LICENSE.txt for further details.

## SEE ALSO

groff(1), <http://en.wikipedia.org/wiki/Man_page>, [mail2kindle](https://gist.github.com/1410840)
