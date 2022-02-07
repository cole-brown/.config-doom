;; -*- mode: emacs-lisp; lexical-binding: t -*-

;;-------------------------------------spy--------------------------------------
;;--                             Path Functions                               --
;;---------------------------------/mnt/hello-----------------------------------

(imp:require :str)

;; TODO: defaliases for emacs's path functions?
;;   - file-name-as-directory == path->dir ?
;;     - and some inverse: path->file ?

;;------------------------------------------------------------------------------
;; Predicates
;;------------------------------------------------------------------------------

(defun path:directory? (path)
  "Returns non-nil if PATH is a directory name path."
  (directory-name-p path))


(defun path:file? (path)
  "Returns non-nil if PATH is a file name path."
  (not (path:directory? path)))


(defun path:absolute? (path)
  "Returns non-nil if PATH is an absolute path."
  (file-name-absolute-p path))


;;------------------------------------------------------------------------------
;; Traversal
;;------------------------------------------------------------------------------

(defun path:parent (path)
  "Returns the parent directory of PATH."
  (directory-file-name (file-name-directory path)))


;;------------------------------------------------------------------------------
;; Join
;;------------------------------------------------------------------------------

;; TODO: `path:validate' function?

(defun int<path>:append (parent next)
  "Append NEXT element as-is to parent, adding dir separator between them if
needed.

NEXT is normalized via `str:normalize:name->list', so
keywords or symbol names can be used as well as strings."
  ;; Use next's string value, or symbol name.
  (let ((next (car (str:normalize:name->list next))))
    (if (null parent)
        next
      (concat (file-name-as-directory parent) next))))
;; (int<path>:append nil "jeff")
;; (str:normalize:name->list "jill")
;; (int<path>:append "jeff" "jill")
;; (int<path>:append "jeff/" "jill")
;; (int<path>:append "jeff/" :jill)


