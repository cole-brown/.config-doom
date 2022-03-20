;;; config/emacs.el -*- lexical-binding: t; -*-


(imp:require :modules 'spy 'datetime 'format)


;;------------------------------------------------------------------------------
;; Emacs Itself
;;------------------------------------------------------------------------------

;;------------------------------
;; Font
;;------------------------------

;; [2022-03-10] Using "Cascadia Code PL Regular" via `font-use-system-font'.
;;   - Set in Ubuntu 20.04 via "Gnome Tweaks" app.

;; If this variable is true, emacs will use the default system font.
;;   font-use-system-font

;; ;; NOTE: If using a different font, find out answers to these questions:
;; ;;   1) Is there any way to check if a font exists before setting it?
;; ;;   2) Make this a per-system setting if not?
;; (set-face-attribute 'default
;;                     nil
;;                     :font "CaskaydiaCove Nerd Font Mono"
;;                     ;; integers -> absolute font height in 1/10th font point (pt) units.
;;                     :height 94)
;; (set-face-attribute 'default
;;                     nil
;;                     :font "CaskaydiaCove Nerd Font"
;;                     ;; integers -> absolute font height in 1/10th font point (pt) units.
;;                     :height 94)
;; (set-face-attribute 'default
;;                     nil
;;                     :font "Ubuntu Mono Nerd Font"
;;                     ;; integers -> absolute font height in 1/10th font point (pt) units.
;;                     :height 96)

;;------------------------------
;; Quitting
;;------------------------------

;; Don't ask me if I intended to quit.
;;   - That just trains me to hit 'y' to whatever message popped up.
;;     - Oh wait. Did I kill an unsaved buffer... again?
(setq confirm-kill-emacs nil)


;;------------------------------
;; Random
;;------------------------------

;; Seed the RNG.
(random t)


;;------------------------------
;; Buffer: *Messages*
;;------------------------------

;; Default is 1000.
;; Is 10,000 too much?
(customize-set-variable 'messages-buffer-max-lines
                        10000
                        "Increase the size of the *Messages* buffer.")


;;------------------------------
;; Undo
;;------------------------------
;; Ok; technically not Emacs Itself since I'm using `undo-tree' package, but...
;; it replaces Emacs undo.
;;
;; Keybinds are in "keybinds/undo-tree.el"
;;
;; (use-package! undo-tree
;;   ;;--------------------
;;   :config
;;   ;;--------------------
;;   )



;;------------------------------------------------------------------------------
;; File Time Formats
;;------------------------------------------------------------------------------

(customize-set-variable 'ls-lisp-format-time-list
                        (list
                         ;; Recent Time Format:
                         (spy:datetime/format.get 'iso-8601 'long)
                         ;; Not-Recent Time Format:
                         (spy:datetime/format.get 'iso-8601 'long))
                        (concat "Set time format for e.g. dired to a better format - ISO-8601. "
                                "Original value: '(\"%d.%m.%Y %H:%M\" \"%d.%m.%Y %H:%M\"))"))
(customize-set-variable 'ls-lisp-use-localized-time-format t
                        "Force use of `ls-lisp-format-time-list' regardless of locale.")


;;------------------------------------------------------------------------------
;; Buffer Names
;;------------------------------------------------------------------------------

(defvar sss:emacs:uniquify-buffer-name-style 'post-forward
  "Set uniquify names to e.g. 'file.txt|to/path'")


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
  (customize-set-variable 'uniquify-buffer-name-style sss:emacs:uniquify-buffer-name-style
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

;; [2021-11-29] `uniquify-buffer-name-style' is getting overwritten?
;;   - I think this broke it?
;;     > :hook (doom-init-ui . persp-mode)
;;     >> https://github.com/hlissner/doom-emacs/blame/develop/modules/ui/workspaces/config.el
;;     >> https://github.com/hlissner/doom-emacs/commit/e431dbc13860afb5b700c5f409716b28d3c2b4c0
;;   - May have to use something other that `persp-mode' if I can't get it and uniquify to behave together?
;;     + Or maybe see if I can fix `persp-mode' and do a pull request?

(spy:hook/defun-and-hooker persp-mode-hook
  '(:name "hack-fix/uniquify-buffer-name-style"
    :file ".doom.d/config/emacs.el"
    :docstr "`uniquify-buffer-name-style' is getting overwritten due to `persp-mode', maybe? Try this to fix..."
    :quiet t)

  ;; Set `uniquify-buffer-name-style' back to desired style.
  (setq uniquify-buffer-name-style sss:emacs:uniquify-buffer-name-style))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :dot-emacs 'config 'emacs)
