;;; input/keyboard/registration-debug.el -*- lexical-binding: t; -*-



;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                       Register to be The Layout.                       ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;                           There can be only one.                           ;;
;;                                 ──────────                                 ;;


(imp:require :input 'keyboard 'output)
(imp:require :input 'keyboard 'debug)
(imp:require :input 'keyboard 'alist)
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
  (int<keyboard>:cmd:run
   (let ((prev (int<keyboard>:registrar:get registrar :state))
         (registering (int<keyboard>:normalize->keyword registering)))
     (int<keyboard>:registrar:set registrar :state registering)
     (message "Set registering to: %S (was %S)" registering prev))))


(defun debug<keyboard>:layout:bind (eval/sexpr layout type keybind-map)
  "Allows changing an `keyboard:layout:bind' to
`debug<keyboard>:layout:bind', running, and testing its keybinds.

EVAL/RETURN should be:
  - For evaluating/applying layout: `:eval'
  - For getting layout sexprs returned: `:sexpr'
  - For getting layout sexprs pretty-printed: `:sexpr-pp'

LAYOUT should be a keyboard layout keyword.

TYPE should be one of the keywords from `int<keyboard>:layout:types'.

KEYBIND-MAP should be a list of input to `keyboard:layout:map!'.

Does not run unless current registration state is `:active'.
  - That is: does not run temp blocks during Emacs/Doom start-up.

Calls:
  - `keyboard:layout:unbind'
  - `keyboard:layout:bind'
  - `keyboard:layout:config'
  - `int<keyboard>:layout:activate'

For a complete activation of a keyboard layout, see `keyboard:layout:apply'."
  (declare (indent 3))

  (let* ((func/name "debug<keyboard>:layout:bind")
         (registrar :temp) ;; Do all this work in the temp registrar.
         (state/current (int<keyboard>:registrar:get registrar :state))
         (state/desired :init)
         (state/valids (int<keyboard>:registration:state:valid? state/desired))
         (state/transition/valid? (int<keyboard>:registration:state/transition:valid? registrar state/desired :no-error))
         (no-eval (cond ((eq eval/sexpr :eval)
                         nil)
                        ((memq eval/sexpr '(:sexpr :pp-sexpr))
                         t)
                        (t
                         (int<keyboard>:output :error
                                               func/name
                                               '("`eval/sexpr' must be one of: %S; "
                                                 "got: %S")
                                               '(:eval :sexpr)
                                               eval/sexpr)))))

    (int<keyboard>:debug func/name
        '(:registering)
      "map: %S" keybind-map)
    (int<keyboard>:debug func/name
        '(:registering)
      "state: %S -> %S :: valid? %S"
      state/current
      state/desired
      state/transition/valid?)

    (if (not state/transition/valid?)
        ;; [FAIL]: Current registration state doesn't allowed running the temp block.
        (progn
          (int<keyboard>:debug func/name
              '(:registering)
            (concat "Skipping this as not in a valid state for it:\n"
                    "current state:        %S\n"
                    "desired state:        %S\n"
                    "valid desired states: %S\n"
                    "valid?                %S")
            state/current
            state/desired
            state/valids
            state/transition/valid?)

          ;; Explain why we're doing nothing.
          (int<keyboard>:debug/message?
              (format "%s(%S %S ...)" func/name layout type)
              '(:register)
              ;; Message if not in some set-up state, else debug.
              (not (memq state/current
                         (int<keyboard>:alist:get/value :set-up int<keyboard>:registration:state/meta)))
            (concat "not run due to current registration state %S. "
                    "Set to one of these (can do via "
                    "`debug<keyboard>:layout:set-registering') to run: %S")
            state/current
            state/valids)

          ;; Run this check again but allow errors this time for a final, hopefully specific/useful, (error) message.
          (int<keyboard>:registration:state/transition:valid? registrar state/desired))

      ;; [ OK ]: Run the temp block.
      (prog1
          (int<keyboard>:debug func/name
              '(:registering)
            (concat "EXECUTING 'temp binds' BLOCK!!!\n"
                    "current state:        %S\n"
                    "desired state:        %S\n"
                    "valid desired states: %S\n"
                    "valid?                %S")
            state/current
            state/desired
            state/valids
            state/transition/valid?)

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
  "Allows changing an `keyboard:layout:bind' to
`debug<keyboard>:layout:bind', running, and testing its keybinds.

EVAL/RETURN should be:
  - For evaluating/applying layout: `:eval'
  - For getting layout sexprs returned: `:sexpr'
  - For getting layout sexprs pretty-printed: `:sexpr-pp'

LAYOUT should be a keyboard layout keyword.

TYPE should be one of the keywords from `int<keyboard>:layout:types'.

KEYBIND-MAP should be a list of input to `keyboard:layout:map!'.

Does not run unless current registration state is `:active'.
  - That is: does not run temp blocks during Emacs/Doom start-up.

Calls:
  - `keyboard:layout:unbind'
  - `keyboard:layout:bind'
  - `keyboard:layout:config'
  - `int<keyboard>:layout:activate'

For a complete activation of a keyboard layout, see `keyboard:layout:apply'."
  (declare (indent 3))

  (let* ((func/name "debug<keyboard>:layout:unbind")
         (registrar :temp) ;; Do all this work in the temp registrar.
         (state/current (int<keyboard>:registrar:get registrar :state))
         (state/desired :init)
         (state/valids (int<keyboard>:registration:state:valid? state/desired))
         (state/transition/valid? (int<keyboard>:registration:state/transition:valid? registrar state/desired :no-error))
         (no-eval (cond ((eq eval/sexpr :eval)
                         nil)
                        ((memq eval/sexpr '(:sexpr :pp-sexpr))
                         t)
                        (t
                         (int<keyboard>:output :error
                                               func/name
                                               '("`eval/sexpr' must be one of: %S; "
                                                 "got: %S")
                                               '(:eval :sexpr)
                                               eval/sexpr)))))

    (int<keyboard>:debug func/name
        '(:registering)
      "map: %S" keybind-map)
    (int<keyboard>:debug func/name
        '(:registering)
      "state: %S -> %S :: valid? %S"
      state/current
      state/desired
      state/transition/valid?)

    (if (not state/transition/valid?)
        ;; [FAIL]: Current registration state doesn't allowed running the temp block.
        (progn
          (int<keyboard>:debug func/name
              '(:registering)
            (concat "Skipping this as not in a valid state for it:\n"
                    "current state:        %S\n"
                    "desired state:        %S\n"
                    "valid desired states: %S\n"
                    "valid?                %S")
            state/current
            state/desired
            state/valids
            state/transition/valid?)

          ;; Explain why we're doing nothing.
          (int<keyboard>:debug/message?
              (format "%s(%S %S ...)" func/name layout type)
              '(:register)
              ;; Message if not in some set-up state, else debug.
              (not (memq state/current
                         (int<keyboard>:alist:get/value :set-up int<keyboard>:registration:state/meta)))
            (concat "not run due to current registration state %S. "
                    "Set to one of these (can do via "
                    "`debug<keyboard>:layout:set-registering') to run: %S")
            state/current
            state/valids))

      ;; [ OK ]: Run the temp block.
      (prog1
          (int<keyboard>:debug func/name
              '(:registering)
            (concat "EXECUTING 'temp binds' BLOCK!!!\n"
                    "current state:        %S\n"
                    "desired state:        %S\n"
                    "valid desired states: %S\n"
                    "valid?                %S")
            state/current
            state/desired
            state/valids
            state/transition/valid?)

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

  (int<keyboard>:cmd:run
   ;; Change to our special `:apply' registering state so `:init' state will happen.
   (let* ((registrar :actual)
          (state/prev (int<keyboard>:registrar:get registrar :state))
          (state/curr state/prev)
          (layout/keyword      (int<keyboard>:normalize->keyword layout))
          (layout/prev/desired int<keyboard>:layout:desired)
          (layout/prev/active  int<keyboard>:layout:active))

     (if (int<keyboard>:registration:state/transition:set registrar :apply)
         (message "Reset layout registration state: %S -> %S"
                  state/prev (int<keyboard>:registrar:get registrar :state))
       (message "[FAILURE] Failed resetting registration state?! Shouldn't happen... state: %S -> %S"
                state/prev (int<keyboard>:registrar:get registrar :state))
       ;; Signal error to fail out now.
       (error "Failed resetting registration state?! Shouldn't happen... state: %S -> %S"
              state/prev (int<keyboard>:registrar:get registrar :state)))

     ;; Check/report about desired.
     (message "Input keyboard layout: %S" layout/keyword)

     ;; Updated desired first.
     (setq int<keyboard>:layout:desired layout/keyword)
     (cond ((null layout/prev/desired)
            ;; Undefined
            (message "Set desired keyboard layout: %S -> %S"
                     layout/prev/desired
                     int<keyboard>:layout:desired))

           ((not (eq layout/prev/desired layout/keyword))
            (message "Changed desired keyboard layout: %S -> %S"
                     layout/prev/desired
                     int<keyboard>:layout:desired))

           (t
            (message "Reapplied desired keyboard layout: %S -> %S"
                     layout/prev/desired
                     int<keyboard>:layout:desired)))

     ;; Load active.
     (keyboard:load:active "init" :cmd) ;; This will set active.

     ;; Check/report about active.
     (cond ((null layout/prev/active)
            (message "Setting active keyboard layout: %S -> %S"
                     layout/prev/active
                     int<keyboard>:layout:active))
           ((not (eq layout/prev/active int<keyboard>:layout:active))
            (message "Changing active keyboard layout: %S -> %S"
                     layout/prev/active
                     int<keyboard>:layout:active))
           (t
            (message "Reapplying active keyboard layout: %S -> %S"
                     layout/prev/active
                     int<keyboard>:layout:active)))

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

       ;; Verify state transitioned correctly.
       (setq state/curr (int<keyboard>:registrar:get registrar :state))
       (message "State: %S -> %S"
                state/prev
                state/curr)

       (if (not (eq state/curr :init))
           (progn
             (message "[FAILURE] State failed transition: `%S' -> `:init'!"
                      state/prev)
             (setq state/prev state/curr))

         (setq state/prev state/curr)
         ;; Config the new layout.
         (message "Configuring %S..." int<keyboard>:layout:active)
         (keyboard:load:active "config" :cmd)

         ;; Verify state transition again.
         (setq state/curr (int<keyboard>:registrar:get registrar :state))
         (message "State: %S -> %S"
                  state/prev
                  state/curr)

         (if (not (eq state/curr :config))
             (progn
               (message "[FAILURE] State failed transition: `%S' -> `:config'!"
                        state/prev)
               (setq state/prev state/curr))

           (setq state/prev state/curr)
           (setq state/curr (int<keyboard>:registrar:get registrar :state))

           ;; Finalize the new layout.
           (message "Finalizing & binding %S..." int<keyboard>:layout:active)
           (keyboard:layout:finalize)

           ;; Verify the final state transition.
           (setq state/curr (int<keyboard>:registrar:get registrar :state))
           (message "State: %S -> %S"
                    state/prev
                    state/curr)

           (if (not (eq state/curr :active))
               (message "[FAILURE] State failed transition: `%S' -> `:active'!"
                        state/prev)

             (message " \n")
             (message "[SUCCESS] Loaded layout %S." int<keyboard>:layout:active))))))))
;; (keyboard:layout:clear)


(defun keyboard:layout:clear ()
  "Clear the saved state, keybinds and unbinds.

Sets to nil:
  - `(int<keyboard>:registrar:get registrar :keybinds)'
  - `(int<keyboard>:registrar:get registrar :unbinds)'.

For e.g. resetting after a bad testing command. You will have to
add back in all keybinds you want."
  (interactive)
  (int<keyboard>:cmd:run
   ;; Reset all registrars or just one given registrar?
   ;;  - Both if no input, one if input?
   ;; Let's just go with reset all of them for now.
   (dolist (registrar (mapcar (lambda (registrar-assoc)
                                "Get registrar keywords."
                                (car registrar-assoc))
                              int<keyboard>:registrars))
     (int<keyboard>:registrar:set registrar :state nil)
     (int<keyboard>:registrar:set registrar :unbinds nil)
     (int<keyboard>:registrar:set registrar :keybinds nil)
     (message (mapconcat #'identity
                         '("registrar: %S"
                           "  - state:    %S"
                           "  - keybinds: %S"
                           "  - unbinds:  %S")
                         "\n")
              registrar
              (int<keyboard>:registrar:get registrar :state)
              (int<keyboard>:registrar:get registrar :unbinds)
              (int<keyboard>:registrar:get registrar :keybinds)))))


;;------------------------------------------------------------------------------
;; The End
;;------------------------------------------------------------------------------
(imp:provide :input 'keyboard 'layout 'bind-debug)
