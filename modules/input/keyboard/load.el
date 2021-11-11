;;; input/keyboard/load.el -*- lexical-binding: t; -*-


;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                            Loading Files...                            ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;                               PC LOAD LETTER                               ;;
;;                                 ──────────                                 ;;

(imp:require :input 'keyboard 'utils)


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

(defconst int<keyboard>:path:dir/root (dir!)
  "Absolute path to `:input/keyboard' root directory.")


(defconst int<keyboard>:path:dir/layouts "layout"
  "Relative path from `int<keyboard>:path:dir/root' to the directory with all
the layout directories.")


(defconst int<keyboard>:path:dir/layout/prefix "+"
  "Layout dirs must start with a '+'.")


;;------------------------------------------------------------------------------
;; Debugging Helper
;;------------------------------------------------------------------------------

(defun int<keyboard>:load:loading? ()
  "Use this to hide code you only want to run during Doom/Emacs start-up or to
do some debugging vs actual stuff.

For best, most consistent results: do not use this at all.

Returns non-nil if `doom-init-p' is nil."
  ;; This var is set to `t' after Doom has been initialized.
  ;; ...it's already set by the time this runs.
  ;;(not doom-init-p)

  ;; Maybe this one is more accurate.
  ;; Nope. This gives us 'not loading' when this file is loaded...
  ;; (not doom-init-modules-p)

  ;; I give up? If `load-file-name' is set, some file is being loaded right now.
  load-file-name)


;;------------------------------------------------------------------------------
;; Path Functions
;;------------------------------------------------------------------------------

(defun int<keyboard>:path:append (parent next)
  "Append NEXT element as-is to PARENT, adding dir separator between them if
needed.

NEXT and PARENT are expected to be strings.
"
  (cond ((and (null parent)
              (null next))
         nil)
        ((null parent)
         ;; Normalize backslashes to forward slashes, if present.
         (directory-file-name next))
        (t
         (concat (file-name-as-directory parent) next))))


(defun int<keyboard>:path:join (&rest paths)
  "Joins together all strings in PATHS.
If relative, will prepend `int<keyboard>:path:dir/root'."
  (let ((path (seq-reduce #'int<keyboard>:path:append paths nil)))
    (if (file-name-absolute-p path)
        path
      (int<keyboard>:path:append int<keyboard>:path:dir/root path))))
;; (int<keyboard>:path:join nil "bar")
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

LAYOUT can be the flag symbol or keyword (see `int<keyboard>:normalize->keyword').

E.g. if `:dvorak' is our desired layout, this returns non-nil for LAYOUT
`:dvorak', and nil for others."
  (and int<keyboard>:layout:desired
       layout
       (eq int<keyboard>:layout:desired
           (int<keyboard>:normalize->keyword layout))))
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
  (let ((func/name "int<keyboard>:load:file")
        (debug.tags '(:load))
        (load-name.ext (file-name-extension load-name))
        path.load
        path.file)
    (int<keyboard>:debug
        func/name
        debug.tags
      '("args:\n"
        "  layout:        %S\n"
        "  load-name:     %S\n"
        "  load-name.ext: %S (valid?: %S)\n"
        "  root:          %S")
      layout
      load-name
      load-name.ext (not (and (not (null load-name.ext))
                              (string-prefix-p "el" load-name.ext)))
      root)

    ;;------------------------------
    ;; Error checking and path set-up part 1 - the root part.
    ;;------------------------------
    (cond
     ;;---
     ;; Errors
     ;;---
     ;; If root is provided, it must be a string.
     ((and root
           (not (stringp root)))
      (int<keyboard>:output :error
                            func/name
                            "ROOT must be a string or `nil'! Got '%s' from: %S"
                            (type-of root)
                            root))

     ;; Caller should provide name sans extension so we can load '*.elc' if it exists.
     ;; But make sure not to disqualify names with dots - e.g. "jeff.dvorak" should load "jeff.dvorak.el"
     ((and (not (null load-name.ext))
           (string-prefix-p "el" load-name.ext)
           ;; May be pushing into overkill but don't disqualify something like "jeff.eldorado".
           (or (= 2 (length load-name.ext))
               (= 3 (length load-name.ext))))
      (int<keyboard>:output :error
                            func/name
                            "LOAD-NAME should not include an emacs file extension ('el*')! Got '%s' from: %s"
                            load-name.ext
                            load-name))

     ;; Path's ROOT should be absolute, if provided.
     ((and root
           (not (file-name-absolute-p root)))
      (int<keyboard>:output :error
                            func/name
                            "ROOT, if provided, must be absolute! Got: %S"
                            root))

     ;;---
     ;; Valid roots.
     ;;---
     ;; Absolute ROOT - ok as-is.
     (root
      nil)

     ;; Not provided - set the root.
     (t
      (setq root int<keyboard>:path:dir/root)
      (int<keyboard>:debug
          func/name
          debug.tags
        '("No ROOT provided; using `int<keyboard>:path:dir/root'."
          "  root: %S")
        int<keyboard>:path:dir/root)))

    ;;------------------------------
    ;; PATH setup part 2 - the relative part.
    ;;------------------------------
    (int<keyboard>:debug
        func/name
        debug.tags
      '("Creating PATH from:\n"
        "  root: %S\n"
        "  children:\n"
        "    - %S\n"
        "    - %S\n"
        "  file: %S")
      root
      int<keyboard>:path:dir/layouts
      (concat
       int<keyboard>:path:dir/layout/prefix
       (int<keyboard>:normalize->string layout))
      load-name)
    (setq path.load (int<keyboard>:path:join root
                                             ;; All are layouts in this sub-dir.
                                             int<keyboard>:path:dir/layouts
                                             ;; Add the required '+'.
                                             (concat
                                              int<keyboard>:path:dir/layout/prefix
                                              (int<keyboard>:normalize->string layout))
                                             ;; And the filename.
                                             load-name)
          path.file (concat path.load ".el"))
    (int<keyboard>:debug
        func/name
        debug.tags
      '("Created path:\n"
        "  <-path.load: %S\n"
        "  <-path.file: %S")
      path.load
      path.file)

    ;; Is it ok for some files to not exist, maybe?
    ;; Perhaps a layout has an init.el but not a config.el right now?..
    (if (int<keyboard>:path:file/exists? path.file)
        (progn
          (int<keyboard>:debug
              func/name
              debug.tags
            "Path exists; loading...")
          (load path.load))

      ;; If it's not ok to not exist, switch this to always output `:error' or `:warn'.
      (if error?
          (int<keyboard>:output :error
                                func/name
                                '("Path does not exist!\n"
                                  "  path.load: %s")
                                path.load)
        (int<keyboard>:debug
            func/name
            debug.tags
          '("Path does not exist!\n"
            "  path.load: %s")
          path.load)))))
;; (int<keyboard>:load:file :spydez "config")


;;------------------------------------------------------------------------------
;; Load Active Layout Functions
;;------------------------------------------------------------------------------

(defun int<keyboard>:load:active? (layout load-name &optional root error?)
  "Load LAYOUT if it is the desired layout according to `int<keyboard>:load:layout?'
and if its LOAD-NAME file exists on the filesystem.
  - And only if `int<keyboard>:testing:disable-start-up-init' is nil.

LOAD-NAME should be filename (without extension) to be passed to `load!' as:
(concat (file-name-as-directory \"layout\")
        (file-name-as-directory DIRECTORY)
        LOAD-NAME)

ROOT, if nil, will be LAYOUT's directory under `int<keyboard>:path:dir/root'
child directory 'layout'.
ROOT, if non-nil, must be absolute.

The extension '.el' is used to check for file existance.

ERROR?, if non-nil, will signal an error if the file does not exist.
  - If nil, a debug message will (try to) be output instead."
  (int<keyboard>:debug
      "int<keyboard>:load:active?"
      '(:load)
    '("Inputs:\n"
      "  - layout:    %S\n"
      "  - load-name: %S\n"
      "  - root:      %S\n"
      "  - error?:    %S")
    layout load-name root error?)

  ;; Only allow load if we have start-up-init enabled /and/ we're loading during start-up.
  (let* ((allow-load? (and (int<keyboard>:load:loading?)
                           (not int<keyboard>:testing:disable-start-up-init))))
    (int<keyboard>:debug
        "int<keyboard>:load:active?"
        '(:load)
      '("Load checks:\n"
        "     loading?        %S\n"
        "  && allow-init?     %S\n"
        "  == allow load?:    %S\n"
        "  && `load:layout?': %S\n"
        "  == load file? ---> %S")
      ;; Loading Allowed?
      (int<keyboard>:load:loading?)
      (not int<keyboard>:testing:disable-start-up-init)
      allow-load?
      ;; Layout?
      (int<keyboard>:load:layout? layout)
      ;; All together!
      (and allow-load?
           (int<keyboard>:load:layout? layout)))

    ;; Is loading allowed and...
    (when (and allow-load?
               ;; ...is this layout the desired one to load?
               (int<keyboard>:load:layout? layout))
      ;; Yes and yes - load it.
      (int<keyboard>:load:file layout load-name root error?))))
