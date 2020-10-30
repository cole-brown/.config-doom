;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!
;;   - You do, however, need to restart or do that command I forget to get
;;     the changes.


;;------------------------------------------------------------------------------
;; Includes
;;------------------------------------------------------------------------------

(spy/require :spy 'jerky)
(spy/require :spy 'path)


;;------------------------------------------------------------------------------
;; Hello, my name is...
;;------------------------------------------------------------------------------

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Cole Brown"
      user-mail-address "code@brown.dev")

;; TODO: need to change whatever snipped doom uses for new .el files. My github
;; username is not my computer username.


;;------------------------------------------------------------------------------
;; Keybinds
;;------------------------------------------------------------------------------

;; TODO: Add these?
;;   C-d for backwards delete char
;;   movement keys for in insert mode?
;;   search, reverse search
;;
;; TODO: REMOVE!!!
;;   Redo is mean. I'm too used to Emacs's ring and using C-r for reverse search.

;; explanation of map!
;; http://github.com/hlissner/doom-emacs/issues/814#issuecomment-414051945
(map!
 ;; :normal, :visual states of evil
 ;; (not :motion, :emacs, :insert, :operator-pending)
 :nv "h" nil  ; was: 'evil-backward-char
 :nv "j" nil  ; was: 'evil-forward-char
 :nv "k" nil  ; was: 'evil-next-line
 :nv "l" nil  ; was 'evil-previous-line

 ;; Rebind to Dvorak-friendly, WASD-style keys.
 ;; Blows up some evil/vim commands, I'm sure, but hjkl is awkward as fuck.
 :nv "h" 'evil-backward-char
 :nv "n" 'evil-forward-char
 :nv "t" 'evil-next-line
 :nv "c" 'evil-previous-line)


;;------------------------------------------------------------------------------
;; Look & Feel
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

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)
;; TODO: Switch to Zenburn once I'm comfortable with Doom...


;;------------------------------------------------------------------------------
;; Org-Mode & Its Legions
;;------------------------------------------------------------------------------

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(if-let (lily (jerky/get :default :path: :lily))
    ;; Set org to use lily dir if we have it.
    (setq org-directory lily)
  ;; Otherwise not sure... This is fine until something is figured out.
  (setq org-directory "~/org/"))


;;------------------------------------------------------------------------------
;; yasnippet
;;------------------------------------------------------------------------------

;; Do yasnippet setup after doom loads it.
(after! yasnippet
  ;; Also indent the rest if indenting non-first, non-empty lines.
  (when yas-indent-line
    (setq yas-also-auto-indent-first-line t
          yas-also-indent-empty-lines t))

  ;; Allow snippet inside of snippets. Snippet inception.
  (setq yas-triggers-in-field t))

;; Don't let emacs stuff a newline into snippet files. Sometimes I want the
;; snippet flush up with what's below it.
(add-hook! snippet-mode
  (setq require-final-newline nil))


;;------------------------------------------------------------------------------
;; Settings
;;------------------------------------------------------------------------------

(blink-cursor-mode 1)
(setq blink-cursor-interval 0.75) ; default is 0.5 seconds

;;This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)


;;---------------------------------
;; DOOM INFO

;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; DOOM INFO
;;---------------------------------
