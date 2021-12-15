;;; mis/text/string.el -*- lexical-binding: t; -*-


(imp:require :mis 'internal 'const)
(imp:require :mis 'internal 'valid)
(imp:require :mis 'internal 'mlist)


;;------------------------------------------------------------------------------
;; Constants
;;------------------------------------------------------------------------------

(defconst int<mis>:strings
  '(:trim
    :string
    :indent)
  "Valid mis :string section keywords.")


;;------------------------------------------------------------------------------
;; Field Setters
;;------------------------------------------------------------------------------

(defun mis:string:trim (trim &optional mlist)
  "Sets a string trim. Returns an mlist.
"
  (int<mis>:out.string:trim.set mlist trim))


(defun mis:string:string (string &optional mlist)
  "Sets a string string. Returns an mlist.
"
  (int<mis>:out.string:string.set mlist string))


(defun mis:string:indent (indent &optional mlist)
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
  (let ((func.name "mis:string:indent"))
    (cond ((memq indent (alist-get :unsupported int<mis>:const:indent)) ;; disabled-for-now list
           (nub:error int<mis>:nub:user
                      func.name
                      "`auto' is not currently supported for indentation."))

          ;; Supported Symbols
          ((memq indent (alist-get :supported int<mis>:const:indent))
           (int<mis>:out.string:indent.set mlist indent (current-column)))

          ;; Supported Type: Integers
          ((integerp indent)
           (int<mis>:out.string:indent.set mlist indent))

          ;; Default Case: Error out.
          (t
           (nub:error int<mis>:nub:user
                      func.name
                      "indent must be one of %s, or an integer. Got: %S"
                      (alist-get :all int<mis>:const:indent)
                      indent)))))
;; (mis:string:indent 42)
;; (mis:string:indent 'fixed)
;; (mis:string:indent 'auto)
;; (mis:string:indent t)
;; (mis:string:indent 'existing)


;;------------------------------------------------------------------------------
;; Helpers
;;------------------------------------------------------------------------------

(defun mis:string:trim.if (string mlists)
  "Trim STRING if there is a :string/trim set in MLISTS.
"
  (if (int<mis>:return:invalid? (int<mis>:string:first :trim mlists :mis/nil) '(:mis/nil))
      string
    (string-trim string)))
;; (message "trimmed? '%s'" (mis:string:trim.if "    hello there     " nil))


(defun int<mis>:string:indent.amount (mlists)
  "Get indent amount.

Indent can be:
  'fixed    -> indent to (current-column)
  'existing -> do not indent; use (current-column) as indent amount.
  integer   -> integer

Disabled for now:
  'auto    -> (indent-according-to-mode)
"
  (let ((indent (int<mis>:string:first :indent mlists 0)))
    ;; `fixed' and `existing' both return current column for the amount; they differ
    ;; in `int<mis>:string:indent.get'.
    (cond ((memq indent (alist-get :supported int<mis>:const:indent))
           (current-column))

          ;; Auto is disabled for now...
          ((memq indent (alist-get :unsupported int<mis>:const:indent))
           (nub:error int<mis>:nub:user
                      "int<mis>:string:indent.amount"
                      "%s not supported until it gets properly figured out."
                      indent)
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
;; (int<mis>:string:indent.amount (list (mis:string:indent 'auto)))
;; (int<mis>:string:indent.amount (list (mis:string:indent 'fixed)))
;; (int<mis>:string:indent.amount (list (mis:string:indent 'existing)))
;; (int<mis>:string:first :indent (list (mis:string:indent 'existing) 0))


(defun int<mis>:string:indent.get (mlists)
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
  (if (eq (int<mis>:string:first :indent  mlists :mis/nil) 'existing)
      ""
    (make-string (int<mis>:string:indent.amount mlists) ?\s)))
;; (int<mis>:string:indent.get (list (mis:string:indent 'auto)))
;; (int<mis>:string:indent.get (list (mis:string:indent 'existing)))
;; (int<mis>:string:indent.get (list (mis:string:indent 'fixed)))


(defun mis:string:newline (mlists)
  "Returns a newline string.

String will possibly be indented by an amount represented in MLISTS. If no
indentation is desired, provide nil.
"
  ;; Return newline, plus any indentation.
  (concat "\n"
          (int<mis>:string:indent.get mlists)))


(defun int<mis>:line/width (mlists)
  "Returns the allowed max width of the line.

Width is either:
  1) An explicitly set width in the MLISTS.
  2) Calculated by max line width (`fill-column') minus border, indents, etc."
  (let ((explicit-width (int<mis>:style:first :width mlists :mis/nil)))
    (if (int<mis>:return:invalid? explicit-width '(:mis/nil))
        (- fill-column
           ;; TODO: Need to get the actual border string...
           ;; Think I'll need a thing in the mlists that's for building as we go?
           ;; Save the built :border strings there?
           ;; (length (int<mis>:style:first :border mlists))
           (int<mis>:string:indent.amount mlists))
      explicit-width)))
;; (int<mis>:line/width nil)


(defun int<mis>:string:get (mlists)
  "Get string (aligned, trimmed, etc) from MLISTS."
  (mis:string:trim.if (int<mis>:string:first :string mlists "") mlists))
;; (int<mis>:string:get (list (mis:string:string "  testing     ") (mis:string:trim t)))
;; (int<mis>:string:get (list (mis:string:string "  testing     ")))




;;------------------------------------------------------------------------------
;; String Output
;;------------------------------------------------------------------------------

(defun int<mis>:out.string:trim.get (mout)
  "Get :string/trim from MOUT list.

Returns :mis/nil if none."
  (int<mis>:mlist:entry.get mout :trim))


(defun int<mis>:out.string:trim.set (mout value)
  "Set :string/trim to VALUE in MOUT list.

Returns updated MOUT list."
  (int<mis>:mlist:entry.set mout :trim value))


(defun int<mis>:out.string:string.get (mout)
  "Get :string/string from MOUT list.

Returns :mis/nil if none."
  (int<mis>:mlist:entry.get mout :string))


(defun int<mis>:out.string:string.set (mout value)
  "Set :string/string to VALUE in MOUT list.

Returns updated MOUT list."
  (int<mis>:mlist:entry.set mout :string value))


(defun int<mis>:out.string:indent.get (mout)
  "Get :string/indent from MOUT list.

Returns :mis/nil if none."
  (int<mis>:mlist:entry.get mout :indent))


(defun int<mis>:out.string:indent.set (mout &rest value)
  "Set :string/indent to VALUE in MOUT list.

VALUE can be multiple things in some cases.
  (fixed 4), for example for a fixed indent to column 4.

Returns updated MOUT list."
  (int<mis>:mlist:entry.set mout :indent value))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide:with-emacs :mis 'text 'string)
