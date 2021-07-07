;;; tools/autogit/commands.el -*- lexical-binding: t; -*-
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
;; Buffer Functions
;;------------------------------------------------------------------------------

(defun autogit:buffers:bury ()
  "Hide and bury the autogit output buffers.

Will hide/bury the \"*Messages*\" buffer if any of the output buffer name
settings are `:messages'."
  (interactive)
  (dolist (name (list autogit:buffer:name/push
                      autogit:buffer:name/status))
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
  (dolist (name (list autogit:buffer:name/push
                      autogit:buffer:name/status))
    ;; Prevent "No buffer named <...>" messages.
    (when (get-buffer name)
      (kill-buffer name))))
;; (autogit:buffers:kill)


;;------------------------------------------------------------------------------
;; Commit & Push
;;------------------------------------------------------------------------------

(defun autogit:push (&optional dry-run)
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

    (let ((buffer autogit:buffer:name/push)
          (step 1)
          results)
      (autogit//macro:with-buffer buffer
        (autogit//section-break/auto buffer)
        (autogit//message buffer
                          (list :prop :face:self
                                :text autogit:text:name)
                          " "
                          (format-time-string autogit:datetime:format)
                          ": "
                          "Commit "
                          (list :prop :face:highlight
                                :text (list "%d" (length autogit:repos:path/commit)))
                          " locations...\n")
        (autogit//buffer/show buffer)

        ;; Walk our list of auto-commit loctaions.
        (dolist (path autogit:repos:path/commit)
          (autogit//output/newline buffer)
          (autogit//message buffer
                            (list :prop :face:self
                                  :text autogit:text:name)
                            ": "
                            "Checking "
                            (list :prop :face:path :text (list "%s" path))
                            "...")

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
                                     (list :prop :face:failure
                                           :text "  Unmerged changes - cannot auto-commit!"))
                   ;; TODO: Display unmerged paths in alist/changes.
                   )

                  ;; Not necessary to commit?
                  ((and (keywordp changes/abs)
                        (eq changes/abs :no-op))
                   ;; Save that nothing happened.
                   (push (cons path "None.") results)
                   ;; Say why nothing happened.)
                   (autogit//message buffer
                                     "  No changes to auto-commit: "
                                     (list :prorp :face:path "%s"
                                           :text default-directory)))

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
                                       (list :prop :face:highlight
                                             :text (list "  %d. " step))
                                       "Adding changes found:"
                                       (list :prop :face:path
                                             :text changed-str))
                     (setq step (1+ step))

                     ;; "add <path>" or "add -A ." work to add untracked.
                     ;; "add -A ." == "add ." + "add -u ."
                     ;; "add ." only adds modified.
                     (autogit//magit/git dry-run
                                         buffer
                                         nil
                                         :args-as-msg
                                         "add" "-A" ".")
                     (setq step (1+ step))


                     ;; Commit!
                     (autogit//output/newline buffer)
                     ;; TODO: Get list of staged for message? Currently trusting they are
                     ;; the same as the `changes/abs' - and they /should/ be.
                     (autogit//message buffer
                                       (list :prop :face:highlight
                                             :text (list "  %d. " step))
                                       "Committing changes:"
                                       (list :prop :face:path
                                             :text changed-str))
                     (setq step (1+ step))

                     ;; Don't 'commit all' ("commit -a"), so we can commit just whatever
                     ;; sub-folder we are in.
                     (autogit//magit/git dry-run
                                         buffer
                                         nil
                                         :args-as-msg
                                         "commit" "-m" commit-message)
                     (setq step (1+ step))

                     ;; Push?
                     (autogit//output/newline buffer)
                     (autogit//message buffer
                                       (list :prop :face:highlight
                                             :text (list "  %d. " step))
                                       "Pushing changes:"
                                       (list :prop :face:path
                                             :text changed-str))
                     (setq step (1+ step))
                     ;; Just "push" to default...
                     (autogit//message buffer
                                       (list :prop :face:highlight
                                             :text (list "  %d. " step))
                                       "Git:")
                     (autogit//magit/git dry-run
                                         buffer
                                         nil
                                         :args-as-msg
                                         "push")
                     (setq step (1+ step))

                     ;; Done. Until I find all the edge cases I guess.
                     ;; Like when push fails?
                     (autogit//output/newline buffer)
                     (autogit//message buffer
                                       (list :prop :face:self
                                             :text autogit:text:name)
                                       ": "
                                       "Committed and pushed (probably?): "
                                       (list :prop :face:path
                                             :text path)
                                       (list :prop :face:path
                                             :text changed-str))
                     (push (cons path (or changed-str "None.")) results)))))

          ;; Finished pushing commits on autogit locations. Give a rundown.
          (autogit//output/newline buffer)
          (autogit//message buffer
                            (list :prop :face:self
                                  :text autogit:text:name)
                            ": "
                            (list :prop :face:success :text "Done")
                            "; commit ran on "
                            (list :prop :face:highlight :text (list "%d" (length autogit:repos:path/commit)))
                            " locations:")
          (let ((first-result t))
            (dolist (result results)
              (if first-result
                  (setq first-result nil)
                (autogit//output/newline buffer))
              (autogit//message buffer
                                "  path: "
                                (list :prop :face:path
                                      :text (list "%s" (car result)))
                                "\n  changes: "
                                (list :prop :face:path
                                      :text (list "%s" (cdr result)))))))))))
;; (setq autogit:repos:path/commit nil)
;; (push "D:/home/spydez/.lily.d" autogit:repos:path/commit)
;; (autogit:push 'dry-run)


;;------------------------------------------------------------------------------
;; Status
;;------------------------------------------------------------------------------


(defun autogit:status ()
  "For each item in `autogit:repos:path/watch', use Magit to look for
uncommitted(/unpushed?) changes."
  (interactive)

  (let ((buffer autogit:buffer:name/status))
    (autogit//macro:with-buffer buffer
      ;;------------------------------
      ;; Title and stuff.
      ;;------------------------------
      (autogit//section-break/auto buffer)
      (autogit//message buffer
                        (list :prop :face:self :text autogit:text:name)
                        " "
                        (format-time-string autogit:datetime:format)
                        ": "
                        "Status of "
                        (list :prop :face:highlight
                              :text (list "%d" (length autogit:repos:path/watch)))
                        " watch locations...")
      (autogit//buffer/show buffer)
      ;; TODO: Is there a way to force the buffer to show before this finishes?
      ;;   - Make this an async func, probably.

      ;;------------------------------
      ;; Get status for each repo.
      ;;------------------------------
      (dolist (path autogit:repos:path/watch)
        ;; Get & display the alist of changes based on settings.
        (autogit//message buffer
                          "\n"
                          (list :prop :face:self :text autogit:text:name)
                          ": "
                          "Checking "
                          (list :prop :face:path :text (list "%s" path))
                          "...")
        (autogit//output/status buffer (autogit//changes/in-subdir path))))))
;; (autogit:status)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(provide 'autogit)
