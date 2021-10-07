;;; emacs/dlv/path.el -*- lexical-binding: t; -*-

(imp:require :dlv 'debug)


;;------------------------------------------------------------------------------
;; DLV Directory Path
;;------------------------------------------------------------------------------

(defun int<dlv>:path:expand (path &optional as-dir)
  "Expands PATH using `expand-file-name', then reverts any \"~\" expansion.

- Lowercases Windows drive letters.
- Converts Windows backslashes to forwardslashes.
- Resolves any \"..\" and \".\" in the path.
- etc.

If AS-DIR is non-nil, PATH will be resolved as a directory path. "
  (when (or (null path)
            (not (stringp path)))
    (error "int<dlv>:path:expand: PATH must be a string! Got: %S %S"
           (type-of path)
           path))

  (let ((path/abs (expand-file-name
                   (if as-dir
                       (file-name-as-directory path)
                     path))))
    ;; Check _original_ `path'.
    (if (string-prefix-p "~" path)
        ;; Return expanded but with "~" still.
        (replace-regexp-in-string (expand-file-name "~")
                                  "~"
                                  path/abs)
      ;; Return expanded as-is.
      path/abs)))
;; (int<dlv>:path:expand "~/foo/../bar")
;; (int<dlv>:path:expand "~/foo/../bar" :dir)
;; (int<dlv>:path:expand "d:/home/work/foo/../bar")
;; (int<dlv>:path:expand nil)


(defun int<dlv>:dir:normalize (dir &optional preserve-tilde)
  "Normalize DIR into an absolute path with '/' separators and ending in a '/'.

NOTE: Loses the \"~\" unless PRESERVE-TILDE is non-nil!

Example:
  (int<dlv>:dir:normalize \"D:\\foo\\bar\")
    -> \"d:/foo/bar/\"

  (int<dlv>:dir:normalize \"D:\\home\\work\\foo\\bar\")
    -> \"d:/home/work/foo/bar/\"

  (int<dlv>:dir:normalize \"D:\\home\\work\\foo\\bar\")
    -> \"d:/foo/bar/\"

  (int<dlv>:dir:normalize \"D:\\home\\work\\foo\\bar\")
    -> \"d:/foo/bar/\"

  (int<dlv>:dir:normalize \"D:\\home\\work\\foo\\bar\")
    -> \"d:/foo/bar/\""
  ;; Finish by ensuring we have a trailing '/'.
  (file-name-as-directory
   ;; Do we want to preserve "~"?
   (if preserve-tilde
       (int<dlv>:path:expand dir)
     ;; `expand-file-name' lowercases Windows drive letters and converts backslash to forwardslash.
     ;; It also converts "~" into the absolute path, which isn't really desired in this case...
     (expand-file-name dir))))
;; (int<dlv>:dir:normalize "D:\\foo\\bar")
;; (int<dlv>:dir:normalize "~/foo/bar")
;; (int<dlv>:dir:normalize "~/foo/bar" :preserve)


(defun int<dlv>:path:multiplex (path &optional as-dir)
  "Returns PATH split up into: '(prefix-list rest-str)

If AS-DIR is non-nil, PATH will be resolved as a directory path.

`prefix-list' will be either list of strings or nil.
`rest-str' will be either remainder of path (to concat onto prefix list members)
or entire expanded path.

example:
  (int<dlv>:path:multiplex \"~/foo/bar\")
    -> '((\"~/\" \"/home/jeff/\") . \"foo/bar\")

  (int<dlv>:path:multiplex \"/home/jeff\")
    -> '((\"~/\" \"/home/jeff/\") . \"\")

  (int<dlv>:path:multiplex \"/some/path/foo/bar\")
    -> '((nil) . \"/some/path/foo/bar\")"
  (let ((func.name "int<dlv>:path:multiplex"))
    ;;------------------------------
    ;; Error Checks
    ;;------------------------------
    (when (null path)
      (error "%s: PATH must not be nil! path: %S"
             func.name
             path))

    (when (not (stringp path))
      (error "%s: PATH must be a string! path: %S %S"
             func.name
             (type-of path)
             path))

    ;;------------------------------
    ;; Figure out path/paths.
    ;;------------------------------
    (let* ((path/home.abbrev "~")
           (path/home.abs (expand-file-name "~"))
           (path/abs (int<dlv>:path:expand path as-dir)))

      ;; If it's one of the home paths, output two paths.
      ;;   - "~" needs to be both "~" and the absolute/expanded path.
      ;;   - ...and vice versa.
      (cond
       ;; "~" in resolved PATH.
       ((string-prefix-p path/home.abbrev path/abs)
        (let ((dir/prefix
               (file-name-as-directory path/home.abbrev)))
          ;; Remove leading part of path that is covered by the prefixes.
          (message "'~': replace-regex: %S %S %S -> %S"
                   (concat dir/prefix "?")
                   ""
                   path/abs
                   (replace-regexp-in-string (concat dir/prefix "?")
                                             ""
                                             path/abs))
          (cons (list dir/prefix
                      (file-name-as-directory path/home.abs))
                ;; Remove prefix.
                (replace-regexp-in-string (concat dir/prefix "?") ;; May or may not have the final "/".
                                          ""
                                          path/abs))))

       ;; "/home/jeff" in resolved PATH.
       ((string-prefix-p path/home.abs path/abs)
        (let ((dir/prefix
               (file-name-as-directory path/home.abs)))
          ;; Remove leading part of path that is covered by the prefixes.
          (message "'/home': replace-regex: %S %S %S -> %S"
                   (concat dir/prefix "?")
                   ""
                   path/abs
                   (replace-regexp-in-string (concat dir/prefix "?")
                                             ""
                                             path/abs))
          (cons (list (file-name-as-directory path/home.abbrev)
                      dir/prefix)
                ;; Remove prefix.
                (replace-regexp-in-string (concat dir/prefix "?") ;; May or may not have the final "/".
                                          ""
                                          path/abs))))
       ;; Not a home path; ok as-is - just make it fit the return.
       (t
        (cons nil
              path/abs))))))
;; (int<dlv>:path:multiplex "~/foo/bar")
;; (int<dlv>:path:multiplex "d:/home/work")
;; (int<dlv>:path:multiplex "d:/some/path/foo/bar")


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide:with-emacs :dlv 'path)
