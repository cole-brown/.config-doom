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
(spy/require :spy 'config)


;;------------------------------------------------------------------------------
;; Config Setup.
;;------------------------------------------------------------------------------

;; Our config files for different bits of emacs/doom/packages are in the
;; config sub-dir.
(spy/config.root/set "config")


;;------------------------------------------------------------------------------
;; Cole Brown, Multi-pass.
;;------------------------------------------------------------------------------

(spy/config 'identity)

;; TODO: need to change whatever snipped doom uses for new .el files. My github
;; username is not my computer username.


;;------------------------------------------------------------------------------
;; Keybinds
;;------------------------------------------------------------------------------

(spy/config 'keybinds)


;;------------------------------------------------------------------------------
;; Look & Feel
;;------------------------------------------------------------------------------

(spy/config 'ui)


;;------------------------------------------------------------------------------
;; Org-Mode & Its Legions
;;------------------------------------------------------------------------------

;; (load! (spy/path/to-file "config/org-mode.el"))

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
  (setq yas-triggers-in-field t)

  (when-let ((dir/snippets (jerky/get :default :emacs :snippets)))
    (add-to-list 'yas-snippet-dirs dir/snippets))

  ;; TODO [2020-10-30]: Do I need this? It's probably bound somewhere else in
  ;; evil mode... But I might still not want it depending on where?
  ;; ;; Get rid of `yas-expand' binding on TAB. Cannot do this from the `:bind'
  ;; ;; section, annoyingly. And other annoyinglies as well. See:
  ;; ;;   (spydez/help/issue/visit "yasnippet" "unbind-tab.org")
  ;; ;; for more details.
  ;; (unbind-key "TAB" yas-minor-mode-map)
  ;; (unbind-key "<tab>" yas-minor-mode-map)

  ;; TODO [2020-10-30]: I use this in emacs. How else are yasnippets triggered?
  ;; I don't recall...
  ;; (yas-global-mode 1)
  )

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
