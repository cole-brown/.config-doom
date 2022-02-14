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


;;------------------------------------------------------------------------------
;; Usage
;;------------------------------------------------------------------------------



;;------------------------------------------------------------------------------
;; Custom Variables
;;------------------------------------------------------------------------------


;;------------------------------
;; Group
;;------------------------------

(defgroup autogit:group nil
  "Automatically-ish commit/push git repos for note, docs, etc."
  :prefix "autogit:"
  :group 'tools)


;;------------------------------
;; Paths
;;------------------------------

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


;;------------------------------
;; Timestamp
;;------------------------------

;; Default to ISO-8601 with space separator for in text.
(defcustom autogit:datetime:format
  "%Y-%m-%d %H:%M:%S"
  "Datetime format string for autogit messages."
  :group 'autogit:group
  :type 'string)


;;------------------------------
;; Output
;;------------------------------

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

;;------------------------------
;; Buffer
;;------------------------------

(defcustom autogit:buffer:name/push
  "ⓘ-autogit:push-ⓘ"
  "Buffer name to print to. If you want it to go to *Messages* with the usual
minibuffer interaction, set to: `:messages'"
  :group 'autogit:group
  :type '(choice (string :tag "Name of Buffer")
                 (const :tag "Use `message' to send to *Messages* buffer with the usual minibuffer interactions."
                        :messages)))


(defcustom autogit:buffer:name/status
  "ⓘ-autogit:status-ⓘ"
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


;;------------------------------
;; Look & Feel
;;------------------------------

(defcustom autogit:text:name
  "[AUTOGIT]"
  "Name of this package, used in output messages.

Set to `nil' if not desired in output.")
;; (makunbound 'autogit:text:name)


(defcustom autogit:text:dry-run
  "[DRY-RUN]"
  "Text to prefix `git` \"calls\" with during a dry-run.

Dry-Runs won't actually do some of the git calls, as a dry-run
should not result in anything changing.

Set to `nil' if not desired in output.")
;; (makunbound 'autogit:text:dry-run)


(defcustom autogit:text:properties
  '(;; General
    :face:self      (face package-name) ;; font-lock-keyword-face ; for `autogit:text:name'
    :face:title     (face outline-1) ;; font-lock-function-name-face
    :face:highlight (face outline-2) ;; font-lock-variable-name-face
    :face:path      (face outline-3) ;; font-lock-doc-face
    :face:git       (face outline-4) ;; font-lock-preprocessor-face

    ;; Status
    :face:error   (face error) ;; font-lock-string-face
    :face:failure (face font-lock-warning-face)
    :face:success (face font-lock-comment-delimiter-face)

    ;; Misc
    :face:section (face org-headline-done))
  "Plist of text properties for prettier output.")
;; (plist-get autogit:text:properties :face:self)
;; (makunbound 'autogit:text:properties)


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

(defconst autogit//changes:display/valid '(:summary :paths :full)
  "Allowed values of `autogit:changes:display'.")


;;------------------------------------------------------------------------------
;; Load our functions...
;;------------------------------------------------------------------------------

;; Order may matter...
(imp:load :feature  '(:autogit internal)
          :filename "internal")
(imp:load :feature  '(:autogit api)
          :filename "api")
(imp:load :feature  '(:autogit commands)
          :filename "commands")


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide:with-emacs :autogit)
