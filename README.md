# Neo-emacsd

Your humble correspondent's personal Emacs configuration - because [Emacs loves
all its users](https://emacs.love/tales/emacs-loves-all-its-users.html).

---

Every Emacs user's .emacs.d will inevitably grow until they find it unwieldy, at
which point the sensible thing to do is to tear it down and rebuild it.

My old .emacs.d (preserved on [github](https://github.com/japanoise/dotemacs))
is one such case. Some things wrong with it:

* Use of vendored packages, mostly for old shit that used to be on Melpa from
  EmacsWiki but got taken down.
* The separation of code into files was, while a good idea, unintuitive and in
  some places illogical.
* There were all sorts of language files, many for languages I don't use and am
  not actively planning to learn.
  - Among these were language files that used to be on Melpa but aren't any
    more, some of which I never got round to vendoring.
  - Many of these also had program requirements that I just didn't have lying
    around on all my machines and were occasionally a pain to install.
* It was full of old stuff from my old workplace.
* There was a lot of hacking to get it to avoid using TLS to work around
  Marmalade's shittiness - despite me hardly using Marmalade.
* Helm's author seems to be experiencing burn-out, and may in the future exit
  Emacs development: [here's the issue I saw on
  this](https://github.com/emacs-helm/helm/issues/2386); apparently it's
  [damaging to the maintainer's family,
  too](https://sachachua.com/blog/2018/09/interview-with-thierry-volpiatto/).
  Ivy seems more my speed, so I'm trying it out now (I never used any advanced
  helm features anyway, just used it as a completion engine).

And the main one: My desire was a .emacs.d that you could just clone into your
home directory and forget about. I even set up some of my scripts to do
that. However, the instability of the setup just didn't allow that - packages
kept getting deprecated and removed and I only discovered so when installing it
on a new machine. As a result of this hack-and-fix approach there are now
slightly different versions of my old .emacs.d on all my various installs, and I
really don't want to commit any of the monkey-patches in case they all break
each other.

So, in the proud tradition of other Emacs-heads before me, I am tearing down and
building up my .emacs.d from scratch. While I never keep these READMEs up to
date, here's some of the features, anti-features, and design goals:

- Use Ivy rather than Helm - as above. I loved Helm's fuzzy-find, but the
  package sorely lacked intuitivity, even for someone used to Emacs bindings. I
  think it's better that I learned how to do things in a very slightly tweaked
  Emacs (such as using C-x C-b to kill multiple buffers) rather than learning
  Helm's baroque way of doing such things. Also, have you ever accidentally
  entered a Helm buffer? Yikes.
- Don't vendor things unless absolutely necessary. It's the package maintainer's
  job to get things into Melpa or Elpa. Nothing against packages that aren't,
  it's just so sketchy copying and pasting in a source file, especially when a
  better alternative exists.
- Don't copy the behavior of Spacemacs. I'm still fond of that distro for
  getting me into Emacs, but if I wanted to use it I would use it. So stuff like
  the dashboard
  ([jank](https://github.com/japanoise/dotemacs/commit/5ef4168e47e9d7e6b780e532030943c5e06383f2)
  [as](https://github.com/japanoise/dotemacs/commit/f3390ab413ccbe1f6cf1cdb99826be125a33319b)
  [fuck](https://github.com/japanoise/dotemacs/commit/51b0ea7a980b65b71407ee6940a21b46e0f3baf4))
  or the rotating theme switcher (only ever used to go back to snazzy) are out.
- Just put everything into init.el. I really liked the work that [Sacha
  Chua](https://sachachua.com/blog/emacs/) did, where her .emacs.d was a
  literate programming exercise, but it just doesn't work for me.  If one
  [.vimrc](https://github.com/japanoise/scripts-dotfiles/blob/master/.vimrc) was
  good for me back during my penance, one init.el should be good for me now.
  * I really don't have enough clout that anyone but me (and perhaps you, dear
    reader) will ever care about my .emacs.d :P
- Try and keep stuff workplace-independent. Inevitably stuff from work will seep
  in (back then it was Groovy, and now it'll probably be protobuf) but ricing
  Emacs specifically to integrate with workplace systems is probably a recipe
  for disaster.
- Keep all the cool uemacs/emacs-mode bindings that I now love. C-u and C-z in
  particular are my babies.
- Keep chameleon-prefix on F5 because it's burned into my fingers now.
- Snazzy uses a nice readable color for comments rather than a diminished
  one. Why?  [Because I read an article ages
  ago](https://jameshfisher.com/2014/05/11/your-syntax-highlighter-is-wrong/)
  that changed the way I think about comments.

For the most part, the main difference someone who switched from the old to the
new would notice is that now there's Ivy instead of Helm and the Snazzy theme is
the default and only one.

## Dependencies

Some dependencies are external to Emacs and will need some manual attention.

- https://github.com/ggreer/the_silver_searcher#installing for dumb-jump.
- A spellchecker; Ispell on Linux and Mac, hunspell on Windows - see below.

## Spelling on Windows

You'll need hunspell and dictionaries. The easiest way to get dictionaries is
to install LibreOffice. The easiest way to get hunspell is to use ezwinports,
as described [here](https://stackoverflow.com/a/62117664). Presumably at some
point though, you'll be able to use winget (which is my personal favorite way to
get the Silver Searcher installed, by-the-by).

## License

GPLv3 or, at your option, any later version.
