;;; alist/generic.el -*- lexical-binding: t; -*-

;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                         Better Alist Functions                         ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;               At least these all have 'alist' in the name...               ;;
;;                                 ──────────                                 ;;

;; Helper functions for alists that follow a convention for naming and stuff.
;; And will assist you in keeping you alist up-to-date, like it's a variable
;; or something.
;;
;; "Generic" in that it can be used to implement e.g. string alists.

(require 'seq)
(imp:require :alist 'internal)


;;------------------------------------------------------------------------------
;; Alist Types
;;------------------------------------------------------------------------------


(defconst int<alist>:types:preset
  ;;------------------------------
  ;; Alist Type -> Equality Function
  ;;------------------------------
  '(;;---
    ;; Default/Generic Alists
    ;;---
    ;; Emacs' alist functions default to `eq' when a test func is not supplied
    ;; or is `nil', so allow that defaulting to happen.
    ;;
    (:type/default . nil)
    (nil           . nil)

    ;;---
    ;; Special Types
    ;;---
    (:type/string . string=)

    ;;---
    ;; Operators
    ;;---
    (:op/eq      . eq)
    (:op/equal   . equal)
    (:op/eql     . eql)
    (:op/=       . =)
    (:op/string= . string=))
  "Alist of our preset alist type keywords to equality function.

For customizing, register with `alist:type:register', which will use
`int<alist>:types:registered'.

NOTE: Use a default value when getting values so you know if you found the
value of `:type/default' vs didn't find anything!")


(defvar int<alist>:types:registered '()
  "Alist of user registered alist type keywords to equality function.

Register with `alist:type:register', which will not allow any of the keys
in `int<alist>:types:preset'.")


(defun int<alist>:type:testfn (type)
  "Get the equality test function for the alist TYPE.

E.g. `:string' returns `string='."
  ;;------------------------------
  ;; Translate TYPE to an equality function.
  ;;------------------------------
  ;; Need to have a "found" flag because the equality test can be `nil' for the default types.
  (let (equality-function
        found)
    ;; Did we get a function passed in? Use that function.
    (cond ((functionp type)
           (setq equality-function type
                 found t))

          ;; Use a preset if found there.
          ((let ((func (alist-get type int<alist>:types:preset :does-not-exist)))
             (if (not (eq func :does-not-exist))
                 (setq equality-function func
                       found t)
               nil)))

          ;; And lowest priority: user-registered types.
          (t
           (let ((func (alist-get type int<alist>:types:registered :does-not-exist)))
             (if (not (eq func :does-not-exist))
                 (setq equality-function func
                       found t)
               nil))))

    ;;------------------------------
    ;; Return function or error.
    ;;------------------------------
    (if found
        ;; Can be nil; that's ok and means "use Emacs' default alist equality func."
        equality-function
      (int<alist>:error "int<alist>:type:testfn"
                        '(:newlines
                          "Alist type '%S' is unknown! Register it with `(alist:type:register %S %S)'?"
                          "Known types:"
                          "  Presets:"
                          "%s"
                          "  Registered:"
                          "%s")
                        type
                        type
                        "equality-function"
                        (pp-to-string int<alist>:types:preset)
                        (if int<alist>:types:registered
                            (pp-to-string int<alist>:types:registered)
                          "(none)")))))
