;;; input/keyboard/load.el -*- lexical-binding: t; -*-


;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                            Loading Files...                            ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;                               PC LOAD LETTER                               ;;
;;                                 ──────────                                 ;;


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

(defconst input//kl:dir/root (dir!)
  "Absolute path to `:input/keyboard' root directory.")


(defconst input//kl:dir/layout/prefix "+"
  "Layout dirs must start with a '+'.")


;;------------------------------------------------------------------------------
;; Path Functions
;;------------------------------------------------------------------------------

(defun input//kl:path/append (parent next)
  "Append NEXT element as-is to PARENT, adding dir separator between them if
needed.

NEXT and PARENT are expected to be strings.
"
  (if (null parent)
      next
    (concat (file-name-as-directory parent) next)))


(defun input//kl:path (&rest paths)
  "Joins together all strings in PATHS.
If relative, will append `input//kl:dir/root'."
  (let ((path (seq-reduce #'input//kl:path/append paths nil)))
    (if (file-name-absolute-p path)
        path
      (input//kl:path/append input//kl:dir/root path))))
;; (input//kl:path "foo" "bar")
;; (input//kl:path "layout" "+spydez" "init.el")
;; (input//kl:path "c:/" "foo" "bar")


;;------------------------------------------------------------------------------
;; Basic Load Functions
;;------------------------------------------------------------------------------

(defun input//kl:file/exists? (&rest path)
  "Returns non-nil if PATH exists.
If relative, `input//kl:dir/root' will be used as the path's root."
  (file-exists-p (apply #'input//kl:path path)))
;; (input//kl:file/exists? "layout/+spydez/init.el")


(defun input//kl:loading-for (layout)
  "Returns non-nil if loading (or developing/debugging) for the LAYOUT.

LAYOUT can be the flag symbol or keyword (see `input//kl:normalize->keyword').

E.g. if `:dvorak' is our desired layout, this returns non-nil for LAYOUT
`:dvorak', and nil for others."
  (and input//kl:layout/desired
       layout
       (eq input//kl:layout/desired
           (input//kl:normalize->keyword layout))))
;; (input//kl:loading-for :spydez)
;; (input//kl:loading-for :qwerty)


(defun input:keyboard/layout:load-file (layout load-name &optional directory)
  "Load LOAD-NAME file if its LAYOUT directory and LOAD-NAME file exists on the
filesystem.

DIRECTORY, if nil, will be FLAG minus its '+' prefix (e.g. `+dvorak' is
'dvorak/' directory).
  - The keyboard layout's keyword is also accepted (e.g. `:dvorak').

LOAD-NAME should be filename (without extension) to be passed to `load!' as:
(concat (file-name-as-directory \"layout\")
        (file-name-as-directory DIRECTORY)
        LOAD-NAME)

The extension '.el' is used to check for file existance."
  ;; Allow keyword or flag.
  (let* ((directory (or directory
                        (input//kl:normalize->string layout)))
         (path (input//kl:path "layout"
                               (concat
                                ;; Add the required '+'.
                                input//kl:dir/layout/prefix
                                ;; Should end up the same.
                                ;; Does in current cases, anyawys. [2021-06-05]
                                (or directory
                                    (input//kl:normalize->string layout)))
                               load-name)))
    ;; Is it ok for some files to not exist, maybe?
    ;; Perhaps a layout has an init.el but not a config.el right now?..
    (when (input//kl:file/exists? (concat path ".el"))
      (load! path))
    ;; If not, switch back to this:
    ;; (if (input//kl:file/exists? (concat path ".el"))
    ;;     (load! path)
    ;;   (int<keyboard>:output :warn
    ;;                         "input:keyboard/layout:load-file"
    ;;                         '("Could not find "
    ;;                          "'%s' file for '%s'. path: %s")
    ;;                         load-name
    ;;                         flag
    ;;                         (concat path ".el")))
    ))
;; (input:keyboard/layout:load-file :spydez "config")


;;------------------------------------------------------------------------------
;; Load Active Layout Functions
;;------------------------------------------------------------------------------

(defun input:keyboard/layout:load-active (layout load-name &optional directory)
  "Load LAYOUT if it is the desired layout according to `input//kl:loading-for'
and if its LOAD-NAME file exists on the filesystem.
  - And only if `input//kl:testing:disable-start-up-init' is nil.

DIRECTORY, if nil, will be FLAG minus its default prefix (e.g. `+layout/dvorak'
is 'dvorak/' directory).
  - The keyboard layout's keyword is also accepted (e.g. `:dvorak').

LOAD-NAME should be filename (without extension) to be passed to `load!' as:
(concat (file-name-as-directory \"layout\")
        (file-name-as-directory DIRECTORY)
        LOAD-NAME)

The extension '.el' is used to check for file existance."
  (when (and
         ;; If we're loading during start-up /and/ have start-up-init disabled:
         ;; Do not load.
         (not (and (input//kl:loading?)
                   input//kl:testing:disable-start-up-init))
         ;; Only load for desired layout.
         (input//kl:loading-for layout))
    (input:keyboard/layout:load-file layout load-name directory)))
;; (input:keyboard/layout:load-active :spydez "init")
;; (input:keyboard/layout:load-active :spydez "config")


(defun input:keyboard/layout:find-and-load-active (file)
  "Find/load active layout's FILE.

Search relative to directory the caller is in. For each directory
found, load file name FILE /only if/ it is the directory name matches the active
layout.

FILE should /not/ have its extension so that the .elc can be used if it exists."
  ;; Find all files/dirs in the layout directory that match the layout folder regex.
  ;; Get their attributes too so we can filter down to just directories.
  (let* ((directory-path (input//kl:path "layout"))
         ;; Layout dirs must have '+' in front of them and must be our direct children.
         (files-and-attrs (directory-files-and-attributes directory-path
                                                          nil
                                                          (rx string-start
                                                              "+"
                                                              (one-or-more print)
                                                              string-end))))
    ;; Iterate through what was found and figure out if its a directory.
    (dolist (file-and-attr files-and-attrs)
      (let ((name (car file-and-attr))
            (dir? (file-attribute-type (cdr file-and-attr))))
        ;; `file-attribute-type' returns t for a directory, so skip any
        ;; non-directories like so.
        (when dir?
          ;; Our keyboard layout directories are named such that they can be
          ;; passed into `input:keyboard/layout:load-active'.
          (input:keyboard/layout:load-active name file))))))
;; (input:keyboard/layout:find-and-load-active "config")
;; (input:keyboard/layout:find-and-load-active "config")


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------

(defun input:keyboard/layout:list-layouts ()
  "Get a list of all layout directories as layout keywords.

E.g. if 'input/keyboard/layout/' dir has subdirs '+foo', '+bar', and 'baz':
  -> '(:foo :bar)"
  (let* ((directory-path (input//kl:path "layout"))
         ;; Layout dirs must have '+' in front of them and must be our direct children.
         (files-and-attrs (directory-files-and-attributes directory-path
                                                          nil
                                                          (rx string-start
                                                              "+"
                                                              (one-or-more print)
                                                              string-end)))
         layouts)
    ;; Iterate through what was found and figure out if its a directory.
    ;; Return `layouts' as the function's  return value.
    (dolist (file-and-attr files-and-attrs layouts)
      (let ((name (car file-and-attr))
            (dir? (file-attribute-type (cdr file-and-attr))))
        ;; `file-attribute-type' returns t for a directory, so skip any
        ;; non-directories like so.
        (when dir?
          ;; Convert to a layout keyword and add to the list.
          (push (input//kl:normalize->keyword name) layouts))))))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
