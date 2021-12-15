;;; mis/internal/valid.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Logic
;;------------------------------------------------------------------------------

(defun int<mis>:or (&rest input)
  "Acts like `or' but treats `:mis/error' and `:mis/nil' as nil."
  (-some #'identity
         (-filter
          (lambda (x)
            (if (memq x int<mis>:const/flags)
                nil
              x))
          input)))
;; (int<mis>:or :mis/nil t)
;; (int<mis>:or :mis/nil nil :mis/error "hello")


;;------------------------------------------------------------------------------
;; Predicates
;;------------------------------------------------------------------------------

(defun int<mis>:input/invalid? (input valids)
  "Returns t if INPUT is not a member of valids, or if INPUT is a special case
  like `:mis/error'."

  (cond
   ;; Special case invalid?
   ((eq input :mis/error)
    t)

   ;; Member of specified valids?
   ((memq input valids)
    nil)

   ;; Not a valid member, so... invalid.
   (t
    t)))
;; (int<mis>:input/invalid? :trim '(:trim :string))


(defun int<mis>:return/error->nil (input)
  "Converts INPUT of `:mis/error' to nil. Leaves other inputs alone."
  (if (eq input :mis/error)
      nil
    input))


(defun int<mis>:return/invalid? (values &optional invalids)
  "Returns t if any VALUES are considered \"invalid\".

`:mis/error' is always considered invalid; any other invalids (e.g. `nil',
`:mis/nil') should be provided in INVALIDS as a list.
  - For convenience, an INVALIDS of `t' means `nil' and `:mis/nil' are invalid.
"
  ;; Convert shortcut invalids into the nil&niller list.
  (let ((invalids (if (eq invalids t)
                      '(nil :mis/nil)
                    invalids))
        ;; Allow for either a list or a value by turning the latter into a list.
        ;; Watch out for the friendly neighborhood list/value Schrodenger's nil.
        (values (if (and (listp values)
                         (not (eq values nil)))
                    values
                  (list values))))
    (if invalids
        ;; If we have extra invalid values, we got to check for too...
        (-any? (lambda (val)
                 "Check for values that are invalid."
                 (or (memq val invalids)
                     (eq val :mis/error)))
               values)

      ;; Else only `:mis/error' is invalid.
      (-any? (lambda (val)
               "Check that values are not invalid."
               (eq val :mis/error))
             values))))
;; (int<mis>:return/invalid? '(jeff))
;; (int<mis>:return/invalid? 'jeff)
;; (int<mis>:return/invalid? '(:mis/error))
;; (int<mis>:return/invalid? :mis/error)
;; (int<mis>:return/invalid? '(nil :mis/error 'jeff))
;; (int<mis>:return/invalid? '("" 'jeff))
;; (int<mis>:return/invalid? '(nil 'jeff) t) ;; nil is invalid
;; (int<mis>:return/invalid? '(:mis/nil 'jeff) t) ;; :mis/nil is invalid
;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :mis 'internal 'valid)
