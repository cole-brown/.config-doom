;;; input/keyboard/layout/layout.el -*- lexical-binding: t; -*-


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

(defun input//kl:layout:valid/keymap? (keymap)
  "Returns `t' if KEYMAP a is valid.
'Valid' is a: symbol, nil, `global', or `:global'."
  (cond ((memq keymap '(nil global :global))
         ;; These all mean 'the global keymap'.
         t)
        ((symbolp keymap)
         ;; These could be for things that aren't loaded yet so don't think we
         ;; can do any additional checks.
         t)
        (t
         (error (input//kl:error-message
                 "input//kl:layout:valid/keymap?"
                 "KEYMAP '%S' is not valid.")
                keymap))))


(defun input//kl:layout:valid/keyword? (keyword)
  "Is KEYWORD a keyword and is it a valid keyboard layout keyword?"
  (and (keywordp keyword)
       (string-prefix-p input//kl:layout:keyword/prefix
                        (symbol-name keyword))))


(defun input//kl:layout:valid/keybind? (keybind)
  "Is KEYBIND a string and is it a valid keybinding string?"
  (stringp keybind)
  ;; TODO: "and is it a valid keybinding string?"
  )


(defun input//kl:layout:valid/function? (func)
  "Is FUNC a symbol or function symbol and is it a valid keybinding function?
FUNC is optional, so `nil' is valid."
  (or (null func)
      (and (symbolp func)
           (not (keywordp func))
           ;; Could get something that is not defined yet? In which case this
           ;; causes us to say it's invalid:
           ;; (functionp func)
           ;;
           ;; TODO: "and is it a valid keybinding function?"
           )))


;;------------------------------------------------------------------------------
;; Normalization
;;------------------------------------------------------------------------------

(defun input//kl:layout:normalize/keymap (keymap)
  "In general, returns KEYMAP as-is.

Will convert `nil' and `global' to `:global'."
  (cond
   ;;---
   ;; Invalid KEYMAP
   ;;---
   ((not (input//kl:layout:valid/keymap? keymap))
    ;; `input//kl:layout:valid/keymap?' should have errored but:
    (error (input//kl:error-message
            "input//kl:layout:normalize/keymap"
            "KEYMAP '%S' is not valid.")
           keymap))

   ;;---
   ;; Synonyms
   ;;---
   ((memq keymap '(nil global :global))
    ;; These all mean 'the global keymap' and we'll normalize to `:global'.
    :global)

   ;;---
   ;; (Expected) Default: Return as-is.
   ;;---
   ((symbolp keymap)
    keymap)

   ;;---
   ;; (Unexpected) Default: "...IDK what's going on" error.
   ;;---
   (t
    (error (input//kl:error-message
            "input//kl:layout:normalize/keymap"
            "KEYMAP '%S' fell through all valid checks "
            "- cannot normalize.")
           keymap))))


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
            ((not (input//kl:layout:valid/keyword? keyword))
             (error (input//kl:error-message
                     "input:keyboard/layout:define/keywords"
                     "Expected a valid keyboard layout keyword, got: %S")
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

            ((not (input//kl:layout:valid/type type))
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
  (let ((func (or (input//kl:alist/get keyword-or-func
                                       input//kl:definitions:keywords)
                  keyword-or-func)))
    ;; Empty string keybind and null func are modified into an ignored keybind.
    ;; Null func is an unbind.
    ;; So not much to error check...

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


;; TODO: Get rid of debug `message' calls.
;; TODO: keyword is for _FUNCTION_, not keybind string!
;;       - see after `input:keyboard/layout:map!' for example.
(defun input//kl:layout:map-parse (rest)
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
                 ;; Evil States
                 ;;---
                 (_
                  (condition-case err ;; TODO: `err' back to: _
                      ;; Evil states are followed by a `kbd'-type string, then
                      ;; either a function or a layout-keyword to bind to the
                      ;; keyword/string.
                      (input//kl:layout:map-bind (pop rest)
                                                 (pop rest)
                                                 (doom--map-keyword-to-states key)
                                                 desc)
                    (error
                     (input//kl:error-message "input//kl:layout:map-parse"
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
;;                                  (input//kl:layout:map-parse '(:desc "test" :nvm "t" :layout:line-next))
;;                                  :should-equal-keybind-string
;;                                  (doom--map-process '(:desc "test" :nvm "t" #'evil-next-line))))


(defmacro input//kl:map! (rest)
  "Same as `input:keyboard/layout:map!', but expects input of a variable whose
value is the list of things to map, instead of expecting the things to map
directly."
  (input//kl:layout:map-parse rest))


(defmacro input:keyboard/layout:map! (&rest rest)
  "A convenience macro for defining keybinds, powered by `general'.

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
    (map! :leader :desc \"Description\" :n \"C-c\" #'dosomething)
    (map! :leader :desc \"Description\" :n :layout:action-name #'dosomething)
  Don't
    (map! :n :leader :desc \"Description\" \"C-c\" #'dosomething)
    (map! :n :leader :desc \"Description\" :layout:action-name #'dosomething)
    (map! :leader :n :desc \"Description\" \"C-c\" #'dosomething)
    (map! :leader :n :desc \"Description\" :layout:action-name #'dosomething)

Keybinds
  A keybind can be described by either:
    - A `kbd'-type string (\"C-c\", \"M-S-o\", \"x\", etc.)
    - An `input:keyboard/layout'-type keyword - must begin with
     `input//kl:layout:keyword/prefix' (:layout:text-center, :layout:line-prev,
     :layout:paste-after, etc).

  A keybind also needs a function to bind to (#'dosomething, #'evil-paste-after,
  #'org-agenda, etc).
"
  (input//kl:layout:map-parse rest))



;;   (if (and (listp rest)
;;            (= (length rest) 1))
;;       (progn
;;         `(message "car rest: %S" ,(car rest))
;;         `(input//kl:layout:map-parse ,(car rest))
;;       ;;`(list ,(input//kl:layout:map-parse (car rest)))
;;       )
;;     (message "just rest.\nlistp? %S, len=1? %S listp-car? %S"
;; (listp rest)
;;            (= (length rest) 1)
;;            (listp (car rest))
;;              )
;;     (input//kl:layout:map-parse rest)))

;;  (input//kl:layout:map-process rest))
;; Dvorak keyboard right-handed WASD-type movement:
;; (input:keyboard/layout:map!
;;  ;; ┌──────────────────────────────────────────────────────────────────────┐
;;  ;; │ Movement                                                             │
;;  ;; └──────────────────────────────────────────────────────────────────────┘
;;  :nvm  "c"  :layout:evil:line-prev
;;  :nvm  "t"  :layout:evil:line-next
;;  :nvm  "h"  :layout:evil:char-next
;;  :nvm  "n"  :layout:evil:char-prev)


;;------------------------------------------------------------------------------
;; The End
;;------------------------------------------------------------------------------
