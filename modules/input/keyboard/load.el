;;; input/keyboard/load.el -*- lexical-binding: t; -*-


;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                            Loading Files...                            ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;                               PC LOAD LETTER                               ;;
;;                                 ──────────                                 ;;

;; (imp:require :input 'keyboard 'utils)


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


(defvar int<keyboard>:load:deny nil
  "Variable to disallow loading until unset.")


(defvar int<keyboard>:load:deny/valids '(:init :cmd :test)
  "Valid keyword flags for `int<keyboard>:load:deny'.")


;;------------------------------------------------------------------------------
;; Debugging Helper
;;------------------------------------------------------------------------------

(defun int<keyboard>:load:allowed? (&rest args)
  "Conditionally allow a load based on keywords in ARGS.

ARGS can contain:
  - `:init' - Allow if we are initializing (e.g. loading files during start-up).
  - `:cmd'  - Allow if we are being called interactively.
  - `:test' - We are testing; allow.

For `:cmd', caller should use macro `int<keyboard>:cmd:run' so that the flag
this function checks is set correctly."

  (let ((func/name "int<keyboard>:load:allowed?")
        (debug/tags '(:load))
        deny?
        denied-by)
    (int<keyboard>:debug:func
        func/name
        debug/tags
      :start
      (list (cons 'args args)))

    ;;------------------------------
    ;; Globally Denied?
    ;;------------------------------
    ;; `t' == always deny
    (when (or (eq t int<keyboard>:load:deny)
              (memq t int<keyboard>:load:deny))
      (push t denied-by))

    ;; Any arg match to a keyword in `int<keyboard>:load:deny'?
    (when-let ((matches (seq-intersection args int<keyboard>:load:deny)))
      (setq denied-by (append denied-by matches)))

    ;;------------------------------
    ;; Initializing
    ;;------------------------------
    (when (memq :init args)
      (setq deny? (not (and
                        ;;---
                        ;; Check if we're "starting up"...
                        ;;---
                        ;; I give up? If `load-file-name' is set, some file is being loaded right now.
                        load-file-name

                        ;;---
                        ;; Are we allowed to load during start-up?
                        ;;---
                        (not int<keyboard>:testing:disable-start-up-init))))
      (when deny?
        (push :init denied-by))
      (int<keyboard>:debug
          func/name
          debug/tags
        '("`:init' == \n"
          "  loading? %S\n"
          "  init not disabled? %S\n"
          "  ==> %S ==> deny? %S\n"
          "==> denied-by = %S")
        load-file-name
        (not int<keyboard>:testing:disable-start-up-init)
        (and
         load-file-name
         (not int<keyboard>:testing:disable-start-up-init))
        deny?
        denied-by))

    ;;------------------------------
    ;; Command
    ;;------------------------------
    (when (memq :cmd args)
      ;; Allow if we're inside an interactive call.
      (setq deny? (not (int<keyboard>:cmd:running?)))
      (int<keyboard>:debug
          func/name
          debug/tags
        '("`:cmd' == \n"
          "  cmd running? %S\n"
          "  ==> deny? %S\n"
          "==> denied-by %S")
        (not deny?)
        deny?
        denied-by)
      (when deny?
        (push :cmd denied-by)))

    ;;------------------------------
    ;; Testing
    ;;------------------------------
    ;; Must be last so we can force allow if `:test' supplied.
    (when (memq :test args)
      (int<keyboard>:debug
          func/name
          debug/tags
        '("`:test' == always allowed\n"
          "  `denied-by' was: %S\n"
          "Cleared out by `:test' flag.")
        denied-by)
      ;; Clear so no longer denied by anything.
      (setq denied-by nil))

    (when-let ((unknowns (seq-difference args int<keyboard>:load:deny/valids)))
      (int<keyboard>:debug
          func/name
          debug/tags
        "Unknown args: %S"
        unknows))

    (let ((return (null denied-by)))
      (int<keyboard>:debug:func
          func/name
          debug/tags
        :end/list
        (list (cons 'denied-by denied-by)
              (cons 'return return)))
      return)))
;; (int<keyboard>:load:allowed? :init)
;; (int<keyboard>:load:allowed? :cmd)
;; (int<keyboard>:load:allowed? :test)


(defmacro int<keyboard>:load:if-allowed (load-flags &rest body)
  "Run BODY if load-flags allow it."
  (declare (indent 1))
  `(condition-case err
       ;; Set `load:deny' flag to correct value and run body?
       (progn
         (int<keyboard>:load:deny/set load-flags)
         (unless int<keyboard>:load:deny
           ,@body))
     ;; Reset `load:deny' flag only if we found an error signal.
     ;; Normally it will be reset by a call to `int<keyboard>:load:deny/clear' after loading is done.
     (error
      (int<keyboard>:load:deny/clear)
      ;; Reraise the error signal.
      (signal (car err) (cdr err)))))


(defun int<keyboard>:load:deny/set (&rest load-flags)
  "Set deny based on LOAD-FLAGS."
  (let ((func/name "int<keyboard>:load:deny/set")
        (debug/tags '(:load)))
    (int<keyboard>:debug:func
        func/name
        debug/tags
      :start
      (list (cons 'args args)))

    (int<keyboard>:load:deny/clear)
    (let* ((flags/invalid (seq-difference load-flags int<keyboard>:load:deny/valids)))
      ;; Check for invalid flags.
      (when flags/invalid
        (int<keyboard>:output :error
                              func/name
                              "Unknown/invalid load-flags %S in input: %S"
                              flags/invalid
                              load-flags))

      ;; Set to the valid flags.
      (setq int<keyboard>:load:deny (seq-intersection int<keyboard>:load:deny/valids load-flags))
      (int<keyboard>:debug:func
          func/name
          debug/tags
        :end
        int<keyboard>:load:deny)

      int<keyboard>:load:deny)))


(defun int<keyboard>:load:deny/clear ()
  "Reset `int<keyboard>:load:deny' to nil."
  (setq int<keyboard>:load:deny nil))



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
        (debug/tags '(:load))
        (load-name.ext (file-name-extension load-name))
        path.load
        path.file)
    (int<keyboard>:debug
        func/name
        debug/tags
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
          debug/tags
        '("No ROOT provided; using `int<keyboard>:path:dir/root'."
          "  root: %S")
        int<keyboard>:path:dir/root)))

    ;;------------------------------
    ;; PATH setup part 2 - the relative part.
    ;;------------------------------
    (int<keyboard>:debug
        func/name
        debug/tags
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
        debug/tags
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
              debug/tags
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
            debug/tags
          '("Path does not exist!\n"
            "  path.load: %s")
          path.load)))))
;; (int<keyboard>:load:file :spydez "config")


;;------------------------------------------------------------------------------
;; Load Active Layout Functions
;;------------------------------------------------------------------------------

(defun int<keyboard>:load:active? (layout load-name load-flags &optional root error?)
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
      "  - layout:     %S\n"
      "  - load-name:  %S\n"
      "  - load-flags: %S\n"
      "  - root:       %S\n"
      "  - error?:     %S")
    layout load-name load-flags root error?)

  ;; Only allow load if we have start-up-init enabled /and/ we're loading during start-up.
  (let ((allow-load? (int<keyboard>:load:allowed? load-flags)))
    (int<keyboard>:debug
        "int<keyboard>:load:active?"
        '(:load)
      '("Load checks:\n"
        "  ----> allow-init?  %S\n"
        "     allow load?:    %S\n"
        "  && `load:layout?': %S\n"
        "  == load file? ---> %S")
      ;; Loading Allowed?
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
;; (int<keyboard>:load:active? :spydez "init" :cmd)
;; (int<keyboard>:load:active? :spydez "config" :cmd)


(defun keyboard:load:active (file load-flags &optional root error?)
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
          ;; Set `loaded-something' to true if any file loads.
          (setq loaded-something (or (int<keyboard>:load:active? name file load-flags root error?)
                                     loaded-something)))))

    ;; Return something that indicates if anything was loaded.
    loaded-something))
;; (keyboard:load:active "config" :cmd)
;; (keyboard:load:active "config" :cmd)


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
;; (imp:provide :input 'keyboard 'load)
