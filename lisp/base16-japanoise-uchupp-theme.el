;; base16-japanoise-uchupp-theme.el -- A base16 colorscheme

;;; Commentary:
;; Base16: (https://github.com/tinted-theming/home)

;;; Authors:
;; Scheme: japanoise & NetOperator Wibby
;; Template: Kaleb Elwert <belak@coded.io>

;;; Code:

(require 'base16-theme)

(defvar base16-japanoise-uchupp-theme-colors
  '(:base00 "#080a0d"
    :base01 "#202225"
    :base02 "#383b3d"
    :base03 "#828386"
    :base04 "#b2b4b6"
    :base05 "#e3e4e6"
    :base06 "#f0f0f2"
    :base07 "#fdfdfd"
    :base08 "#ea3c65"
    :base09 "#ff9f5b"
    :base0A "#fedf7b"
    :base0B "#64d970"
    :base0C "#25d2d2"
    :base0D "#3984f2"
    :base0E "#ff6ac1"
    :base0F "#915ad3")
  "All colors for Base16 uchū++ are defined here.")

;; Define the theme
(deftheme base16-japanoise-uchupp)

;; Add all the faces to the theme
(base16-theme-define 'base16-japanoise-uchupp base16-japanoise-uchupp-theme-colors)

;; Mark the theme as provided
(provide-theme 'base16-japanoise-uchupp)

(provide 'base16-japanoise-uchupp-theme)

;;; base16-japanoise-uchupp-theme.el ends here
