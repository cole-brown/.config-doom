;;; input/keyboard/registration-debug.el -*- lexical-binding: t; -*-



;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                       Register to be The Layout.                       ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;                           There can be only one.                           ;;
;;                                 ──────────                                 ;;


(imp:require :input 'keyboard 'utils)
(imp:require :input 'keyboard 'vars)
(imp:require :input 'keyboard 'registrars)
(imp:require :input 'keyboard 'layout 'bind)


;;------------------------------------------------------------------------------
;; Debugging / Testing
;;------------------------------------------------------------------------------

(defun debug<keyboard>:layout:set-registering (registering)
  "Allows forcing current registration state to a REGISTERING state."
  (interactive (list (completing-read "Registering State: "
                                      int<keyboard>:registration:states
                                      nil
                                      t
                                      ":init")))
  (let ((prev (int<keyboard>:registrar:get registrar :state))
        (registering (int<keyboard>:normalize->keyword registering)))
    (int<keyboard>:registrar:set registrar :state registering)
    (message "Set registering to: %S (was %S)" registering prev)))


(defun debug<keyboard>:layout:bind (eval/sexpr layout type keybind-map)
  "Allows changing an `input:keyboard/layout:set' to
`debug<keyboard>:layout:bind', running, and testing its keybinds.

EVAL/RETURN should be:
  - For evaluating/applying layout: `:eval'
  - For getting layout sexprs returned: `:sexpr'
  - For getting layout sexprs pretty-printed: `:sexpr-pp'

LAYOUT should be a keyboard layout keyword.

TYPE should be one of the keywords from `int<keyboard>:layout:types'.

KEYBIND-MAP should be a list of input to `input:keyboard/layout:map!'.

Does not run unless current registration state is `:active'.
  - That is: does not run temp blocks during Emacs/Doom start-up.

Calls:
  - `input:keyboard/layout:unbind'
  - `input:keyboard/layout:set'
  - `keyboard:layout:config'
  - `int<keyboard>:layout:activate'

For a complete activation of a keyboard layout, see `keyboard:layout:apply'."
  (declare (indent 3))

  (let* ((func.name "debug<keyboard>:layout:bind")
         (registrar :temp) ;; Do all this work in the temp registrar.
         (registration/current (int<keyboard>:registrar:get registrar :state))
         (no-eval (cond ((eq eval/sexpr :eval)
                         nil)
                        ((memq eval/sexpr '(:sexpr :pp-sexpr))
                         t)
                        (t
                         (int<keyboard>:output :error
                                               func.name
                                               '("`eval/sexpr' must be one of: %S; "
                                                 "got: %S")
                                               '(:eval :sexpr)
                                               eval/sexpr)))))

    (int<keyboard>:debug func.name
                         '(:registering)
                         "map: %S" keybind-map)
    (int<keyboard>:debug func.name
                         '(:registering)
                         "registering: %S, valids: %S, valid? %S"
                         registration/current
                         registration/valids
                         (memq registration/current registration/valids))

    (if (not (memq registration/current
                   registration/valids))
        ;; [FAIL]: Current registration state doesn't allowed running the temp block.
        (progn
          (int<keyboard>:debug func.name
                               '(:registering)
                               (concat "Skipping this as not in a valid state for it:\n"
                                       "registering: %S\n"
                                       "valids:      %S\n"
                                       "valid?       %S")
                               registration/current
                               registration/valids
                               (memq registration/current registration/valids))

          ;; Explain why we're doing nothing.
          (int<keyboard>:debug/message?
           (format "%s(%S %S ...)" func.name layout type)
           '(:register)
           ;; Message if not in some set-up state, else debug.
           (not (memq registration/current '(nil :init :config)))
           (concat "not run due to current registration state %S. "
                   "Set to one of these (can do via "
                   "`debug<keyboard>:layout:set-registering') to run: %S")
           registration/current
           registration/valids))

      ;; [ OK ]: Run the temp block.
      (prog1
          (int<keyboard>:debug func.name
                               '(:registering)
                               (concat "EXECUTING 'temp binds' BLOCK!!!\n"
                                       "registering: %S\n"
                                       "valids:      %S\n"
                                       "valid?       %S")
                               registration/current
                               registration/valids
                               (memq registration/current registration/valids))

        (let (return-value)
          ;; Apply the keybinds.
          (keyboard:layout:bind layout type keybind-map)

          ;;---
          ;; Since we're testing this block, always continue on to config & activation.
          ;;---

          ;; Config the keybinds.
          (keyboard:layout:config bind/unbind layout)

          ;; Activate the keybinds.
          (setq return-value
                (int<keyboard>:layout:activate registrar bind/unbind (list type) no-eval))
          (when (eq eval/sexpr :pp-sexpr)
            (pp-macroexpand-expression return-value))
          return-value)))))


(defun debug<keyboard>:layout:unbind (eval/sexpr layout type keybind-map)
  "Allows changing an `input:keyboard/layout:set' to
`debug<keyboard>:layout:bind', running, and testing its keybinds.

EVAL/RETURN should be:
  - For evaluating/applying layout: `:eval'
  - For getting layout sexprs returned: `:sexpr'
  - For getting layout sexprs pretty-printed: `:sexpr-pp'

LAYOUT should be a keyboard layout keyword.

TYPE should be one of the keywords from `int<keyboard>:layout:types'.

KEYBIND-MAP should be a list of input to `input:keyboard/layout:map!'.

Does not run unless current registration state is `:active'.
  - That is: does not run temp blocks during Emacs/Doom start-up.

Calls:
  - `input:keyboard/layout:unbind'
  - `input:keyboard/layout:set'
  - `keyboard:layout:config'
  - `int<keyboard>:layout:activate'

For a complete activation of a keyboard layout, see `keyboard:layout:apply'."
  (declare (indent 3))

  (let* ((func.name "debug<keyboard>:layout:unbind")
         (registrar :temp) ;; Do all this work in the temp registrar.
         (registration/current (int<keyboard>:registrar:get registrar :state))
         (no-eval (cond ((eq eval/sexpr :eval)
                         nil)
                        ((memq eval/sexpr '(:sexpr :pp-sexpr))
                         t)
                        (t
                         (int<keyboard>:output :error
                                               func.name
                                               '("`eval/sexpr' must be one of: %S; "
                                                 "got: %S")
                                               '(:eval :sexpr)
                                               eval/sexpr)))))

    (int<keyboard>:debug func.name
                         '(:registering)
                         "map: %S" keybind-map)
    (int<keyboard>:debug func.name
                         '(:registering)
                         "registering: %S, valids: %S, valid? %S"
                         registration/current
                         registration/valids
                         (memq registration/current registration/valids))

    (if (not (memq registration/current
                   registration/valids))
        ;; [FAIL]: Current registration state doesn't allowed running the temp block.
        (progn
          (int<keyboard>:debug func.name
                               '(:registering)
                               (concat "Skipping this as not in a valid state for it:\n"
                                       "registering: %S\n"
                                       "valids:      %S\n"
                                       "valid?       %S")
                               registration/current
                               registration/valids
                               (memq registration/current registration/valids))

          ;; Explain why we're doing nothing.
          (int<keyboard>:debug/message?
           (format "%s(%S %S ...)" func.name layout type)
           '(:register)
           ;; Message if not in some set-up state, else debug.
           (not (memq registration/current '(nil :init :config)))
           (concat "not run due to current registration state %S. "
                   "Set to one of these (can do via "
                   "`debug<keyboard>:layout:set-registering') to run: %S")
           registration/current
           registration/valids))

      ;; [ OK ]: Run the temp block.
      (prog1
          (int<keyboard>:debug func.name
                               '(:registering)
                               (concat "EXECUTING 'temp binds' BLOCK!!!\n"
                                       "registering: %S\n"
                                       "valids:      %S\n"
                                       "valid?       %S")
                               registration/current
                               registration/valids
                               (memq registration/current registration/valids))

        (let (return-value)
          ;; Apply the unbinds.
          (keyboard:layout:unbind layout type keybind-map)

          ;;---
          ;; Since we're testing this block, always continue on to config & activation.
          ;;---

          ;; Config the keybinds.
          (keyboard:layout:config bind/unbind layout)

          ;; Activate the keybinds.
          (setq return-value
                (int<keyboard>:layout:activate registrar bind/unbind (list type) no-eval))
          (when (eq eval/sexpr :pp-sexpr)
            (pp-macroexpand-expression return-value))
          return-value)))))


;;------------------------------------------------------------------------------
;; API / Interactive Commands
;;------------------------------------------------------------------------------

(defun keyboard:layout:apply (layout)
  "Initialize, configure, and apply the LAYOUT.

Overrides any current active layout with the new LAYOUT."
  ;; Could do a completing read or something with the valid layout dirs as the choices.
  (interactive (list (completing-read "Load Layout: "
                                      (keyboard:load:layouts/list)
                                      nil
                                      t
                                      (when int<keyboard>:layout:active
                                        (symbol-name int<keyboard>:layout:active)))))

  ;; Change to our special `:apply' registering state so `:init' state will happen.

  (let ((registrar :actual)
        (registering/prev (int<keyboard>:registrar:get registrar :state)))
    (if (int<keyboard>:registration:state/transition:set registrar :apply)
        (message "Reset layout registration state: %S -> %S"
                 registering/prev (int<keyboard>:registrar:get registrar :state))
      (message "Failed resetting registration state?! Shouldn't happen... state: %S -> %S"
               registering/prev (int<keyboard>:registrar:get registrar :state))))

  ;; Check/report about desired.
  (let ((layout/keyword (int<keyboard>:normalize->keyword layout)))
    ;; Updated desired first.
    (cond ((null int<keyboard>:layout:desired)
           ;; Undefined
           (message "Setting desired keyboard layout: %S -> %S"
                    int<keyboard>:layout:desired
                    layout/keyword))

          ((not (eq int<keyboard>:layout:desired layout/keyword))
           (message "Changing desired keyboard layout: %S -> %S"
                    int<keyboard>:layout:desired
                    layout/keyword))

          (t
           (message "Reapplying desired keyboard layout: %S -> %S"
                    int<keyboard>:layout:desired
                    layout/keyword)))
    (setq int<keyboard>:layout:desired layout/keyword)

    ;; Check/report about active.
    (cond ((null int<keyboard>:layout:active)
           (message "Setting active keyboard layout: %S -> %S"
                    int<keyboard>:layout:active
                    layout/keyword))
          ((not (eq int<keyboard>:layout:active layout/keyword))
           (message "Changing active keyboard layout: %S -> %S"
                    int<keyboard>:layout:active
                    layout/keyword))
          (t
           (message "Reapplying active keyboard layout: %S -> %S"
                    int<keyboard>:layout:active
                    layout/keyword)))

    ;; Load active.
    (keyboard:load:active "init") ;; This will set active.

    ;; Verify it was set before config/finalization.
    (if (not (eq int<keyboard>:layout:active layout/keyword))
        ;; Fail message.
        (message (concat
                  "Initializing layout did not set it to the active layout?!\n"
                  "  Input:   %S\n"
                  "  Desired: %S\n"
                  "  Active:  %S")
                 layout/keyword
                 int<keyboard>:layout:desired
                 int<keyboard>:layout:active)

      ;; Config and finalize the new layout.
      (message "Configuring & binding %S..." int<keyboard>:layout:active)
      (keyboard:load:active "config")
      (input:keyboard/layout:finalize)
      (message "Loaded layout %S." int<keyboard>:layout:active))))
;; (keyboard:layout:clear)


(defun keyboard:layout:clear ()
  "Clear the saved keybinds and unbinds.

Sets to nil:
  - `(int<keyboard>:registrar:get registrar :keybinds)'
  - `(int<keyboard>:registrar:get registrar :unbinds)'.

For e.g. resetting after a bad testing command. You will have to
add back in all keybinds you want."
  (interactive)
  ;; Reset all registrars or just one given registrar?
  ;;  - Both if no input, one if input?
  ;; Let's just go with reset all of them for now.
  (dolist (registrar (mapcar (lambda (registrar-assoc)
                               "Get registrar keywords."
                               (car registrar-assoc))
                             input//kl:registrars))
    (int<keyboard>:registrar:set registrar :unbinds nil)
    (int<keyboard>:registrar:set registrar :keybinds nil)))


;;------------------------------------------------------------------------------
;; The End
;;------------------------------------------------------------------------------
(imp:provide :input 'keyboard 'registration-debug)
