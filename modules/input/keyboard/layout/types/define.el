;;; input/keyboard/layout/define.el -*- lexical-binding: t; -*-


;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║             Layout Definition & Keybind Mapping Functions              ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;             Keyboard-Layout-Aware `map!' equivalent and stuff!             ;;
;;                                 ──────────                                 ;;


(imp:require :input 'keyboard 'vars)
(imp:require :input 'keyboard 'output)
(imp:require :input 'keyboard 'debug)
(imp:require :input 'keyboard 'alist)


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

;;------------------------------
;; Constants
;;------------------------------

(defconst int<keyboard>:layout/types:keyword/prefix ":layout:"
"Keyboard layout keywords must always begin with ':layout:' so that they can
be parsed properly.")


;;------------------------------
;; Variables
;;------------------------------

(defvar int<keyboard>:layout/types:keywords nil
"Definition of the keywords->functions created by calling
`keyboard:layout/types:define/keywords'.

Multiple calls to `keyboard:layout/types:define/keywords' accumulate the
result here.

Format:
- alist of alists of cons:
    - type (:common, :emacs, :evil) -> keyword alist
      - keybind-keyword -> keybind-function")
;; (pp-macroexpand-expression int<keyboard>:layout/types:keywords)


;;------------------------------------------------------------------------------
;; Normalization
;;------------------------------------------------------------------------------

(defun int<keyboard>:layout/types:normalize->func (keyword-or-func &optional keywords)
  "Normalizes a KEYWORD-OR-FUNC to a function.

If KEYWORDS is non-nil, it will be searched for keyword matches to KEYWORD-OR-FUNC.
If KEYWORDS is nil, it will search `int<keyboard>:layout/types:keywords'."
  (let ((debug/tags '(:normalize))
        (debug/name "int<keyboard>:layout/types:normalize->func"))
    (int<keyboard>:debug
        debug/name
        debug/tags
      '("Inputs:\n"
        "  Normalize: %S\n"
        "  Search:    %S")
      keyword-or-func
      keywords)

    (if (not (keywordp keyword-or-func))
        ;;------------------------------
        ;; Function
        ;;------------------------------
        ;; Well it's not a keyword so we'll assume it's a function and return as-is.
        keyword-or-func

      ;;------------------------------
      ;; Keyword -> Function
      ;;------------------------------

      ;; Get first type's alist, and other prep-for-search-loop stuff.
      (let* ((keywords (or keywords
                           int<keyboard>:layout/types:keywords))
             (assoc/type (car keywords))
             (rest/types (cdr keywords))
             (keywords/type (cdr assoc/type))
             ;; Keyword's value/function can be nil, so we need a flag to say we found
             ;; it and another var to save it to.
             found-keyword?
             keyword/found)

        ;; Search each type's alist for the KEYWORD-OR-FUNC.
        (while (and keywords/type
                    (not found-keyword?))
          ;; "Function" can be nil for unbinding something, so get the key and value to check
          ;; for its existance instead.
          (when-let ((key->func (int<keyboard>:alist:get/pair keyword-or-func
                                                              keywords/type)))
            ;; Found the kvp; save its value (function/nil).
            (setq found-keyword? t
                  keyword/found (cdr key->func)))

          ;; Get the next type to check.
          (setq assoc/type (car rest/types)
                rest/types (cdr rest/types)
                keywords/type (cdr assoc/type)))

        ;; Return the keyword or error on not finding it.
        (if (not found-keyword?)
            (int<keyboard>:output :error
                                  "int<keyboard>:layout/types:normalize->func"
                                  "No known keyword for %S."
                                  keyword-or-func)
          (int<keyboard>:debug
              debug/name
              debug/tags
            "%S -> %S"
            keyword-or-func
            keyword/found)

          keyword/found)))))
;; (int<keyboard>:layout/types:normalize->func :layout:evil:line-prev)
;; (int<keyboard>:layout/types:normalize->func :layout:common:undefined)
;; (int<keyboard>:layout/types:normalize->func :layout:DNE:should-error)


;;------------------------------------------------------------------------------
;; Validity
;;------------------------------------------------------------------------------

