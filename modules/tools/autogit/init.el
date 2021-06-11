;;; tools/autogit/init.el --- auto-commit git repos -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2021 Cole Brown
;; TODO: MIT or GPL dual license?
;; TODO: full header?
;;
;; Author: Cole Brown <http://github/cole-brown>
;; Maintainer: Cole Brown <code@brown.dev>
;; Created: October 28, 2020
;; Modified: October 28, 2020
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
;;   1) Auto-committing changes to certain git repos.
;;      - E.g. notes repositories.
;;   2) Getting general status for certain other git repos.
;;      - E.g. get status for your notes repo(s) and your code repo(s) in one go.
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
;; Load our files...
;;------------------------------------------------------------------------------

;; ;; Debug First!..
;; (if (featurep! -debug)
;;     (load! "+debug")
;;
;;   ;; Fake debug funcs so no one screams.
;;   (load! "+no-debug"))

;; Order may matter...
;; (load! "thing1")
;; (load! "thing2")


;;------------------------------------------------------------------------------
;; Custom Variables
;;------------------------------------------------------------------------------

;; TODO: group customs together under sec/med headers.

(defgroup autogit:group nil
  "Automatically-ish commit/push git repos for note, docs, etc."
  :prefix "autogit:"
  :group 'tools)


(defcustom autogit:repos:path/commit
  nil
  "List of strings of directories to automatically add/commit/push in their
respective git repos. Can be sub-directories of a repository (TODO: add
allowance for single files?)."
  :group 'autogit:group
  :type '(restricted-sexp :tag "String List"
                          :match-alternatives
                          (lambda (x) (and (listp x)
                                           (seq-every-p #'stringp x)))))


(defcustom autogit:repos:path/watch
  nil
  "List of strings of directories to watch for (not necessarily auto-commit)
changes. Can be sub-directories of a repository (TODO: add allowance for single
files?)."
  :group 'autogit:group
  :type '(restricted-sexp :tag "String List"
                          :match-alternatives
                          (lambda (x) (and (listp x)
                                           (seq-every-p #'stringp x)))))


;; Default to ISO-8601 with space separator for in text.
(defcustom autogit:datetime:format
  "%Y-%m-%d %H:%M:%S"
  "Datetime format string for autogit messages."
  :group 'autogit:group
  :type 'string)


(defcustom autogit:changes:symbols
  '((:staged    . "•")
    (:unstaged  . "+")  ;; too wide in current font/theme: ✚
    (:untracked . "¬")  ;; acceptable: ?
    (:unmerged  . "⊥")) ;; acceptable: ×, too wide in current font/theme: ✖
  "Symbol/icon/character to use to represent change type."
  :group 'autogit:group
  ;; TODO: type is... what? stupid types.
  :type '(alist :key-type symbol :value-type string))
;; (makunbound 'autogit:changes:symbols)


(defcustom autogit:changes:display
  :full
  "What to display for status of each watch location during `autogit:repos:watch'.

Options:
  - :summary - One line of number of files staged/unstaged/etc. See `autogit:changes:symbols'.
  - :paths   - List of lists. Type of change (staged/etc) -> file paths.
  - :full    - Summary followed by paths."
  :group 'autogit:group
  ;; TODO: type is... what? stupid types.
  :type '(choice (const :tag "Summary: One line of number of files staged/unstaged/etc. See `autogit:changes:symbols'" :summary)
                 (const :tag "Paths: List of lists. Type of change (staged/etc) -> file paths." :paths)
                 (const :tag "Full: 'Summary' followed by 'paths'." :full)))

;; TODO: Move to vars?
(defconst autogit//changes:display/valid '(:summary :paths :full)
  "Allowed values of `autogit:changes:display'.")


(defcustom autogit:buffer:name/commit
  "ⓘ-autogit:commit-ⓘ"
  "Buffer name to print to. If you want it to go to *Messages* with the usual
minibuffer interaction, set to: `:messages'"
  :group 'autogit:group
  :type '(choice (string :tag "Name of Buffer")
                 (const :tag "Use `message' to send to *Messages* buffer with the usual minibuffer interactions."
                        :messages)))


(defcustom autogit:buffer:name/watch
  "ⓘ-autogit:watch-ⓘ"
  "Buffer name to print to. If you want it to go to *Messages* with the usual
minibuffer interaction, set to: `:messages'"
  :group 'autogit:group
  :type '(choice (string :tag "Name of Buffer")
                 (const :tag "Use `message' to send to *Messages* buffer with the usual minibuffer interactions."
                        :messages)))


(defcustom autogit:doom:popup-rules
 '((:ignore t))
  "Rules to use if running in Doom Emacs for `pop-to-buffer'. See
`set-popup-rule!' for rules."
  :group 'autogit:group)


;;------------------------------------------------------------------------------
;; Private Functions
;;------------------------------------------------------------------------------

(defun autogit//path (root &rest path)
  "Given a git ROOT, and a PATH of e.g. ('path/to' 'dir'
'with-file' 'file.txt'), will return full /file/ path in
platform-agnostic manner."
  (concat (file-name-as-directory (expand-file-name "" root))
          (directory-file-name (mapconcat #'file-name-as-directory path ""))))
;; (autogit//path (car autogit:repos:path/commit) "foo")


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
                    "%s%s%s"
                    (if dry-run
                        "[DRY-RUN]: "
                      "")
                    (if (wholenump indent)
                        (make-string indent ?\s)
                      indent)
                    (if (eq message :args-as-msg)
                        (concat "git " (string-join args " "))
                      message))
  (unless dry-run
    (apply #'magit-call-git args)))


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
;;  (autogit//macro:with-buffer autogit:buffer:name/commit
;;                              (message "hello there")))
;; (pp-macroexpand-expression
;;  (autogit//macro:with-buffer :messages
;;                              (message "hello there")))


(defun autogit//message (buffer format-string &rest args)
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
;; (autogit//message :messages "hello there"))
;; (autogit//message :messages
;;                   "[AUTOGIT]: Commit %d locations...\n"
;;                   (length autogit:repos:path/commit))


;; TODO: namespace for 'message', 'section', 'buffer' type things.
;;   - 'output'?
;;   - 'display'?
(defun autogit//output/newline (buffer)
  "Insert a newline into autogit output BUFFER."
  (autogit//message "\n"))


(defun autogit//section-break/display (buffer)
  "Inserts a section break into BUFFER."
  ;; TODO: Make these from defcustoms. num newlines, padding cons, padding char, width-or-use-fill-column.
  (let* ((newlines (make-string 2 ?\n))
         (padding '("┌" . "┐")))
    (autogit//message buffer
                      (concat newlines
                              (car padding)
                              (make-string (- fill-column
                                              (length (car padding))
                                              (length (cdr padding)))
                                           (string-to-char "─"))
                              (cdr padding)))))


(defun autogit//section-break/auto (buffer)
  "Inserts a section break into BUFFER if needed."
  (when (> (point) 1)
      (autogit//section-break/display buffer)))


(defun autogit//emacs/doom? ()
  "Returns non-nil if a certain Doom function exists, which we'll assume means
we're running in Doom Emacs."
  (bound-and-true-p +popup-mode))


(defun autogit//buffer/show (name)
  "Show message buffer or not, depending on settings.

If in Doom Emacs, set up popup rules first."
  (if (autogit//emacs/doom?)
      (with-popup-rules! autogit:doom:popup-rules
        (pop-to-buffer name))
    ;; Not using Doom & its popup window system, so just pop to the buffer.
    (pop-to-buffer name)))


;;------------------------------------------------------------------------------
;; Public Functions
;;------------------------------------------------------------------------------

(defun autogit:buffers:bury ()
  "Hide and bury the autogit output buffers.

Will hide/bury the \"*Messages*\" buffer if any of the output buffer name
settings are `:messages'."
  (interactive)
  (dolist (name (list autogit:buffer:name/commit
                      autogit:buffer:name/watch))
    (when-let* ((name (if (and (keywordp name)
                               (eq name :messages))
                          "*Messages*"
                        name))
                (window (get-buffer-window name)))
      (with-selected-window window
        (bury-buffer)))))
;; (autogit:buffers:bury)


(defun autogit:buffers:kill ()
  "Kill the autogit output buffer NAME.

If NAME is `:messages', kills the \"*Messages*\" buffer."
  (interactive)
  (dolist (name (list autogit:buffer:name/commit
                      autogit:buffer:name/watch))
    ;; Prevent "No buffer named <...>" messages.
    (when (get-buffer name)
      (kill-buffer name))))
;; (autogit:buffers:kill)


(defun autogit:repos:commit (&optional dry-run)
  "For each item in `autogit:repos:path/commit', use
Magit to: add files, commit, and push."
  (interactive "P")

  ;; Either have to require magit here, or set magit to ":demand t" in
  ;; use-package. Trying out requiring here as magit isn't the fastest to start.
  ;; TODO: Or we could figure out auto-loading and prereqs and shenanigans...
  (require 'magit)

  (if (null autogit:repos:path/commit)
      (message "Autogit Error: No paths in `autogit:repos:path/commit': %S"
               autogit:repos:path/commit)

    (let ((buffer autogit:buffer:name/commit)
          (step 1)
          results)
      (autogit//macro:with-buffer buffer
        (autogit//section-break/auto buffer)
        (autogit//message buffer
                          "[AUTOGIT]: Commit %d locations...\n"
                          (length autogit:repos:path/commit))
        (autogit//buffer/show buffer)

        ;; Walk our list of auto-commit loctaions.
        (dolist (path autogit:repos:path/commit)
          (autogit//message buffer "\n[AUTOGIT] Checking %s..." path)

          ;; Change the default-directory just for this scope...
          (let* ((default-directory (if (file-directory-p path)
                                        ;; Already a 'directory' path; is ok.
                                        path
                                      ;; Needs a slash?
                                      (file-name-as-directory path)))
                 ;; Some silly little message.
                 (commit-message (format "autogit commit\n\n%s: %s triggered in %s by %s"
                                         (format-time-string autogit:datetime:format)
                                         "Auto-commit"
                                         "emacs/magit"
                                         "autogit:magit/auto-commit function."))
                 ;; Full changes.
                 (alist/changes (autogit//changes/in-subdir default-directory))
                 ;; Filtered changes or "do-not-commit" reason keyword.
                 (changes/abs (autogit//changes/commit-filter alist/changes)))

            ;; Not allowed to commit?
            (cond ((and (keywordp changes/abs)
                        (eq changes/abs :unmerged))
                   ;; Save that nothing happened.
                   (push (cons path "Blocked by unmerged files.") results)
                   ;; And say why.
                   (autogit//message buffer
                                     "  Unmerged changes - cannot auto-commit!")
                   ;; TODO: Display unmerged paths in alist/changes.
                   )

                  ;; Not necessary to commit?
                  ((and (keywordp changes/abs)
                        (eq changes/abs :no-op))
                   ;; Save that nothing happened.
                   (push (cons path "None.") results)
                   ;; Say why nothing happened.)
                   (autogit//message buffer
                                     "  No changes to auto-commit: %s"
                                     default-directory))

                  ;; Ok. Commit.
                  (t
                   (let* ((changes/rel
                           ;; Gather up all changed files, strip out dir prefix.
                           (mapcar (lambda (x)
                                     (string-remove-prefix default-directory x))
                                   changes/abs))
                          (prefix "\n    + ")
                          (changed-str (concat
                                        prefix
                                        (string-join changes/rel prefix))))
                     ;; Add!
                     (autogit//message buffer
                                       "  %d. Adding changes found:%s"
                                       step changed-str)
                     (setq step (1+ step))

                     ;; "add <path>" or "add -A ." work to add untracked.
                     ;; "add -A ." == "add ." + "add -u ."
                     ;; "add ." only adds modified.
                     (autogit//magit/git dry-run
                                         buffer
                                         (format "  %d. " step)
                                         :args-as-msg
                                         "add" "-A" ".")
                     (setq step (1+ step))


                     ;; Commit!
                     ;; TODO: Get list of staged for message? Currently trusting they are
                     ;; the same as the `changes/abs' - and they /should/ be.
                     (autogit//message buffer
                                       "  %d. Committing changes:%s"
                                       step changed-str)
                     (setq step (1+ step))

                     ;; Don't 'commit all' ("commit -a"), so we can commit just whatever
                     ;; sub-folder we are in.
                     (autogit//magit/git dry-run
                                         buffer
                                         (format "  %d. " step)
                                         :args-as-msg
                                         "commit" "-m" commit-message)
                     (setq step (1+ step))

                     ;; Push?
                     (autogit//message buffer
                                       "  %d. Pushing changes:%s"
                                       step changed-str)
                     (setq step (1+ step))
                     ;; Just "push" to default...
                     (autogit//magit/git dry-run
                                         buffer
                                         (format "  %d. " step)
                                         :args-as-msg
                                         "push")
                     (setq step (1+ step))

                     ;; Done. Until I find all the edge cases I guess.
                     ;; Like when push fails?
                     (autogit//message buffer
                                       "[AUTOGIT]: Committed and pushed (probably?):%s%s"
                                       path
                                       changed-str)
                     (push (cons path (or changed-str "None.")) results)))))

          ;; Finished pushing commits on autogit locations. Give a rundown.
          (autogit//message buffer
                            "\n[AUTOGIT]: Done; commit ran on %d locations:"
                            (length autogit:repos:path/commit))
          (let ((first-result t))
            (dolist (result results)
              (if first-result
                  (setq first-result nil)
                (autogit//message buffer "\n"))
              (autogit//message buffer
                                "  path: %s\n  changes: %s"
                                (car result) (cdr result)))))))))
;; (setq autogit:repos:path/commit nil)
;; (push "D:/home/spydez/.lily.d" autogit:repos:path/commit)
;; (autogit:repos:commit 'dry-run)


;; TODO: orginize private funcs section into several sections
;; TODO: move up to private funcs section
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
                        "  Status: %s"
                        (autogit//changes/summary alist/changes))
      (setq indent t))

    ;; List, if desired.
    (when (memq autogit:changes:display '(:paths :full))
      ;; Extra indentation if we also printed summary.
      (setq indent (if indent
                       "    "
                     "  "))
      (dolist (entry alist/changes)
        ;; TODO: Keyword to display string.
        (if (null (cdr entry))
            ;; TODO: Display empties option?
            (autogit//message buffer
                              "%s%s: None."
                              indent (car entry))
          (autogit//message buffer
                            "%s%s:"
                            indent (car entry))
          (dolist (path (cdr entry))
            (autogit//message buffer
                              "%s  - %s"
                              indent path)))))))


;; TODO: Colors in output message would be nice. Even if ugly/manual for now.
(defun autogit:repos:watch ()
  "For each item in `autogit:repos:path/watch', use Magit to look for
uncommitted(/unpushed?) changes."
  (interactive)

  (let ((buffer autogit:buffer:name/watch)
        (section-break nil))
    (autogit//macro:with-buffer buffer
      ;;------------------------------
      ;; Title and stuff.
      ;;------------------------------
      (autogit//section-break/auto buffer)
      (autogit//message buffer
                        "[AUTOGIT]: Status of %d watch locations..."
                        (length autogit:repos:path/watch))
      (autogit//buffer/show buffer)
      ;; TODO: Is there a way to force the buffer to show before this finishes?
      ;;   - Make this an async func, probably.

      ;;------------------------------
      ;; Get status for each repo.
      ;;------------------------------
      (dolist (path autogit:repos:path/watch)
        ;; Get & display the alist of changes based on settings.
        (autogit//message buffer "\n[AUTOGIT] Checking %s..." path)
        (autogit//output/status buffer (autogit//changes/in-subdir path))))))
;; (autogit:repos:watch)

;; 'check' might be more understandable than 'watch'...
;; TODO: just change to 'watch' (custom var as well)?
(defalias 'autogit:repos:check 'autogit:repos:watch)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(provide 'autogit)
