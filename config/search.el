;;; config/search.el -*- lexical-binding: t; -*-

;;------------------------------------------------------------------------------
;; ripgrep & deadgrep - grep faster
;;------------------------------------------------------------------------------

;;------------------------------
;; ripgrep
;;------------------------------
;; https://github.com/BurntSushi/ripgrep
;;
;; This needs installed on the computer separately from Emacs.
;;
;;-----
;; System home/2017/desk::02d29a-8bdef1:
;;   Installed:
;;     binary: ripgrep-11.0.2-x86_64-pc-windows-gnu
;;     date:   [2019-08-30]
;;   Installed GNU version as MSVC version needs DLLs or something so meh.
;;-----
;; Other systems:
;;   Installed via package manager.
;;-----
;;
;;   "ripgrep is a line-oriented search tool that recursively searches your
;; current directory for a regex pattern. By default, ripgrep will respect your
;; .gitignore and automatically skip hidden files/directories and binary files.
;; ripgrep has first class support on Windows, macOS and Linux, with binary
;; downloads available for every release. ripgrep is similar to other popular
;; search tools like The Silver Searcher, ack and grep."


;;------------------------------
;; deadgrep
;;------------------------------
;; https://github.com/Wilfred/deadgrep
;; "Deadgrep is the fast, beautiful text search that your Emacs deserves."
(use-package deadgrep
  :demand t


  ;;---
  ;; Old Vanilla Emacs keybinds.
  ;;---
  ;; Doom Emacs keybinds in config/keybinds/search.el.

  ;; ;;---
  ;; :bind ;; global
  ;; ;;---
  ;; ;; Try binding to F5?
  ;; ;; Maybe replace projectile search or something if don't like F5?
  ;; (("<f5>" . #'deadgrep))

  ;; ;;---
  ;; :bind ;; deadgrep-mode-map
  ;; ;;---
  ;; (:map deadgrep-mode-map
  ;;       ;; kill-or-quit instead of original quit-or-kill?
  ;;       ("q" . kill-this-buffer))

  ;; ;;---
  ;; :bind ;; projectile-command-map
  ;; ;;---
  ;; (:map projectile-command-map
  ;;       ;; Also map into the projectile search group
  ;;       ;; (projectile-grep, projectile-deadgrep, et al):
  ;;       ("s d" . deadgrep))

  ;;---
  ;; Project Root Overrides
  ;;---
  ;; Search per-comp configs for `deadgrep-project-root' to find what's set.
  ;;   - `deadgrep-project-root-overrides'
  ;;   - `deadgrep-project-root-function'
  )
