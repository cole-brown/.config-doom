;;; config/evil.el -*- lexical-binding: t; -*-

;;------------------------------------------------------------------------------
;; Evil Settings of Evil
;;------------------------------------------------------------------------------

;; Set evil-snipe ('s') to more than just the same line.
(setq evil-snipe-scope 'whole-visible
      evil-snipe-spillover-scope 'whole-buffer
      evil-snipe-repeat-scope 'whole-buffer)
