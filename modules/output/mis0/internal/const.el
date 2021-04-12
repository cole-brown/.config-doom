;;; mis0/internal/const.el -*- lexical-binding: t; -*-


(defconst -m//const/flags
  '(:mis0/nil
    :mis0/error)
  "Super special mis0 constants. Not very special. Used to indicate mis0 returned
a nil (to be ignored) as opposed to mis0 returing a nil value from a user input
(to be used).")


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(-m//provide 'internal 'const)
