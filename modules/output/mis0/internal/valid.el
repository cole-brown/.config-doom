;;; mis0/internal/valid.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Logic
;;------------------------------------------------------------------------------

(defun -m//or (&rest input)
  "Acts like `or' but treats `:mis0/error' and `:mis0/nil' as nil."
  (-some #'identity
         (-filter
          (lambda (x)
            (if (memq x -m//const/flags)
                nil
              x))
          input)))
;; (-m//or :mis0/nil t)
;; (-m//or :mis0/nil nil :mis0/error "hello")


;;------------------------------------------------------------------------------
;; Predicates
;;------------------------------------------------------------------------------

(defun -m//input/invalid? (input valids)
  "Returns t if INPUT is not a member of valids, or if INPUT is a special case
  like `:mis0/error'."

  (cond
   ;; Special case invalid?
   ((eq input :mis0/error)
    t)

   ;; Member of specified valids?
   ((memq input valids)
    nil)

   ;; Not a valid member, so... invalid.
   (t
    t)))
;; (-m//input/invalid? :trim '(:trim :string))


(defun -m//return/error->nil (input)
  "Converts INPUT of `:mis0/error' to nil. Leaves other inputs alone."
  (if (eq input :mis0/error)
      nil
    input))


(defun -m//return/invalid? (values &optional invalids)
  "Returns t if any VALUES are considered \"invalid\".

`:mis0/error' is always considered invalid; any other invalids (e.g. `nil',
`:mis0/nil') should be provided in INVALIDS as a list.
  - For convenience, an INVALIDS of `t' means `nil' and `:mis0/nil' are invalid.
"
  ;; Convert shortcut invalids into the nil&niller list.
  (let ((invalids (if (eq invalids t)
                      '(nil :mis0/nil)
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
                     (eq val :mis0/error)))
               values)

      ;; Else only `:mis0/error' is invalid.
      (-any? (lambda (val)
               "Check that values are not invalid."
               (eq val :mis0/error))
             values))))
;; (-m//return/invalid? '(jeff))
;; (-m//return/invalid? 'jeff)
;; (-m//return/invalid? '(:mis0/error))
;; (-m//return/invalid? :mis0/error)
;; (-m//return/invalid? '(nil :mis0/error 'jeff))
;; (-m//return/invalid? '("" 'jeff))
;; (-m//return/invalid? '(nil 'jeff) t) ;; nil is invalid
;; (-m//return/invalid? '(:mis0/nil 'jeff) t) ;; :mis0/nil is invalid


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(-m//provide 'internal 'valid)
