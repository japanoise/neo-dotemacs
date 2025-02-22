;;; init.el --- The main init entry for Emacs -*- lexical-binding: t -*-
;;; Commentary:

;;; Code:

;; ,---------------------------------------------------------------------------,
;; |                                                                           |
;; | elpaca - package manager                                                  |
;; |                                                                           |
;; `---------------------------------------------------------------------------'

(defvar elpaca-installer-version 0.7)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1
                              :files (:defaults "elpaca-test.el"
                                                (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (< emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                 ((zerop
                   (apply #'call-process `("git" nil ,buffer t "clone"
                                           ,@(when-let
                                                 ((depth
                                                   (plist-get order :depth)))
                                               (list (format "--depth=%d" depth)
                                                     "--no-single-branch"))
                                           ,(plist-get order :repo) ,repo))))
                 ((zerop (call-process "git" nil buffer t "checkout"
                                       (or (plist-get order :ref) "--"))))
                 (emacs (concat invocation-directory invocation-name))
                 ((zerop
                   (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                 "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                 ((require 'elpaca))
                 ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (load "./elpaca-autoloads")))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

(elpaca elpaca-use-package
  (elpaca-use-package-mode)
  (setq elpaca-use-package-by-default t))

;; Block until current queue processed.
(elpaca-wait)

;; ,---------------------------------------------------------------------------,
;; |                                                                           |
;; | my key bindings - permanently burned into my fingers                      |
;; |                                                                           |
;; `---------------------------------------------------------------------------'

(global-set-key [f6]
                'universal-argument)
(define-key universal-argument-map [f6] 'universal-argument-more)
(define-key universal-argument-map "\C-u"
  nil)
(defun kill-line-backwards ()
  "Kill line backwards."
  (interactive)
  (kill-line 0))
(global-set-key (kbd "C-u")
                'kill-line-backwards)
(global-set-key (kbd "C-z") 'scroll-down-command)
(global-set-key (kbd "C-M-z") 'scroll-other-window-down)
(global-set-key (kbd "M-n") 'forward-paragraph)
(global-set-key (kbd "M-p") 'backward-paragraph)

;; Some commands
(defun my/pivot-chars ()
  "Pivot chars around each other."
  (interactive)
  (transpose-chars 1)
  (transpose-chars 1)
  (backward-char)
  (backward-char)
  (transpose-chars 1)
  (backward-char))

(defun my/pivot-words ()
  "Pivot words around each other."
  (interactive)
  (transpose-words 1)
  (transpose-words 1)
  (backward-word)
  (backward-word)
  (transpose-words 1)
  (backward-word))

;; chameleon-prefix
(progn
  (defvar chameleon-prefix-map)
  (define-prefix-command 'chameleon-prefix-map)
  (define-key chameleon-prefix-map (kbd "s") 'replace-string)
  (define-key chameleon-prefix-map (kbd "r") 'replace-regexp)
  (define-key chameleon-prefix-map (kbd "q r") 'query-replace-regexp)
  (define-key chameleon-prefix-map (kbd "q s") 'query-replace)
  (define-key chameleon-prefix-map (kbd "t") 'my/pivot-chars)
  (define-key chameleon-prefix-map (kbd "T") 'my/pivot-words)
  (global-set-key (kbd "<f5>")
                  'chameleon-prefix-map))

;; New empty buffer
(defun xah-new-empty-buffer ()
  "Create a new empty buffer.
New buffer will be named \"untitled\" or \"untitled<2>\", \"untitled<3>\", etc.

It returns the buffer (for elisp programing).

URL `http://ergoemacs.org/emacs/emacs_new_empty_buffer.html'
Version 2017-11-01"
  (interactive)
  (let (($buf (generate-new-buffer "untitled")))
    (switch-to-buffer $buf)
    (funcall initial-major-mode)
    (setq buffer-offer-save t)
    (text-mode)
    $buf))

