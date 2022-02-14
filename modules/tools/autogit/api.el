;;; tools/autogit/api.el -*- lexical-binding: t; -*-

(imp:require :path)


;;------------------------------------------------------------------------------
;; Repositories
;;------------------------------------------------------------------------------

(defun autogit:repos:list (root)
  "Get all repo directories that are (direct) children of ROOT path.

Returns list of absolute paths or nil."
  ;;------------------------------
  ;; Error Checking
  ;;------------------------------
  (unless (stringp root)
    (error "autogit:repos:list: ROOT must be a string! Got: %S"
           root))

  (let ((path:root (path:canonicalize:dir root)))
    (unless (path:exists? path:root)
      (error "autogit:repos:list: ROOT does not exist! %s"
             path:root))
    (unless (path:exists? path:root :dir)
      (error "autogit:repos:list: ROOT is not a directory! %s"
             path:root))

    ;;------------------------------
    ;; Find Git Repos.
    ;;------------------------------
    ;; Is the root itself a repo?
    (if (magit-git-repo-p path:root)
        (list path:root)
      ;; Nope; check its direct children.
      (let (repos)
        (dolist (path:dir (path:children path:root :absolute :dir))
          (when (magit-git-repo-p path:dir)
            (push path:dir repos)))
        ;; Return absolute path to any repos found.
        repos))))
;; (autogit:repos:list "~/.config")


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :autogit 'api)
