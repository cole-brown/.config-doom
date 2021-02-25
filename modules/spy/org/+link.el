;;; spy/org/+link.el -*- lexical-binding: t; -*-


  ;; Easy paste of e.g. URLs.
  (defun smd/org/here.yank (&optional prefix)
    (interactive)
    (insert "[[")
    (yank)
    (insert "][here]]"))

  (defun smd/org/here.link (&optional prefix)
    (interactive)
    (org-insert-link nil (car (car org-stored-links)) "here"))
