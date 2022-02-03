;;; config/spy/join.el -*- lexical-binding: t; -*-


(require 'hydra)


;;------------------------------------------------------------------------------
;; Line Joining Hydra
;;------------------------------------------------------------------------------

(defhydra hydra:join-lines (:color red  ;; Allow & quit on non-hydra-heads.
                            :hint none) ;; no hint - just docstr
  "
Join lines.
_o_: ?o?     _c_: ?c?
_O_: ?O?     _t_: ?t?
"
  ;;------------------------------
  ;; Emacs Functions
  ;;------------------------------
  ("c" #'join-line "↑ `join-line' (Trim)")
  ("t" (lambda () (interactive) (join-line 1)) "↓ `join-line' (Trim)")

  ;;------------------------------
  ;; Evil Functions
  ;;------------------------------
  ("o" #'evil-join (format "%-50s" "↓ `evil-join' (Smart Comments): (evil: J)"))
  ("O" #'evil-join-whitespace (format "%-50s" "↓ `evil-join-whitespace' (As-Is): (evil: g J)")))
;; ↑: Above line.
;; (hydra:join/lines/body)
;; ↓: Below line.
;; ↓: Another line.


(defun spy:join/lines ()
  "`spy' namespaced function to get into the box drawing hydra.
"
  (interactive)
  (call-interactively #'hydra:join-lines/body))


;;------------------------------------------------------------------------------
;; The End
;;------------------------------------------------------------------------------
(imp:provide :dot-emacs 'config 'spy 'join)
