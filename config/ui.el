;;; config/ui.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Fonts
;;------------------------------------------------------------------------------

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))
;;(setq doom-font (font-spec :family "Cascadia Code PL" :size 12 :weight 'semi-light))


;;------------------------------------------------------------------------------
;; Cursor
;;------------------------------------------------------------------------------

(blink-cursor-mode 1)
(setq blink-cursor-interval 0.75) ; default is 0.5 seconds


;;------------------------------------------------------------------------------
;; Lines
;;------------------------------------------------------------------------------

;;This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)


;;------------------------------------------------------------------------------
;; Whitespace
;;------------------------------------------------------------------------------

;; See 'whitespace.el'.


;;------------------------------------------------------------------------------
;; Theme
;;------------------------------------------------------------------------------

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;; (setq doom-theme 'doom-one)

;; This is the best theme:
(setq doom-theme 'doom-zenburn)


;; Zenburn customizations:
