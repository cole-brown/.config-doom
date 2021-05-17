;;; config/keybinds.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Useful Keys I've Found So Far...
;;------------------------------------------------------------------------------

;; s - snipe - a two char search & goto.
;; o - insert line below point and go into insert mode there.
;; e - forward to word end
;; b - backward to word begin
;; u - undo
;; - - previous line that isn't blank
;; i - insert - switch to insert mode at/before point.
;; a - append - switch to insert mode just after point.
;; f - snipe - 1 character forward search
;; s - snipe - 2 character forward search
;; ; - repeat forwards
;; , - repeat backwards
;; ] SPC - insert newline below
;; [ SPC - insert newline above
;; Y - yank - yank to end of line
;; x - delete character at point
;; X - delete character before point

;; i - insert before/at point
;; a - insert after point
;; o - insert line below point and go into insert mode there.
;;     - `evil-open-below'


;;                                  ──────────                                ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                                 KEYBINDS                               ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                  ──────────                                ;;

;;------------------------------
;; Explanation of `map!':
;;   http://github.com/hlissner/doom-emacs/issues/814#issuecomment-414051945
;;------------------------------


;; TODO: Add these?
;;   C-d for backwards delete char
;;     - no... 'X' does backwards, 'x' does forwards.
;;   movement keys for in insert mode?
;;   search, reverse search
;;
;; REMOVED!!!
;;   Redo is mean. I'm too used to Emacs's ring and using C-r for reverse search.


;;------------------------------------------------------------------------------
;; Remapping for Keyboard Layout
;;------------------------------------------------------------------------------

;; See ":input/keyboard/layout" module.


;;------------------------------------------------------------------------------
;; Projectile
;;------------------------------------------------------------------------------

;; BUG: Doom bug right now: I have no projectile mode map even though this
;; exists in modules/config/default/+emacs-bindings.el:
;;   (setq persp-keymap-prefix (kbd "C-c w"))
;;   (after! projectile
;;     (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map))
;; persp just gets "C-c p"... and "C-c w" is... undefined?!
;; Oh. Those are the non-evil bindings. evil bindings are in:
;; modules/config/default/+evil-bindings.el and... just don't have projectile's
;; find/replace in project. :|
(when (featurep 'projectile)
  (map! :leader
        (:prefix "p" ;; add to "project" prefix
         :desc "Replace in project"          "/"  #'projectile-replace
         :desc "Replace in project (regex)"  "\\" #'projectile-replace-regexp)))


