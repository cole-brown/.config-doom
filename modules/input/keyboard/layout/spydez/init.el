;;; input/keyboard/layout/spydez/init.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

(defvar input//kl:spydez:keys
  '(;;-------------------------------------------------------------------------
    ;; Global Keymap
    ;;-------------------------------------------------------------------------
    (nil . (;;------------------------------
            ;; Movement
            ;;------------------------------
            (:up    . "c")
            (:down  . "t")
            (:left  . "h")
            (:right . "n")

            ;; TODO: switch to these
            ;; (:up    . ".")
            ;; (:down  . "e")
            ;; (:left  . "o")
            ;; (:right . "u")
            )))
  "Keyword -> kbd string alist for the active/desired keyboard layout.")


(defvar input//kl:spydez:functions
  '(;;--------------------------------------------------------------------------
    ;; Global Keymap
    ;;--------------------------------------------------------------------------
    (nil .
         (;;------------------------------
          ;; Movement
          ;;------------------------------
          (:up    :nvm #'evil-previous-line)
          (:down  :nvm #'evil-next-line)
          (:left  :nvm #'evil-backward-char)
          (:right :nvm #'evil-forward-char))))
  "Keymap -> Keyword -> evil-state/function alists for the active/desired keyboard
layout.")


;;------------------------------------------------------------------------------
;; Registration
;;------------------------------------------------------------------------------

(input//kl:layout/init :spydez
                       'input//kl:spydez:keys
                       'input//kl:spydez:functions)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
