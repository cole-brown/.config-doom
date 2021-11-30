;;; -*- lexical-binding: t; -*-

;;-------------------------------------spy--------------------------------------
;;--                             File Functions                               --
;;----------------------------/mnt/hello/there.txt------------------------------

(imp:require :path 'path)


;;------------------------------------------------------------------------------
;; Filters / Ignore Regexes
;;------------------------------------------------------------------------------

(defun files:ignore/regex (rx/path/partial &optional ignore)
  "Create a regex for ignoring RX/PATH/PARTIAL.

RX/PATH/PARTIAL should be a regex string. It can be either absolute or relative.
If relative, it can start with or without a path separator. Both Unix and
Windows type paths are supported.

IGNORE can be:
  - nil - No extra options.
  - :dir - Also ignore a trailing directory separator character.
  - :children - Like `:dir', and also ignore all of its children."
  (let* ((dir-sep '(or "/" "\\"))
         ;; Root of file system can be a few things, depending...
         (root (list 'or
                     (list 'and 'alphabetic ":") ;; Windows drive.
                     "~" ;; Home directory.
                     "/"))) ;; Unix root.
    (concat
     ;; First RX: the optional leading-up-to-`rx/path/partial' stuff.
     (eval `(rx string-start
                ;; Allow path to start at root, or with a directory separator.
                (optional (or ,root ,dir-sep))
                ;; Allow optional parent directories in path.
                (zero-or-more
                 (and (one-or-more printing)
                      ,dir-sep))))
     ;; Second RX: The Input.
     ;;   - Our path we're actually looking for.
     rx/path/partial
     ;; Third RX: The optional ending stuff.
     (eval `(rx
             ;; No path after our match - we want to match the end of the path.
             ;; Do, however, allow for optional trailing directory separator.
             ,(cond ((eq ignore :dir)
                     (list 'zero-or-one dir-sep))
                    ;; Path allowed after our match - ignore the dir and all its children.
                    ((eq ignore :children)
                     (list
                      ;; Allow path after the `rx/path/partial' dir.
                      'zero-or-more
                      (list 'and
                            dir-sep
                            '(one-or-more printing))
                      ;; Allow the optional trailing directory separator.
                      (list 'optional dir-sep)))
                    ;; Nothing is allowed after our match.
                    (t
                     ""))
             string-end)))))
;; (files:ignore/regex ".git" :children)
;; (files:ignore/regex "init.el")


(defun files:ignore/string (string/path/partial &optional ignore)
  "Create a regex for ignoring STRING/PATH/PARTIAL.

STRING/PATH/PARTIAL should NOT be a regex string. It can be either absolute or relative.
If relative, it can start with or without a path separator. Both Unix and
Windows type paths are supported.

IGNORE can be:
  - nil - No extra options.
  - :dir - Also ignore a trailing directory separator character.
  - :children - Like `:dir', and also ignore all of its children."
  (files:ignore/regex (regexp-quote string/path/partial) ignore))
;; (files:ignore/string ".git" :children)


(defun files:ignore? (path ignores)
  "Return non-nil if PATH should be ignored based on IGNORES (list of regex strings)."
  (declare (pure t) (side-effect-free t))

  (let ((ignores ignores) ;; Give ourself an `ignores' to modify.
        path/rx/ignore
        regex)
    (while (and (not path/rx/ignore)
                ignores)
      (setq regex (car ignores)
            ignores (cdr ignores))
       (when (string-match-p regex path)
        (setq path/rx/ignore t)))

    ;; Return whether to ignore or not.
    path/rx/ignore))
;; (files:ignore? "~/mnt/d/somewhere/.git" (list (files:ignore/string ".git" :children)))
;; Doesn't care about "." or "..":
;; (files:ignore? "~/mnt/d/somewhere/." (list (files:ignore/string ".git" :children)))
;; Not a regex, but still works:
;; (files:ignore? "d:/home/work/.doom.d/modules/spy/buffer/init.el" (list "init.el"))
;; "Regex" version of above:
;; (files:ignore? "d:/home/work/.doom.d/modules/spy/buffer/init.el" (list (files:ignore/string "init.el")))
;; (files:ignore? "~/mnt/d/somewhere/init.el" (list (files:ignore/string "init.el")))



;;------------------------------------------------------------------------------
;; Files in directory
;;------------------------------------------------------------------------------

(defun files:in-directory (dir &optional recursive types ignores)
  "Get all files in directory DIR (never returns \".\" or \"..\").

If RECURSIVE is non-nil, looks in DIR and all children directories.

If TYPES is nil, all file types are vaild for returning.
TYPES can also be a list with these valid members:
  - :dir - allow directories
  - :file - allow files
  - :link - symbolic links
Any file type matching a member of TYPES will be returned if not ignored.

If IGNORES is non-nil, it should be a list of regex strings to use. Any absolute
path matching any of the filters will not be included in return values."
  (let ((dir/root dir)
        dir/current
        dirs/to-process
        paths/return)
    ;; Add root dir to processing list and output (if desired) now.
    (push dir/root dirs/to-process)
    (when (or (null types)
              (memq :dir types))
      (push dir/root paths/return))

    ;; Get/process one dir at a time from our processing list.
    (while dirs/to-process
      (setq dir/current (pop dirs/to-process))

      (dolist (entry (directory-files-and-attributes dir/current 'full))
        (let ((path (car entry))
              (attrs (cdr entry)))
          ;; Force ignore "." and ".." to avoid infinite loop.
          (cond ((string-suffix-p "." path)
                 nil)

                ;; Ignore anything that matches one of our ignore regex.
                ((and ignores
                      (files:ignore? path ignores))
                 nil)

                ;; A directory?
                ((eq (file-attribute-type attrs) t) ;; t == directory
                 ;; Save if TYPES allows.
                 (when (or (not types)
                           (memq :dir types))
                   (push path paths/return))
                 ;; If RECURSIVE, add to list to process.
                 (when recursive
                   (push path dirs/to-process)))

                ;; A file?
                ((eq (file-attribute-type attrs) nil) ;; nil == file
                 ;; Save if TYPES allows.
                 (when (or (not types)
                           (memq :file types))
                   (push path paths/return)))

                ;; A symlink?
                ((stringp (file-attribute-type attrs)) ;; string == symlink
                 ;; Save if TYPES allows.
                 (when (or (not types)
                           (memq :link types))
                   (push path paths/return)))

                ;; Default case - ehm... dunno how you got here.
                (t
                 (error "files:in-directory: Unsupported file-attribute-type ('%S') for path: %s"
                        (file-attribute-type attrs)
                        path))))))

    ;; Return the collected paths.
    paths/return))
;; (files:in-directory "..")
;; (files:in-directory ".." t)
;; (files:in-directory ".." t '(:dir))
;; (files:in-directory ".." t '(:dir :file))
;; (files:in-directory ".." t nil (list (files:ignore/string "init.el")))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :path 'files)
