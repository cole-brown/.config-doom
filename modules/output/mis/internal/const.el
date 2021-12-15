;;; mis/internal/const.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Constants
;;------------------------------------------------------------------------------

(defconst int<mis>:const:flags
  '(:mis/nil
    :mis/error)
  "Super special mis constants. Not very special. Used to indicate mis returned
a nil (to be ignored) as opposed to mis returing a nil value from a user input
(to be used).")


;; TODO: keywords?
(defconst int<mis>:const:indent
  '((:all         . (auto
                     fixed
                     existing))
    (:unsupported . (auto))
    (:supported   . (fixed
                     existing)))
  "Super special mis constants. Not very special. Used to indicate mis returned
a nil (to be ignored) as opposed to mis returing a nil value from a user input
(to be used).")


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :mis 'internal 'const)
