;;; init --- my init file
;;; Commentary:
;;; Just another Emacs hacker,
;;;
;;; Dependencies:
;;; - https://github.com/ggreer/the_silver_searcher#installing
;;; - (Windows only) https://stackoverflow.com/questions/58458901/how-do-i-install-hunspell-on-windows10/62117664#62117664
;;; Code:

;; Remove visual clutter
(scroll-bar-mode 0)
(menu-bar-mode 0)
(tool-bar-mode 0)

;; Some keys
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

;; chameleon-prefix
(progn
  (defvar chameleon-prefix-map)
  (define-prefix-command 'chameleon-prefix-map)
  (define-key chameleon-prefix-map (kbd "s") 'replace-string)
  (define-key chameleon-prefix-map (kbd "r") 'replace-regexp)
  (define-key chameleon-prefix-map (kbd "q r") 'query-replace-regexp)
  (define-key chameleon-prefix-map (kbd "q s") 'query-replace)
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

;; https://www.reddit.com/r/emacs/comments/2kdztw/emacs_in_evil_mode_show_tildes_for_blank_lines/
;; Emacs-y tilde fringe
(defface fringe-tilde-face
  '((t :foreground "#57c7ff"))
  "Used to display tildes in the fringe")
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

;; fundamental-mode is just about useless; default to text-mode
(setq-default major-mode 'text-mode)

;; Disable text-scale-adjust
(dolist (key '("C-x C-0" "C-x C-=" "C-x C--" "C-x C-+" "<C-wheel-up>"
               "<C-wheel-down>" "<C-mouse-4>" "<C-mouse-5>"))
  (global-unset-key (kbd key)))

;; Spaces by default (momentum)
(setq-default indent-tabs-mode nil)

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
  "Increment number at point like vim's C-a."
  (interactive)
  (my-change-number-at-point '1+ ))
(defun my-decrement-number-at-point ()
  "Decrement number at point like vim's C-x."
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

;; For local setup
(defun my/load-file-if-exists (file)
  "If FILE exists, load it."
  ()
  (when (file-exists-p file)
    (load-file file)))

;; Never load settings from .Xresources
(setq inhibit-x-resources t)

;; C - some setup
(setq c-default-style "linux")

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

;; --------------------------- PACKAGES ------------------------------

(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(add-to-list 'package-archives
             '("gnu" . "https://elpa.gnu.org/packages/"))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile (require 'use-package)
                   (setq use-package-always-ensure t))

;; Please don't poop in my .emacs.d!
(use-package no-littering)
;; backup in one place. flat, no tree structure
;; Has to happen after no-littering
(setq backup-directory-alist '(("" . "~/.emacs.d/emacs-backup")))

;; Because the update workflow is unintuitive:
(use-package auto-package-update)
;; Now I can M-x (auto-)package-update :)

;; Generic-x; various random major modes
;; Do it first so anything defined here can be overwritten by subsequent prog-modes
(require 'generic-x)
(add-to-list 'auto-mode-alist
             '("\\.gitignore$" . hosts-generic-mode)) ;; Highlight comments for .gitignore files

;; Ido - starting to prefer it over helm.
(require 'ido)
(ido-mode t)
(use-package smex)
(smex-initialize)
(global-set-key (kbd "M-x") 'smex)

;; browse-kill-ring - alternative to helm's M-y behavior
(use-package browse-kill-ring)
(browse-kill-ring-default-keybindings)

;; Auto completion with company.
;; It sucks, but the alternatives suck more.
(use-package company
  :diminish company-mode)
(global-company-mode)
;; Don't downcase completion results
(setq company-dabbrev-downcase nil)

;; Diminish - for noisy minor modes
(use-package diminish)

;; Anzu mode (counts isearch occurrences)
(use-package anzu :diminish anzu-mode)
(global-anzu-mode)

;; Shorten some minor modes
(use-package delight)

;; For snazzy theme
(use-package base16-theme
  :config (setq base16-highlight-mode-line 'contrast))

;; Rainbow Delimiters
(use-package rainbow-delimiters
  :init (add-hook 'prog-mode-hook 'rainbow-delimiters-mode))

;; Smartparens
(use-package smartparens
  :diminish smartparens-mode
  :bind (("C-M-f" . sp-forward-sexp)
         ("C-M-b" . sp-backward-sexp)))
(require 'smartparens-config)
(add-hook 'prog-mode-hook #'smartparens-mode)

;; Highlights matching parens
(require 'paren)
(setq show-paren-delay 0)
(show-paren-mode 1)

;; Update PATH from zsh (or bash, if you're not as sexy as me)
;; Doesn't work on windows so don't bother
(unless (eq system-type 'windows-nt)
  (use-package exec-path-from-shell)
  (exec-path-from-shell-initialize))

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
(use-package which-key :diminish which-key-mode)
(setq which-key-echo-keystrokes 0.1)
(which-key-mode)

;; Magit, with some bindings
(use-package magit
  :bind (("C-x g" . magit-status) :map chameleon-prefix-map
         ("g s" . magit-status)))
(use-package diff-hl)
(add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)
(global-diff-hl-mode)

;; Replace ^L with a horizontal rule
(use-package page-break-lines :diminish page-break-lines-mode)
(global-page-break-lines-mode 1)

;; Non-confusing undo
(use-package undo-tree
  :diminish undo-tree-mode
  :bind (("C-?" . undo-tree-redo)))
(global-undo-tree-mode 1)

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
  :bind ("M-L" . my/insert-markdown-link))
(add-hook 'markdown-mode-hook
          (lambda ()
            (setq-local fill-column 80)
            (auto-fill-mode)
            (wc-mode)))

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
(require 'lsp-ido)

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
(use-package go-mode
  :config (use-package godoctor):bind
  (("C-c C-r" . go-remove-unused-imports)))
(use-package company-go)
(use-package go-rename)
(add-hook 'go-mode-hook #'lsp-deferred)
(defun my-go-mode-hook ()
  "Hook for go mode.  Setup company & lsp."
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t)
  (set (make-local-variable 'company-backends)
       '(company-go)))
(add-hook 'go-mode-hook 'my-go-mode-hook)
(use-package go-eldoc
  :init (add-hook 'go-mode-hook 'go-eldoc-setup))

;; Lua Mode
(use-package lua-mode)

;; cmake
(use-package cmake-mode)

;; dumb-jump
(use-package dumb-jump)
(add-hook 'xref-backend-functions #'dumb-jump-xref-activate)

;; Whitespace cleanup
(use-package whitespace-cleanup-mode)
(global-whitespace-cleanup-mode)

;; rainbow-mode
(use-package rainbow-mode)

;; All-the-icons
;; install fonts with (all-the-icons-install-fonts)
(use-package all-the-icons)

;; doom modeline
(use-package doom-modeline
  :ensure t)
(doom-modeline-mode 1)
(setq doom-modeline-continuous-word-count-modes '(markdown-mode gfm-mode org-mode))

;; Word wrap
(use-package visual-fill-column)
(add-hook 'visual-line-mode-hook #'visual-fill-column-mode)
(setq-default visual-fill-column-center-text t)

;; Webpaste
(use-package webpaste)

;; Elpher: For Gopher and Gemini
(use-package elpher)

;; ----------------------------- END ---------------------------------

;; Snazzy theme!
(load-theme 'base16-snazzy t)

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
 '(column-number-mode t)
 '(custom-safe-themes
   '("7220c44ef252ec651491125f1d95ad555fdfdc88f872d3552766862d63454582" default))
 '(doom-modeline-default-eol-type 0)
 '(doom-modeline-enable-word-count t)
 '(doom-modeline-height 21)
 '(doom-modeline-mode t)
 '(org-link-descriptive nil)
 '(package-selected-packages
   '(cmake-mode lua-mode lsp-mode elpher webpaste visual-fill-column go-rename company-go godoctor rainbow-mode exec-path-from-shell browse-kill-ring dumb-jump go-mode company auto-complete auto-package-update no-littering editorconfig smex markdown-mode wc-mode flycheck smartparens rainbow-delimiters delight base16-theme diminish anzu use-package)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(fixed-pitch ((t (:family "Go Mono"))))
 '(font-lock-comment-delimiter-face ((t (:background "purple4" :foreground "plum"))))
 '(font-lock-comment-face ((t (:background "purple4" :foreground "plum"))))
 '(mouse ((t (:background "white"))))
 '(tooltip ((t (:inherit default :background "#34353e" :foreground "white")))))

(provide 'init)
;;; init.el ends here
