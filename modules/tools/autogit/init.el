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
;; Package-Requires: ((emacs 27.1) (cl-lib "0.5"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  Initialize Secrets!
;;
;;; Code:


(require 'subr-x)


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
  :group 'autogit:group)


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
      (message "No buffers in `autogit:repos:path/commit': %S"
               autogit:repos:path/commit)

    (let ((buffer autogit:buffer:name/commit)
          (step 1)
          results)
      (autogit//macro:with-buffer buffer
        (autogit//message buffer
                          "[AUTOGIT]: Commit %d locations...\n"
                          (length autogit:repos:path/commit))
        (autogit//buffer/show buffer)

        ;; Walk our list of auto-commit loctaions.
        (dolist (path autogit:repos:path/commit)
          ;; Change the default-directory just for this scope...
          (let ((default-directory (if (file-directory-p path)
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
                (change-list (autogit//magit/changes-in-subdir path)))

            (autogit//message buffer "") ;; Give some space from previous thing in buffer.
            (autogit//message buffer "[AUTOGIT] Checking %s..." path)

            ;; Magit works on `default-directory', so we are checking status
            ;; on our repo with this.
            (if (null change-list)
                (progn
                  ;; Save that nothing happened.
                  (push (cons path "None.") results)
                  ;; Say why nothing happened.
                  (autogit//message buffer
                                    "  No changes to auto-commit: %s\n"
                                    default-directory))

              ;; Else, commit changes.
              (let* ((changed-files
                      ;; Gather up all changed files, strip out dir prefix.
                      (mapcar (lambda (x)
                                (string-remove-prefix default-directory x))
                              change-list))
                     (prefix "\n    + ")
                     (changed-str (concat
                                   prefix
                                   (string-join changed-files prefix))))
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
                ;; the same as the `change-list' - and they /should/ be.
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
                              (car result) (cdr result))))))))
;; (setq autogit:repos:path/commit nil)
;; (push "D:/home/spydez/.lily.d" autogit:repos:path/commit)
;; (autogit:repos:commit 'dry-run)


;;
;; TODO HERE
;;

(defun autogit:repos:watch ()
  "For each item in `autogit:repos:path/watch', use Magit to look for
uncommitted(/unpushed?) changes."
  (interactive)

  (message "TODO HERE")
  )

;;   (let (;; Defaults that we don't really care about probably in interactive mode.
;;         (mis/minibuffer-echo (or mis/minibuffer-echo
;;                                  t))
;;         (mis/msg-type (or mis/msg-type
;;                           :default))
;;
;;         ;; speed up mis/message clearing out of minibuffer echo area
;;         (mis/message/echo-area-timeout '(0.2 0.5)))
;;
;;     ;; Only show *Messages* buffer when user called this interactively directly
;;     ;; (not via a macro or whatever).
;;     (when (called-interactively-p 'interactive)
;;       (view-echo-area-messages)
;;       (mis/message/propertize mis/minibuffer-echo mis/msg-type :newline))
;;
;;     ;; Either have to require magit here, or set magit to ":demand t" in
;;     ;; use-package. Trying out requiring here as magit isn't the fastest to
;;     ;; start.
;;     (require 'magit)
;;
;;     ;; Walk our list of auto-commit loctaions.
;;     (dolist (path autogit:repos:path/watch)
;;       (let* ((repo-path (if (f-dir? path)
;;                             path
;;                           (f-dirname path)))
;;              (repo-name (f-filename repo-path))
;;              (path-above-name (f-slash (f-dirname repo-path)))
;;              ;; Change the default-directory just for this scope...
;;              (default-directory repo-path)
;;              (change-list (autogit//changes-in-subdir path)))
;;
;;         (mis/message/propertize mis/minibuffer-echo
;;                                 mis/msg-type
;;                                 `(:part
;;                                   (:highlight "Checking ")
;;                                   :part
;;                                   (:highlight "%s" ,path-above-name)
;;                                   :part
;;                                   (:inattention "%s" ,repo-name)
;;                                   :part
;;                                   (:highlight "...")))
;;
;;         ;; Magit works on `default-directory', so we are checking status
;;         ;; on our repo with this.
;;         (if (null change-list)
;;             ;;---
;;             ;; Say nothing happened here.
;;             ;;---
;;             (mis/message/propertize
;;              mis/minibuffer-echo
;;              mis/msg-type
;;              `(:part
;;                ;; Say 'No changes' or 'x changes', depending.
;;                (:text "  %s " "No")
;;                :part
;;                (:text "changes in: ")
;;                :part
;;                (:text "%s" ,path-above-name)
;;                :part
;;                (:inattention "%s" ,repo-name)
;;                :part
;;                (:text "...")))
;;
;;           ;;---
;;           ;; Else, note changes.
;;           ;;---
;;
;;           ;; Summary
;;           (mis/message/propertize
;;            mis/minibuffer-echo
;;            mis/msg-type
;;            `(:part
;;              ;; Say 'No changes' or 'x changes', depending.
;;              (:inattention "  %s " ,(length change-list))
;;              :part
;;              (:text "changes in: ")
;;
;;              :part
;;              (:text "%s" ,path-above-name)
;;              :part
;;              (:inattention "%s" ,repo-name)
;;              :part
;;              (:text "..."))))
;;
;;         ;; Details
;;         (dolist (change-path change-list)
;;           (mis/message/propertize mis/minibuffer-echo
;;                                   mis/msg-type :text
;;                                   "    - %s"
;;                                   (string-remove-prefix default-directory
;;                                                         change-path))))
;;
;;       (mis/message/propertize mis/minibuffer-echo mis/msg-type ""))
;;
;;     (mis/message/propertize mis/minibuffer-echo
;;                             mis/msg-type :highlight
;;                             "Checked status on %s paths."
;;                             (length autogit:repos:path/watch))))
;; ;; (autogit:repos:watch t '(spydez homeward))

;; 'check' might be more understandable than 'watch'...
;; TODO: just change to 'watch' (custom var as well)?
(defalias 'autogit:repos:check 'autogit:repos:watch)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(provide 'autogit)
