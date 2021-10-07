;;; input/keyboard/registrars.el -*- lexical-binding: t; -*-

;;------------------------------------------------------------------------------
;; Registrars for Keybinds
;;------------------------------------------------------------------------------
;; Currently 2 registrars:
;;   1. active (default)
;;   2. debug  (temp/debugging)
;;------------------------------

;;------------------------------------------------------------------------------
;; Common: Constants & Variables
;;------------------------------------------------------------------------------

;;------------------------------
;; General Consts/Vars
;;------------------------------

;; TODO: Move elsewhere.
(defconst int<keyboard>:layout:types '((:common . "common")
                                       (:emacs  . "emacs")
                                       (:evil   . "evil"))
  "Allowed types for a few function args, alist keys.

Types are:
  :common - Any keybinds that exist in both evil-mode and standard Emacs.
  :emacs  - Any Emacs-only keybinds (non-evil-mode).
  :evil   - Any Evil-only keybinds.")
;; int<keyboard>:layout:types
;; (makunbound 'int<keyboard>:layout:types)


;; TODO: Are these in correct order?
;; TODO: Should we have a :finished state? Is one of these already a finished state?
(defconst int<keyboard>:layout:registering/states
  '(nil
    :init
    :config
    :active
    :inactive
    :apply)
  "All valid values for `(input//kl:registrar:get registrar :state)'.")


