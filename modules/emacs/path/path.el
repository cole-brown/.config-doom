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
  ->\"jeff/jill.el\"
"
  (-reduce #'int<path>:append path))
;; (path:join "jeff" "jill")
;; (path:join "jeff" "jill/")
;; (path:join "jeff")


;;------------------------------------------------------------------------------
;; Normalize / Canonicalize
;;------------------------------------------------------------------------------

;; TODO: Rename to `path:canonicalize:file'?
(defun path:file-path (path &rest segment)
  "Canonicalize/normalize a file PATH and path SEGMENTS.

Returns an absolute path.

Does not fix or validate PATH or SEGMENT components; they are expected to be valid."
  (apply #'path:join
         (expand-file-name "" path)
         segment))
;; (path:file-path "~" "personal" "something.exe" "zort.txt")


;; TODO: Rename to `path:canonicalize:dir'?
(defun path:dir-path (path &rest segment)
  "Canonicalize/normalize a directory PATH and path SEGMENTS.

Returns an absolute path.

Does not fix or validate PATH or SEGMENT components; they are expected to be valid."
  ;; Fully qualify base as start of return value.
  (file-name-as-directory (apply #'path:file-path path segment)))
;; (path:dir-path "~" "personal" "something" "zort")


(defun path:canonicalize:absolute (path &rest segment)
  "Canonicalize/normalize a file PATH and path SEGMENTS.

Attempts to preserve file/directory-ness off PATH - that is, tries to
preserve the final slash if it exists.

Returns an absolute path.

Does not fix or validate PATH or SEGMENT components; they are expected to be valid."
  (let ((path/joined (apply #'path:join path segment)))
    (funcall (if (path:directory? path/joined)
                 #'path:dir-path
               #'path:file-path)
             path/joined)))
;; (path:canonicalize:absolute "/foo" "bar")
;; (path:canonicalize:absolute "/foo" "bar/")


;;------------------------------------------------------------------------------
;; Relative Paths
;;------------------------------------------------------------------------------

;; TODO: Rename to `path:canonicalize:relative'?
(defun path:relative-path (&optional path root)
  "Returns a file path to PATH relative to ROOT.

Could just return PATH if it has no relation to ROOT.

Raises an error if PATH is not a string.
Raises an error if ROOT is not nil and not a string."
  (unless (stringp path)
    (error "path:relative-path: PATH must be a string! Got: path: %S, root: %S"
           path root))
  (unless (or (null root)
              (stringp root))
    (error "path:relative-path: ROOT must be nil or a string! Got: path: %S, root: %S"
           path root))

  ;; Translate nil ROOT to empty string if needed.
  ;; And canonicalize our paths.
  (let ((root (or (path:dir-path root) ""))
        (path (path:file-path path)))
    (replace-regexp-in-string
     root ;; Look for ROOT directory path...
     ""   ;; Replace with nothing to get a relative path.
     path ;; Ensure
     :fixedcase
     :literal)))
;; (path:relative-path "/path/to/a/file/location.txt" "/path/to/a/")
;; (path:relative-path "/path/to/a/dir/location/" "/path/to/a/")
;; (path:relative-path "/path/to/a/dir/location/" "/path/to/a")
;; (path:relative-path)


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
