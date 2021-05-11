;;; mis2/args/string2.el -*- lexical-binding: t; -*-

(-m//require 'internal 'const)
(-m//require 'internal 'valid)
(-m//require 'internal 'mlist2)


;;------------------------------------------------------------------------------
;; Constants
;;------------------------------------------------------------------------------

(defconst -m//strings
  '(:trim
    :string
    :indent)
  "Valid mis :string section keywords.")


;;------------------------------------------------------------------------------
;; Field Setters
;;------------------------------------------------------------------------------

(defun mis2/string/trim (trim &optional mlist)
  "Sets a string trim. Returns an mlist.
"
  (mis2//out.string/trim.set mlist trim))


(defun mis2/string/string (string &optional mlist)
  "Sets a string string. Returns an mlist.
"
  (mis2//out.string/string.set mlist string))


(defun mis2/string/indent (indent &optional mlist)
  "Sets indent type/amount to INDENT.

INDENT supported can be:
  'fixed    -> Indent an amount according to (current-column) return value.
  'existing -> Do not create indention; use (current-column) as indent amount.
               Useful for telling mis that you're already indented this much.
  integer   -> Indent according to integer's value.

Disabled for now:
  'auto     -> (indent-according-to-mode)

Returns an mlist.
"
  (cond ((memq indent '(auto))  ;; disabled-for-now list
         (error "%S: `auto' is not currently supported for indentation."
                "mis2/string/indent"))

        ;; Supported Symbols
        ((memq indent '(fixed existing))
         (mis2//out.string/indent.set mlist indent (current-column)))

        ;; Supported Type: Integers
        ((integerp indent)
          (mis2//out.string/indent.set mlist indent))

        ;; Default Case: Error out.
        (t
         (error "%S: indent must be: %s. Got: %S"
                "mis2/string/indent"
                "'auto, 'fixed, 'existing or an integer"
                indent))))
;; (mis2/string/indent 42)
;; (mis2/string/indent 'fixed)
;; (mis2/string/indent 'auto)
;; (mis2/string/indent t)
;; (mis2/string/indent 'existing)


;;------------------------------------------------------------------------------
;; Helpers
;;------------------------------------------------------------------------------

(defun mis2/string/trim.if (string mlists)
  "Trim STRING if there is a :string/trim set in MLISTS.
"
  (if (-m//return/invalid? (-m//string/first :trim mlists :mis2/nil) '(:mis2/nil))
      string
    (string-trim string)))
;; (message "trimmed? '%s'" (mis2/string/trim.if "    hello there     " nil))


(defun -m//string/indent.amount (mlists)
  "Get indent amount.

Indent can be:
  'fixed    -> indent to (current-column)
  'existing -> do not indent; use (current-column) as indent amount.
  integer   -> integer

Disabled for now:
  'auto    -> (indent-according-to-mode)
"
  (let ((indent (-m//string/first :indent mlists 0)))
    ;; `fixed' and `existing' both return current column for the amount; they differ
    ;; in `-m//string/indent.get'.
    (cond ((memq indent '(fixed existing))
           (current-column))

          ;; Auto is disabled for now...
          ((eq indent 'auto)
           (error "-m//string/indent.amount: `auto' not supported until it gets properly figured out.")
           ;; ;; Fun fact: No way to just ask "what will/should the indent be"...
           ;; ;; ...so... We have to actually indent in order to figure out how
           ;; ;; much indention we need?
           ;; ;; ...and then we have to undo our change?
           ;; ;; That sounds terrible.
           ;; (save-excursion  ;; <- Does not save/restore buffer contents; so cannot use that...
           ;;   (indent-according-to-mode)
           ;;   (beginning-of-line-text)
           ;;   (current-column))
           )

          ;; And an integer is just its value.
          ((integerp indent)
           indent)

          (t
           0))))
;; (-m//string/indent.amount (list (mis2/string/indent 'auto)))
;; (-m//string/indent.amount (list (mis2/string/indent 'fixed)))
;; (-m//string/indent.amount (list (mis2/string/indent 'existing)))
;; (-m//string/first :indent (list (mis2/string/indent 'existing) 0))


(defun -m//string/indent.get (mlists)
  "Get indent amount and return a string of that width.

Indent can be:
  'fixed    -> Indent to according to (current-column).
               So, if current column is 4, returns string \"    \".
  'existing -> Do not indent; use (current-column) as indent amount.
               This will always return an empty string.
  integer   -> Indent the amount of the integer.

Disabled for now:
  'auto     -> Indent according to the mode's indentation:
               (indent-according-to-mode)
"
  (if (eq (-m//string/first :indent  mlists :mis2/nil) 'existing)
      ""
    (make-string (-m//string/indent.amount mlists) ?\s)))
;; (-m//string/indent.get (list (mis2/string/indent 'auto)))
;; (-m//string/indent.get (list (mis2/string/indent 'existing)))
;; (-m//string/indent.get (list (mis2/string/indent 'fixed)))


(defun mis2/string/newline (mlists)
  "Returns a newline string.

String will possibly be indented by an amount represented in MLISTS. If no
indentation is desired, provide nil.
"
  ;; Return newline, plus any indentation.
  (concat "\n"
          (-m//string/indent.get mlists)))


(defun -m//line/width (mlists)
  "Returns the allowed max width of the line.

Width is either:
  1) An explicitly set width in the MLISTS.
  2) Calculated by max line width (`fill-column') minus border, indents, etc."
  (let ((explicit-width (-m//style/first :width mlists :mis2/nil)))
    (if (-m//return/invalid? explicit-width '(:mis2/nil))
        (- fill-column
           ;; TODO: Need to get the actual border string...
           ;; Think I'll need a thing in the mlists that's for building as we go?
           ;; Save the built :border strings there?
           ;; (length (-m//style/first :border mlists))
           (-m//string/indent.amount mlists))
      explicit-width)))
;; (-m//line/width nil)


(defun -m//string/get (mlists)
  "Get string (aligned, trimmed, etc) from MLISTS."
  (mis2/string/trim.if (-m//string/first :string mlists "") mlists))
;; (-m//string/get (list (mis2/string/string "  testing     ") (mis2/string/trim t)))
;; (-m//string/get (list (mis2/string/string "  testing     ")))




;;------------------------------------------------------------------------------
;; String Output
;;------------------------------------------------------------------------------

(defun mis2//out.string/trim.get (mout)
  "Get :string/trim from MOUT list.

Returns :mis2/nil if none."
  (-m//out/entry.get mout :trim))


(defun mis2//out.string/trim.set (mout value)
  "Set :string/trim to VALUE in MOUT list.

Returns updated MOUT list."
  (-m//out/entry.set mout :trim value))


(defun mis2//out.string/string.get (mout)
  "Get :string/string from MOUT list.

Returns :mis2/nil if none."
  (-m//out/entry.get mout :string))


(defun mis2//out.string/string.set (mout value)
  "Set :string/string to VALUE in MOUT list.

Returns updated MOUT list."
  (-m//out/entry.set mout :string value))


(defun mis2//out.string/indent.get (mout)
  "Get :string/indent from MOUT list.

Returns :mis2/nil if none."
  (-m//out/entry.get mout :indent))


(defun mis2//out.string/indent.set (mout &rest value)
  "Set :string/indent to VALUE in MOUT list.

VALUE can be multiple things in some cases.
  (fixed 4), for example for a fixed indent to column 4.

Returns updated MOUT list."
  (-m//out/entry.set mout :indent value))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(-m//provide 'args 'string2)
(provide 'mis/args/string2)
