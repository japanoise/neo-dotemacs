;;; early-init.el --- Emacs pre-initialization config -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; Disable vanilla packages
(setq package-enable-at-startup nil)

;; utf-8
(set-default-coding-systems 'utf-8)

;; Remove visual clutter
(scroll-bar-mode 0)
(menu-bar-mode 0)
(tool-bar-mode 0)

;; Load path
(add-to-list 'load-path (expand-file-name "~/.emacs.d/vendor"))
(add-to-list 'load-path (expand-file-name "~/.emacs.d/lisp"))
(add-to-list 'custom-theme-load-path (expand-file-name "~/.emacs.d/lisp"))

(setq inhibit-startup-message t)

(provide 'early-init)
;;; early-init.el ends here
