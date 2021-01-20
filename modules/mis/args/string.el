;;; mis/args/+string.el -*- lexical-binding: t; -*-

(-m//require 'internal 'mlist)


;;------------------------------------------------------------------------------
;; Constants
;;------------------------------------------------------------------------------

(defconst -m//strings
  '(:trim
    :string)
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


;;------------------------------------------------------------------------------
;; Field Setters
;;------------------------------------------------------------------------------

(defun mis/string/trim.if (string mlists)
  "Trim STRING if there is a :string/trim set in MLISTS.
"
  (if (-m//return/invalid? (-m//string/first :trim mlists t) t)
      string
    (string-trim string)))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(-m//provide 'args 'string)
(provide 'mis/args/string)
