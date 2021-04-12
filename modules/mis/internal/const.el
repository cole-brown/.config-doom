;;; mis/internal/const.el -*- lexical-binding: t; -*-


(defconst -m//const/flags
  '(:mis/nil
    :mis/error)
  "Super special mis constants. Not very special. Used to indicate mis returned
a nil (to be ignored) as opposed to mis returing a nil value from a user input
(to be used).")


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(-m//provide 'internal 'const)
