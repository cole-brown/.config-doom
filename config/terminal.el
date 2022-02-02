;;; config/terminal.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; VTerm
;;------------------------------------------------------------------------------

;; VTerm doesn't play well with Windows.
(unless (memq system-type '(cygwin windows-nt ms-dos))
  (use-package! vterm

    ;;--------------------
    :config
    ;;--------------------

    ;;--------------------
    ;; customization: org-mode
    ;;--------------------

    ;; Doom says to set this in order to use libvterm you installed on your system...
    ;; ...but this variable doesn't exist anywhere in vterm or Doom, except for
    ;; the doc that mentions it.
    ;;   - https://github.com/hlissner/doom-emacs/blob/develop/modules/term/vterm/README.org#compilation-tools-for-vterm-moduleso
    (setq vterm-module-cmake-args "-DUSE_SYSTEM_LIBVTERM=yes")

    ;;--------------------
    ;; configuration: org-mode
    ;;--------------------

    ))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :dot-emacs 'config 'terminal)