(defun int<keyboard>:layout/types:keyword/valid-name-regex (type)
  "Returns a layout keyword validation regex for the TYPE keyword
(:common, :emacs, :evil).

If type is invalid or has no string from `int<keyboard>:layout:type->string',
returns nil."
  (when-let ((type/string (int<keyboard>:layout:type->string type)))
    (rx-to-string
     `(sequence
       ;;---
       ;; Validate start/prefix.
       ;;---
       string-start
       ;; ":layout:"
       ,int<keyboard>:layout/types:keyword/prefix
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
;; (int<keyboard>:layout/types:keyword/valid-name-regex :emacs)


(defun int<keyboard>:layout/types:valid/keyword? (type keyword)
  "Is KEYWORD a keyword, is it a valid keyboard layout keyword, and is it named
correctly for TYPE?

Returns non-nil for valid KEYWORD."
  (when-let* ((valid/keyword? (keywordp keyword))
              (valid/name-rx (int<keyboard>:layout/types:keyword/valid-name-regex type)))
    (string-match-p valid/name-rx (symbol-name keyword))))
;; (int<keyboard>:layout/types:valid/keyword? :evil :layout:evil:valid_hello-there)
;; (int<keyboard>:layout/types:valid/keyword? :evil :layout:evil:INVALID:hello-there)


(defun int<keyboard>:layout/types:valid/function? (func)
  "Is FUNC a symbol or function symbol and is it a valid keybinding function?
`nil' is valid - it is used for unbinding already-bound keys."
  (or (null func)
      (and (symbolp func)
           (not (eq func t)) ;; `t' is not a valid function.
           (not (keywordp func))
           ;; Could get something that is not defined yet? In which case this
           ;; causes us to say it's invalid:
           ;; (functionp func)
           )))


(defun int<keyboard>:layout/types:define/func (input)
  "Turn value of INPUT into a quoted function (e.g. #'ignore) for putting
into the keybind definitions."
  `(function ,(doom-unquote input)))


;;------------------------------------------------------------------------------
;; API: Create Layout Keywords
;;------------------------------------------------------------------------------

(defun keyboard:layout/types:define/keywords (type _docstr &rest rest)
  "Define TYPE's layout keywords and their default functions in REST.

TYPE should be one of:
  :common - Any keybinds that exist in both evil-mode and standard Emacs.
  :emacs  - Any Emacs-only keybinds (non-evil-mode).
  :evil   - Any Evil-only keybinds.

_DOCSTR: For you to document if desired - not preserved.

REST: Repeating list of: '(keyword function keyword function ...)"
  (declare (indent 1) (doc-string 2))

  (let ((func/name "keyboard:layout/types:define/keywords")
        (debug/tags '(:layout :define)))

  ;;------------------------------
  ;; Parse all the keywords.
  ;;------------------------------
  (while rest
    (let* ((keyword (pop rest))
           (value (doom-unquote (pop rest)))
           (func (int<keyboard>:layout/types:define/func value))
           ;; Get TYPE's alist from `int<keyboard>:layout/types:keywords'.
           (alist (int<keyboard>:alist:get/value type int<keyboard>:layout/types:keywords)))

      ;;------------------------------
      ;; Error check vars.
      ;;------------------------------
      (cond ((not (keywordp keyword))
             (int<keyboard>:output :error
                                   func/name
                                   "Expected a keyword, got: %S"
                                   keyword))
            ((not (int<keyboard>:layout/types:valid/keyword? type keyword))
             (int<keyboard>:output :error
                                   func/name
                                   "Expected a valid keyboard layout keyword for '%S', got: %S"
                                   type
                                   keyword))

            ((not (symbolp value))
             (int<keyboard>:output :error
                                   func/name
                                   "Expected a symbol, got: %S"
                                   value))
            ((not (int<keyboard>:layout/types:valid/function? value))
             (int<keyboard>:output :error
                                   func/name
                                   "Expected a valid keyboard layout function, got: %S"
                                   value))

            ((not (int<keyboard>:layout:type/valid? type))
             (int<keyboard>:output :error
                                   func/name
                                   '("Type '%S' is not a valid type. "
                                     "Must be one of: %S")
                                   type int<keyboard>:layout:types))

            (t
             nil))

      ;;------------------------------
      ;; Add this keyword entry to alist.
      ;;------------------------------
      (when int<keyboard>:debugging
        (let* ((kw-str (format "%S" keyword))
               (pad-str (int<keyboard>:debug:fill (- 45    ; Enlarge as needed.
                                                     (length kw-str)
                                                     2)))) ; Preexisting pad spaces in msg.
          (int<keyboard>:debug
              func/name
              debug/tags
            "%s %s -> %-S"
            kw-str
            pad-str
            func)))

      ;; Update full alist.
      (int<keyboard>:alist:update
       type
       ;; Update TYPE's alist.
       (int<keyboard>:alist:update keyword
                                   func
                                   alist)
       int<keyboard>:layout/types:keywords)))))
;; int<keyboard>:layout/types:keywords
;; (setq int<keyboard>:layout/types:keywords nil)
;; (keyboard:layout/types:define/keywords :evil "docstring here" :layout:evil:test-keyword #'ignore)
;; (alist-get :evil int<keyboard>:layout/types:keywords)
;; (alist-get :layout:evil:test-keyword (alist-get :evil int<keyboard>:layout/types:keywords))


;;------------------------------------------------------------------------------
;; The End
;;------------------------------------------------------------------------------
(imp:provide :input 'keyboard 'layout 'types 'define)
