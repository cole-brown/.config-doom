;; -*- mode: emacs-lisp; lexical-binding: t -*-

;;-------------------------------------spy--------------------------------------
;;--                             Path Functions                               --
;;---------------------------------/mnt/hello-----------------------------------

(imp:require :str)


;;------------------------------------------------------------------------------
;; Path Functions
;;------------------------------------------------------------------------------


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
;; (path:join "jeff")


(defun path:file-path (parent &rest path)
  "Given a base dir, and a &rest of e.g. ('path/to' 'dir'
'with-file' 'file.txt'), will return full /file/ path in
platform-agnostic manner. Does not 'fix' any `path' components;
they are expected to be valid.
"
  (apply #'path:join
         (expand-file-name "" parent)
         path))
;; (path:file-path "~" "personal" "something.exe" "zort.txt")


(defun path:dir-path (parent &rest path)
  "Given a base dir, and a &rest of e.g. ('path/to' 'dir' 'with-file'),
will return full /directory/ path in platform-agnostic manner.
Does not 'fix' any `path' components; they are expected to be
valid."
  ;; fully qualify base as start of return value
  (file-name-as-directory (apply #'path:file-path parent path)))
;; (path:dir-path "~" "personal" "something" "zort")


(defun path:relative-path (&optional path root)
  "Given a possibly absolute PATH, try to trim out ROOT. If both
nil, returns file name."
  (let ((path (or path (buffer-file-name)))
        (root (or root "")))
    (s-replace (file-name-as-directory  ;; make sure to have an ending slash
                (expand-file-name root)) ;; and expand it out fully
               "" ;; replace with nothing
               (expand-file-name path)))) ;; make sure we're all expanded here too.
;; (path:relative-path "/path/to/a/file/location.txt" "/path/to/a/")
;; (path:relative-path)


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
