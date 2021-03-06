;;; mis0/args/+string.el -*- lexical-binding: t; -*-

(-m//require 'internal 'mlist)


;;------------------------------------------------------------------------------
;; Constants
;;------------------------------------------------------------------------------

(defconst -m//strings
  '(:trim
    :string
    :indent)
  "Valid mis0 :string section keywords.")


;;------------------------------------------------------------------------------
;; General Getters/Setters
;;------------------------------------------------------------------------------

(defun -m//string/get (key mlist &optional default)
  "Get a string value from this mlist.
"
  (-m//section/get key :string mlist -m//strings default))


(defun -m//string/set (key value mlist)
  "Set a string value in this mlist.
"
  (-m//section/set key value :string mlist -m//strings))
;; (-m//string/set :trim t nil)


(defun -m//string/first (key mlists &optional default)
   "Get first style match for KEY in MLISTS. Returns DEFAULT if no matches.

Use `:mis0/nil', `:mis0/error', etc for DEFAULT if you have a \"nil is valid\"
situation in the calling code.
"
  (-m//mlists/get.first key :string mlists -m//strings default))
;; (-m//string/first :trim '((:mis0 t :string (:mis0 :string :trim :mis0/nil))) nil)
;; (-m//string/first :trim '((:mis0 t :string (:mis0 :string :trim :mis0/nil))) t)
;; (-m//mlists/get.first :trim :string '(:mis0 t :string (:mis0 :string :trim :mis0/nil)) -m//strings t)
;; (-m//string/first :indent (list (mis0/string/indent 'existing)) "error dude")


;;------------------------------------------------------------------------------
;; Field Setters
;;------------------------------------------------------------------------------

(defun mis0/string/trim (trim &optional mlist)
  "Sets a string trim. Returns an mlist.
"
  (-m//string/set :trim trim mlist))


(defun mis0/string/string (string &optional mlist)
  "Sets a string string. Returns an mlist.
"
  (-m//string/set :string string mlist))


(defun mis0/string/indent (indent &optional mlist)
  "Sets indent type/amount to INDENT.

INDENT supported can be:
  'fixed    -> Indent an amount according to (current-column) return value.
  'existing -> Do not create indention; use (current-column) as indent amount.
               Useful for telling mis0 that you're already indented this much.
  integer   -> Indent according to integer's value.

Disabled for now:
  'auto     -> (indent-according-to-mode)

Returns an mlist.
"
  (cond ((memq indent '(auto))  ;; disabled-for-now list
         (error "%S: `auto' is not currently supported for indentation."
                "mis0/string/indent"))

        ;; Supported Symbols
        ((memq indent '(fixed existing auto))
         (-m//string/set :indent indent mlist))

        ;; Supported Type: Integers
        ((integerp indent)
          (-m//string/set :indent indent mlist))

        ;; Default Case: Error out.
        (t
         (error "%S: indent must be: %s. Got: %S"
                "mis0/string/indent"
                "'auto, 'fixed, 'existing or an integer"
                indent))))
;; (mis0/string/indent 42)
;; (mis0/string/indent 'fixed)
;; (mis0/string/indent 'auto)
;; (mis0/string/indent t)
;; (mis0/string/indent 'existing)


;;------------------------------------------------------------------------------
;; Helpers
;;------------------------------------------------------------------------------

(defun mis0/string/trim.if (string mlists)
  "Trim STRING if there is a :string/trim set in MLISTS.
"
  (if (-m//return/invalid? (-m//string/first :trim mlists :mis0/nil) '(:mis0/nil))
      string
    (string-trim string)))
;; (message "trimmed? '%s'" (mis0/string/trim.if "    hello there     " nil))


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
;; (-m//string/indent.amount (list (mis0/string/indent 'auto)))
;; (-m//string/indent.amount (list (mis0/string/indent 'fixed)))
;; (-m//string/indent.amount (list (mis0/string/indent 'existing)))
;; (-m//string/first :indent (list (mis0/string/indent 'existing) 0))


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
  (if (eq (-m//string/first :indent  mlists :mis0/nil) 'existing)
      ""
    (make-string (-m//string/indent.amount mlists) ?\s)))
;; (-m//string/indent.get (list (mis0/string/indent 'auto)))
;; (-m//string/indent.get (list (mis0/string/indent 'existing)))
;; (-m//string/indent.get (list (mis0/string/indent 'fixed)))


(defun mis0/string/newline (mlists)
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
  (let ((explicit-width (-m//style/first :width mlists :mis0/nil)))
    (if (-m//return/invalid? explicit-width '(:mis0/nil))
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
  (mis0/string/trim.if (-m//string/first :string mlists "") mlists))
;; (-m//string/get (list (mis0/string/string "  testing     ") (mis0/string/trim t)))
;; (-m//string/get (list (mis0/string/string "  testing     ")))




;;------------------------------------------------------------------------------
;; String Output
;;------------------------------------------------------------------------------

(defun mis0//out.string/trim.get (mout)
  "Get :string/trim from MOUT list.

Returns :mis0/nil if none."
  (-m//out/entry.get :trim mout))


(defun mis0//out.string/trim.set (value mout)
  "Set :string/trim to VALUE in MOUT list.

Returns updated MOUT list."
  (-m//out/entry.set :trim value mout))


(defun mis0//out.string/string.get (mout)
  "Get :string/string from MOUT list.

Returns :mis0/nil if none."
  (-m//out/entry.get :string mout))


(defun mis0//out.string/string.set (value mout)
  "Set :string/string to VALUE in MOUT list.

Returns updated MOUT list."
  (-m//out/entry.set :string value mout))


(defun mis0//out.string/indent.get (mout)
  "Get :string/indent from MOUT list.

Returns :mis0/nil if none."
  (-m//out/entry.get :indent mout))


(defun mis0//out.string/indent.set (value mout)
  "Set :string/indent to VALUE in MOUT list.

Returns updated MOUT list."
  (-m//out/entry.set :indent value mout))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(-m//provide 'args 'string)
(provide 'mis0/args/string)
