;;; emacs/imp/path.el -*- lexical-binding: t; -*-


;; imp requirements:
;;   - :imp 'debug
;;   - :imp 'error


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------


(defvar imp:path:roots nil
  "alist of require/provide root keywords to a cons of: (root-dir . root-file).

Example:
  `:imp' entry is: '(:imp \"/path/to/imp/\" \"/path/to/imp/init.el\")")
;; imp:path:roots
;; (setq imp:path:roots nil)


;;------------------------------------------------------------------------------
;; `imp:path:roots' Getters
;;------------------------------------------------------------------------------

(defun iii:path:root/dir (keyword)
  "Get the root directory from `imp:path:roots' for KEYWORD."
  (if-let ((dir (nth 0 (iii:alist/general:get keyword imp:path:roots))))
      (expand-file-name "" dir)
    (iii:error "iii:path:root/dir"
               "Root keyword '%S' unknown."
               keyword)))
;; (iii:path:root/dir :imp)


(defun iii:path:root/file (keyword)
  "Get the root directory from `imp:path:roots' for KEYWORD."
  (if-let ((paths (iii:alist/general:get keyword imp:path:roots)))
      (expand-file-name (nth 1 paths) (nth 0 paths))
    (iii:error "iii:path:root/file"
               "Root keyword '%S' unknown."
               keyword)))
;; (iii:path:root/file :imp)


(defun iii:path:root/contains? (keyword)
  "Returns bool based on if `imp:path:roots' contains KEYWORD."
  (not (null (iii:alist/general:get keyword imp:path:roots))))


(defun iii:path:root/valid? (func path &rest kwargs)
  "Checks that PATH is a vaild root path.

KWARGS should be a plist. All default to `t':
  - :exists - path must exist
  - :dir    - path must be a directory (implies :exists)"
  (let ((exists (if (and kwargs
                         (plist-member kwargs :exists))
                    (plist-get kwargs :exists)
                  t))
        (dir    (if (and kwargs
                         (plist-member kwargs :dir))
                    (plist-get kwargs :dir)
                  t))
        (result t))

    (iii:debug "iii:path:root/valid?" "func:   %s" func)
    (iii:debug "iii:path:root/valid?" "path:   %s" path)
    (iii:debug "iii:path:root/valid?" "kwargs: %S" kwargs)
    (iii:debug "iii:path:root/valid?" "  exists: %S" exists)
    (iii:debug "iii:path:root/valid?" "  dir:    %S" dir)
    (iii:debug "iii:path:root/valid?" "  result: %S" result)

    ;;---
    ;; Validity Checks
    ;;---
    (when (or exists dir)  ; :dir implies :exists
      (cond ((null path)
             (iii:error func
                        "Null `path'?! path: %s"
                        path)
             (setq result nil))

            ((not (file-exists-p path))
             (iii:error func
                        "Path does not exist: %s"
                        path)
             (setq result nil))

            (t
             nil)))

    (when dir
      (unless (file-directory-p path)
        (iii:error func
                   "Path is not a directory: %s"
                   path)
        (setq result nil)))

    ;;---
    ;; Return valid
    ;;---
    (iii:debug "iii:path:root/valid?" "->result: %S" result)
    result))
;; (iii:path:root/valid? "manual:test" "d:/home/spydez/.doom.d/modules/emacs/imp/")


;;------------------------------------------------------------------------------
;; String Helpers
;;------------------------------------------------------------------------------

