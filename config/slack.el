;;; config/slack.el -*- lexical-binding: t; -*-

;; TODO: configure `alert'?
;;   - Slack uses it...
;; https://github.com/jwiegley/alert


;;------------------------------------------------------------------------------
;; `use-package': Slack
;;------------------------------------------------------------------------------
;; https://github.com/yuya373/emacs-slack

(use-package! slack
  ;;--------------------
  :commands
  ;;--------------------
  ;; Defer loading until one of these commands is used.
  (slack-start)

  ;;--------------------
  :init
  ;;--------------------
  ;; Dunno why these are in init; but they are.
  (setq slack-buffer-emojify      t  ;; If you want to enable emoji (default: nil)
        slack-prefer-current-team t)

  ;; ;;--------------------
  ;; :hook
  ;; ;;--------------------


  ;;--------------------
  :config
  ;;--------------------

  ;;--------------------
  ;; customization
  ;;--------------------
  ;; If set to `t', some functions use the current/default team without asking.
  (customize-set-variable 'slack-prefer-current-team t)

  ;;---
  ;; Keybinds
  ;;---
  ;; Keybind: See config/keybinds/slack.el

  ;;--------------------
  ;; configuration
  ;;--------------------

  ;; Run all the registration functions we've got.
  (when (boundp 'secret:slack:register-funcs)
    (dolist (func secret:slack:register-funcs)
      (funcall func))))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :dot-emacs 'config 'slack)