;; (int<alist>:type:testfn #'ignore)
;; (int<alist>:type:testfn :type/string)
;; (int<alist>:type:testfn :type/default)
;; (int<alist>:type:testfn nil)
;; (int<alist>:type:testfn :dne)


(defun alist:type:register (type-keyword equality-function)
  "Register/update alist type TYPE-KEYWORD to use EQUALITY-FUNCTION for
finding alist entries."
  ;;------------------------------
  ;; Error checks.
  ;;------------------------------
  (cond ((not (keywordp type-keyword))
         (int<alist>:error "alist:type:register"
                           '("TYPE-KEYWORD must be a keyword! "
                             "Got type '%S' for `%S'.")
                           type-keyword))

        ((assoc type-keyword int<alist>:types:preset)
         (int<alist>:error "alist:type:register"
                           '("Alist type '%S' is pre-defined! "
                             "Register with a different keyword. "
                             "Preset types: %s")
                           type-keyword
                           int<alist>:types:preset))

        ((not (functionp equality-function))
         (int<alist>:error "alist:type:register"
                           '("EQUALITY-FUNCTION '%S' must be a function! "
                             "Got type: %S")
                           equality-function
                           (type-of equality-function)))

        ;;------------------------------
        ;; Register user type.
        ;;------------------------------
        (t
         (setf (alist-get type-keyword int<alist>:types:registered)
               equality-function))))