(defun iii:path:to-string (symbol-or-string)
  "Translate the FEATURE (a single symbol) to a path string using
`imp:translate-to-path:replace' translations."
  (let ((name (if (symbolp symbol-or-string)
                  (symbol-name symbol-or-string)
                symbol-or-string))
        regex
        replacement)
    ;; Defaults first.
    (iii:debug "iii:path:to-string" "defaults:")
    (dolist (pair
             (iii:alist/general:get 'default imp:translate-to-path:replace)
             name)
      (setq regex (nth 0 pair)
            replacement (if (symbolp (nth 1 pair))
                                          (symbol-value (nth 1 pair))
                                        (nth 1 pair)))
      (iii:debug "iii:path:to-string" "  rx: %S" regex)
      (iii:debug "iii:path:to-string" "  ->: %S" replacement)
      (setq name (replace-regexp-in-string regex replacement name)))

    ;; Now the system-specifics, if any. Return `name' from `dolist' because
    ;; we're done.
    (iii:debug "iii:path:to-string" "system(%S):" system-type)
    (dolist (pair
             (iii:alist/general:get system-type imp:translate-to-path:replace)
             name)
      (setq regex (nth 0 pair)
            replacement (if (symbolp (nth 1 pair))
                                          (symbol-value (nth 1 pair))
                          (nth 1 pair)))
      (iii:debug "iii:path:to-string" "  rx: %S" regex)
      (iii:debug "iii:path:to-string" "  ->: %S" replacement)
      (setq name (replace-regexp-in-string regex replacement name)))))
;; (iii:path:to-string :imp)
;; Should lose both slashes:
;; (iii:path:to-string "~/doom.d/")
;; bugged: (iii:path:to-string "config")


