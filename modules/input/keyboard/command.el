;;; input/keyboard/command.el -*- lexical-binding: t; -*-

;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                            Loading Files...                            ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;                               PC LOAD LETTER                               ;;
;;                                 ──────────                                 ;;

;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

(defvar int<keyboard>:cmd:interactive? nil
  "`t' if a command is currently running interactively.")


;;------------------------------------------------------------------------------
;; Keyboard Command Helper
;;------------------------------------------------------------------------------

(defun int<keyboard>:cmd:running? ()
  "Call this in command functions."
  int<keyboard>:cmd:interactive?)


(defmacro int<keyboard>:cmd:run (&rest body)
  "Call this in command functions."
  `(let ((int<keyboard>:cmd:interactive? (called-interactively-p)))
     ,@body))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :input 'keyboard 'command)
