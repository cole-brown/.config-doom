;;; input/keyboard/layout/layout.el -*- lexical-binding: t; -*-

;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║             Layout Definition & Keybind Mapping Functions              ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;             Keyboard-Layout-Aware `map!' equivalent and stuff!             ;;
;;                                 ──────────                                 ;;


(imp:require :input 'keyboard 'vars)
(imp:provide :input 'keyboard 'layout 'define)
(imp:require :input 'keyboard 'layout 'derive)


;;------------------------------------------------------------------------------
;; Layout-Aware Keybind Mapping
;;------------------------------------------------------------------------------

;; Equivalent to `doom--map-def'.
(defun int<keyboard>:layout:map/bind (registrar keybind keyword-or-func &optional states desc)
  "Map KEYBIND to a function indicated by KEYWORD-OR-FUNC with DESC description string
for evil STATES.

If STATES is nil or is a list containing `global', the keybind will be global
(no evil state; this is different from evil's \"Emacs\" state and will work in
the absence of `evil-mode').

KEYBIND must be a `kbd'-type string describing the keybind and must fulfill
the `input//kl:layout:valid/keybind?' predicate.

KEYWORD-OR-FUNC must fulfill `input//kl:layout:valid/keyword?' predicate and /is not/
checked by this function. It will be translated to a function via the
`int<keyboard>:layout/types:keywords' alist.

DESC can be nil or a string describing the keybinding.

Used for side-effects; just returns non-nil (`t')."
  (let ((func/name "int<keyboard>:layout:map/bind")
        (debug/tags '(:map :map/bind)))
    (int<keyboard>:debug:func
     func/name
     debug/tags
     :start
     (list (cons 'registrar registrar)
           (cons 'keybind keybind)
           (cons 'keyword-or-func keyword-or-func)
           (cons 'states states)
           (cons 'desc desc)))

    ;;------------------------------
    ;; Normalize States.
    ;;------------------------------
    (when (or (memq 'global states)
              (null states))
      (setq states (cons 'nil (delq 'global states))))
    (int<keyboard>:debug
        func/name
        debug/tags
      "states -> %S"
      states)

    ;;------------------------------
    ;; Keyword -> Function
    ;;------------------------------
    ;; Is `keyword-or-func' a keyword? Assume a function if not.
    (let ((func (int<keyboard>:layout/types:normalize->func keyword-or-func)))
      (when (keywordp func)
        (int<keyboard>:debug
            func/name
            debug/tags
          "Unknown keybind keyword: %s -> %s"
          keyword-or-func func)
        (int<keyboard>:output :error
                              func/name
                              "Unknown keybind keyword: %s -> %s"
                              keyword-or-func func))
      (int<keyboard>:debug
          func/name
          debug/tags
        "keyword-or-func: %S -> func: %S"
        keyword-or-func func)
      ;; Empty string keybind and null func are modified into an ignored keybind.
      ;; Null func is an unbind.
      ;; So not much to error check...

      ;;------------------------------
      ;; Is it a derived keybind?
      ;;------------------------------
      ;; (int<keyboard>:debug
      ;;     func/name
      ;;     debug/tags
      ;;   "IS IT DERIVED???: %S %S -> %S"
      ;;   (listp keybind)
      ;;   (if (listp keybind)
      ;;       (car keybind)
      ;;     "<nope>")
      ;;   (and (listp keybind)
      ;;        (eq (car keybind) :derive)))
      (when (and (listp keybind)
                 (eq (car keybind) :derive))
        (int<keyboard>:debug
            func/name
            debug/tags
          "  states: %S\n  batch-forms: %S\n derive-info: %S"
          states doom--map-batch-forms (cdr keybind))
        (int<keyboard>:debug
            func/name
            debug/tags
          "-->map-bind derived: %S <- %S"
          (int<keyboard>:layout:derive states
                                       (cdr keybind)
                                       doom--map-batch-forms
                                       (int<keyboard>:registrar:get registrar :keybinds)
                                       int<keyboard>:layout/types:keywords
                                       )
          keybind)
        (let ((debug-orig keybind))
          (setq keybind
                ;; We've guarenteed that `states' is a list of at least `nil'.
                (int<keyboard>:layout:derive states
                                             (cdr keybind)
                                             doom--map-batch-forms
                                             (int<keyboard>:registrar:get registrar :keybinds)
                                             int<keyboard>:layout/types:keywords
                                             ))
          (int<keyboard>:debug
              func/name
              debug/tags
            "derived %S from: %S"
            keybind
            debug-orig)))

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
              (alist-get state doom--map-batch-forms))
        (int<keyboard>:debug
            func/name
            debug/tags
          "SAVE: %S + %S -> %S"
          state keybind func))

      ;;------------------------------
      ;; Always return non-nil as expected by caller.
      ;;------------------------------
      (int<keyboard>:debug:func
             func/name
             debug/tags
             :end
             t)

      t)))
;; int<keyboard>:layout/types:keywords
;; (setq doom--map-batch-forms nil)
;; (int<keyboard>:layout:map/bind :debug "c" :layout:evil:line-prev nil "testing...")
;; (doom--map-def "c" #'evil-prev-line nil "testing...")
;; (int<keyboard>:layout:map/bind :debug '(derive control :layout:evil:line-prev) :layout:evil:scroll-up (doom--map-keyword-to-states :n))
;; doom--map-batch-forms


(defun int<keyboard>:layout:map/nested (registrar wrapper rest)
  "Map a nested list in `int<keyboard>:layout:map/process'."
  ;; Finish current map-forms.
  (doom--map-commit)
  ;; Setup for the nested call.
  (let ((doom--map-parent-state (doom--map-state)))
    (push (if wrapper
              (append wrapper (list (int<keyboard>:layout:map/process registrar rest)))
            (int<keyboard>:layout:map/process registrar rest))
          doom--map-forms)))


(defun int<keyboard>:layout:map/process (registrar rest)
  "Layout-aware backend for `map!' - equivalent to `doom--map-process'.

Create sexprs required for `map!' to be able to map keybinds based on its
input keywords and such."
  (let ((func/name "int<keyboard>:layout:map/process")
        (debug/tags '(:map :map/process))
        (doom--map-fn doom--map-fn)
        doom--map-state
        doom--map-forms
        desc)
    (while rest
      (let ((key (pop rest)))
        (int<keyboard>:debug
            func/name
            debug/tags
          "MAP-PROCESS _KEY_ LOOP: %S"
          key)
        ;;------------------------------
        ;; Nested Mapping?
        ;;------------------------------
        (cond ((listp key)
               (int<keyboard>:debug
                   func/name
                   debug/tags
                 "-cond->list: list: send to int<keyboard>:layout:map/nested: %S" key)
               (int<keyboard>:layout:map/nested registrar nil key))

              ;;------------------------------
              ;; `map!' keyword to parse.
              ;;------------------------------
              ((keywordp key)
               (int<keyboard>:debug
                   func/name
                   debug/tags
                 "-cond->keyword: keyword->pcase: %S" key)
               (pcase key
                 ;;---
                 ;; Leaders
                 ;;---
                 ;; Save off info for later.
                 (:leader
                  (int<keyboard>:debug
                      func/name
                      debug/tags
                    "---pcase->keyword: `%S': doom--map-fn -> `doom--define-leader-key'" key)
                  (doom--map-commit)
                  (setq doom--map-fn 'doom--define-leader-key))
                 (:localleader
                  (int<keyboard>:debug
                      func/name
                      debug/tags
                    "---pcase->keyword: `%S': doom--map-fn -> `define-localleader-key!'" key)
                  (doom--map-commit)
                  (setq doom--map-fn 'define-localleader-key!))
                 ;;---
                 ;; `:after'  - map as nested under an `after!' macro.
                 ;;---
                 (:after
                  (int<keyboard>:debug
                      func/name
                      debug/tags
                    "---pcase->keyword: `%S': Call `doom--map-nested'" key)
                  (int<keyboard>:layout:map/nested registrar (list 'after! (pop rest)) rest)
                  (setq rest nil))
                 ;;---
                 ;; Description
                 ;;---
                 ;; Save for next item that wants a description.
                 (:desc
                  (int<keyboard>:debug
                      func/name
                      debug/tags
                    "---pcase->keyword: `%S': setq desc: %S" key (car rest))
                  (setq desc (pop rest)))
                 ;;---
                 ;; Keymaps
                 ;;---
                 (:map
                  (int<keyboard>:debug
                      func/name
                      debug/tags
                    "---pcase->keyword: `%S': doom--map-set: %S" key rest)
                  ;; TODO: do I need to remake `doom--map-set'?
                  (doom--map-set :keymaps `(quote ,(doom-enlist (pop rest)))))
                 ;;---
                 ;; Major Mode
                 ;;---
                 (:mode
                  (int<keyboard>:debug
                      func/name
                      debug/tags
                    "---pcase->keyword: `%S': Push mode stuff into rest." key)
                  (push (cl-loop for m in (doom-enlist (pop rest))
                                 collect (intern (concat (symbol-name m) "-map")))
                        rest)
                  (push :map rest))
                 ;;---
                 ;; Conditions
                 ;;---
                 ((or :when :unless)
                  (int<keyboard>:debug
                      func/name
                      debug/tags
                    "---pcase->keyword: `%S': -> `doom--map-nested'" key)
                  (doom--map-nested (list (intern (doom-keyword-name key)) (pop rest)) rest)
                  (setq rest nil))
                 ;;---
                 ;; Prefix/Prefix-Map
                 ;;---
                 (:prefix-map
                  (int<keyboard>:debug
                      func/name
                      debug/tags
                    "---pcase->keyword: `%S': create `doom-leader-%s-map'" key desc)
                  (cl-destructuring-bind (prefix . desc)
                      ;; I'm not really sure what this does besides delete `arg' from `rest'... with extra steps.
                      (let ((arg (pop rest)))
                        (if (consp arg) arg (list arg)))
                    (let ((keymap (intern (format "doom-leader-%s-map" desc))))
                      (setq rest
                            (append (list :desc desc prefix keymap
                                          :prefix prefix)
                                    rest))
                      (push `(defvar ,keymap (make-sparse-keymap))
                            doom--map-forms))))
                 (:prefix
                  (int<keyboard>:debug
                      func/name
                      debug/tags
                    "---pcase->keyword: `%S': prefix stuff" key)
                  (cl-destructuring-bind (prefix . desc)
                      ;; I'm not really sure what this does besides delete `arg' from `rest'... with extra steps.
                      (let ((arg (pop rest)))
                        (if (consp arg) arg (list arg)))
                    (int<keyboard>:debug
                        func/name
                        debug/tags
                      "---pcase->:prefix: (%S . %S): rest=%S" prefix desc rest)
                    (doom--map-set (if doom--map-fn :infix :prefix)
                                   prefix)
                    (when (stringp desc)
                      (int<keyboard>:debug
                          func/name
                          debug/tags
                        "---pcase->:prefix: string desc %S" desc)
                      (setq rest (append (list :desc desc "" nil) rest))
                      (int<keyboard>:debug
                          func/name
                          debug/tags
                        "---pcase->:prefix: rest w/ desc -> %S" rest)
                      )))
                 ;;---
                 ;; Text Object Inner/Outer Keybind Pairing.
                 ;;---
                 (:textobj
                  (int<keyboard>:debug
                      func/name
                      debug/tags
                    "---pcase->keyword: `%S': text-objects-map stuff: key: %S, inner: %S, outer: %S"
                    key key inner outer)
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
                  (int<keyboard>:debug
                      func/name
                      debug/tags
                    "---pcase->_/fallthrough: `%S': evil state? %S + %S -> %S"
                    key
                    (doom--map-keyword-to-states key)
                    (nth 0 rest)
                    (nth 1 rest))
                  ;; `doom--map-process' did a condition-case around this equivalent and then raised a different error message if an error
                  ;; was caught. But I want `int<keyboard>:layout:map/bind' to do the erroring - it knows more than we do about what went wrong.
                  ;;
                  ;; Evil states are followed by a `kbd'-type string, then
                  ;; either a function or a layout-keyword to bind to the
                  ;; keyword/string.
                  ;;
                  ;; NOTE: Keep `progn'! I keep adding a debug print or something here and ruining the flow into
                  ;; `int<keyboard>:layout:map/bind'...
                  (int<keyboard>:debug
                      func/name
                      debug/tags
                    "-----map-bind->:state: %S=%S, %S -> %S"
                    key (doom--map-keyword-to-states key)
                    (nth 0 rest) (nth 1 rest))
                  (int<keyboard>:layout:map/bind registrar
                                             (pop rest)
                                             (pop rest)
                                             (doom--map-keyword-to-states key)
                                             desc)

                  ;; Reset `desc' since we used it.
                  (setq desc nil))))

              ;;------------------------------
              ;; Keybind string to map?
              ;;------------------------------
              (t
               (int<keyboard>:debug
                   func/name
                   debug/tags
                 "-cond->t/default: 'string'?: %S -> %S" key (car rest))
               ;; Takes over for `doom--map-def' - handles normal string->func
               ;; and new layout-keyword->func functionality.
               (int<keyboard>:layout:map/bind registrar
                                          key
                                          (pop rest)
                                          nil
                                          desc)
               ;; We used `desc' - reset it.
               (setq desc nil)))))

    ;;------------------------------
    ;; Finalize
    ;;------------------------------
    ;; (pp-macroexpand-expression doom--map-forms)))
    (doom--map-commit)
    ;; Get rid of nils and order correctly.
    (macroexp-progn (nreverse (delq nil doom--map-forms)))))
;; (pp-macroexpand-expression (list :layout-keyword
;;                                  (int<keyboard>:layout:map/process :debug '(:desc "test" :nvm "t" :layout:line-next))
;;                                  :should-equal-keybind-string
;;                                  (doom--map-process '(:desc "test" :nvm "t" #'evil-next-line))))
;; (doom--map-process '(:nvm  "c"  :layout:evil:line-prev
;;                      :desc "hello" :nvm  "t"  :layout:evil:line-next
;;                      :nvm  "n"  :layout:evil:char-prev
;;                      :nvm  "h"  :layout:evil:char-next))


(defmacro keyboard:layout:map! (&rest rest)
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
    (keyboard:layout:map! :leader :desc \"Description\" :n \"C-c\" #'dosomething)
    (keyboard:layout:map! :leader :desc \"Description\" :n \"C-c\" :layout:action-name)
  Don't
    (keyboard:layout:map! :n :leader :desc \"Description\" \"C-c\" #'dosomething)
    (keyboard:layout:map! :n :leader :desc \"Description\" \"C-c\" :layout:action-name)
    (keyboard:layout:map! :leader :n :desc \"Description\" \"C-c\" #'dosomething)
    (keyboard:layout:map! :leader :n :desc \"Description\" \"C-c\" :layout:action-name)

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
  (int<keyboard>:layout:map/process :actual rest))
;; Dvorak keyboard right-handed WASD-type movement:
;; (keyboard:layout:map!
;;  :nvm  "c"  :layout:evil:line-prev
;;  :nvm  "t"  :layout:evil:line-next
;;  :nvm  "h"  :layout:evil:char-next
;;  :nvm  "n"  :layout:evil:char-prev)
;; (keyboard:layout:map! :nvm  "c"  :layout:evil:line-prev
;;                       :desc "hello" :nvm  "t"  :layout:evil:line-next
;;                       :nvm  "n"  :layout:evil:char-prev
;;                       :nvm  "h"  :layout:evil:char-next)


;;------------------------------------------------------------------------------
;; The End
;;------------------------------------------------------------------------------
(imp:provide :input 'keyboard 'layout 'layout)
