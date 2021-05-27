;;; emacs/imp/init.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Usage
;;------------------------------------------------------------------------------

;;------------------
;; Require
;; ------
;; (imp:require <symbol/keyword0> ...)
;;   - If a root is set for <symbol/keyword0>, this can (try to) find the file
;;     required.
;;------------------

;;------------------
;; Provide
;; -------
;; (imp:provide <symbol/keyword0> ...)            ; Provide via imp only.
;; (imp:provide:with-emacs <symbol/keyword0> ...) ; Provide via imp and emacs.
;;------------------

;;------------------
;; (Optional) Set-Up:
;; ------
;; (imp:path:root <symbol/keyword0>
;;                <path-to-root-dir-absolute>
;;                &optional <path-to-root-file-relative-or-absolute>)
;;   - Setting a root for <symbol/keyword0> allows later `imp:require' calls to
;;     try to find the file if not already provided.
;;------------------


;;------------------------------------------------------------------------------
;; Custom Variables
;;------------------------------------------------------------------------------
;; All of imp's custom variables should be here.

(defgroup imp:group nil
  "Automatically-ish commit/push git repos for note, docs, etc."
  :prefix "imp:"
  :group 'tools)


(defcustom imp:features:buffer
  "*imp:features*"
  "Name of the buffer for `imp:features:print' to output a pretty-printed tree
of the features imp has provided."
  :group 'imp:group)


(defcustom imp:translate-to-emacs:replace
  '((":" ""))
  "Alist of regexs to replace and their replacement strings.

Using lists instead of cons for alist entries because `cons' doesn't like
strings.

Used symbol-by-symbol in `iii:feature:imp->emacs' when translating an imp symbol
chain into one symbol for Emacs."
  :group 'imp:group)


(defcustom imp:translate-to-emacs:separator
  ":"
  "String to use in between symbols when translating an imp symbol chain to
an Emacs symbol."
  :group 'imp:group)


(defcustom imp:translate-to-path:replace/default ""
  "Default replacement for entries in `imp:translate-to-path:replace'.")


(defcustom imp:translate-to-path:replace
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
       'imp:translate-to-path:replace/default)
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
                                         "LPT8" "LPT9")))
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
     (":" 'imp:translate-to-path:replace/default))
    ;;------------------------------
    ;; Unsupported/Only Defaults
    ;;------------------------------
    (ms-dos
     nil))
  "Alist of regexs to replace and their replacement strings.

Used symbol-by-symbol in `iii:feature:imp->emacs' when translating an imp symbol
chain into one symbol for Emacs."
  :type '(alist :key-type (choice (string :tag "Regex String")
                                  (sexp :tag "Expression that returns a string."))
                :value-type (choice (list string :tag "Replacement Value")
                                    (list symbol :tag "Symbol whose value is the replacement value")))
  :group 'imp:group)
;; (pp-display-expression imp:translate-to-path:replace "*imp:translate-to-path:replace*")
;; (makunbound 'imp:translate-to-path:replace)


(defcustom imp:error:function
  #'error
  "A function to call for imp errors.

If you desire to not raise error signals during init, for instance, change this
to:
  - #'warn    - Produce a warning message
  - #'message - just send error to *Messages* buffer.
  - nil       - Silently ignore errors (not recommended).
  - Your own function with parameters: (format-string &rest args)"
  :type '(choice (const #'error)
                 (const #'warn)
                 (const #'message)
                 (const nil :tag "nil - Silently ignore errors.")
                  function)
  :group 'imp:group)


;;------------------------------------------------------------------------------
;; Load our files...
;;------------------------------------------------------------------------------

;; Debug First!..
(if (featurep! +debug)
    (load! "+debug") ; Internal only.

  ;; Fake debug funcs so no one screams.
  (load! "+no-debug")) ; Internal only.

;; Order matters.
(load! "error")   ; Internal only.
(load! "tree")    ; Internal only.
(load! "path")    ; Has Public API; mostly internal only.
(load! "provide") ; Has Public API.
(load! "require") ; Has Public API.


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
;; Not strictly necessary to provide to emacs, since provide and require both
;; provide to emacs as well, but does help when requiring via Emacs.
(imp:provide:with-emacs :imp)
