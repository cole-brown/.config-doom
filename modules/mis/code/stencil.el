;;; mis/code/stencil.el -*- lexical-binding: t; -*-


;;----------------------------------------HELP!
;;--         My fancy header generator is broken...                   --
;;------------------------------------------------------------------------------

(-m//require 'internal 'mlist)
(-m//require 'code 'comment)


;;------------------------------------------------------------------------------
;; Table of Stencils
;;------------------------------------------------------------------------------

(defun -m//stencil//repo.test.string=/cmp (a b)
  "Compare strings (ignoring case) for `-m//stencil//repo.test.string='.
"
  ;; `compare-strings' returns t or integer.
  ;; Convert that to a bool t/nil.
  (eq t
      ;; Compare the strings, ignoring case.
      (compare-strings a nil nil b nil nil t)))


(defun -m//stencil//repo.test.string=/hash (key)
  "Get a hashed value for the (lowercased) key for
`-m//stencil//repo.test.string='.
"
  (sxhash-equal (downcase key)))


;; String comparison, ignores case.
(define-hash-table-test '-m//stencil//repo.test.string=
  '-m//stencil//repo.test.string=/cmp
  '-m//stencil//repo.test.string=/hash)


(defvar -m//stencil//repo (make-hash-table :test '-m//stencil//repo.test.string=
                                           :weakness nil)
  "Our hash-table of stencils.")


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------


;;------------------------------------------------------------------------------
;; Helpers.
;;------------------------------------------------------------------------------


(defun -m//stencil/key ()
  "Get possible stencil name (a string) using `thing-at-point'.
"
  (or (thing-at-point 'symbol t)
      (thing-at-point 'word t)))
;; (-m//stencil/key)


(defun -m//stencil/get (key)
  "Get the stencil matching the key and buffer major mode.
"
  (gethash key -m//stencil//repo))


(defun -m//stencil/eval (stencil start end)
  "Evaluates STENCIL into a string ready to insert into the buffer.

Can use region defined by START and END to aid in evaluation.
"
  (message "stencil: %S, start: %S, end: %S" stencil start end)
  )


(defun -m//stencil/insert (stencil start end)
  "Insert the provided stencil in the region described by START and END.

Overwrites anything in the region of START, END if they are not equal.
"
  ;; TODO: eval stencil to replace vars and stuff?
  (save-restriction
    (widen)

    ;; Delete region?
    (delete-region start end)

    ;; Insert stencil.
    ;; TODO: expand stencil first?
    (insert stencil)))
;; (-m//stencil/insert "hi" (point) (point))


;;------------------------------------------------------------------------------
;; Main Function
;;------------------------------------------------------------------------------

(defun mis/stencil (&optional prefix)
   "Expand a mis/snippet in place, offers a pop-up a list of choices if no stencil
found at point (using `mis/custom.stencil/functions/prompt').

With PREFIX argument... TODO: do something?
"
  (interactive "P")
  (if-let* ((key (-m//stencil/key))
            (stencil (-m//stencil/get key))
            (location (if (region-active-p)
                          (cons (region-beginning) (region-end))
                        (cons (point) (point)))))
      (if (not (null stencil))
          (-m//stencil/insert stencil (car location) (cdr location))
        (message "No stencil found to insert for '%s'" key))

    (message "No stencil found for: '%s'" key)))




;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
;; provide to mis and to everyone
(-m//provide 'code 'stencil)
(provide 'mis/code/stencil)