(defun iii:path:imp->string (feature)
  "Normalize FEATURE (a list of symbols/keywords) to a list of strings.

Returns the list of normalized string."
  (mapcar #'iii:path:to-string feature))
;; (iii:path:imp->string '(:root test feature))
;; bugged: (iii:path:imp->string '(spy system config))


;;------------------------------------------------------------------------------
;; Path Helpers
;;------------------------------------------------------------------------------

(defun iii:path:append (parent next)
  "Append NEXT element as-is to PARENT, adding dir separator between them if
needed.

NEXT and PARENT are expected to be keywords or symbols.
"
  ;; Error checks first.
  (cond ((and parent
              (not (stringp parent)))
         (iii:error "iii:path:append"
                    "Paths to append must be strings. Parent is: %S"
                    parent))
        ((or (null next)
             (not (stringp next)))
         (iii:error "iii:path:append"
                    "Paths to append must be strings. Next is: %S"
                    next))

        ;;---
        ;; Append or not?
        ;;---
        ;; Expected initial case for appending: nil parent, non-nil next.
        ((null parent)
         next)

        (t
         (concat (file-name-as-directory parent) next))))


(defun iii:path:features->path (feature)
  "Combine FEATURE (a list of keywords/symbols) together into a path
platform-agnostically.

(iii:path:features->path :jeff 'jill)
  -> \"jeff/jill\"
or possibly
  -> \"jeff\\jill\""
  (iii:debug "iii:path:features->path" "--input: %S" feature)
  (unless (seq-every-p #'symbolp feature)
    (iii:error "iii:path:features->path"
               "FEATURE list must only contain symbols/keywords. Got: %S"
               feature))
  (seq-reduce #'iii:path:append
              (iii:path:imp->string feature)
              nil))
;; works: (iii:path:features->path '(:jeff jill))
;; fails: (iii:path:features->path '("~/.doom.d/" "modules"))
;; bugged: (iii:path:features->path '(spy system config))


;;------------------------------------------------------------------------------
;; Load Symbols -> Load Path
;;------------------------------------------------------------------------------

(defun iii:path:get (feature)
  "Convert FEATURE (a list of keywords/symbols) to a load path string.

NOTE: the first element in FEATURE must exist as a root in `imp:path:roots',
presumably by having called `imp:root'."
  (iii:path:append (iii:path:root/dir (car feature))
                   (iii:path:features->path (cdr feature))))
;; (iii:path:get '(:imp test feature))
;; (iii:path:get '(:config spy system config))


;; TODO: Move this to init.el with other defcustoms.
(defcustom imp:path:find/regex
  (rx
   ;; Prefix
   (group (optional (or "+"
                        ;; Any other prefixes?
                        )))
   ;; Feature Name to insert
   "%S"
   ;; Postfix
   (group (optional (or ".el"
                        ".imp.el"))))
  "Regex to apply to each name in a feature list (except root) when searching
for a filepath match.

Feature name string will replace the '%S'.")


;; TODO: Change to this after implementing?
(defun iii:path:find (feature)
  "Convert FEATURE (a list of keywords/symbols) to a load path.

1) Converts FEATURE into a load path regex string.
2) Searches for a load path that matches.
   - Fails if more than one match: nil return.
   - Fails if zero matches: nil return.
3) Returns load path string if it exists, nil if not.

NOTE: the first element in FEATURE must exist as a root in `imp:path:roots',
presumably by having called `imp:root'.

Example:
  (iii:path:find :imp 'foo 'bar 'baz)
  Could return:
    -> \"/path/to/imp-root/foo/bar/baz.el\"
    -> \"/path/to/imp-root/+foo/bar/baz.el\"
    -> \"/path/to/imp-root/foo/+bar/baz.el\"
    -> \"/path/to/imp-root/+foo/bar/+baz.el\"
    -> etc, depending on `imp:path:find/regex' settings."
  ;; TODO: implement this.
  ;; Features to strings.
  ;; For each string except first:
  ;;   - turn into regex
  ;; Search for path that matches regex somehow.
  ;; Return if found.
  nil)


;;------------------------------------------------------------------------------
;; Public API: Feature Root Directories
;;------------------------------------------------------------------------------

(defun imp:path:features->path (&rest feature)
  "Combine FEATURE (keywords/symbols) together into a path
platform-agnostically.

(imp:path:features->path :jeff 'jill)
  -> \"jeff/jill\"
or possibly
  -> \"jeff\\jill\""
  (iii:debug "imp:path:features->path" "input: %S" feature)
  (iii:path:features->path feature))
;; works: (imp:path:features->path :jeff 'jill)
;; fails: (imp:path:features->path "~/.doom.d/" "modules")


(defun imp:path:paths->path (&rest paths)
  "Combine PATHS (a list of path strings) together into a path
platform-agnostically.

(imp:path:paths->path \"~/.doom.d\" \"foo\" \"bar\")
  -> \"~/.doom.d/foo/bar\""
  (seq-reduce #'iii:path:append
              paths
              nil))
;; works: (imp:path:paths->path "~/.doom.d/" "modules")
;; fails: (imp:path:paths->path :jeff 'jill)


(defun imp:path:root (keyword path-to-root-dir &optional path-to-root-file)
  "Set the root path(s) of KEYWORD for future `imp:require' calls.

PATH-TO-ROOT-DIR is the directory under which all of KEYWORD's features exist.

PATH-TO-ROOT-FILE is nil or the file to load if only KEYWORD is used in an
`imp:require', and the feature isn't loaded, AND we have the entry... somehow...
in `imp:path:roots'.
  - This can be either an absolute or relative path. If relative, it will be
    relative to PATH-TO-ROOT-DIR."
  (cond ((iii:path:root/contains? keyword)
         (iii:error "imp:root"
                    "Keyword '%S' is already an imp root.\n  path: %s\n  file: %s"
                    keyword
                    (iii:path:root/dir keyword)
                    (iii:path:root/file keyword)))

        ((not (keywordp keyword))
         (iii:error "imp:root"
                    "Keyword must be a keyword (e.g. `:foo' `:bar' etc)"))

        ;; iii:path:root/valid? will error with better reason, so the error here
        ;; isn't actually triggered... I think?
        ((not (iii:path:root/valid? "imp:root" path-to-root-dir))
         (iii:error "imp:root"
                    "Path must be a valid directory: %s" path-to-root-dir))

        ;; Ok; set keyword to path.
        (t
         (push (list keyword path-to-root-dir path-to-root-file)
               imp:path:roots))))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------

;; Might as well automatically fill ourself in.
(let ((dir/imp (file-name-directory (if load-in-progress
                                        load-file-name
                                      (buffer-file-name)))))
  (imp:path:root :imp
                 ;; root dir
                 dir/imp
                 ;; root file - just provide relative to dir/imp
                 "init.el"))

;; And provide; we have an external/API function so we'd like to follow our imp
;; policy of using `imp:provide:with-emacs', but...
;; We are loaded before that exists.
;;   (imp:provide:with-emacs :imp 'path)
;; So instead expect someone to call this function:
(defun iii:path:provide ()
  "Lets the imp:path module provide itself after
`imp:provide:with-emacs' is loaded."
  (imp:provide:with-emacs :imp 'path))
