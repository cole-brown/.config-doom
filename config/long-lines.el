;;; config/long-lines.el -*- lexical-binding: t; -*-

;;------------------------------------------------------------------------------
;; So-Long Mode for Long Lines
;;------------------------------------------------------------------------------

;; Emacs because frozen molasses on files with very long lines.
;;   - 'So-Long Mode' tries to fix this.

;; [2021-07-20]: `global-so-long-mode' is set to `t' - by Doom or Emacs (dunno which).
;;   - But doesn't seem to be helping on gigantic 750 kb JSON files, so...
;;     Tweak it?
;;     + Oh - probably the default `so-long-max-lines' of 5 was just too small.
(use-package! so-long

  ;; ;;--------------------
  ;; :init
  ;; ;;--------------------


  ;; ;;--------------------
  ;; :hook
  ;; ;;--------------------
  ;;
  ;; ;; Connect my hooks up.
  ;; ((so-long . sss:hook/so-long/some-hook-func))


  ;;--------------------
  :config
  ;;--------------------

  ;;--------------------
  ;; customization
  ;;--------------------

  ;;--------------------
  ;; configuration
  ;;--------------------

  ;; `global-so-long-mode' is set to `t' - by Doom or Emacs (dunno which).
  ;; (global-so-long-mode 1)

  ;; Basic settings.
  ;; Currently `so-long-mode'.
  ;; (setq so-long-action 'so-long-minor-mode)
  ;; Currently 400.
  (setq so-long-threshold 1000)
  ;; Default of 5 is not enough. Is 100 enough?
  (setq so-long-max-lines 100)

  ;; Additional target major modes to trigger for.
  (mapc (apply-partially #'add-to-list 'so-long-target-modes)
        '(sgml-mode nxml-mode json-mode))

  ;; Additional buffer-local minor modes to disable.
  (mapc (apply-partially #'add-to-list 'so-long-minor-modes)
        '(diff-hl-mode diff-hl-amend-mode diff-hl-flydiff-mode))

  ;; Additional variables to override.
  (mapc (apply-partially #'add-to-list 'so-long-variable-overrides)
        '((show-trailing-whitespace . nil)
          (truncate-lines . nil))))