(defun path:join (&rest path)
  "Combines PATH elements together into a path platform-agnostically.

(path:join \"jeff\" \"jill.el\")
  ->\"jeff/jill.el\""
  (-reduce #'int<path>:append path))
;; (path:join "jeff" "jill")
;; (path:join "jeff" "jill/")
;; (path:join "jeff")


;;------------------------------------------------------------------------------
;; Split
;;------------------------------------------------------------------------------


(defvar int<path>:separators:rx (rx-to-string '(one-or-more (or ?/ ?\\)) ;; '(or ?/ ?\\)
                                              :no-group)
  "Separators for Windows and Linux paths.")


(defun int<path>:filter:strings:keep (item)
  "`-keep' needs the item itself returned, so you can't just use `stringp'."
  (and (stringp item) item))


;;------------------------------
;; Path Segments
;;------------------------------

(defun path:segments (&rest path)
  "Splits all PATH strings by directory separators, returns a plist.

Returned PLIST will have these keys (if their values are non-nil).
  :drive   - Drive letter / name
           - \"C:/foo/bar\" -> \"C:\"
  :root    - Root of the path (\"/\", \"C:\\\", etc.)
           - \"C:/foo/bar\" -> \"/\"
           - \"/foo/bar\" -> \"/\"
  :parents - Parent directory ancestors of PATH.
           - \"/foo/bar/baz\" -> '(\"foo\" \"bar\")
  :name    - Name of the final path element.
           - \"/foo/bar/baz\" -> \"baz\"
           - \"/foo/bar/\" -> \"bar\"
           - \"/foo/bar.tar.gz\" -> \"bar.tar.gz\""
  (let (drive
        root
        ;; `segments' will get split into `parents' and `name'.
        segments
        parents
        name
        output
        ;; Get rid of any nulls or invalid segments.
        (paths (-keep #'int<path>:filter:strings:keep path)))
    (if (null paths)
        (error "path:segments: PATH has no strings to split: %S"
               path)

      ;;------------------------------
      ;; Parse input.
      ;;------------------------------
      ;; Path is absolute if first/only segment is absolute.
      (when (path:absolute? (car paths))

        ;; If absolute, set the root directory.
        (setq root "/")

        ;; If on windows, set the root drive.
        (when (eq system-type 'windows-nt)
          (save-match-data
            (when (string-match (rx-to-string '(and string-start letter ":")
                                              :no-group)
                                (car paths))
              (setq drive (match-string 0 (car paths)))))))

      ;; Split each input into segments.
      (dolist (path paths)
        (dolist (segment (split-string path
                                       int<path>:separators:rx
                                       t
                                       split-string-default-separators))
          (push segment segments)))

      ;; `segments' is backwards, so first item is file/dir `name',
      ;; rest need to be reversed into the `parents'.
      (setq name    (car segments)
            parents (nreverse (cdr segments)))

      ;;------------------------------
      ;; Build output plist (in reverse).
      ;;------------------------------
      (when name
        (push name output)
        (push :name output))

      (when parents
        (push parents output)
        (push :parents output))

      (when root
        (push root output)
        (push :root output))

      (when drive
        (push drive output)
        (push :drive output))

      ;; Return segments plist.
      output)))
;; (path:segments "/foo/bar" "/baz")


;;------------------------------
;; Split on Dir Separators
;;------------------------------

(defun path:split (&rest path-segments)
  "Splits all PATH strings by directory separators, returns one list."
  ;; `path:segments' will do the heavy lifting.
  (let ((segments (apply #'path:segments path-segments)))
    ;; Now just convert the plist into a list, and drop any nulls.
    (-keep #'int<path>:filter:strings:keep
           (-flatten (list
                      (plist-get segments :drive)
                      (plist-get segments :root)
                      (plist-get segments :parents)
                      (plist-get segments :name))))))
;; (path:split "/foo/bar" "/baz")


;;------------------------------------------------------------------------------
;; Normalize / Canonicalize
;;------------------------------------------------------------------------------

(defun path:canonicalize:file (path &rest segment)
  "Canonicalize/normalize a file PATH and path SEGMENTS.

Returns an absolute path.

Does not fix or validate PATH or SEGMENT components; they are expected to be valid."
  (apply #'path:join
         (expand-file-name "" path)
         segment))
;; (path:canonicalize:file "~" "personal" "something.exe" "zort.txt")


(defalias 'path:absolute:file 'path:canonicalize:file)
(defalias 'path:abs:file      'path:canonicalize:file)


(defun path:canonicalize:dir (path &rest segment)
  "Canonicalize/normalize a directory PATH and path SEGMENTS.

Returns an absolute path.

Does not fix or validate PATH or SEGMENT components; they are expected to be valid."
  ;; Fully qualify base as start of return value.
  (file-name-as-directory (apply #'path:canonicalize:file path segment)))
;; (path:canonicalize:dir "~" "personal" "something" "zort")


(defalias 'path:absolute:dir 'path:canonicalize:dir)
(defalias 'path:abs:dir      'path:canonicalize:dir)


(defun path:canonicalize:absolute (path &rest segment)
  "Canonicalize/normalize a file PATH and path SEGMENTS.

Attempts to preserve file/directory-ness off PATH - that is, tries to
preserve the final slash if it exists.

Returns an absolute path.

Does not fix or validate PATH or SEGMENT components; they are expected to be valid."
  (let ((path/joined (apply #'path:join path segment)))
    (funcall (if (path:directory? path/joined)
                 #'path:canonicalize:dir
               #'path:canonicalize:file)
             path/joined)))
;; (path:canonicalize:absolute "/foo" "bar")
;; (path:canonicalize:absolute "/foo" "bar/")


(defalias 'path:canonicalize       'path:canonicalize:absolute)
(defalias 'path:absolute           'path:canonicalize:absolute)
(defalias 'path:abs                'path:canonicalize:absolute)


;;------------------------------------------------------------------------------
;; Relative Paths
;;------------------------------------------------------------------------------

(defun path:canonicalize:relative (&optional path root)
  "Returns a file path to PATH relative to ROOT.

Could just return PATH if it has no relation to ROOT.

Raises an error if PATH is not a string.
Raises an error if ROOT is not nil and not a string."
  (unless (stringp path)
    (error "path:canonicalize:relative: PATH must be a string! Got: path: %S, root: %S"
           path root))
  (unless (or (null root)
              (stringp root))
    (error "path:canonicalize:relative: ROOT must be nil or a string! Got: path: %S, root: %S"
           path root))

  ;; Translate nil ROOT to empty string if needed.
  ;; And canonicalize our paths.
  (let ((root (or (path:canonicalize:dir root) ""))
        (path (path:canonicalize:file path)))
    ;; Don't like `file-relative-name' as it can return wierd things when it
    ;; goes off looking for actual directories and files...
    (replace-regexp-in-string
     root ;; Look for ROOT directory path...
     ""   ;; Replace with nothing to get a relative path.
     path ;; Ensure
     :fixedcase
     :literal)))
;; (path:canonicalize:relative "/path/to/a/file/location.txt" "/path/to/a/")
;; (path:canonicalize:relative "/path/to/a/dir/location/" "/path/to/a/")
;; (path:canonicalize:relative "/path/to/a/dir/location/" "/path/to/a")
;; (path:canonicalize:relative)


(defalias 'path:relative           'path:canonicalize:relative)
(defalias 'path:rel                'path:canonicalize:relative)


;;------------------------------------------------------------------------------
;; Current Paths
;;------------------------------------------------------------------------------

(defun path:current:file ()
  "Return the emacs lisp file this function is called from.

Works when:
  - byte compiling
    - `byte-compile-current-file'
  - loading
    - `load-file-name'
    - `current-load-list'
  - visiting/evaluating
    - `buffer-file-name'

Raises an error signal if it cannot find a file path."
  (cond
   ;;------------------------------
   ;; Look for a valid "current file" variable.
   ;;------------------------------
   ((bound-and-true-p byte-compile-current-file))

   (load-file-name)

   ((stringp (car-safe current-load-list))
    (car current-load-list))

   (buffer-file-name)

   ;;------------------------------
   ;; Error: Didn't find anything valid.
   ;;------------------------------
   ((error "path:current:file: Cannot get the current file's path."))))
;; (path:current:file)


(defun path:current:dir ()
  "Returns the directory of the emacs lisp file this function is called from.

Uses `path:current:file' and just chops off the filename."
  (when-let (path (path:current:file))
    (directory-file-name (file-name-directory path))))
;; (path:current:dir)


;;------------------------------------------------------------------------------
;; Translations Between OSes
;;------------------------------------------------------------------------------

;; There are some existing packages for dealing with windows->unix or unix->windows paths...
;;   Windows emacs, Cygwin paths: https://www.emacswiki.org/emacs/cygwin-mount.el
;;   Cygwin/WSL emacs, win paths: https://github.com/victorhge/windows-path
;; but..: aren't on melpa, haven't been updated in years, etc.
(defun path:translate (from to dir)
  "Translates a path style, e.g. from Windows to WSL.

FROM and TO should be one of: (:windows :wsl :linux)
DIR should be a string.

For `:windows' -> `:wsl':
  - Translates '<drive>:' to '/mnt/<drive>'.
  - Translates '\\' to '/'.
"
  (let ((trans dir))
    ;; Translate: :windows -> :wsl
    (cond ((and (eq from :windows)
                (eq to   :wsl))
           (let ((drive nil)
                 (path nil))
             ;; Regex to:
             ;;   1) Find <drive> letter.
             ;;   2) Ignore ':'.
             ;;   3) Find <path>.
             (if (not (string-match (rx string-start
                                        ;; Get drive letter as a capture group.
                                        (group (= 1 (any "a-z" "A-Z")))
                                        ":"
                                        (group (zero-or-more anything))
                                        string-end)
                                    dir))
                 ;; No match - no translation.
                 (setq trans "")
               (setq drive (downcase (match-string 1 dir))
                     path (match-string 2 dir))
               (setq trans (concat "/mnt/"
                                   drive
                                   (replace-regexp-in-string (rx "\\")
                                                             "/"
                                                             path))))))

          ;; Translate: :windows -> :wsl
          ((and (eq from :wsl)
                (eq to   :windows))
           ;; Replace '/mnt/<drive>' with '<drive>:'.
           (let ((drive nil)
                 (path nil))
             ;; Regex to:
             ;;   1) Trim off leading "/mnt/".
             ;;   2) Find <drive> letter.
             ;;   3) Find <path>.
             (if (not (string-match (rx string-start
                                        "/mnt/"
                                        ;; Get drive letter as a capture group.
                                        (group (= 1 (any "a-z" "A-Z")))
                                        (group (or (and (not (any "a-z" "A-Z"))
                                                        (zero-or-more anything))
                                                   string-end)))
                                    dir))
                 ;; No match - no translation.
                 (setq trans "")

               ;; Get drive and path from regex matching, then build
               ;; translation.
               (setq drive (upcase (match-string 1 dir))
                     path (match-string 2 dir)
                     trans (concat drive
                                   ":"
                                   (if (and (not (null path))
                                            (not (string= "" path)))
                                       path
                                     "/"))))))

          ;; Fallthrough -> error out.
          (t
           (error "path:translate currently does not support %s -> %s: %s"
                  from to path)))

    ;; Return the translation.
    trans))
;; (path:translate :windows :wsl "D:/path/to/somewhere.txt")
;; (path:translate :windows :wsl "D:/path/to/somewhere.txt")
;; (path:translate :wsl :windows "/mnt/d/path/to/somewhere.txt")
;; Should not be able to translate so should return "".
;; (path:translate :windows :wsl "~/path/to/somewhere.txt")


(defun int<path>:type (path)
  "Tries to guess a path type.

Returns:
   :wsl     - Linux path to a windows drive?
   :windows - Windows path?
   :linix   - Linux path?
"
  ;; Start guessing...
  ;; If it has a backslash, it's probably windows.
  (cond ((s-contains? "\\" path)
         :windows)

        ;; Does it start with a drive-letter and colon?
        ;; Probably windows.
        ((string-match (rx string-start
                           letter
                           ":")
                       path)
         :windows)

        ((string-match (rx string-start
                           "/mnt/"
                           letter
                           "/")
                       path)
         :wsl)

        (t
         :linux)))


(defun path:cmd:translate (path)
  "Tries to auto-guess source/dest path types and then translate the path."
  (interactive "sPath: ")
  (let* ((source (int<path>:type path))
         (dest (if (eq source :windows)
                   ;; WSL should work for translating to Linux too?
                   :wsl
                 :windows))
         (translated (path:translate source
                            dest
                            path)))
    ;; Copy to kill-ring...
    (kill-new translated)
    ;; Return it.
    translated))
;; (path:cmd:translate "D:/")


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :path 'path)
