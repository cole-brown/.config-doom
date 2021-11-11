;;; input/keyboard/registrars.el -*- lexical-binding: t; -*-

;;------------------------------------------------------------------------------
;; Registrars for Keybinds
;;------------------------------------------------------------------------------
;; Currently 2 registrars:
;;   1. actual (default)
;;   2. debug  (temporary/testing/debugging)
;;------------------------------

;;------------------------------------------------------------------------------
;; Common: Constants & Variables
;;------------------------------------------------------------------------------

;;------------------------------
;; General Consts/Vars
;;------------------------------

;; TODO: Are these in correct order?
;; TODO: Should we have a :finished state? Is one of these already a finished state?
(defconst int<keyboard>:registration:states
  '(nil
    :init
    :config
    :active
    :inactive
    :apply)
  "All valid values for `(int<keyboard>:registrar:get registrar :state)'.")


(defconst int<keyboard>:registration:state/transitions
  ;;    '(state     . (list of valid states to transition from))
  (list '(nil       . (nil))
        '(:init     . (nil :apply))
        '(:config   . (:init))
        '(:active   . (:config))
        '(:inactive . (nil :init :config))

        ;;---
        ;; Valid to enter from (almost) any state:
        ;;---
        (cons :apply  int<keyboard>:registration:states))
  "Alist of all valid values for moving `(int<keyboard>:registrar:get registrar :state)'
to a certain state.")


(defun int<keyboard>:registration:state:valid? (desired)
  "Get the list of valid values current registration state can be for
entering DESIRED state."
  (alist-get desired int<keyboard>:registration:state/transitions))


(defun int<keyboard>:registration:valid/action? (keyword)
  "Valid actions are `:bind', `:unbind', and `:full'.

Returns nil if not valid."
  (memq keyword '(:bind :unbind :full)))
;; (int<keyboard>:registration:valid/action? :bind)
;; (int<keyboard>:registration:valid/action? :set)
;; (int<keyboard>:registration:valid/action? :jeff)
;; (int<keyboard>:registration:valid/action? :full)


(defun int<keyboard>:registration:state/transition:valid? (registrar state/to &optional no-error)
  "Returns non-nil if transition of current registration state to new STATE/TO
state is valid/allowed."
  (let ((func/name "int<keyboard>:registration:state/transition:valid?")
        (debug.tags '(:registering))
        (state/current (int<keyboard>:registrar:get registrar :state)))

    ;;------------------------------
    ;; Invalid Cases:
    ;;------------------------------
    (cond ((not (memq state/current
                      int<keyboard>:registration:states))
           (int<keyboard>:debug
               func/name
               debug.tags
             "Current state %S for registrar %S is not a valid state: %S"
             state/current
             registrar
             int<keyboard>:registration:states)
           ;; Error or nil.
           (if no-error
               nil
             (int<keyboard>:output
              :error
              func/name
              "Current state %S for registrar %S is not a valid state: %S"
              state/current
              registrar
              int<keyboard>:registration:states)))

          ((not (memq state/to int<keyboard>:registration:states))
           (int<keyboard>:debug
               func/name
               debug.tags
             "Desired state %S for registrar %S is not a valid state: %S"
             state/to
             registrar
             int<keyboard>:registration:states)
           ;; Error or nil.
           (if no-error
               nil
             (int<keyboard>:output
              :error
              func/name
              "Desired state %S for registrar %S is not a valid state: %S"
              state/to
              registrar
              int<keyboard>:registration:states)))

          ;;------------------------------
          ;; Valid Cases:
          ;;------------------------------
          ;; `state/to' _is_ `state/current'?... ok, fine.
          ((eq state/to state/current)
           t)

          ;; Valid transition?
          (t
           (let ((valid/froms (int<keyboard>:registration:state:valid? state/to)))
             (if (not (memq state/current valid/froms))
                 ;; Invalid transition - error or return nil.
                 (if no-error
                     nil
                   (int<keyboard>:output :error
                                         func/name
                                         '("Registrar %S at current registration state %S cannot transition to %S state. "
                                           "Must be one of: %S")
                                         registrar
                                         state/current
                                         state/to
                                         valid/froms))
               ;; Valid. Return non-nil.
               t))))))


(defun int<keyboard>:registration:state/transition:set (registrar state/to &optional no-error)
  "Returns non-nil if transition of current registration state to new STATE/TO
state is valid.

If NO-SET is non-nil, skips setting current registration state.

If NO-ERROR is non-nil, will return nil instead of signaling an error."
  ;; Check for errors.
  (message "int<keyboard>:registration:state/transition:set: valid? %S"
           (int<keyboard>:registration:state/transition:valid? registrar state/to no-error))
  (if (not (int<keyboard>:registration:state/transition:valid? registrar state/to no-error))
      ;; Invalid transition - that raised an error signal if `no-error' is /not/ set,
      ;; so the only other thing to do is return nil if `no-error' is set.
      nil

    ;; Valid transition - apply/set it.
    (int<keyboard>:registrar:set registrar :state state/to)))
;; (int<keyboard>:registrar:set :debug :state nil)
;; (int<keyboard>:registrar:get :debug :state)
;; (int<keyboard>:registration:state/transition:set :debug :inactive)
;; (int<keyboard>:registrar:get :debug :state)
;; (int<keyboard>:registration:state/transition:set :debug :active)
;; (int<keyboard>:registration:state/transition:set :debug :active t)
;; (int<keyboard>:registrar:get :debug :state)


;;------------------------------------------------------------------------------
;; Actual/Default: Permanent Registrar
;;------------------------------------------------------------------------------

(defvar int<keyboard>:registrar<actual>:keybinds nil
  "The keybinds for the actual/active layout.

Saved in `input:keyboard/layout:set' during module config; set/activated in
`int<keyboard>:layout:activate' during module finalization.

This is an alist with 3 expected entries:
  :common - Any keybinds that exist in both evil-mode and standard Emacs.
  :emacs  - Any Emacs-only keybinds (non-evil-mode).
  :evil   - Any Evil-only keybinds.

Each alist key's value should be a list of args for
`keyboard:layout:map!'.")
;; (pp-macroexpand-expression int<keyboard>:registrar<actual>:keybinds)


(defvar int<keyboard>:registrar<actual>:unbinds nil
  "The unbindings for the actual/active layout.

Saved in `input:keyboard/layout:set' during module config; set/activated in
`int<keyboard>:layout:activate' during module finalization.

This is an alist with 3 expected entries:
  :common - Any keybinds that should just be unset.
  :emacs  - Any Emacs-only unbinds.
  :evil   - Any Evil-only unbinds.

Each alist key's value should be a list of args for
`keyboard:layout:map!'.")


(defvar int<keyboard>:registrar<actual>:state nil
  "The state of registration/initialization.

Valid States (see `int<keyboard>:registration:states'
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
  "The keybinds for the debug layout.

Saved in `input:keyboard/layout:set' during module config; set/activated in
`int<keyboard>:layout:activate' during module finalization.

This is an alist with 3 expected entries:
  :common - Any keybinds that exist in both evil-mode and standard Emacs.
  :emacs  - Any Emacs-only keybinds (non-evil-mode).
  :evil   - Any Evil-only keybinds.

Each alist key's value should be a list of args for
`keyboard:layout:map!'.")
;; (pp-macroexpand-expression int<keyboard>:layout/temp:keybinds)


(defvar int<keyboard>:registrar<debug>:unbinds nil
  "The unbindings for the debug layout.

Saved in `input:keyboard/layout:set' during module config; set/activated in
`int<keyboard>:layout:activate' during module finalization.

This is an alist with 3 expected entries:
  :common - Any keybinds that should just be unset.
  :emacs  - Any Emacs-only unbinds.
  :evil   - Any Evil-only unbinds.

Each alist key's value should be a list of args for
`keyboard:layout:map!'.")


(defvar int<keyboard>:registrar<debug>:state nil
  "The state of registration/initialization.

Valid States (see `int<keyboard>:registration:states'
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

(defconst int<keyboard>:registrars
  '((:actual . ((:keybinds . int<keyboard>:registrar<actual>:keybinds)
                (:unbinds  . int<keyboard>:registrar<actual>:unbinds)
                (:state    . int<keyboard>:registrar<actual>:state)))

    (:debug . ((:keybinds . int<keyboard>:registrar<debug>:keybinds)
               (:unbinds  . int<keyboard>:registrar<debug>:unbinds)
               (:state    . int<keyboard>:registrar<debug>:state))))
  "Alist of Registrar Type -> Var Keyword -> Actual Var.")
;; (alist-get :state (alist-get :actual int<keyboard>:registrars))


(defun int<keyboard>:registrar:valid? (registrar-keyword)
  "Returns t if REGISTRAR-KEYWORD is valid. Else signals error."
  (if (alist-get registrar-keyword int<keyboard>:registrars)
      registrar-keyword

    ;; Invalid registrar symbol!
    (int<keyboard>:output :error
                          "int<keyboard>:registrar:valid?"
                          '("REGISTRAR is not a valid registrar keyword. "
                            "Must be one of: %S; "
                            "got: %S")
                          (mapcar (lambda (registrar-assoc)
                                    "Get registrar keywords for error message."
                                    (car registrar-assoc))
                                  int<keyboard>:registrars)
                          registrar)))


;;------------------------------------------------------------------------------
;; Registrar Getters
;;------------------------------------------------------------------------------
;; Get vars based on registrar desired.
;;------------------------------

(defun int<keyboard>:registrar:symbol (registrar keyword)
  "Get a registrar variable's symbol based on REGISTRAR type and
variable identifier KEYWORD.

REGISTRAR should be a valid keyword from `int<keyboard>:registrar/types'."
  ;; Get registrar's alist of stuff; error if invalid REGISTRAR.
  (if-let ((registrar.vars (alist-get registrar int<keyboard>:registrars)))
      ;; Return the var or signal error if we didn't find anything.
      (if-let ((symbol (alist-get keyword registrar.vars)))
          ;; Return the symbol itself.
          symbol

        ;; Invalid registrar symbol!
        (int<keyboard>:output :error
                              "int<keyboard>:registrar:get"
                              '("KEYWORD is not a valid variable keyword. "
                                "Must be one of: %S; "
                                "got: %S")
                              (mapcar (lambda (vars-assoc)
                                        "Get registrar keywords for error message."
                                        (car vars-assoc))
                                      registrar.vars)
                              keyword))

    ;; Invalid registrar symbol!
    (int<keyboard>:output :error
                          "int<keyboard>:registrar:get"
                          '("REGISTRAR is not a valid registrar keyword. "
                            "Must be one of: %S; "
                            "got: %S")
                          (mapcar (lambda (registrar-assoc)
                                    "Get registrar keywords for error message."
                                    (car registrar-assoc))
                                  int<keyboard>:registrars)
                          registrar)))
(let ((int<keyboard>:registrar<debug>:state "testing?"))
  (eval (int<keyboard>:registrar:symbol :debug :state)))


(defun int<keyboard>:registrar:get (registrar keyword)
  "Get a registrar variable's value based on REGISTRAR type and
variable identifier KEYWORD.

REGISTRAR should be a valid keyword from `int<keyboard>:registrar/types'."
  ;; Get the symbol and then return its value.
  ;; `int<keyboard>:registrar:symbol' will error on anything invalid.
  ;;
  ;; NOTE: Using `eval' instead of `symbol-value' so tests can lexically bind variables
  ;; and not mess with the real values.
  (eval (int<keyboard>:registrar:symbol registrar keyword)))
;; (int<keyboard>:registrar:get :actual :state)
;; (int<keyboard>:registrar:get :debug :state)
;; (int<keyboard>:registrar:get :actual :keybinds)


(defun int<keyboard>:registrar:set (registrar keyword value)
  "Set a registrar variable's value to VALUE based on REGISTRAR type and
variable identifier KEYWORD.

REGISTRAR should be a valid keyword from `int<keyboard>:registrar/types'.

NOTE: Does not validate/error check VALUE."
  ;; Get registrar's alist of stuff; error if invalid REGISTRAR.
  (if-let ((registrar.vars (alist-get registrar int<keyboard>:registrars)))
      ;; Return the var or signal error if we didn't find anything.
      (if-let ((symbol (alist-get keyword registrar.vars)))
          ;; Set the symbol to the new value.
          (set symbol value)

        ;; Invalid registrar symbol!
        (int<keyboard>:output :error
                              "int<keyboard>:registrar:set"
                              '("KEYWORD is not a valid variable keyword. "
                                "Must be one of: %S; "
                                "got: %S")
                              (mapcar (lambda (vars-assoc)
                                        "Get registrar keywords for error message."
                                        (car vars-assoc))
                                      registrar.vars)
                              keyword))

    ;; Invalid registrar symbol!
    (int<keyboard>:output :error
                          "int<keyboard>:registrar:set"
                          '("REGISTRAR is not a valid registrar keyword. "
                            "Must be one of: %S; "
                            "got: %S")
                          (mapcar (lambda (registrar-assoc)
                                    "Get registrar keywords for error message."
                                    (car registrar-assoc))
                                  int<keyboard>:registrars)
                          registrar)))
;; (int<keyboard>:registrar:set :debug :state :foo)


;;------------------------------------------------------------------------------
;; The End
;;------------------------------------------------------------------------------
(imp:provide :input 'keyboard 'registrars)
