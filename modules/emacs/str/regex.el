;;; emacs/str/regex.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; General Constants
;;------------------------------------------------------------------------------

;; TODO: defconst w/ docstr when settled
(defcustom str:rx:default:separators.word
  '(any "-" "_" " ")
  "An `rx' list for what is considered 'word-separators'."
  :group 'str:group)


;;------------------------------------------------------------------------------
;; Regexes
;;------------------------------------------------------------------------------

;;------------------------------
;; Case Sensitivitiy Training!
;;------------------------------

;; <rant>
;; JESUS FUCKING WEPT CASE-FOLD-SEARCH
;; `case-fold-search' will fucking wreck your life if you don't realize it's enabled...
;; T_T
;; </rant>

(defmacro str:rx:with/case.sensitive (&rest body)
  "Run BODY forms with `case-fold-search' disabled."
  `(let ((case-fold-search nil))
     ,@body))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide:with-emacs :str 'regex)
