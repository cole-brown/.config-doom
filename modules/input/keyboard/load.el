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

(defconst int<keyboard>:path:dir/root (dir!)
  "Absolute path to `:input/keyboard' root directory.")


(defconst int<keyboard>:path:dir/layout/prefix "+"
  "Layout dirs must start with a '+'.")


;;------------------------------------------------------------------------------
;; Path Functions
;;------------------------------------------------------------------------------

(defun int<keyboard>:path:append (parent next)
  "Append NEXT element as-is to PARENT, adding dir separator between them if
needed.

NEXT and PARENT are expected to be strings.
"
  (if (null parent)
      ;; Normalize backslashes to forward slashes, if present.
      (directory-file-name next)
    (concat (file-name-as-directory parent) next)))


(defun int<keyboard>:path:join (&rest paths)
  "Joins together all strings in PATHS.
If relative, will append `int<keyboard>:path:dir/root'."
  (let ((path (seq-reduce #'int<keyboard>:path:append paths nil)))
    (if (file-name-absolute-p path)
        path
      (int<keyboard>:path:append int<keyboard>:path:dir/root path))))
;; (int<keyboard>:path:join "foo" "bar")
;; (int<keyboard>:path:join "layout" "+spydez" "init.el")
;; (int<keyboard>:path:join "c:/" "foo" "bar")


(defun int<keyboard>:path:file/exists? (&rest path)
  "Returns non-nil if PATH exists.
If relative, `int<keyboard>:path:dir/root' will be used as the path's root."
  (file-exists-p (apply #'int<keyboard>:path:join path)))
;; (int<keyboard>:path:file/exists? "layout/+spydez/init.el")


;;------------------------------------------------------------------------------
;; Basic Load Functions
;;------------------------------------------------------------------------------

(defun int<keyboard>:load:layout? (layout)
  "Returns non-nil if loading (or developing/debugging) for the LAYOUT.

LAYOUT can be the flag symbol or keyword (see `input//kl:normalize->keyword').

E.g. if `:dvorak' is our desired layout, this returns non-nil for LAYOUT
`:dvorak', and nil for others."
  (and input//kl:layout/desired
       layout
       (eq input//kl:layout/desired
           (input//kl:normalize->keyword layout))))
;; (int<keyboard>:load:layout? :spydez)
;; (int<keyboard>:load:layout? :qwerty)


(defun int<keyboard>:load:file (layout load-name &optional root error?)
  "Load LOAD-NAME file if its LAYOUT directory and LOAD-NAME file exists on the
filesystem.

LOAD-NAME should be the filename (without extension) to be loaded.

ROOT, if nil, will be LAYOUT's directory under `int<keyboard>:path:dir/root'
child directory 'layout'.
ROOT, if non-nil, must be absolute.

The extension '.el' is used to check for file existance.

ERROR?, if non-nil, will signal an error if the file does not exist.
  - If nil, a debug message will (try to) be output instead."
  (let ((func.name "int<keyboard>:load:file")
        (debug.tags '(:load))
        path)
    (int<keyboard>:debug
        func.name
        debug.tags
      '("args:\n"
        "  layout:    %S\n"
        "  load-name: %S\n"
        "  root:      %S")
      layout load-name root)

    ;;------------------------------
    ;; Error checking and path set-up part 1 - the root part.
    ;;------------------------------
    (cond ((and root
                (not (file-name-absolute-p root)))
           (int<keyboard>:output :error
                                 func.name
                                 "ROOT, if provided, must be absolute! Got: %S"
                                 root))

          ;; Absolute ROOT - ok as-is.
          (root
           nil)

          ;; Not provided - set the root.
          (t
           (setq root int<keyboard>:path:dir/root)
           (int<keyboard>:debug
               func.name
               debug.tags
             '("No ROOT provided; using `int<keyboard>:path:dir/root'."
               "  root: %S")
             int<keyboard>:path:dir/root)))

    ;;------------------------------
    ;; PATH setup part 2 - the relative part.
    ;;------------------------------
    (setq path (int<keyboard>:path:join path
                                        ;; All are layouts in this sub-dir.
                                        "layout"
                                        ;; Add the required '+'.
                                        (concat
                                         int<keyboard>:path:dir/layout/prefix
                                         (input//kl:normalize->string layout))
                                        ;; And the filename.
                                        load-name))
    (int<keyboard>:debug
        func.name
        debug.tags
      '("Created PATH from:\n"
        "  root: %S\n"
        "  children:\n"
        "    - %S\n"
        "    - %S\n"
        "  file: %S\n"
        "<-path: %S")
      int<keyboard>:path:dir/root
      "layout"
      (concat
       int<keyboard>:path:dir/layout/prefix
       (input//kl:normalize->string layout))
      load-name
      path)

    ;; Is it ok for some files to not exist, maybe?
    ;; Perhaps a layout has an init.el but not a config.el right now?..
    (if (int<keyboard>:path:file/exists? (concat path ".el"))
        (progn
          (int<keyboard>:debug
              func.name
              debug.tags
            "Path exists; loading...")
          (load path))

      ;; If it's not ok to not exist, switch this to always output `:error' or `:warn'.
      (if error?
          (int<keyboard>:output :error
                                func.name
                                '("Path does not exist!\n"
                                  "  path: %S")
                                path)
        (int<keyboard>:debug
            func.name
            debug.tags
          '("Path does not exist!\n"
            "  path: %S")
          path)))))
;; (int<keyboard>:load:file :spydez "config")


;;------------------------------------------------------------------------------
;; Load Active Layout Functions
;;------------------------------------------------------------------------------

(defun int<keyboard>:load:active? (layout load-name &optional directory)
  "Load LAYOUT if it is the desired layout according to `int<keyboard>:load:layout?'
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
         (int<keyboard>:load:layout? layout))
    (int<keyboard>:load:file layout load-name directory)))
;; (int<keyboard>:load:active? :spydez "init")
;; (int<keyboard>:load:active? :spydez "config")


(defun keyboard:load:active (file)
  "Find/load active layout's FILE.

Search relative to directory the caller is in. For each directory
found, load file name FILE /only if/ it is the directory name matches the active
layout.

FILE should /not/ have its extension so that the .elc can be used if it exists."
  ;; Find all files/dirs in the layout directory that match the layout folder regex.
  ;; Get their attributes too so we can filter down to just directories.
  (let* ((directory-path (int<keyboard>:path:join "layout"))
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
          ;; passed into `int<keyboard>:load:active?'.
          (int<keyboard>:load:active? name file))))))
;; (keyboard:load:active "config")
;; (keyboard:load:active "config")


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------

(defun keyboard:load:layouts/list ()
  "Get a list of all layout directories as layout keywords.

E.g. if 'input/keyboard/layout/' dir has subdirs '+foo', '+bar', and 'baz':
  -> '(:foo :bar)"
  (let* ((directory-path (int<keyboard>:path:join "layout"))
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
