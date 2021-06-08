;;; spy/org/+link.el -*- lexical-binding: t; -*-


;; Easy paste of e.g. URLs.
(defun spy:cmd:org/here.yank ()
  "Insert item from kill ring as an org-mode link with description 'here'."
  (interactive)
  (insert "[[")
  (yank)
  (insert "][here]]"))


(defun spy:cmd:org/here.link ()
  "Insert stored org link as an org-mode link with description 'here'."
  (interactive)
  (org-insert-link nil (car (car org-stored-links)) "here"))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :modules 'spy 'org 'link)
