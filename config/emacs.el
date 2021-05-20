;;; config/emacs.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Emacs Itself
;;------------------------------------------------------------------------------


;;------------------------------
;; Quitting
;;------------------------------

;; Don't ask me if I intended to quit.
;;   - That just trains me to hit 'y' to whatever message popped up.
;;     - Oh wait. Did I kill an unsaved buffer... again?
(setq confirm-kill-emacs nil)


;;------------------------------------------------------------------------------
;; Buffer Names
;;------------------------------------------------------------------------------

;;------------------------------
;; Modeline - Doom Modeline
;;------------------------------

(customize-set-variable 'doom-modeline-buffer-file-name-style 'buffer-name
                        (concat "Switching to `buffer-name' in order to have "
                                "everything under `uniquify'. Default is "
                                "`relative-from-project'."))
;; `relative-from-project' is good enough for the modeline, but the buffer names
;; themselves /need/ to be uniquify'd. And having different actual buffer name
;; and displayed buffer names would just ultimately be confusing.


;;------------------------------
;; Buffer Names in General - Uniquify
;;------------------------------

(use-package! uniquify
  ;;--------------------
  :config
  ;;--------------------

  ;;--------------------
  ;; customization
  ;;--------------------

  ;;---
  ;; Buffer Names
  ;;---
  ;; Set uniquify buffer/path separator to e.g. "file.txt:path/to"
  (customize-set-variable 'uniquify-buffer-name-style 'post-forward
                          "Set uniquify names to e.g. file.txt|to/path")
  (customize-set-variable 'uniquify-separator ":"
                          "I think ':' is better than '|' for `post-forward' style.")
  (customize-set-variable 'uniquify-min-dir-content 1
                          "Have at least this many dirs in buffer names.")
  (customize-set-variable 'uniquify-trailing-separator-p t
                          "Add path separator to dired buffer names.")

  ;;---
  ;; Other uniquify Settings
  ;;---
  ;; Refresh buffer names.
  (customize-set-variable 'uniquify-after-kill-buffer-p t
                          "Rename after killing uniquified. E.g. de-uniquify others as possible.")

  ;; Ignored for uniquifying.
  (customize-set-variable 'uniquify-ignore-buffers-re spy:buffer/regexp/specials
                          "Don't muck with my or Emacs' special buffers."))
