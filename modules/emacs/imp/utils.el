;;; emacs/imp/utils.el -*- lexical-binding: t; -*-

;;------------------------------------------------------------------------------
;; Custom Variables
;;------------------------------------------------------------------------------
;; TODO: Move to wherever file uses `imp:features:buffer'?

(defgroup imp:group nil
  "Automatically-ish commit/push git repos for note, docs, etc."
  :prefix "imp:"
  :group 'tools)

;; TODO: Move to wherever file uses `imp:features:buffer'?
(defcustom imp:features:buffer
  "*imp:features*"
  "Name of the buffer for `imp:features:print' to output a pretty-printed tree
of the features imp has provided."
  :group 'imp:group)


;;------------------------------------------------------------------------------
;; Imp structured tree/list -> Emacs symbol name
;;------------------------------------------------------------------------------

(defconst imp:translate-to-emacs:replace
  '((":" ""))
  "Alist of regexs to replace and their replacement strings.

Using lists instead of cons for alist entries because `cons' doesn't like
strings.

Used symbol-by-symbol in `iii:feature:imp->emacs' when translating an imp symbol
chain into one symbol for Emacs.")


(defconst imp:translate-to-emacs:separator
  ":"
  "String to use in between symbols when translating an imp symbol chain to
an Emacs symbol.")


;;------------------------------------------------------------------------------
;; Imp structured tree/list -> File Path
;;------------------------------------------------------------------------------

(defconst imp:translate-to-path:replace/default ""
  "Default replacement for entries in `imp:translate-to-path:replace'.")


(defconst imp:translate-to-path:replace
  `(;;------------------------------
    ;; Default/Any/All
    ;;------------------------------
    (default
      ;;---
      ;; Valid, but...
      ;;---
      ;; We are going to disallow some valids just to make life easier.
      ;; E.g. regex "^:" is not allowed so that keywords can be used.
      ,(list (rx-to-string `(sequence string-start ":"))
             'imp:translate-to-path:replace/default)
      ;;---
      ;; Disallowed by all:
      ;;---
      ("/"
       imp:translate-to-path:replace/default)
      ,(list (rx-to-string `control)
             'imp:translate-to-path:replace/default))

    ;;------------------------------
    ;; Linux/Unix/Etc.
    ;;------------------------------
    ;; We'll just assume all the unixy systems are the same...
    ;;
    ;; Linux has these restrictions:
    ;;   1. Invalid/reserved file system characters:
    ;;      - / (forward slash)
    ;;      - Integer 0 (1-31: technically legal, but we will not allow).
    (gnu
     ;; Just the defaults, thanks.
     nil)
    (gnu/linux
     ;; Just the defaults, thanks.
     nil)
    (gnu/kfreebsd
     ;; Just the defaults, thanks.
     nil)
    (cygwin
     ;; Just the defaults, thanks.
     nil)

    ;;------------------------------
    ;; Windows
    ;;------------------------------
    ;; Windows has these restrictions:
    ;;   1. Invalid/reserved file system characters:
    ;;      - < (less than)
    ;;      - > (greater than)
    ;;      - : (colon)
    ;;      - " (double quote)
    ;;      - / (forward slash)
    ;;      - \ (backslash)
    ;;      - | (vertical bar or pipe)
    ;;      - ? (question mark)
    ;;      - * (asterisk)
    ;;      - Integers 0 through 31.
    ;;      - "Any other character that the target file system does not allow.
    ;;        - Very useful; thanks.
    ;;   2. Invalid as filenames (bare or with extensions):
    ;;      - CON, PRN, AUX, NUL COM1, COM2, COM3, COM4, COM5, COM6, COM7, COM8,
    ;;        COM9, LPT1, LPT2, LPT3, LPT4, LPT5, LPT6, LPT7, LPT8, LPT9
    ;;   3. Other rules:
    ;;      - Filenames cannot end in: . (period/dot/full-stop)
    (windows-nt
     ,(list (rx-to-string `(sequence (or "<"
                                         ">"
                                         ":"
                                         "\""
                                         "/" ; Also in defaults.
                                         "\\"
                                         "|"
                                         "?"
                                         "*")))
            'imp:translate-to-path:replace/default)
     ,(list (rx-to-string `(sequence string-start
                                     (or "CON"  "PRN"  "AUX"  "NUL"  "COM1"
                                         "COM2" "COM3" "COM4" "COM5" "COM6"
                                         "COM7" "COM8" "COM9" "LPT1" "LPT2"
                                         "LPT3" "LPT4" "LPT5" "LPT6" "LPT7"
                                         "LPT8" "LPT9")
                                     (or "." string-end)))
             'imp:translate-to-path:replace/default)
     ,(list (rx-to-string `(sequence "." string-end))
            'imp:translate-to-path:replace/default))

    ;;------------------------------
    ;; Mac
    ;;------------------------------
    ;; Mac has these restrictions:
    ;;   1. Invalid/reserved file system characters:
    ;;      - / (forward slash)
    ;;      - : (colon)
    ;;      - Technically that's all for HFS+, but usually you can't get away with
    ;;        NUL (integer 0), et al.
    (darwin
     (":" imp:translate-to-path:replace/default))

    ;;------------------------------
    ;; Unsupported/Only Defaults
    ;;------------------------------
    (ms-dos
     nil))
  "Alist of regexs to replace and their replacement strings.

Used symbol-by-symbol in `iii:feature:imp->emacs' when translating an imp symbol
chain into one symbol for Emacs.

Alist format in `defcustom' language:
  :type '(alist :key-type (choice (string :tag \"Regex String\")
                                  (sexp :tag \"Expression that returns a string.\"))
                :value-type (choice (list string :tag \"Replacement Value\")
                                    (list symbol :tag \"Symbol whose value is the replacement value\")))")
;; (pp-display-expression imp:translate-to-path:replace "*imp:translate-to-path:replace*")
;; (makunbound 'imp:translate-to-path:replace)


;;------------------------------------------------------------------------------
;; Normalize to keywords/symbols.
;;------------------------------------------------------------------------------

(defun imp:feature:normalize (&rest input)
  "Normalize INPUT to feature in one of two ways.

If only one INPUT param, returns a symbol/keyword.
  - This is useful for converting strings to symbols for e.g. `imp:provide'.
If more than one INPUT param, returns a list of symbol/keywords.

If INPUT item is:
  - Keyword: Return as-is.
  - Symbol:  Return as-is.
  - String:  Convert to a keyword.
E.g.
  1) `:modules' -> `:modules'
  2) `feature' -> `feature'
  3) \"str-4874\" -> `:str-4874'"
  (let (output)
    (dolist (item input)
      (push
       ;; Keyword or symbol? -> no-op
       (cond ((symbolp item)
              item)

             ;; String? Convert to keyword and return.
             ((and (stringp item)
                   (not (string-empty-p item)))
              (message "string->symbol: %S->%S"
                       item
                       (intern
                        ;; Add leading ":" to make it a keyword.
                        (if (not (string-prefix-p ":" item))
                            (concat ":" item)
                          item)))
              (intern
               ;; Add leading ":" to make it a keyword.
               (if (not (string-prefix-p ":" item))
                   (concat ":" item)
                 item)))

             ;; Other? Error.
             (t
              (iii:error "imp:feature:normalize"
                         (concat "Cannot convert INPUT item type to a symbol. "
                                 "Need a string or symbol/keyword. Got: %S")
                         item)))
       output))

    ;; Return the list, the one item, or what?
    (cond ((null output)
           (iii:error "imp:feature:normalize"
                      "No normalized features produced from INPUT: %S"
                      input))

          ((= 1 (length output))
           (nth 0 output))

          (t
           (nreverse output)))))
;; (imp:feature:normalize '+layout/spydez)
;; (imp:feature:normalize :spydez)
;; (imp:feature:normalize "spydez")
;; (imp:feature:normalize "+spydez")
;; (imp:feature:normalize "+spydez" "foo" "bar")