(defconst int<keyboard>:registration:valid
  ;;    '(state     . (list of valid states to transition from))
  (list '(nil       . (nil))
        '(:init     . (nil :apply))
        '(:config   . (:init))
        '(:active   . (:config))
        '(:inactive . (nil :init :config))

        ;;---
        ;; Valid to enter from (almost) any state:
        ;;---
        (cons :apply  int<keyboard>:layout:registering/states))
  "Alist of all valid values for moving `(input//kl:registrar:get registrar :state)'
to a certain state.")


;;------------------------------------------------------------------------------
;; Active/Default: Permanent Registrar
;;------------------------------------------------------------------------------

(defvar int<keyboard>:registrar<active>:keybinds nil
  "The keybinds for the active layout.

Saved in `input:keyboard/layout:set' during module config; set/activated in
`int<keyboard>:layout:activate' during module finalization.

This is an alist with 3 expected entries:
  :common - Any keybinds that exist in both evil-mode and standard Emacs.
  :emacs  - Any Emacs-only keybinds (non-evil-mode).
  :evil   - Any Evil-only keybinds.

Each alist key's value should be a list of args for
`input:keyboard/layout:map!'.")
;; (pp-macroexpand-expression int<keyboard>:registrar<active>:keybinds)


(defvar int<keyboard>:registrar<active>:unbinds nil
  "The unbindings for the active layout.

Saved in `input:keyboard/layout:set' during module config; set/activated in
`int<keyboard>:layout:activate' during module finalization.

This is an alist with 3 expected entries:
  :common - Any keybinds that should just be unset.
  :emacs  - Any Emacs-only unbinds.
  :evil   - Any Evil-only unbinds.

Each alist key's value should be a list of args for
`input:keyboard/layout:map!'.")


(defvar int<keyboard>:registrar<active>:registering nil
  "The state of registration/initialization.

Valid States (see `int<keyboard>:layout:registering/states'
and `int<keyboard>:registration:valid'):
  nil - Nothing has happened yet.
  :init - Initialization happened.
  :config - Configuration happened.
  :active - Activation/finalization happened w/ valid keybinds.
  :inactive - Activation/finalization happened w/o valid keybinds.
  :apply - Someone called `keyboard:layout:apply' and it's about to let init do its thing.")


;;------------------------------------------------------------------------------
;; Testing/Debugging: Temporary Registrar
;;------------------------------------------------------------------------------

(defvar int<keyboard>:registrar<debug>:keybinds nil
  "The keybinds for the active layout.

Saved in `input:keyboard/layout:set' during module config; set/activated in
`int<keyboard>:layout:activate' during module finalization.

This is an alist with 3 expected entries:
  :common - Any keybinds that exist in both evil-mode and standard Emacs.
  :emacs  - Any Emacs-only keybinds (non-evil-mode).
  :evil   - Any Evil-only keybinds.

Each alist key's value should be a list of args for
`input:keyboard/layout:map!'.")
;; (pp-macroexpand-expression input//kl:layout/temp:keybinds)


(defvar int<keyboard>:registrar<debug>:unbinds nil
  "The unbindings for the active layout.

Saved in `input:keyboard/layout:set' during module config; set/activated in
`int<keyboard>:layout:activate' during module finalization.

This is an alist with 3 expected entries:
  :common - Any keybinds that should just be unset.
  :emacs  - Any Emacs-only unbinds.
  :evil   - Any Evil-only unbinds.

Each alist key's value should be a list of args for
`input:keyboard/layout:map!'.")


(defvar int<keyboard>:registrar<debug>:registering nil
  "The state of registration/initialization.

Valid States (see `int<keyboard>:layout:registering/states'
and `int<keyboard>:registration:valid'):
  nil - Nothing has happened yet.
  :init - Initialization happened.
  :config - Configuration happened.
  :active - Activation/finalization happened w/ valid keybinds.
  :inactive - Activation/finalization happened w/o valid keybinds.
  :apply - Someone called `keyboard:layout:apply' and it's about to let init do its thing.")


;;------------------------------------------------------------------------------
;; Registrars
;;------------------------------------------------------------------------------

(defconst input//kl:registrars
  '((:actual . ((:keybinds . int<keyboard>:registrar<active>:keybinds)
                (:unbinds  . int<keyboard>:registrar<active>:unbinds)
                (:state    . int<keyboard>:registrar<active>:registering)))

    (:debug . ((:keybinds . int<keyboard>:registrar<debug>:keybinds)
               (:unbinds  . int<keyboard>:registrar<debug>:unbinds)
               (:state    . int<keyboard>:registrar<debug>:registering))))
  "Alist of Registrar Type -> Var Keyword -> Actual Var.")
;; (alist-get :state (alist-get :actual input//kl:registrars))


(defun int<keyboard>:registrar:valid? (registrar-keyword)
  "Returns t if REGISTRAR-KEYWORD is valid. Else signals error."
  (if (alist-get registrar input//kl:registrars)
      registrar-keyword

    ;; Invalid registrar symbol!
    (error (int<keyboard>:error:format "int<keyboard>:registrar:valid?"
                                       "REGISTRAR is not a valid registrar keyword. "
                                       "Must be one of: %S; "
                                       "got: %S")
           (mapcar (lambda (registrar-assoc)
                     "Get registrar keywords for error message."
                     (car registrar-assoc))
                   input//kl:registrars)
           registrar)))


;;------------------------------------------------------------------------------
;; Registrar Getters
;;------------------------------------------------------------------------------
;; Get vars based on registrar desired.
;;------------------------------

(defun int<keyboard>:registrar:get (registrar keyword)
  "Get a registrar variable's value based on REGISTRAR type and
variable identifier KEYWORD.

REGISTRAR should be a valid keyword from `input//kl:registrar/types'."
  ;; Get registrar's alist of stuff; error if invalid REGISTRAR.
  (if-let ((registrar.vars (alist-get registrar input//kl:registrars)))
      ;; Return the var or signal error if we didn't find anything.
      (if-let ((symbol (alist-get keyword registrar.vars)))
          ;; Return the symbol's value.
          (symbol-value symbol)

        ;; Invalid registrar symbol!
        (error (int<keyboard>:error:format "int<keyboard>:registrar:get"
                                           "KEYWORD is not a valid variable keyword. "
                                           "Must be one of: %S; "
                                           "got: %S")
               (mapcar (lambda (vars-assoc)
                         "Get registrar keywords for error message."
                         (car vars-assoc))
                       registrar.vars)
               keyword))

    ;; Invalid registrar symbol!
    (error (int<keyboard>:error:format "int<keyboard>:registrar:get"
                                       "REGISTRAR is not a valid registrar keyword. "
                                       "Must be one of: %S; "
                                       "got: %S")
           (mapcar (lambda (registrar-assoc)
                     "Get registrar keywords for error message."
                     (car registrar-assoc))
                   input//kl:registrars)
           registrar)))
;; (int<keyboard>:registrar:get :actual :state)
;; (int<keyboard>:registrar:get :debug :state)



(defun int<keyboard>:registrar:set (registrar keyword value)
  "Set a registrar variable's value to VALUE based on REGISTRAR type and
variable identifier KEYWORD.

REGISTRAR should be a valid keyword from `input//kl:registrar/types'.

NOTE: Does not validate/error check VALUE."
  ;; Get registrar's alist of stuff; error if invalid REGISTRAR.
  (if-let ((registrar.vars (alist-get registrar input//kl:registrars)))
      ;; Return the var or signal error if we didn't find anything.
      (if-let ((symbol (alist-get keyword registrar.vars)))
          ;; Set the symbol to the new value.
          (set symbol value)

        ;; Invalid registrar symbol!
        (error (int<keyboard>:error:format "int<keyboard>:registrar:set"
                                           "KEYWORD is not a valid variable keyword. "
                                           "Must be one of: %S; "
                                           "got: %S")
               (mapcar (lambda (vars-assoc)
                         "Get registrar keywords for error message."
                         (car vars-assoc))
                       registrar.vars)
               keyword))

    ;; Invalid registrar symbol!
    (error (int<keyboard>:error:format "int<keyboard>:registrar:set"
                                       "REGISTRAR is not a valid registrar keyword. "
                                       "Must be one of: %S; "
                                       "got: %S")
           (mapcar (lambda (registrar-assoc)
                     "Get registrar keywords for error message."
                     (car registrar-assoc))
                   input//kl:registrars)
           registrar)))
;; (int<keyboard>:registrar:set :debug :state :foo)


;;------------------------------------------------------------------------------
;; The End
;;------------------------------------------------------------------------------
(imp:provide :input 'keyboard 'registrars)
