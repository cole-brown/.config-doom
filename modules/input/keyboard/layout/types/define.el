;;; input/keyboard/layout/define.el -*- lexical-binding: t; -*-

input:keyboard
input//kl

;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║             Layout Definition & Keybind Mapping Functions              ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;             Keyboard-Layout-Aware `map!' equivalent and stuff!             ;;
;;                                 ──────────                                 ;;


(imp:require :input 'keyboard 'vars)
(imp:require :input 'keyboard 'layout 'utils)


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

;;------------------------------
;; Constants
;;------------------------------

(defconst int<keyboard>:layout/define:keyword/prefix ":layout:"
  "Keyboard layout keywords must always begin with ':layout:' so that they can
be parsed properly.")


;;------------------------------
;; Variables
;;------------------------------

(defvar int<keyboard>:layout/define:keywords nil
  "Definition of the keywords->functions created by calling
`input:keyboard/layout:define/keywords'.

Multiple calls to `input:keyboard/layout:define/keywords' accumulate the
result here.

Format:
  - alist of alists of cons:
    - type (:common, :emacs, :evil) -> keyword alist
      - keybind-keyword -> keybind-function")
;; (pp-macroexpand-expression int<keyboard>:layout/define:keywords)


;;------------------------------------------------------------------------------
;; Validity
;;------------------------------------------------------------------------------

(defun int<keyboard>:layout:keyword/valid-name-regex (type)
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
       ,int<keyboard>:layout/define:keyword/prefix
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
;; (int<keyboard>:layout:keyword/valid-name-regex :emacs)


(defun int<keyboard>:layout:valid/keyword? (type keyword)
  "Is KEYWORD a keyword, is it a valid keyboard layout keyword, and is it named
correctly for TYPE?

Returns non-nil for valid KEYWORD."
  (when-let* ((valid/keyword? (keywordp keyword))
              (valid/name-rx (int<keyboard>:layout:keyword/valid-name-regex type)))
    (string-match-p valid/name-rx (symbol-name keyword))))
;; (int<keyboard>:layout:valid/keyword? :evil :layout:evil:valid_hello-there)
;; (int<keyboard>:layout:valid/keyword? :evil :layout:evil:INVALID:hello-there)


(defun int<keyboard>:layout:valid/function? (func)
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
;; API: Create Layout Keywords
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
             (int<keyboard>:output :error
                                   '("input:keyboard/layout:define/keywords"
                                     "Expected a keyword, got: %S")
                                   keyword))
            ((not (int<keyboard>:layout:valid/keyword? type keyword))
             (int<keyboard>:output :error
                                   '("input:keyboard/layout:define/keywords"
                                     "Expected a valid keyboard layout keyword for '%S', got: %S")
                                   type
                                   keyword))

            ((not (symbolp func))
             (int<keyboard>:output :error
                                   '("input:keyboard/layout:define/keywords"
                                     "Expected a symbol, got: %S")
                                   func))
            ((not (int<keyboard>:layout:valid/function? func))
             (int<keyboard>:output :error
                                   '("input:keyboard/layout:define/keywords"
                                     "Expected a valid keyboard layout function, got: %S")
                                   func))

            ((not (int<keyboard>:layout:type/valid? type))
             (int<keyboard>:output :error
                                   '("input:keyboard/layout:define/keywords"
                                     "Type '%S' is not a valid type. "
                                     "Must be one of: %S")
                                   type int<keyboard>:layout:types))

            (t
             nil))

      ;;------------------------------
      ;; Add this keyword entry to alist.
      ;;------------------------------
      ;; Use `int<keyboard>:alist:update' so we overwrite a pre-existing.
      (when int<keyboard>:debugging
        (let* ((kw-str (format "%S" keyword))
               (pad-str (int<keyboard>:debug:fill (- 45    ; Enlarge as needed.
                                                     (length kw-str)
                                                     2)))) ; Preexisting pad spaces in msg.
          (int<keyboard>:debug "input:keyboard/layout:define/keywords"
              '(:layout :define)
            "%s %s -> %-S"
            kw-str
            pad-str
            value)))
      (int<keyboard>:alist:update keyword
                                  value ;; Save the quoted value, not `func'.
                                  int<keyboard>:layout/define:keywords))))
;; int<keyboard>:layout/define:keywords
;; (setq int<keyboard>:layout/define:keywords nil)
;; (input:keyboard/layout:define/keywords :evil "docstring here" :layout:test-keyword #'ignore)
;; (alist-get :layout:test-keyword int<keyboard>:layout/define:keywords)


;;------------------------------------------------------------------------------
;; The End
;;------------------------------------------------------------------------------
(imp:provide :input 'keyboard 'layout 'types 'define)
