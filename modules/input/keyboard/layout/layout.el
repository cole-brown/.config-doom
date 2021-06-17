;;; input/keyboard/layout/layout.el -*- lexical-binding: t; -*-


;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║             Layout Definition & Keybind Mapping Functions              ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;             Keyboard-Layout-Aware `map!' equivalent and stuff!             ;;
;;                                 ──────────                                 ;;


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

;;------------------------------
;; Constants
;;------------------------------

(defconst input//kl:layout:keyword/prefix ":layout:"
  "Keyboard layout keywords must always begin with ':layout:' so that they can
be parsed properly.")


;;------------------------------
;; Variables
;;------------------------------

(defvar input//kl:definitions:keywords nil
  "Definition of the keywords->functions created by calling
`input:keyboard/layout:define/keywords'.

Multiple calls to `input:keyboard/layout:define/keywords' accumulate the
result here.

Format:
  - alist of alists of cons:
    - type (:common, :emacs, :evil) -> keyword alist
      - keybind-keyword -> keybind-function")
;; (pp-macroexpand-expression input//kl:definitions:keywords)


;;------------------------------------------------------------------------------
;; Validity
;;------------------------------------------------------------------------------


(defun input//kl:layout:keyword/valid-name-regex (type)
  "Returns a layout keyword validation regex for the TYPE keyword
(:common, :emacs, :evil).

If type is invalid or has no string from `input//kl:layout:type->string',
returns nil."
  (when-let ((type/string (input//kl:layout:type->string type)))
    (rx-to-string
     `(sequence
       ;;---
       ;; Validate start/prefix.
       ;;---
       string-start
       ;; ":layout:"
       ,input//kl:layout:keyword/prefix
       ;; "emacs:"
       ,type/string
       ":"
       ;;---
       ;; Validate the name itself.
       ;;---
       ;; Could expand this more; I just want to disallow ":" for now.
       ;; May re-allow it if we want to use it for groupings
       ;; (e.g. :layout:evil:word:next-begin or something).
       (one-or-more (any "-" "/" "_" "?" alphanumeric))
       ;;---
       ;; Validate the end/postfix.
       ;;---
       string-end))))
;; (input//kl:layout:keyword/valid-name-regex :emacs)


(defun input//kl:layout:valid/keyword? (type keyword)
  "Is KEYWORD a keyword, is it a valid keyboard layout keyword, and is it named
correctly for TYPE?

Returns non-nil for valid KEYWORD."
  (when-let* ((valid/keyword? (keywordp keyword))
              (valid/name-rx (input//kl:layout:keyword/valid-name-regex type)))
    (string-match-p valid/name-rx (symbol-name keyword))))
;; (input//kl:layout:valid/keyword? :evil :layout:evil:valid_hello-there)
;; (input//kl:layout:valid/keyword? :evil :layout:evil:INVALID:hello-there)


(defun input//kl:layout:valid/function? (func)
  "Is FUNC a symbol or function symbol and is it a valid keybinding function?
`nil' is valid - it is used for unbinding already-bound keys."
  (or (null func)
      (and (symbolp func)
           (not (keywordp func))
           ;; Could get something that is not defined yet? In which case this
           ;; causes us to say it's invalid:
           ;; (functionp func)
           )))


;;------------------------------------------------------------------------------
;; Layout Keywords
;;------------------------------------------------------------------------------

(defmacro input:keyboard/layout:define/keywords (type _docstr &rest rest)
  "Define TYPE's layout keywords and their default functions in REST.

TYPE should be one of:
  :common - Any keybinds that exist in both evil-mode and standard Emacs.
  :emacs  - Any Emacs-only keybinds (non-evil-mode).
  :evil   - Any Evil-only keybinds.

_DOCSTR: For you to document if desired - not preserved.

REST: Repeating list of: '(keyword function keyword function ...)"
  (declare (indent 1) (doc-string 2))

  ;;------------------------------
  ;; Parse all the keywords.
  ;;------------------------------
  (while rest
    (let* ((keyword (pop rest))
           (value (pop rest))
           (func (doom-unquote value)))

      ;;------------------------------
      ;; Error check vars.
      ;;------------------------------
      (cond ((not (keywordp keyword))
             (error (input//kl:error-message
                     "input:keyboard/layout:define/keywords"
                     "Expected a keyword, got: %S")
                    keyword))
            ((not (input//kl:layout:valid/keyword? type keyword))
             (error (input//kl:error-message
                     "input:keyboard/layout:define/keywords"
                     "Expected a valid keyboard layout keyword for '%S', got: %S")
                    keyword))

            ((not (symbolp func))
             (error (input//kl:error-message
                     "input:keyboard/layout:define/keywords"
                     "Expected a symbol, got: %S")
                    func))
            ((not (input//kl:layout:valid/function? func))
             (error (input//kl:error-message
                     "input:keyboard/layout:define/keywords"
                     "Expected a valid keyboard layout function, got: %S")
                    func))

            ((not (input//kl:layout:valid/type? type))
             (error (input//kl:error-message
                     "input:keyboard/layout:define/keywords"
                     "Type '%S' is not a valid type. "
                     "Must be one of: %S")
                    type input//kl:layout:types))

            (t
             nil))

      ;;------------------------------
      ;; Add this keyword entry to alist.
      ;;------------------------------
      ;; Use `input//kl:alist/update' so we overwrite a pre-existing.
      (input//kl:alist/update-quoted keyword
                              value ;; Save the quoted value, not `func'.
                              input//kl:definitions:keywords
                              t))))
;; input//kl:definitions:keywords
;; (setq input//kl:definitions:keywords nil)
;; (input:keyboard/layout:define/keywords :evil "docstring here" :layout:test-keyword #'ignore)
;; (alist-get :layout:test-keyword input//kl:definitions:keywords)


;;------------------------------------------------------------------------------
;; Layout Helpers
;;------------------------------------------------------------------------------

(defun input//kl:layout:normalize->func (keyword-or-func)
  "Normalizes a KEYWORD-OR-FUNC to a function."
  (or (input//kl:alist/get keyword-or-func
                           input//kl:definitions:keywords)
      keyword-or-func))


;;------------------------------------------------------------------------------
;; Layout Derivations
;;------------------------------------------------------------------------------


(defun input//kl:layout:derive/search/in-progress (states func in-progress-map-forms)
  "Search `doom--map-batch-forms' for a match to the desired FUNC.

STATES should be a list of the evil state(s) of the existing keybind.

FUNC should be the function to search for.

IN-PROGRESS-MAP-FORMS should be `doom--map-batch-forms'.

Returns keybind string or nil."
  (let (keybind-found)
    (while (and (not keybind-found)
                states)
      (let* ((state (car states))
             (search/bindings (alist-get state in-progress-map-forms)))
        ;; (message "search state: %S" state)
        (setq states (cdr states))
        ;; Go through `search/bindings' until we run out or find something to return.
        (while (and (not keybind-found)
                    search/bindings)
          ;; Split the first `search/bindings' entry into key string and binding item (list or func).
          (let* ((key (nth 0 (car search/bindings)))
                 (binding (nth 1 (car search/bindings))))
            ;; Update `search/bindings' for next loop.
            (setq search/bindings (cdr search/bindings))

            ;; What is `binding', anyways?
            ;;     ;; Just the function; use it.
            (cond ((functionp (doom-unquote binding))
                   ;; (message "search/in-progress: functionp %S == %S?: %S"
                   ;;          binding func
                   ;;          (eq (doom-unquote binding) (doom-unquote func)))
                   ;; If it's a match, save the key.
                   ;; Else ignore.
                   (when (eq (doom-unquote binding) (doom-unquote func))
                     ;; (message "search/in-progress: functionp found %S -> %S" (doom-unquote func) key)
                     (setq keybind-found key)))

                  ;; A list which includes the function.
                  ((listp binding)
                   ;; (message "search/in-progress: listp %S: t" binding)
                   ;; Find the function to return.
                   (dolist (each binding)
                     ;; If it's a function and matches, save the key.
                     ;; Else ignore.
                     (when (and (functionp (doom-unquote each))
                                (eq (doom-unquote each) (doom-unquote func)))
                       ;; (message "search/in-progress: listp found %S -> %S" (doom-unquote func) key)
                       (setq keybind-found key))))

                  ;; Don't know - ignore? error?
                  (t
                   ;; Error for now - want to know about un-encountered types.
                   (error
                    (input//kl:error-message
                     "input//kl:layout:derive/search/in-progress"
                     "Don't know how to process this keybind setting "
                     "in order to search it for '%s': %S")
                    func
                    binding)
                   nil))))))
        ;; Done searching - return whatever we did (or didn't) find.
        keybind-found))
;; (let ((batch-forms '((motion
;;                       ("h" #'evil-backward-char)
;;                       ("n" #'evil-forward-char)
;;                       ("t"
;;                        (list :def #'evil-next-line :which-key "hello"))
;;                       ("c" #'evil-previous-line))
;;                      (visual
;;                       ("h" #'evil-backward-char)
;;                       ("n" #'evil-forward-char)
;;                       ("t"
;;                        (list :def #'evil-next-line :which-key "hello"))
;;                       ("c" #'evil-previous-line))
;;                      (normal
;;                       ("h" #'evil-backward-char)
;;                       ("n" #'evil-forward-char)
;;                       ("t"
;;                        (list :def #'evil-next-line :which-key "hello"))
;;                       ("c" #'evil-previous-line)))))
;;   (message "\nevil-next-line:")
;;   (input//kl:layout:derive/search/in-progress '(motion) #'evil-next-line batch-forms)
;;   (message "\nevil-previous-line:")
;;   (input//kl:layout:derive/search/in-progress '(motion) #'evil-previous-line batch-forms))


(defun input//kl:layout:derive/search/existing (states func)
  "Search existing keybinds for a match to the desired FUNC.

STATES should be a list of the evil state(s) of the existing keybind.

FUNC should be the function to search for.

Uses general's `general-keybindings.

Returns keybind string or nil."
  (let ((search/maps general-keybindings)
        keybind-found)
    (while (and (not keybind-found)
                states)
      (let ((state (car states)))
        (setq states (cdr states))

        ;; Search each keymap...
        (while (and (not keybind-found)
                    search/maps)
          ;; Split the first entry in `search/maps' up.
          (let* (;; (map-symbol (caar search/maps)) ;; (nth 0 (car search/maps)))
                 ;; For this symbol, we only care about the keybinds of `state'.
                 ;; So just get that state from the cdr/alist.
                 (search/bindings (alist-get state (cdar search/maps)))) ;; (cdr search/maps))))
            ;; (message "searching map %S: bindings? %S"
            ;;          map-symbol
            ;;          (not (null search/bindings)))
            ;; (message "search/bindings is: %S" search/bindings)
            ;; Search state's keybinds...
            (while (and (not keybind-found)
                        search/bindings)
              ;; (message "  checking %S binding: %S" map-symbol (car search/bindings))
              ;; Split the first `search/bindings' entry into key string/vector and function bound.
              (let* ((bound-key (nth 0 (car search/bindings)))
                     (bound-func (nth 1 (car search/bindings))))
                ;; (message "    %S -> %S" (kbd key) func)

                ;; Update `search/bindings' for next loop.
                (setq search/bindings (cdr search/bindings))

                ;; Check for match.
                (when (eq (doom-unquote bound-func) (doom-unquote func))
                  ;; (message "search/existing: found %S -> %S" (doom-unquote func) bound-key)
                  (setq keybind-found bound-key)))))

          ;; Update loop variable for next iteration.
          (setq search/maps (cdr search/maps)))))

        ;; Done searching - return whatever we did (or didn't) find.
        keybind-found))
;; (input//kl:layout:derive/search/existing '(normal) #'evil-backward-char)


(defun input//kl:layout:derive (states in-progress args)
  "Derive a `kbd' string from another function/layout-keyword's keybinding.

STATES should be a list of the evil state(s) of the existing keybind.

IN-PROGRESS should be all the current/in-progress `input//kl:layout:map-process' keybinds.
  - Which, currently, should be `doom--map-batch-forms'.

We will look through that and bound keys to figure out the correct derivation,
preferring `existing' over currently bound keys.

ARGS should be a list of:
  - Modifier key symbols:
    + `control'
    + `shift'
    + `meta'
    + `alt'
    + `super'
    + `hyper'
  - Keyword or function to derive the keybind from. E.g.:
    + :layout:evil:char-prev
    + #'evil-backward-char"
  (let (modifiers
        keys)
    ;; Work through our args to build binding.
    (dolist (arg args)
      ;; What kind of arg is it?
      (cond ((memq arg '(control shift meta ;; Common Modifiers
                         alt super hyper))  ;; Uncommon Modifiers
             (push arg modifiers))

            ;; Our keyword/function we want to derive from.
            ;; Find its keybind string.
            ((or (functionp arg)
                 (keywordp arg))
             (when-let ((func (input//kl:layout:normalize->func arg))
                        (found (or
                                ;; Search the in-progress keybinds for a match.
                                (input//kl:layout:derive/search/in-progress states func in-progress)
                                ;; Else, search for an existing keybind.
                                (input//kl:layout:derive/search/existing states func))))
               ;; Found the keybind - save it.
               (push found keys)))

            ;; Fallthrough: Failed to parse arg - error.
            (t
             (error
              (input//kl:error-message "input//kl:layout:derive"
                                       "Don't know how to process '%s' for deriving keybind. derivation: %S")
              arg
              args))))

    ;; Not sure what to do about trying to derive a 'control' keybind from a base of e.g. "mtt".
    ;; Do they want "C-m tt"? "C-m C-t C-t"?
    (when (and (> (length keys) 1)
               (> (length modifiers) 0)
               ;; Can probably let shift through? Would end up as, I think, "Mtt" currently.
               ;; Maybe they want "MTT"?
               (not (eq modifiers '(shift))))
      ;; Error until a good solution is figured out.
      (error
       (input//kl:error-message
        "input//kl:layout:derive"
        (concat "Don't have a good solution for deriving from multi-key sequences... "
                "modifiers: %S, original keybind: %S"))
       modifiers
       keys))

    ;; Join together the modifiers and keys to create the derived keybind.
    (let (mod/string)
      ;; Process modifiers.
      (dolist (mod/symbol modifiers)
        ;; Convert 'control -> "C-", etc for other modifiers.
        ;; Don't know an actual Emacs function that does this.
        (cond ((eq mod/symbol 'control)
               (setq mod/string (concat mod/string "C-")))
              ((eq mod/symbol 'shift)
               ;; Shift is capital 'S'.
               (setq mod/string (concat mod/string "S-")))
              ((eq mod/symbol 'meta)
               (setq mod/string (concat mod/string "M-")))
              ((eq mod/symbol 'hyper)
               (setq mod/string (concat mod/string "H-")))
              ((eq mod/symbol 'super)
               ;; Super is lowercase 's'.
               (setq mod/string (concat mod/string "s-")))
              ((eq mod/symbol 'alt)
               (setq mod/string (concat mod/string "A-")))
              (t
               (error
                (input//kl:error-message "input//kl:layout:derive"
                                         "Don't know how to process modifier '%s' for deriving keybind: %S")
                mod/symbol
                args))))

      ;; Check our `keys'? Zero is bad; more than one might be weird...
      (cond ((= (length keys) 0)
             (error
                (input//kl:error-message "input//kl:layout:derive"
                                         "No keybind found for: %S")
                args))
            ((> (length keys) 1)
             (error
              (input//kl:error-message "input//kl:layout:derive"
                                       "Not currently sure what to do with more than one keybind string. "
                                       "Found: %S, Args: %S")
              keys
              args))
            ;; Only one result in keys. Create and return resultant derived keybind string.
            (t
             (concat mod/string (key-description (nth 0 keys))))))))
;; (let ((batch-forms '((motion
;;                       ("h" #'evil-backward-char)
;;                       ("n" #'evil-forward-char)
;;                       ("t"
;;                        (list :def #'evil-next-line :which-key "hello"))
;;                       ("c" #'evil-previous-line))
;;                      (visual
;;                       ("h" #'evil-backward-char)
;;                       ("n" #'evil-forward-char)
;;                       ("t"
;;                        (list :def #'evil-next-line :which-key "hello"))
;;                       ("c" #'evil-previous-line))
;;                      (normal
;;                       ("h" #'evil-backward-char)
;;                       ("n" #'evil-forward-char)
;;                       ("t"
;;                        (list :def #'evil-next-line :which-key "hello"))
;;                       ("c" #'evil-previous-line)))))
;;   ;; Should get "C-h" because char-prev is "h".
;;   (input//kl:layout:derive '(motion) batch-forms '(control :layout:evil:char-prev)))


;;------------------------------------------------------------------------------
;; Layout-Aware Keybind Mapping
;;------------------------------------------------------------------------------

(defun input//kl:layout:map-bind (keybind keyword-or-func &optional states desc)
  "Map KEYBIND to a function indicated by KEYWORD-OR-FUNC with DESC description string
for evil STATES.

If STATES is nil or is a list containing `global', the keybind will be global
(no evil state; this is different from evil's \"Emacs\" state and will work in
the absence of `evil-mode').

KEYBIND must be a `kbd'-type string describing the keybind and must fulfill
the `input//kl:layout:valid/keybind?' predicate.

KEYWORD-OR-FUNC must fulfill `input//kl:layout:valid/keyword?' predicate and /is not/
checked by this function. It will be translated to a function via the
`input//kl:definitions:keywords' alist.

DESC can be nil or a string describing the keybinding.

Used for side-effects; just returns non-nil (`t')."
  ;;------------------------------
  ;; Normalize States.
  ;;------------------------------
  (when (or (memq 'global states)
            (null states))
    (setq states (cons 'nil (delq 'global states))))

  ;;------------------------------
  ;; Keyword -> Function
  ;;------------------------------
  ;; Is `keyword-or-func' a keyword? Assume a function if not.
  (let ((func (input//kl:layout:normalize->func keyword-or-func)))
    ;; Empty string keybind and null func are modified into an ignored keybind.
    ;; Null func is an unbind.
    ;; So not much to error check...

    ;;------------------------------
    ;; Is it a `derived' keybind?
    ;;------------------------------
    (when (and (listp keybind)
               (eq (car keybind) 'derive))
      (setq keybind
            ;; We've guarenteed that `states' is a list of at least `nil'.
            (input//kl:layout:derive states
                                     doom--map-batch-forms
                                     (cdr keybind))))

    ;;------------------------------
    ;; Process `desc' into `func'.
    ;;------------------------------
    (when desc
      (let (unquoted)
        (cond ((and (listp func)
                    (keywordp (car-safe (setq unquoted (doom-unquote func)))))
               (setq func (list 'quote (plist-put unquoted :which-key desc))))
              ((setq func (cons 'list
                                (if (and (equal keybind "")
                                         (null func))
                                    `(:ignore t :which-key ,desc)
                                  (plist-put (general--normalize-extended-def func)
                                             :which-key desc))))))))

    ;;------------------------------
    ;; Save Keybind.
    ;;------------------------------
    (dolist (state states)
      (push (list keybind func)
            (alist-get state doom--map-batch-forms)))

    ;;------------------------------
    ;; Always return non-nil as expected by caller.
    ;;------------------------------
    t))
;; input//kl:definitions:keywords
;; (setq doom--map-batch-forms nil)
;; (input//kl:layout:map-bind "c" :layout:evil:line-prev nil "testing...")
;; (doom--map-def "c" #'evil-prev-line nil "testing...")
;; (input//kl:layout:map-bind '(derive control :layout:evil:line-prev) :layout:evil:scroll-up (doom--map-keyword-to-states :n))
;; doom--map-batch-forms


(defun input//kl:layout:map-process (rest)
  "Layout-aware backend for `map!' - equivalent to `doom--map-process'.

Create sexprs required for `map!' to be able to map keybinds based on its
input keywords and such."
  (let ((doom--map-fn doom--map-fn)
        doom--map-state
        doom--map-forms
        desc)
    (while rest
      (let ((key (pop rest)))
        ;;------------------------------
        ;; Nested Mapping?
        ;;------------------------------
        (cond ((listp key)
               (doom--map-nested nil key))

              ;;------------------------------
              ;; `map!' keyword to parse.
              ;;------------------------------
              ((keywordp key)
               (pcase key
                 ;;---
                 ;; Leaders
                 ;;---
                 ;; Save off info for later.
                 (:leader
                  (doom--map-commit)
                  (setq doom--map-fn 'doom--define-leader-key))
                 (:localleader
                  (doom--map-commit)
                  (setq doom--map-fn 'define-localleader-key!))
                 ;;---
                 ;; `:after'  - map as nested under an `after!' macro.
                 ;;---
                 (:after
                  (doom--map-nested (list 'after! (pop rest)) rest)
                  (setq rest nil))
                 ;;---
                 ;; Description
                 ;;---
                 ;; Save for next item that wants a description.
                 (:desc
                  (setq desc (pop rest)))
                 ;;---
                 ;; Keymaps
                 ;;---
                 (:map
                  (doom--map-set :keymaps `(quote ,(doom-enlist (pop rest)))))
                 ;;---
                 ;; Major Mode
                 ;;---
                 (:mode
                  (push (cl-loop for m in (doom-enlist (pop rest))
                                 collect (intern (concat (symbol-name m) "-map")))
                        rest)
                  (push :map rest))
                 ;;---
                 ;; Conditions
                 ;;---
                 ((or :when :unless)
                  (doom--map-nested (list (intern (doom-keyword-name key)) (pop rest)) rest)
                  (setq rest nil))
                 ;;---
                 ;; Prefix/Prefix-Map
                 ;;---
                 (:prefix-map
                  (cl-destructuring-bind (prefix . desc)
                      (doom-enlist (pop rest))
                    (let ((keymap (intern (format "doom-leader-%s-map" desc))))
                      (setq rest
                            (append (list :desc desc prefix keymap
                                          :prefix prefix)
                                    rest))
                      (push `(defvar ,keymap (make-sparse-keymap))
                            doom--map-forms))))
                 (:prefix
                  (cl-destructuring-bind (prefix . desc)
                      (doom-enlist (pop rest))
                    (doom--map-set (if doom--map-fn :infix :prefix)
                                   prefix)
                    (when (stringp desc)
                      (setq rest (append (list :desc desc "" nil) rest)))))
                 ;;---
                 ;; Text Object Inner/Outer Keybind Pairing.
                 ;;---
                 (:textobj
                  (let* ((key (pop rest))
                         (inner (pop rest))
                         (outer (pop rest)))
                    (push `(map! (:map evil-inner-text-objects-map ,key ,inner)
                                 (:map evil-outer-text-objects-map ,key ,outer))
                          doom--map-forms)))
                 ;;---
                 ;; Fallthrough: Evil States
                 ;;---
                 (_
                  (condition-case _
                      ;; Evil states are followed by a `kbd'-type string, then
                      ;; either a function or a layout-keyword to bind to the
                      ;; keyword/string.
                      (input//kl:layout:map-bind (pop rest)
                                                 (pop rest)
                                                 (doom--map-keyword-to-states key)
                                                 desc)
                    (error
                     (input//kl:error-message "input//kl:layout:map-process"
                                              "Not a valid `map!' property: %s")
                                              key))

                  ;; Reset `desc' since we used it.
                  (setq desc nil))))

              ;;------------------------------
              ;; Keybind string to map?
              ;;------------------------------
              (t
               ;; Takes over for `doom--map-def' - handles normal string->func
               ;; and new layout-keyword->func functionality.
               (input//kl:layout:map-bind key
                                          (pop rest)
                                          nil
                                          desc)
               ;; We used `desc' - reset it.
               (setq desc nil)))))

    ;;------------------------------
    ;; Finalize
    ;;------------------------------
    (doom--map-commit)
    ;; Get rid of nils and order correctly.
    (macroexp-progn (nreverse (delq nil doom--map-forms)))))
;; (pp-macroexpand-expression (list :layout-keyword
;;                                  (input//kl:layout:map-process '(:desc "test" :nvm "t" :layout:line-next))
;;                                  :should-equal-keybind-string
;;                                  (doom--map-process '(:desc "test" :nvm "t" #'evil-next-line))))
;; (doom--map-process '(:nvm  "c"  :layout:evil:line-prev
;;                      :desc "hello" :nvm  "t"  :layout:evil:line-next
;;                      :nvm  "n"  :layout:evil:char-prev
;;                      :nvm  "h"  :layout:evil:char-next))


(defmacro input:keyboard/layout:map! (&rest rest)
  "A convenience macro for defining keyboard-layout-aware keybinds,
powered by `general' - equivalent to Doom's `map!' macro.

If evil isn't loaded, evil-specific bindings are ignored.

Properties
  :leader [...]                   an alias for (:prefix doom-leader-key ...)
  :localleader [...]              bind to localleader; requires a keymap
  :mode [MODE(s)] [...]           inner keybinds are applied to major MODE(s)
  :map [KEYMAP(s)] [...]          inner keybinds are applied to KEYMAP(S)
  :prefix [PREFIX] [...]          set keybind prefix for following keys. PREFIX
                                  can be a cons cell: (PREFIX . DESCRIPTION)
  :prefix-map [PREFIX] [...]      same as :prefix, but defines a prefix keymap
                                  where the following keys will be bound. DO NOT
                                  USE THIS IN YOUR PRIVATE CONFIG.
  :after [FEATURE] [...]          apply keybinds when [FEATURE] loads
  :textobj KEY INNER-FN OUTER-FN  define a text object keybind pair
  :when [CONDITION] [...]
  :unless [CONDITION] [...]

  Any of the above properties may be nested, so that they only apply to a
  certain group of keybinds.

States
  :n  normal
  :v  visual
  :i  insert
  :e  emacs
  :o  operator
  :m  motion
  :r  replace
  :g  global  (binds the key without evil `current-global-map')

  These can be combined in any order, e.g. :nvi will apply to normal, visual and
  insert mode. The state resets after the following key=>def pair. If states are
  omitted the keybind will be global (no emacs state; this is different from
  evil's Emacs state and will work in the absence of `evil-mode').

  These must be placed right before the keybind.

  Do
    (input:keyboard/layout:map! :leader :desc \"Description\" :n \"C-c\" #'dosomething)
    (input:keyboard/layout:map! :leader :desc \"Description\" :n \"C-c\" :layout:action-name)
  Don't
    (input:keyboard/layout:map! :n :leader :desc \"Description\" \"C-c\" #'dosomething)
    (input:keyboard/layout:map! :n :leader :desc \"Description\" \"C-c\" :layout:action-name)
    (input:keyboard/layout:map! :leader :n :desc \"Description\" \"C-c\" #'dosomething)
    (input:keyboard/layout:map! :leader :n :desc \"Description\" \"C-c\" :layout:action-name)

Keybinds
  A keybind is in two parts:
    1. The key, which is either:
       a. A `kbd' string - e.g. \"C-c\", \"SPC\", \"M-S-o\", \"x\", etc.)
       b. A `derive' list:
          - (derive 'meta #'dosomething)
          - (derive 'meta :layout:action-name)
          - Those will find the keybind for the func/keyword, and add \"M-\" to the `kbd' string.
    2. The binding, which can either be:
       - A keyboard-layout keyword (e.g. :layout:evil:line-prev).
       - A function symbol (e.g. #'evil-previous-line).
       - nil (which will unbind the key)."
  ;; Process args into a progn of calls to `general' to bind the keys.
  (input//kl:layout:map-process rest))
;; Dvorak keyboard right-handed WASD-type movement:
;; (input:keyboard/layout:map!
;;  :nvm  "c"  :layout:evil:line-prev
;;  :nvm  "t"  :layout:evil:line-next
;;  :nvm  "h"  :layout:evil:char-next
;;  :nvm  "n"  :layout:evil:char-prev)
;; (input:keyboard/layout:map! :nvm  "c"  :layout:evil:line-prev
;;                             :desc "hello" :nvm  "t"  :layout:evil:line-next
;;                             :nvm  "n"  :layout:evil:char-prev
;;                             :nvm  "h"  :layout:evil:char-next)


;;------------------------------------------------------------------------------
;; The End
;;------------------------------------------------------------------------------
