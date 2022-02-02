;;; config/keybinds/misc.el -*- lexical-binding: t; -*-


;;                                                               ──────────                                                               ;;
;; ╔════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                                                              KEYBINDS                                                              ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝ ;;
;;                                                               ──────────                                                               ;;


;;------------------------------------------------------------------------------------------------------------------------------------------
;; Miscellaneous Keybinds
;;------------------------------------------------------------------------------------------------------------------------------------------

;;------------------------------
;; NOTE:
;;------------------------------
;; If any of these sections get a bit big, split them out into their own file.


;;------------------------------------------------------------------------------------------------------------------------------------------
;; REMOVED Keybinds
;;------------------------------------------------------------------------------------------------------------------------------------------

;; See ":input/keyboard/layout" module.
;;   - And ".doom.d/init.el" for ':input/keyboard' module and what '+layout/___' flag is used.


;;------------------------------------------------------------------------------------------------------------------------------------------
;; Projectile
;;------------------------------------------------------------------------------------------------------------------------------------------

;; BUG: Doom bug right now: I have no projectile mode map even though this
;; exists in modules/config/default/+emacs-bindings.el:
;;   (setq persp-keymap-prefix (kbd "C-c w"))
;;   (after! projectile
;;     (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map))
;; persp just gets "C-c p"... and "C-c w" is... undefined?!
;; Oh. Those are the non-evil bindings. evil bindings are in:
;; modules/config/default/+evil-bindings.el and... just don't have projectile's find/replace in project. :|
;;   - Probably cuz it's buggy. Doesn't manage to make it through the entire project most of the time.
(when (featurep 'projectile)
  (map! :leader
        (:prefix "p" ;; add to "project" prefix
         :desc "Replace in project"          "/"  #'projectile-replace
         :desc "Replace in project (regex)"  "\\" #'projectile-replace-regexp)))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :dot-emacs 'config 'keybinds 'misc)
