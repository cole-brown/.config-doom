;;; mis/args/+style.el -*- lexical-binding: t; -*-


(-m//require 'internal 'mlist)


;;------------------------------------------------------------------------------
;; Constants
;;------------------------------------------------------------------------------

(defconst -m//styles
  '(:width
    :margin
    :border
    :padding)
  "Valid mis :style section keywords.")


;;------------------------------------------------------------------------------
;; General Getters/Setters
;;------------------------------------------------------------------------------

(defun -m//style/get (key mlist &optional default)
  "Get a style value from this mlist.
"
  (-m//section/get key :style mlist -m//styles default))


(defun -m//style/set (key value mlist)
  "Set a style value in this mlist.
"
   (-m//section/set key value :style mlist -m//styles))


(defun -m//style/first (key mlists &optional default)
  "Get first style match for KEY in MLISTS. Returns DEFAULT if no matches.

Use `:mis/nil', `:mis/error', etc for DEFAULT if you have a \"nil is valid\"
situation in the calling code.
"
  (-m//mlists/get.first key :style mlists -m//styles default))
;; (-m//style/first :border '((:mis t :string (:mis :string :trim t))) :mis/nil)
;; (-m//style/first :border '((:mis t :string (:mis :string :trim t))) " ")
;; (-m//style/first :border '((:mis t :style (:mis :style :border "x"))) "error dude")

;;------------------------------------------------------------------------------
;; Field Setters
;;------------------------------------------------------------------------------

(defun mis/style/width (width &optional mlist)
  "Sets a style width. Returns an mlist.
"
  (-m//style/set :width width mlist))


(defun mis/style/margin (margin &optional mlist)
  "Sets a style margin. Returns an mlist.
"
  (-m//style/set :margin margin mlist))


(defun mis/style/border (border &optional mlist)
  "Sets a style border. Returns an mlist.
"
  (-m//style/set :border border mlist))
;; (mis/style/border "x")
;;   -> (:mis t :style (:mis :style :border "x"))

(defun mis/style/padding (padding &optional mlist)
  "Sets a style padding. Returns an mlist.
"
  (-m//style/set :padding padding mlist))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(-m//provide 'args 'style)
(provide 'mis/args/style)