(global-set-key (kbd "<f7>") 'xah-new-empty-buffer)

;; https://www.emacswiki.org/emacs/IncrementNumber
(defun my-change-number-at-point (change)
  (let ((number (number-at-point))
        (point (point)))
    (when number
      (progn
        (forward-word)
        (search-backward (number-to-string number))
        (replace-match (number-to-string (funcall change number)))
        (goto-char point)))))
(defun my-increment-number-at-point ()
  "Increment number at point like vim's ^A."
  (interactive)
  (my-change-number-at-point '1+ ))
(defun my-decrement-number-at-point ()
  "Decrement number at point like vim's ^X."
  (interactive)
  (my-change-number-at-point '1- ))

(global-set-key (kbd "C-c a")
                'my-increment-number-at-point)
(global-set-key (kbd "C-c x")
                'my-decrement-number-at-point)

(define-key chameleon-prefix-map (kbd "a") 'my-increment-number-at-point)
(define-key chameleon-prefix-map (kbd "x") 'my-decrement-number-at-point)

(global-set-key (kbd "<kp-add>")
                'my-increment-number-at-point)
(global-set-key (kbd "<kp-subtract>")
                'my-decrement-number-at-point)

;; ,---------------------------------------------------------------------------,
;; |                                                                           |
;; | my rice - I like my Emacs to look pretty~                                 |
;; |                                                                           |
;; `---------------------------------------------------------------------------'

(defgroup my-custom-group nil "My customization group."
  :group 'extensions)

;; Don't emulate xterm please
(setq frame-resize-pixelwise t)

;; Use a sane font
;; It looks small on Mac, so make it 2 points bigger there.
(if (eq system-type 'darwin)
    (add-to-list 'default-frame-alist
                 '(font . "Go Mono 13"))
    (add-to-list 'default-frame-alist
                 '(font . "Go Mono 11")))

;; Eternal blinking cursor
(setq-default cursor-type 'bar)
(blink-cursor-mode 1)
(setq blink-cursor-blinks 0)

;; override insert key to change cursor in overwrite mode - https://gist.github.com/fisher/04d6966491748efa5ad3
(defvar cursor-mode-status 0)
(defun my/toggle-overwrite-mode-and-change-cursor ()
  "As its name suggests."
  (interactive)
  (cond
   ((eq cursor-mode-status 0)
    (setq cursor-type 'box)
    (overwrite-mode (setq cursor-mode-status 1)))
   (t (setq cursor-type 'bar)
      (overwrite-mode (setq cursor-mode-status 0)))))
(global-set-key (kbd "<insert>")
                'my/toggle-overwrite-mode-and-change-cursor)

;; Nice frame title
(setq frame-title-format "%b %&- emacs")
(setq icon-title-format "%b %&- emacs")

;; https://www.reddit.com/r/emacs/comments/2kdztw/emacs_in_evil_mode_show_tildes_for_blank_lines/
;; Emacs-y tilde fringe
(defface fringe-tilde-face
  '((t :foreground "#57c7ff"))
  "Used to display tildes in the fringe."
  :group 'my-custom-group)
(setq-default indicate-empty-lines t)
(progn
  (define-fringe-bitmap 'tilde
    [0 0 0 113 219 142 0 0]
    nil
    nil
    'center)
  (setcdr (assq 'empty-line fringe-indicator-alist)
          'tilde))
(set-fringe-bitmap-face 'tilde 'fringe-tilde-face)

;; Modeline. Fuck it, vanilla is fine.
(setq-default mode-line-format
      (list
       "%3l:%2c "
       mode-line-modified
       " "
       mode-line-percent-position
       " -- "
       mode-line-buffer-identification
       " -- "
       mode-line-modes
       "%-"
       ))

;; Never load settings from .Xresources
(setq inhibit-x-resources t)

;; ,---------------------------------------------------------------------------,
;; |                                                                           |
;; | annoyances - make Emacs do what I want it to, not what was trendy in 1995 |
;; |                                                                           |
;; `---------------------------------------------------------------------------'

;; Never ever ring the bell
(setq ring-bell-function 'ignore)

;; Never ask me to type out 'yes' or 'no'
(defalias 'yes-or-no-p 'y-or-n-p)

;; Make mouse yanking less awkward
(setq mouse-yank-at-point t)

;; utf8
;; https://thraxys.wordpress.com/2016/01/13/utf-8-in-emacs-everywhere-forever/
(set-language-environment "UTF-8")
(set-default-coding-systems 'utf-8)
(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
(when (display-graphic-p)
  (setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING)))

;; https://www.emacswiki.org/emacs/SmoothScrolling
;; scroll one line at a time (less "jumpy" than defaults)

(setq mouse-wheel-progressive-speed 'nil) ;; don't accelerate scrolling
(setq mouse-wheel-follow-mouse 't) ;; scroll window under mouse
(setq scroll-step 1) ;; keyboard scroll one line at a time

;; fundamental-mode is just about useless; default to text-mode
(setq-default major-mode 'text-mode)

;; Disable text-scale-adjust
(dolist (key '("C-x C-0" "C-x C-=" "C-x C--" "C-x C-+" "<C-wheel-up>"
               "<C-wheel-down>" "<C-mouse-4>" "<C-mouse-5>"))
  (global-unset-key (kbd key)))

;; Spaces by default (momentum)
(setq-default indent-tabs-mode nil)

;; ,---------------------------------------------------------------------------,
;; |                                                                           |
;; | useful functions - some used for init, some not                           |
;; |                                                                           |
;; `---------------------------------------------------------------------------'

;; For local setup
(defun my/load-file-if-exists (file)
  "If FILE exists, load it."
  ()
  (when (file-exists-p file)
    (load-file file)))

;; Ascii table - https://www.emacswiki.org/emacs/AsciiTable
(defun ascii-table ()
  "Display basic ASCII table (0 thru 128)."
  (interactive)
  (switch-to-buffer "*ASCII*")
  (erase-buffer)
  (setq buffer-read-only nil)        ;; Not need to edit the content, just read mode (added)
  (setq lower32 '("nul" "soh" "stx" "etx" "eot" "enq" "ack" "bel"
                  "bs" "ht" "nl" "vt" "np" "cr" "so" "si"
                  "dle" "dc1" "dc2" "dc3" "dc4" "nak" "syn" "etb"
                  "can" "em" "sub" "esc" "fs" "gs" "rs" "us"
                  ))
  (save-excursion (let ((i -1))
                    (insert "ASCII characters 0 thru 127.\n\n")
                    (insert " Hex  Dec  Char|  Hex  Dec  Char|  Hex  Dec  Char|  Hex  Dec  Char\n")
                    (while (< i 31)
                      (insert (format "  %02x %4d %4s |   %02x %4d %4s |   %02x %4d %4s |   %02x %4d %4s\n"
                                      (setq i (+ 1  i)) i (elt lower32 i)
                                      (setq i (+ 32 i)) i (single-key-description i)
                                      (setq i (+ 32 i)) i (single-key-description i)
                                      (setq i (+ 32 i)) i (single-key-description i)))
                      (setq i (- i 96))))))

(defun my/filename ()
    "Copy the full path of the current buffer."
    (interactive)
    (kill-new (buffer-file-name (window-buffer (minibuffer-selected-window)))))

;; ,---------------------------------------------------------------------------,
;; |                                                                           |
;; | utility packages - i.e. stuff that helps customization, convenience       |
;; |                                                                           |
;; `---------------------------------------------------------------------------'

;; Diminish - for noisy minor modes
(use-package diminish)

;; Please don't poop in my .emacs.d!
(use-package no-littering)
;; backup in one place. flat, no tree structure
;; Has to happen after no-littering
(make-directory "~/.emacs_backups/" t)
(setq backup-directory-alist '(("" . "~/.emacs.d/emacs-backup")))
;; Don't drop autosaves everywhere
(make-directory "~/.emacs_autosave/" t)
(setq auto-save-file-name-transforms '((".*" "~/.emacs_autosave/" t)))

;; Generic-x; various random major modes
;; Do it first so anything defined here can be overwritten by subsequent prog-modes
(require 'generic-x)
(add-to-list 'auto-mode-alist
             '("\\.gitignore$" . hosts-generic-mode)) ;; Highlight comments for .gitignore files

;; Ivy - best of both worlds between Ido & Helm
(use-package ivy
  :diminish ivy-mode
  :config (ivy-mode 1))
(use-package counsel
  :diminish counsel-mode
  :config
  (counsel-mode)
  (global-set-key (kbd "C-x b") 'counsel-switch-buffer))

;; Auto completion with company.
;; It sucks, but the alternatives suck more.
(use-package company
  :diminish company-mode
  :config
  (global-company-mode)
  ;; Don't downcase completion results
  (setq company-dabbrev-downcase nil))

;; Anzu mode (counts isearch occurrences)
(use-package anzu
  :diminish anzu-mode
  :config (global-anzu-mode))

;; Shorten some minor modes
(use-package delight)

;; For snazzy theme
(use-package base16-theme
  :config
  (setq base16-highlight-mode-line 'contrast)
  (require 'base16-japanoise-uchupp-theme)
  (load-theme 'base16-japanoise-uchupp t))

;; Rainbow Delimiters
(use-package rainbow-delimiters
  :init (add-hook 'prog-mode-hook 'rainbow-delimiters-mode))

;; Smartparens
(use-package smartparens
  :diminish smartparens-mode
  :bind (("C-M-f" . sp-forward-sexp)
         ("C-M-b" . sp-backward-sexp))
  :config
  (require 'smartparens-config)
  (add-hook 'prog-mode-hook #'smartparens-mode))

;; Highlights matching parens
(require 'paren)
(setq show-paren-delay 0)
(show-paren-mode 1)

;; Update PATH from zsh (or bash, if you're not as sexy as me)
;; Doesn't work on windows so don't bother
(unless (eq system-type 'windows-nt)
  (use-package exec-path-from-shell
    :config 
    (when (file-exists-p "~/.zshenv")
      (setq exec-path-from-shell-arguments nil))
    (dolist (var '("PERL5LIB" "PERL_LOCAL_LIB_ROOT" "PERL_MB_OPT" "PERL_MM_OPT"))
      (add-to-list 'exec-path-from-shell-variables var))
    (exec-path-from-shell-initialize)))

;; Flycheck and Flyspell
(use-package flycheck
  :ensure t
  :init (global-flycheck-mode))

(when (eq system-type 'windows-nt)
  ;; Windows' fussy spell setup.
  (setenv "DICTIONARY" "en_US")
  (setq ispell-program-name "hunspell"))

(add-hook 'prog-mode-hook 'flyspell-prog-mode)
(add-hook 'text-mode-hook 'flyspell-mode)

(defun my/disable-flycheck () "Disable flycheck in buffer." (interactive)
       (flycheck-mode -1))

;; bcoz rubocop is broken on OSX atm
(add-hook 'ruby-mode-hook 'my/disable-flycheck)

;; Which-key - spacemacs' nice little prefix popup
(use-package which-key
  :diminish which-key-mode
  :config
  (setq which-key-echo-keystrokes 0.1)
  (which-key-mode))

;; Magit + bindings
(use-package diff-hl)
(use-package magit
  :bind (("C-x g" . magit-status) :map chameleon-prefix-map
         ("g s" . magit-status))
  :config
  (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)
  (global-diff-hl-mode))

;; Replace ^L with a horizontal rule
(use-package page-break-lines
  :diminish page-break-lines-mode
  :config (global-page-break-lines-mode 1))

;; Non-confusing undo
(use-package undo-tree
  :diminish undo-tree-mode
  :bind (("C-?" . undo-tree-redo)
         ("C-x C-/" . undo-tree-redo))
  :config
  (global-undo-tree-mode 1)
  ;; Prevent undo tree files from polluting your git repo
  (setq undo-tree-history-directory-alist '(("." . "~/.emacs.d/var/undo"))))

;; Treemacs
(use-package treemacs
  :bind ([mouse-1] . treemacs-single-click-expand-action))

;; ,---------------------------------------------------------------------------,
;; |                                                                           |
;; | language packages - programming languages &c.                             |
;; |                                                                           |
;; `---------------------------------------------------------------------------'

(use-package typst-ts-mode
  :ensure (:type git
                 :host sourcehut
                 :repo "meow_king/typst-ts-mode"
                 :files (:defaults "*.el"))
  :config
  ;; typst-ts-mode - see https://git.sr.ht/~meow_king/typst-ts-mode
  (add-to-list 'treesit-language-source-alist
               '(typst "https://github.com/uben0/tree-sitter-typst"))
  (treesit-install-language-grammar 'typst))

;; Similar to treemacs - org outline in sidebar
(use-package org-side-tree
  :config (setq outline-minor-mode-cycle t))

;; Markdown mode
(defun my/insert-markdown-link ()
  "Insert a markdown link (known behavior from tiddlywiki)."
  (interactive)
  (save-excursion
    (insert "[]()"))
  (forward-char 1))
(use-package wc-mode)
(use-package markdown-mode
  :ensure t
  :commands (markdown-mode gfm-mode):mode
  (("README\\.md\\'" . gfm-mode)
   ("\\.md\\'" . markdown-mode)
   ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown")
  :bind ("M-L" . my/insert-markdown-link)
  :config (add-hook 'markdown-mode-hook
          (lambda ()
            (setq-local fill-column 80)
            (auto-fill-mode)
            (wc-mode))))

;; Editorconfig
(use-package editorconfig
  :ensure t
  :diminish editorconfig-mode
  :config
  (editorconfig-mode 1))

;; LSP Mode
(use-package lsp-mode
  :hook (lsp-mode . (lambda ()
                      (let ((lsp-keymap-prefix "C-c l"))
                        (lsp-enable-which-key-integration))))
  :config
  (define-key lsp-mode-map (kbd "C-c l") lsp-command-map))
;;(require 'lsp-ido)

;; C-mode & Sepples-mode lsp.
;; Dependencies: clangd (and bear to generate compile_commands.json)
;; See https://emacs-lsp.github.io/lsp-mode/tutorials/CPP-guide/
(add-hook 'c-mode-hook 'lsp)
(add-hook 'c++-mode-hook 'lsp)

;; Go mode. Dependencies:
;; - go install github.com/rogpeppe/godef@latest
;; - go install golang.org/x/tools/cmd/goimports@latest
;; - go install golang.org/x/tools/cmd/gorename@latest
;; - go install golang.org/x/tools/gopls@latest
;; - go install github.com/nsf/gocode@latest
(use-package go-mode
  :config
  (use-package godoctor)
  (add-hook 'go-mode-hook #'lsp-deferred)
  (defun my-go-mode-hook ()
    "Hook for go mode.  Setup company & lsp."
    (add-hook 'before-save-hook #'lsp-format-buffer t t)
    (add-hook 'before-save-hook #'lsp-organize-imports t t)
    (set (make-local-variable 'company-backends)
         '(company-go)))
  (add-hook 'go-mode-hook 'my-go-mode-hook)
  :bind
  (("C-c C-r" . go-remove-unused-imports)))
(use-package company-go)
(use-package go-rename)
(use-package go-eldoc
  :init (add-hook 'go-mode-hook 'go-eldoc-setup))

;; Elixir
(use-package elixir-mode)

;; Lua Mode
(use-package lua-mode)

;; Typescript Mode
(use-package typescript-mode)

;; yaml mode
(use-package yaml-mode)

;; cmake
(use-package cmake-mode)

;; racket-mode
(use-package racket-mode
  :bind (:map racket-mode-map
              ("<f5>" . nil)))

;; dumb-jump
(use-package dumb-jump
  :config (add-hook 'xref-backend-functions #'dumb-jump-xref-activate))

;; Whitespace cleanup
(use-package whitespace-cleanup-mode
  :config (global-whitespace-cleanup-mode))

;; rainbow-mode
(use-package rainbow-mode)

;; All-the-icons
;; install fonts with (all-the-icons-install-fonts)
(use-package all-the-icons)

;; Nerd icons - similar to all the icons I guess
;; (nerd-icons-install-fonts)
(use-package nerd-icons)

;; doom modeline
(use-package doom-modeline
  :config
  (doom-modeline-mode 1)
  (setq doom-modeline-continuous-word-count-modes '(markdown-mode gfm-mode org-mode)))

;; ,---------------------------------------------------------------------------,
;; |                                                                           |
;; | miscellaneous wrapping up                                                 |
;; |                                                                           |
;; `---------------------------------------------------------------------------'

;; Enabled commands
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)

;; Local setup
(my/load-file-if-exists "~/.emacs.d/local.el")

;; Custom-set turd
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(add-log-full-name "japanoise")
 '(add-log-mailing-address "japanoise@seekrit.club")
 '(column-number-mode t)
 '(dired-dwim-target 'dired-dwim-target-next)
 '(doom-modeline-default-eol-type 0)
 '(doom-modeline-enable-word-count t)
 '(doom-modeline-height 21)
 '(doom-modeline-mode t)
 '(ivy-action-wrap t)
 '(lua-indent-level 2))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(fixed-pitch ((t (:family "Go Mono"))))
 '(font-lock-comment-delimiter-face ((t (:foreground "rosy brown"))))
 '(font-lock-comment-face ((t (:foreground "rosy brown"))))
 '(mouse ((t (:background "white"))))
 '(org-link ((t (:foreground "light slate blue" :underline t))))
 '(outline-4 ((t (:foreground "turquoise"))))
 '(term-color-black ((t (:inherit default :background "#080a0d" :foreground "#080a0d"))))
 '(term-color-bright-black ((t (:inherit default :background "#878a8b" :foreground "#878a8b"))))
 '(term-color-red ((t (:inherit default :background "#a30d30" :foreground "#a30d30"))))
 '(term-color-bright-red ((t (:inherit default :background "#ea3c65" :foreground "#ea3c65"))))
 '(term-color-green ((t (:inherit default :background "#2e943a" :foreground "#2e943a"))))
 '(term-color-bright-green ((t (:inherit default :background "#64d970" :foreground "#64d970"))))
 '(term-color-yellow ((t (:inherit default :background "#b59944" :foreground "#b59944"))))
 '(term-color-bright-yellow ((t (:inherit default :background "#fedf7b" :foreground "#fedf7b"))))
 '(term-color-blue ((t (:inherit default :background "#0949ac" :foreground "#0949ac"))))
 '(term-color-bright-blue ((t (:inherit default :background "#3984f2" :foreground "#3984f2"))))
 '(term-color-magenta ((t (:inherit default :background "#8f2366" :foreground "#8f2366"))))
 '(term-color-bright-magenta ((t (:inherit default :background "#ff6ac1" :foreground "#ff6ac1"))))
 '(term-color-cyan ((t (:inherit default :background "#048888" :foreground "#048888"))))
 '(term-color-bright-cyan ((t (:inherit default :background "#25d2d2" :foreground "#25d2d2"))))
 '(term-color-white ((t (:inherit default :background "#cbcdcd" :foreground "#cbcdcd"))))
 '(term-color-bright-white ((t (:inherit default :background "#fdfdfd" :foreground "#fdfdfd"))))
 '(tooltip ((t (:inherit default :background "#34353e" :foreground "white")))))

(provide 'init)
;;; init.el ends here
