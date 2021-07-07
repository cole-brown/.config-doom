;;; tools/autogit/status.el -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2021 Cole Brown
;; TODO: MIT or GPL dual license?
;; TODO: full header?
;;
;; Author: Cole Brown <http://github/cole-brown>
;; Maintainer: Cole Brown <code@brown.dev>
;; Created: 2020-08-28
;; Modified: 2021-06-30 10:10:10
;; Version: 0.0.1
;; Keywords:
;; Homepage: https://github.com/cole-brown/.config-secret
;; Package-Requires: ((emacs 27.1) (magit))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;; Commands for:
;;   - Getting general status for certain other git repos.
;;     + E.g. get status for your notes repo(s) and your code repo(s) in one go.
;;
;;; Code:


(require 'subr-x)

;; How to get this lazy loaded?
;;   - Take the require out of the funcs when figured out.
;; (require 'magit)


;;------------------------------------------------------------------------------
;; Usage
;;------------------------------------------------------------------------------



;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------


;;------------------------------------------------------------------------------
;; Misc
;;------------------------------------------------------------------------------

(defun autogit//emacs/doom? ()
  "Returns non-nil if a certain Doom function exists, which we'll assume means
we're running in Doom Emacs."
  (bound-and-true-p +popup-mode))


;;------------------------------------------------------------------------------
;; Paths & Files
;;------------------------------------------------------------------------------

(defun autogit//path (root &rest path)
  "Given a git ROOT, and a PATH of e.g. ('path/to' 'dir'
'with-file' 'file.txt'), will return full /file/ path in
platform-agnostic manner."
  (concat (file-name-as-directory (expand-file-name "" root))
          (directory-file-name (mapconcat #'file-name-as-directory path ""))))
;; (autogit//path (car autogit:repos:path/commit) "foo")


(defun autogit//changes/path/rel->abs (path-abs alist/changes)
  "Converts all of ALIST/CHANGES' relative paths to absolute paths give
any PATH-ABS inside of the git repository."
  (let* ((default-directory path-abs)
         (git-root (magit-toplevel))
         results)
    ;; Have alist of staged, unstaged, etc files.
    (dolist (entry alist/changes results)
      ;; Convert to absolute paths.
      (push (cons (car entry)
                  (mapcar (lambda (x) (autogit//path git-root x))
                          (cdr entry)))
            results))))
;; (autogit//changes/path/rel->abs default-directory (autogit//changes/in-repo default-directory))


;;------------------------------------------------------------------------------
;; Changes
;;------------------------------------------------------------------------------

(defun autogit//changes/in-repo (subdir-abs)
  "Determines if magit knows of any changes (staged, unstaged, untracked,
unmerged) in the repo that subdir-abs is a directory/sub-directory of.

Returns an alist of changes:
  '((:staged    . <list of filenames or nil)
    (:unstaged  . <list of filenames or nil)
    (:untracked . <list of filenames or nil)
    (:unmerged  . <list of filenames or nil))"
  ;; Magit works on `default-directory', so make sure to set that. Also magit
  ;; returns lowercase paths, so make sure to downcase for Windows.
  (let* ((subdir-abs (downcase subdir-abs))
         (default-directory subdir-abs))
    ;; These are all changes in repo, not subdir
    (list (cons :staged    (magit-staged-files))
          (cons :unstaged  (magit-unstaged-files))
          (cons :untracked (magit-untracked-files))
          (cons :unmerged  (magit-unmerged-files)))))
;; (autogit//changes/in-repo default-directory)


(defun autogit//changes/in-subdir (subdir-abs)
  "Gets all changes in repository that SUBDIR-ABS is a directory/sub-directory
of. Then filter them down to just changes that are in/under SUBDIR-ABS.

Returns an alist of changes:
  '((:staged    . <list of filenames or nil)
    (:unstaged  . <list of filenames or nil)
    (:untracked . <list of filenames or nil)
    (:unmerged  . <list of filenames or nil))"
  (let ((alist/changes (autogit//changes/path/rel->abs subdir-abs
                                                       (autogit//changes/in-repo subdir-abs)))
        results)
    ;; Need to filter each category of changes down to just the subdir requested.
    (dolist (entry alist/changes results)
      (push (cons (car entry)
                  (seq-filter (lambda (x) (string-prefix-p subdir-abs x)) (cdr entry)))
            results))))
;; (autogit//changes/in-subdir default-directory)


;; TODO: Ahead/behind upstream.
;;   - getter
;;   - summarizer
;; (cons "↑" commits-ahead)
;; (cons "↓" commits-behind)


(defun autogit//changes/summary (alist/changes)
  "Converts ALIST/CHANGES into a summary string.

ALIST/CHANGES should be output of `autogit//changes/in-subdir' or
`autogit//changes/in-repo':
  '((:staged    . <list of filenames or nil)
    (:unstaged  . <list of filenames or nil)
    (:untracked . <list of filenames or nil)
    (:unmerged  . <list of filenames or nil))

Will convert using `autogit:changes:symbols' custom var."
  (mapconcat
   (lambda (entry)
     "Convert alist ENTRY into a string of symbol (according to ENTRY's key) and integer (length of ENTRY's value)."
     (when-let ((symbol (alist-get (car entry) autogit:changes:symbols))
                (entries (length (cdr entry))))
       ;; TODO: if zero, display?
       ;;   - 0            (always)
       ;;   - blank space  (blank)
       ;;   - empty string (collapse)
       (concat symbol (number-to-string entries))))
   alist/changes
   " ")
  ;; TODO: also want ahead/behind upstream info?
  )
;; (autogit//changes/summary (autogit//changes/in-subdir default-directory))


(defun autogit//changes/commit-filter (alist/changes)
  "Returns either list of files to commit or a keyword.

Returns a keyword if you shouldn't commit changes.
  - :unmerged - unmerged changes exist - do not commit.
  - :no-op    - No staged/unstaged/untracked to commit.

Returns list of files to commit otherwise - collapses alist down into a
single list."
  ;; Disallow because unmerged?
  (cond ((> (length (alist-get :unmerged alist/changes))
            0)
         :unmerged)

        ;; Nothing to do.
        ((and (= (length (alist-get :staged alist/changes)) 0)
              (= (length (alist-get :unstaged alist/changes)) 0)
              (= (length (alist-get :untracked alist/changes)) 0))
         :no-op)

        ;; Ok; it is allowed.
        (t
         ;; Collapse `alist/changes' down into just paths.
         (append (alist-get :staged alist/changes)
                 (alist-get :unstaged alist/changes)
                 (alist-get :untracked alist/changes)
                 ;; :unmerged must be empty since we got here, so ignore.
                 ))))


;;------------------------------------------------------------------------------
;; Magit
;;------------------------------------------------------------------------------

;; TODO: Delete, replace usage with `autogit//changes/in-subdir'.
(defun autogit//magit/changes-in-subdir (subdir-abs)
  "Determines if magit knows of any changes (staged, unstaged, untracked), and
if any of them are in SUBDIR-ABS (an absolute path to a (sub-dir of a) repo).
Could be repo root, but a subdir of the repo is what magit can't handle with
e.g. `magit-anything-modified-p' and is why this exists."
  ;; Magit works on `default-directory', so make sure to set that. Also magit
  ;; returns lowercase paths, so make sure to downcase for Windows.
  (let* ((subdir-abs (downcase subdir-abs))
         (default-directory subdir-abs)
         ;; these are all changes in repo, not subdir
         (changes-rel (append (magit-staged-files)
                              (magit-unstaged-files)
                              (magit-untracked-files)))
         (git-root (magit-toplevel))
         (changes-abs (mapcar (lambda (x) (autogit//path git-root x))
                              changes-rel)))

    ;; Now just filter and return.
    (seq-filter (lambda (x) (string-prefix-p subdir-abs x)) changes-abs)))
;; (autogit//magit/changes-in-subdir (car autogit:repos:path/commit))


(defun autogit//magit/head-name (subdir-abs)
  "Returns a string about what HEAD is.

- Name of branch.
- First seven of hash."
  ;; TODO: Does this work in a brand new git repo?
  (let* ((subdir-abs (downcase subdir-abs))
         (default-directory subdir-abs)
         (headish (magit-headish))
         (branch (magit-name-branch headish)))
    (or branch headish)))
;; (autogit//magit/head default-directory)
(shell-quote-argument "hello\nthere")

(defun autogit//magit/git (dry-run buffer indent message &rest args)
  "Call `magit-call-git' with ARGS (unless DRY-RUN is nil).

If MESSAGE is a string, prepend with INDENT (if str) or INDENT number of spaces
(if wholenump) and send to `message'.

If MESSAGE is `:args-as-msg', message string will be INDENT (as
above) plus 'git' plus the ARGS provided.

Example:
  (autogit//magit/git 2 :args-as-msg  \"add\" \"-A\" \".\")
     message: \"  git add -A .\"
  (autogit//magit/git \"calling git: \"
                      \"adding all changes...\"
                      \"add\" \"-A\" \".\")
     message: \"calling git: adding all changes...\""
  (autogit//message buffer
                    ;; Indent.
                    (if (wholenump indent)
                        (make-string indent ?\s)
                      indent)

                    ;; Dry-Run prefix?
                    (if dry-run
                        (list :prop :face:failure :text autogit:text:dry-run)
                      ;; nil will just be ignored
                      nil)
                    ;; Dry-Run separator? (Don't want it propertized like prefix is.)
                    (if dry-run
                        ": "
                      ;; nil will just be ignored
                      nil)

                    ;; Command or message.
                    (list :prop :face:git
                          :text (if (eq message :args-as-msg)
                                    (concat "git " (string-join args " "))
                                  message)))
  (unless dry-run
    (apply #'magit-call-git args)))


;;------------------------------------------------------------------------------
;; Buffer
;;------------------------------------------------------------------------------

(defun autogit//macro:with-buffer//call (name body)
  "This is `autogit//macro:with-buffer' private function. Do not use.

Returns a sexpr of executing BODY in `with-current-buffer' block for buffer
NAME."
  (if (and (keywordp name)
           (eq name :messages))
      ;; Just using `message' for the *Messages* buffer.
      `(progn
         ,@body)
    ;; Create/get buffer to use while executing body.
    `(with-current-buffer (get-buffer-create ,name)
       ,@body)))


(defmacro autogit//macro:with-buffer (name &rest body)
  "Get output buffer ready, if needed, via `with-current-buffer', and
execute BODY in its context."
  (declare (indent 1))
    (autogit//macro:with-buffer//call name
        body))
;; (pp-macroexpand-expression
;;  (autogit//macro:with-buffer autogit:buffer:name/push
;;                              (message "hello there")))
;; (pp-macroexpand-expression
;;  (autogit//macro:with-buffer :messages
;;                              (message "hello there")))


(defun autogit//buffer/show (name)
  "Show message buffer or not, depending on settings.

If in Doom Emacs, set up popup rules first."
  (if (autogit//emacs/doom?)
      (with-popup-rules! autogit:doom:popup-rules
        (pop-to-buffer name))
    ;; Not using Doom & its popup window system, so just pop to the buffer.
    (pop-to-buffer name)))


;;------------------------------------------------------------------------------
;; Messages
;;------------------------------------------------------------------------------

;; TODO: namespace for 'message', 'section', 'buffer' type things.
;;   - 'output'?
;;   - 'display'?
(defun autogit//output/newline (buffer)
  "Insert a newline into autogit output BUFFER."
  (autogit//message buffer ""))


(defun autogit//section-break/display (buffer)
  "Inserts a section break into BUFFER."
  ;; TODO: Make these from defcustoms. num newlines, padding cons, padding char, width-or-use-fill-column.
  (let* ((newlines (make-string 2 ?\n))
         (padding '("┌" . "┐")))
    (autogit//message buffer
                      (list :prop :face:section
                            :text (concat newlines
                                          (car padding)
                                          (make-string (- fill-column
                                                          (length (car padding))
                                                          (length (cdr padding)))
                                                       (string-to-char "─"))
                                          (cdr padding))))))


(defun autogit//section-break/auto (buffer)
  "Inserts a section break into BUFFER if needed."
  (when (> (point) 1)
      (autogit//section-break/display buffer)))


(defun autogit//output/propertize (&rest args)
  "Parse args to created a propertized string.

Args is a plist. Keys/Values are:
  - :prop / :property
    + Value must be a list of properties,
      or a single keyword from `autogit:text:properties'.
  - :text
    + Value must be either a single string,
      or a list of (format-string arg0 ...) pass through `format'.

PROPS should be either a keyword from `autogit//properties' or actual string
properties."
  (let (properties
        text)
    ;; Build the string.
    (let* ((args/text (plist-get args :text))
           ;; string is either only thing, or first in list.
           (fmt/str  (if (stringp args/text)
                         args/text
                       (nth 0 args/text)))
           ;; args either don't exist, or are the rest of the list.
           (args/str (if (stringp args/text)
                         nil
                       (cdr args/text))))
      (if (not args/str)
          (if fmt/str
              ;; Only had a string, set it as text and we're done "building".
              (setq text fmt/str)
            ;; No args and no text; error.
            (error (concat "autogit//output/propertize: "
                           "Must have text to propertize. Found nothing "
                           "for key `:text' in args: %S")
                   args))

        ;; Have args.
        (if (not fmt/str)
            ;; Args but no string... Don't know what to do with this.
            (error (concat "autogit//output/propertize: "
                           "Must have a string to propertize as "
                           "`:text' key's value, or as first element in "
                           "`:text' key's value's list. Got `:text' value: %S")
                   args/text)

          ;; Build text.
          (setq text (apply #'format fmt/str args/str)))))

    ;; Check for a property.
    (when-let ((prop (or (plist-get args :prop)
                         (plist-get args :property))))
      (cond ((keywordp prop)
             ;; Just a single keyword - try to process it.
             (if-let ((autogit/props (plist-get autogit:text:properties prop)))
                 (dolist (ag/prop autogit/props)
                   (push ag/prop properties))
               (push prop properties)))

            ((listp prop)
             ;; List of keywords - try to process them.
             (dolist (each props)
               (cond ((keywordp each)
                      (if-let ((autogit/props (plist-get autogit:text:properties each)))
                          (dolist (ag/prop autogit/props)
                            (push ag/prop properties))
                        (push each properties)))

                     ;; TODO: More conditions as we improve this.
                     ;; Or switch to if-else.
                     (t
                      (push each properties)))))

            (t
             ;; Unknown so... error.
             (error (concat "autogit//output/propertize: "
                            "Found `:prop' keyword, but don't know how to "
                            "process its value. Expected keyword or list; "
                            "got: %S (type: %S)")
                    prop (type-of prop)))))

    ;; Apply the props if we have any and return string.
    (if (null properties)
        ;; Just the text (no properties for it).
        text
      ;; Properties are backwards, so fix that.
      (apply #'propertize text (nreverse properties)))))
;; (autogit//output/propertize :text "hello there" :prop :autogit)
;; (autogit//message :messages (autogit//output/propertize "hello there" :autogit))
;; (propertize "hello there" 'face 'package-name)


(defun autogit//message/old (buffer format-string &rest args)
  "Creates a string from FORMAT-STRING and ARGS using `format' or `message',
depending, and then prints it to the correct buffer as per
`autogit//macro:with-buffer'.

NOTE: Intended for use inside the `autogit//macro:with-buffer' macro body! Or
with a variable named `autogit//current-buffer/name' in scope!

BUFFER /must/ be the same buffer name used in the enclosing
`autogit//macro:with-buffer'."
  (if (and (keywordp buffer)
           (eq buffer :messages))
      ;; Using *Messages* buffer, so just use the `message' function to put the
      ;; message there.
      (apply #'message format-string args)
    ;; Not using *Messages*; insert the formatted string on a new line at the
    ;; end of the current buffer, assumed to be the buffer named `buffer'.
    (goto-char (point-max))
    (insert (concat "\n"
                    (apply #'format format-string args)))))
;; (autogit//macro:with-buffer :messages
;; (autogit//message/old :messages "hello there"))
;; (autogit//message/old :messages
;;                   "[AUTOGIT]: Commit %d locations...\n"
;;                   (length autogit:repos:path/commit))


(defun autogit//message (buffer &rest args)
  "Creates a (propertized) string and outputs it to BUFFER.

ARGS should each be one of:
  - A string.
  - A plist for propertizing a string.
    + With requried key `:text', value of a string or list of
      format-string and format-args.
    + With optional key `:prop' or `:property', value of a keyword from
      `autogit//output/propertize'.
  - A list of: a format-string and format-args.

No padding between args is created.

NOTE: If BUFFER is not `:message', it will print to the current buffer,
so it must be used inside the `autogit//macro:with-buffer' macro body!"
  (let (text/list)
    (dolist (arg args)
      (cond ((null arg)
             ;; Allow nil/empty list for conditional things. Just ignore it.
             nil)

            ((stringp arg)
             (push arg text/list))

             ;; Plist
             ((and (listp arg)
                   (keywordp (nth 0 arg)))
              (push (apply #'autogit//output/propertize arg) text/list))

              ;; Regular list
              ((listp arg)
               (push (apply #'format arg) text/list))

              ;; Unknown - Error
              (t
               (error "`autogit//message': Cannot process input: %S"
                      arg))))

    (when text/list
      ;; Combine and output.
      (let ((text (apply #'concat (nreverse text/list))))
        (if (and (keywordp buffer)
                 (eq buffer :messages))
            ;; Using *Messages* buffer, so just use the `message' function to put the
            ;; message there.
            (message text)
          ;; Not using *Messages*; insert the formatted string on a new line at the
          ;; end of the current buffer, assumed to be the buffer named `buffer'.
          (goto-char (point-max))
          (insert (concat "\n" text)))))))
;; (let ((buffer autogit:buffer:name/status))
;;   (autogit//macro:with-buffer buffer
;;     (autogit//message buffer
;;                         (list :prop :face:self :text autogit:text:name)
;;                         ": "
;;                         "Status of "
;;                         (list :prop :face:highlight
;;                               :text (list "%d" (length autogit:repos:path/watch)))
;;                         " watch locations...")
;;     (autogit//buffer/show buffer)))


;;------------------------------------------------------------------------------
;; Output: Status
;;------------------------------------------------------------------------------

(defun autogit//output/status (buffer alist/changes)
  "Output a status message to BUFFER about a git repo sub-dir's ALIST/CHANGES."
  ;; Error checking.
  (unless (memq autogit:changes:display autogit//changes:display/valid)
    (error "`autogit:changes:display' (%S) is not a valid setting. Set it to one of: %S"
           autogit:changes:display
           autogit//changes:display/valid))

  ;; Title or whatever is not our responsibility.

  (let (indent)
    ;; Should we display summary?
    (when (memq autogit:changes:display '(:summary :full))
      (autogit//message buffer
                        (list :prop :face:title
                              :text "  Status: ")
                        (list :prop :face:highlight
                              :text (autogit//changes/summary alist/changes)))
      (setq indent t))

    ;; List, if desired.
    (when (memq autogit:changes:display '(:paths :full))
      ;; Extra indentation if we also printed summary.
      (setq indent (if indent
                       "    "
                     "  "))
      (dolist (entry alist/changes)
        ;; TODO: Keyword (:staged, :unstaged, etc) to display string?
        (if (null (cdr entry))
            ;; No changes for this dir.
            (autogit//message buffer
                              (list "%s" indent)
                              (list :prop :face:title :text (list "%s" (car entry)))
                              ": "
                              (list :prop :face:highlight :text "None."))
          ;; Show type (staged, unstaged...) and list of change.
          (autogit//message buffer
                              (list "%s" indent)
                              (list :prop :face:title :text (list "%s" (car entry)))
                              ":")
          (dolist (path (cdr entry))
            (autogit//message buffer
                              (list "%s  - " indent)
                              (list :prop :face:path :text path))))))))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(provide 'autogit)
