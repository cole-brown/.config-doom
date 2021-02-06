;;; mis/args/+string.el -*- lexical-binding: t; -*-

(-m//require 'internal 'mlist)


;;------------------------------------------------------------------------------
;; Constants
;;------------------------------------------------------------------------------

(defconst -m//strings
  '(:trim
    :string
    :indent)
  "Valid mis :string section keywords.")


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

Use `:mis/nil', `:mis/error', etc for DEFAULT if you have a \"nil is valid\"
situation in the calling code.
"
  (-m//mlists/get.first key :string mlists -m//strings default))
;; (-m//string/first :trim '(:mis t :string (:mis :string :trim :mis/nil)) nil)
;; (-m//string/first :trim '(:mis t :string (:mis :string :trim :mis/nil)) t)
;; (-m//mlists/get.first :trim :string '(:mis t :string (:mis :string :trim :mis/nil)) -m//strings t)
;; (-m//string/first :indent '((:mis t :string (:mis :string :string nil)) (:mis t :string (:mis :string :indent auto))) 0)


;;------------------------------------------------------------------------------
;; Field Setters
;;------------------------------------------------------------------------------

(defun mis/string/trim (trim &optional mlist)
  "Sets a string trim. Returns an mlist.
"
  (-m//string/set :trim trim mlist))


(defun mis/string/string (string &optional mlist)
  "Sets a string string. Returns an mlist.
"
  (-m//string/set :string string mlist))


(defun mis/string/indent (indent &optional mlist)
  "Sets indent type/amount to INDENT.

Supports:
  - 'fixed
  - 'auto
  - integer

Returns an mlist.
"
  (unless (or (memq indent '(fixed auto))
              (integerp indent))
    ;; TODO: error out? Return mis error? IDK?
    (error "%S: indent must be: 'auto, 'fixed, or an integer. Got: %S"
           "mis/string/indent"
           indent))

  (-m//string/set :indent indent
                  mlist))
;; (mis/string/indent 42)
;; (mis/string/indent 'fixed)
;; (mis/string/indent 'auto)
;; (mis/string/indent t)


;;------------------------------------------------------------------------------
;; Helpers
;;------------------------------------------------------------------------------

(defun mis/string/trim.if (string mlists)
  "Trim STRING if there is a :string/trim set in MLISTS.
"
  (if (-m//return/invalid? (-m//string/first :trim mlists t) t)
      string
    (string-trim string)))


(defun -m//string/indent.amount (mlists)
  "Get indent amount.

'fixed  -> (current-column)
'auto   -> (indent-according-to-mode)
integer -> integer
"
  (let ((indent (-m//string/first :indent mlists 0)))
    (cond ((eq indent 'fixed)
           (current-column))

          ((eq indent 'auto)
           ;; Fun fact: No way to just ask "what will/should the indent be"...
           ;; ...so... Do the fucking indent in an excursion so it doesn't
           ;; stick. -_- Then figure out the indent.
           (save-excursion
             (indent-according-to-mode)
             (beginning-of-line-text)
             (current-column)))

          ((integerp indent)
           indent)

          ;; (-m//string/indent.amount (mis/string/indent 'auto))

          (t
           0))))
;; (-m//string/indent.amount (mis/string/indent 'auto))


(defun -m//string/indent.get (mlists)
  "Get indent amount and return a string of that width.

'fixed  -> (current-column)
'auto   -> (indent-according-to-mode)
integer -> integer
"
  (make-string (-m//string/indent.amount mlists) ?\s))
;; (-m//string/indent.amount (mis/string/indent 'auto))


(defun mis/string/newline (mlists)
  "Returns a newline string.

String will possibly be indented by an amount represented in MLISTS. If no
indentation is desired, provide nil.
"
  ;; Return newline, plus any indentation.
  (concat "\n"
          (-m//string/indent.get mlists)))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(-m//provide 'args 'string)
(provide 'mis/args/string)