;; (int<keyboard>:load:active? :spydez "init")
;; (int<keyboard>:load:active? :spydez "config")


(defun keyboard:load:active (file &optional root error?)
  "Find/load active layout's FILE.

FILE should /not/ have its extension so that the '.elc' can be used if it exists.

ROOT, if nil, will be LAYOUT's directory under `int<keyboard>:path:dir/root'
child directory 'layout'.
ROOT, if non-nil, must be absolute.

Search relative to ROOT's `int<keyboard>:path:dir/layouts' directory. For each
directory found, load file name FILE /only if/ the directory name matches
the active layout.

ERROR?, if non-nil, will signal an error if the file does not exist.
  - If nil, a debug message will (try to) be output instead."
  ;; Find all files/dirs in the layout directory that match the layout folder regex.
  ;; Get their attributes too so we can filter down to just directories.
  (let* ((directory-path (int<keyboard>:path:join root int<keyboard>:path:dir/layouts))
         ;; Layout dirs must have '+' in front of them and must be our direct children.
         (files-and-attrs (directory-files-and-attributes directory-path
                                                          nil
                                                          (rx-to-string `(sequence
                                                                          string-start
                                                                          ,int<keyboard>:path:dir/layout/prefix
                                                                          (one-or-more print)
                                                                          string-end)
                                                                        :no-group)))
         loaded-something)
    ;; Iterate through what was found and figure out if its a directory.
    (dolist (file-and-attr files-and-attrs)
      (let ((name (car file-and-attr))
            (dir? (file-attribute-type (cdr file-and-attr))))
        ;; `file-attribute-type' returns t for a directory, so skip any
        ;; non-directories like so.
        (when dir?
          ;; Our keyboard layout directories are named such that they can be
          ;; passed into `int<keyboard>:load:active?'.
          (setq loaded-something (or (int<keyboard>:load:active? name file root error?)
                                     loaded-something)))))

    ;; Return something that indicates if anything was loaded.
    loaded-something))
;; (keyboard:load:active "config")
;; (keyboard:load:active "config")


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------

(defun keyboard:load:layouts/list (&optional root)
  "Get a list of all layout directories as layout keywords.

E.g. if 'input/keyboard/layout/' dir has subdirs '+foo', '+bar', and 'baz':
  -> '(:foo :bar)"
  (let* ((directory-path (int<keyboard>:path:join root int<keyboard>:path:dir/layouts))
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
          (push (int<keyboard>:normalize->keyword name) layouts))))))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :input 'keyboard 'load)