;; (alist:type:register #'ignore :default)
;; (alist:type:register :type/default #'ignore)
;; (alist:type:register :jeff :this-is-incorrect)
;; (alist:type:register :keyword (lambda (a b) (and (keywordp a) (keywordp b) (eq a b))))
;; (int<alist>:type:testfn :keyword)


;; TODO: 'Valid key' function for type? Could have a 'verify' function then...


;;------------------------------------------------------------------------------
;; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;;                'Generic' Functions - Funcs with TYPE param.
;; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;;------------------------------------------------------------------------------

;;------------------------------------------------------------------------------
;; Getters
;;------------------------------------------------------------------------------

(defun alist:generic:get/value (key alist &optional type default)
  "Get cdr of KEY's entry in ALIST.

If TYPE is non-nil, get & use the proper equality function for TYPE."
  (alist-get key
             alist
             default
             nil
             (int<alist>:type:testfn type)))


(defun alist:generic:get/pair (key alist &optional type)
  "Get full assoc/entry of KEY in ALIST.

If TYPE is non-nil, get & use the proper equality function for TYPE."
  (assoc key
         alist
         (int<alist>:type:testfn type)))


;;------------------------------------------------------------------------------
;; Setters
;;------------------------------------------------------------------------------

(defun int<alist>:generic:update/helper (key value alist &optional type)
  "Set/overwrite an entry in the ALIST. Return the new alist.

If VALUE is nil, it will be set as KEY's value. Use
`alist:generic:delete' if you want to remove it.

If TYPE is non-nil, get & use the proper equality function for TYPE.

Returns either a new alist, which isn't ALIST, or the updated alist which may
or may not be ALIST."
  (if (null alist)
      ;; Create a new alist and return it.
      (list (cons key value))

    ;; `setf' creates a new alist sometimes, so buyer beware!
    (setf (alist-get key
                     alist
                     nil
                     nil
                     (int<alist>:type:testfn type))
          value)
    alist))
;; (setq test-alist nil)
;; (setq test-alist (int<alist>:generic:update/helper :k :v test-alist))
;; (int<alist>:generic:update/helper :k2 :v2 test-alist)
;; (int<alist>:generic:update/helper :k2 :v2.0 test-alist)
;; test-alist


(defmacro alist:generic:update (key value alist &optional type)
  "Set/overwrite an entry in the ALIST.

SYMBOL/ALIST should be a (quoted) symbol so that this can update it directly.

If TYPE is non-nil, get & use the proper equality function for TYPE.

If VALUE is nil, it will be set as KEY's value. Use
`alist:generic:delete' if you want to remove it.

Returns ALIST."
  ;; Evaluate inputs only once.*
  `(let ((int<alist>:macro:key   ,key)
         (int<alist>:macro:value ,value)
         (int<alist>:macro:alist ,alist)
         (int<alist>:macro:type  ,type))
     (cond ((listp int<alist>:macro:alist)
            ;; Overwrite the input symbol value with the updated alist value that `int<alist>:macro:alist' holds.
            (setq ,alist ;; *Have to re-eval ALIST here to actually set it for the caller.
                  (int<alist>:generic:update/helper int<alist>:macro:key
                                                    int<alist>:macro:value
                                                    int<alist>:macro:alist
                                                    int<alist>:macro:type)))

           ((symbolp int<alist>:macro:alist)
            ;; Set our updated alist to the symbol that `int<alist>:macro:alist' holds.
            (set int<alist>:macro:alist
                 (int<alist>:generic:update/helper int<alist>:macro:key
                                                   int<alist>:macro:value
                                                   ;;
                                                   (eval int<alist>:macro:alist))))

           (t
            (int<alist>:error "alist:generic:update"
                              "Unable to update alist with type %S: %S"
                              (type-of int<alist>:macro:alist) int<alist>:macro:alist)))))
;; A global variable:
;;   (setq test-alist nil)
;;   (alist:generic:update :k :v test-alist)
;;   test-alist
;;   (alist:generic:update :k :v test-alist)
;;   (alist:generic:update :k2 :v2 test-alist)
;;   (alist:generic:update :k2 :v2.0 test-alist)
;;   test-alist
;;
;; A scoped variable:
;;   (let (test-alist/let)
;;     (alist:generic:update :k :v test-alist/let)
;;     (alist:generic:update :k2 :v2 test-alist/let)
;;     (alist:generic:update :k2 :v2.0 test-alist/let)
;;     test-alist/let)
;;
;; A +function+ macro call in the macro call:
;;   - Needs `test<alist/alist>:alist:get' and `test<alist/alist>:alist/nil' from 'test/alist.el'.
;; (setq test<alist/alist>:alist/nil nil)
;; test<alist/alist>:alist/nil
;; (alist:generic:update :k :v
;;               (test<alist/alist>:alist:get :global/nil))
;; test<alist/alist>:alist/nil


(defun int<alist>:generic:delete/helper (key alist type)
  "Removes KEY from ALIST.

If TYPE is non-nil, get & use the proper equality function for TYPE.

Returns alist without the key."
  ;; If it's null, no need to do anything.
  (unless (null alist)
    (setf (alist-get key
                     alist
                     nil
                     'remove
                     (int<alist>:type:testfn type))
          nil))

  ;; Return the alist.
  alist)


(defmacro alist:generic:delete (key alist &optional type)
  "Removes KEY from ALIST.

If TYPE is non-nil, get & use the proper equality function for TYPE.

Returns ALIST."
  ;; Evaluate inputs only once.*
  `(let ((int<alist>:macro:alist ,alist)
         (int<alist>:macro:key   ,key)
         (int<alist>:macro:type  ,type))
     (cond ((listp int<alist>:macro:alist)
            (setq ,alist ;; *Have to re-eval ALIST here to actually set it for the caller.
                  (int<alist>:generic:delete/helper int<alist>:macro:key
                                                    int<alist>:macro:alist
                                                    int<alist>:macro:type)))

           ((symbolp int<alist>:macro:alist)
            (set int<alist>:macro:alist
                 (int<alist>:generic:delete/helper int<alist>:macro:key
                                                   (eval int<alist>:macro:alist)
                                                   int<alist>:macro:type)))

           (t
            (int<alist>:error "alist:generic:delete"
                              "Unable to delete key from alist (type-of %S)%s: %S"
                              (type-of int<alist>:macro:alist)
                              (if int<alist>:macro:type
                                  (format " with TYPE %S" int<alist>:macro:type)
                                "")
                              int<alist>:macro:alist)))))
;; (setq test-alist '((:k . :value) (:k2 . :value2) (:jeff . :jeff)))
;; (alist:generic:delete :k test-alist)
;; test-alist
;; (alist:generic:update :k :v test-alist)
;; test-alist
;; (alist:generic:delete :k2 test-alist)
;; test-alist
;; (alist:generic:delete :k test-alist)
;; test-alist
;; (alist:generic:delete :jeff test-alist)
;; test-alist


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :alist 'generic)
