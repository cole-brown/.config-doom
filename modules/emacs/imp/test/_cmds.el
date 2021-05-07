;; -*- no-byte-compile: t; -*-
;;; emacs/imp/test/_cmds.el

(require 'cl-lib)

;;------------------------------------------------------------------------------
;; Variables & Constants
;;------------------------------------------------------------------------------

;;------------------------------
;; Buffers
;;------------------------------

(setq iii:test:buffer:messages "*imp:test messages*")


(setq iii:test:buffer:separator "─")
(setq iii:test:buffer:separator.length 80)

;;------------------------------
;; Choices
;;------------------------------

(setq iii:test:choice:all.name "[--all--]")


(defun iii:test:choice:add (name files)
  (prog1
      (if (string= name iii:test:choice:all.name)
          ;; 'all tests': give reserved slot.
          (cons iii:test:choice:all.name
                ;; All tests has no files of its own - just load everyone
                ;; else's.
                nil)

        ;; normal: give next slot and increment.
        (prog2
            ;; Error check now that we know we're not the 'all' test.
            (when (null files)
              (error (concat "iii:test:choice:add: "
                             "Non-'all' tests must have a "
                             "list of files to load. Got: %S")
                     files))
            (cons name
                  files)
          (setq iii:test:choice:last
                (1+ iii:test:choice:last))))))


;; `files' param should be relative to "imp/" directory.
(setq iii:test:choices
      (list (iii:test:choice:add iii:test:choice:all.name
                                 nil)
            (iii:test:choice:add "tree"
                                 '("tree.el"))))


;; Should be relative to "imp/" directory and sans extension.
(setq iii:test:load:defaults
      '("+debug.el"
        "error.el"))

(setq iii:test:path:root
      ;; Parent directory should be the base imp dir.
      (file-name-directory
       (directory-file-name
        ;; Directory path of this file ("imp/test" dir).
        (file-name-directory
         ;; Filepath of this, depending on if this is being loaded or looked at.
         (if load-in-progress
             (file-name-directory load-file-name)
           (buffer-file-name))))))


;;------------------------------------------------------------------------------
;; Functions
;;------------------------------------------------------------------------------

;;------------------------------
;; Suites
;;------------------------------

(defun iii:test:names ()
  "Returns a list of the test suite names from `iii:test:choices'."
  (mapcar #'car iii:test:choices))
;; (iii:test:names)


;;------------------------------
;; Files
;;------------------------------

(defun iii:test:files (suite)
  "Returns the files to load for the collection of tests named SUITE.

Does /not/ include `iii:test:load:defaults'."
  (let* ((files (alist-get suite iii:test:choices)))
    (cond ((null suite)
           (error "Invalid suite: %S" suite))

          ;; "All" has null files - need to return the sum of everyone else's.
          ((null files)
           (dolist (test-suite iii:test:choices)
             (let ((suite-files (cdr test-suite)))
               (dolist (file suite-files)
                 (when (not (member file files))
                   (push file files))))))

          ;; Other tests: `files' is already set up.
          (t
           nil))

    ;; Reverse in case there's some interdependency...
    (nreverse files)))
;; (iii:test:files iii:test:choice:all.name)
;; (iii:test:files "tree")


(defun iii:test:path (relative)
  "Returns absolute path to file/dir RELATIVE by
prepending `iii:test:path:root'."
  (concat iii:test:path:root relative))
;; (iii:test:path "tree.el")
;; (iii:test:path "test/tree.el")


;;------------------------------
;; Messages
;;------------------------------

(defun iii:test:buffer (&optional create?)
  "Get buffer and make sure point is at the end.

Get-or-create if CREATE? is non-nil."
  (when-let ((buffer
              (if create?
                  (get-buffer-create iii:test:buffer:messages)
                (get-buffer iii:test:buffer:messages))))
    (with-current-buffer buffer
      (end-of-buffer))

    buffer))


(defun iii:test:message (show? message &rest args)
  "Send MESSAGE with ARGS to the imp:test buffer (named by
`iii:test:buffer:messages').

Shows buffer (as popup) if SHOW? is non-nil, else leaves it however it is.

Uses `format' for the MESSAGE and ARGS."
  (with-current-buffer (iii:test:buffer t)
    (insert (apply #'format message args) "\n")
    (when show?
      ;; TODO: Un-doom-ify? Just use a normal 'other window' maybe?
      (+popup/buffer))))


(defun iii:test:newline (&optional show? number)
  "Inserts NUMBER of newlines into the test messages buffer.

If NUMBER is nil, inserts 1 newline.

Shows buffer (as popup) if SHOW? is non-nil, else leaves it however it is."
  (when-let ((buffer (iii:test:buffer)))
    (with-current-buffer buffer
      (insert (make-string (or number 1) (string-to-char "\n")))
      (when show?
        ;; TODO: Un-doom-ify? Just use a normal 'other window' maybe?
        (+popup/buffer)))))


(defun iii:test:section.new (&optional clear)
  "If test messages buffer has content in it, make a new section or clear.

If test messages buffer does not exist, does nothing.

If CLEAR is non-nil, clears the buffer. Else prints a newline, a line separator
(hypens, unicode box line, etc), and two more newlines."
  (when-let ((buffer (iii:test:buffer)))
    (with-current-buffer buffer
      (if (not clear)
          ;; Just want to separate sections.
          (insert (concat "\n"
                          (make-string iii:test:buffer:separator.length
                                       (string-to-char iii:test:buffer:separator))
                          "\n\n"))

        ;; Nuke it from orbit.
        (erase-buffer)))))


;;------------------------------
;; Command
;;------------------------------

(defun imp:test:buffer-toggle ()
  "Hide the imp:test message popup buffer."
  (interactive)
  (if (get-buffer-window iii:test:buffer:messages)
      ;; TODO: Un-doom-ify? Just use a normal 'other window' maybe?
      (if (popup-hidden-p)
          (+popup/buffer)
        (+popup/close))))


(defun imp:test:init (suite)
  "Load base imp files like debug, path, etc. in prep for running a test suite.

SUITE should be a valid key in `iii:test:choices' alist."
  (interactive (list (completing-read "Test Suite: "
                                      (iii:test:names)
                                      nil
                                      ;; Must choose something in our list.
                                      t)))

  (let* ((success t)
         (error t)
         filepath)
    (when (not suite)
      (error "Unkown imp test suite #%s. Options: %S" suite
             (iii:test:names))))

  ;; Hello there.
  (iii:test:section.new)
  (iii:test:message t "imp:test:init:\n  suite: %s\n\n" (s-upcase suite))

  ;; First, load the defaults.
  (iii:test:message nil "Loading default files...")
  (unwind-protect
      (progn
        (dolist (file iii:test:load:defaults)
          (setq filepath (iii:test:path file))
          (if (load-file filepath)
              (iii:test:message nil "  %s: %s" "[ OK ]" file)
            (iii:test:message nil "  %s: %s" "[FAIL]" file)
            (setq success nil)))
        (setq error nil))
    (when error
      (iii:test:newline t 2)
      (iii:test:message nil "Errored loading: %s" filepath)
      (iii:test:newline)
      (iii:test:message nil "[FAIL] Failed setting up for test '%s'." suite)))

  (setq error t)

  ;; Second, load the file(s) for the chose test.
  ;;   - Gotta figure out what those are...
  (iii:test:newline)
  (iii:test:message nil "Getting test suite file list...")
  (unwind-protect
      (progn
        (let ((files (iii:test:files suite)))
          (iii:test:message nil "Loading test suite file list...")
          (dolist (file files)
            (setq filepath (iii:test:path file))
            (if (load-file filepath)
                (iii:test:message nil "  %s: %s" "[ OK ]" file)
              (iii:test:message nil "  %s: %s" "[FAIL]" file)
              (setq success nil))))
        (setq error nil))
    (when error
      (iii:test:newline t 2)
      (iii:test:message nil "Errored loading: %s" filepath)
      (iii:test:newline)
      (iii:test:message nil "[FAIL] Failed setting up for test '%s'." suite)))

  (iii:test:newline)
  (if success
      (iii:test:message nil "[ OK ] Done.")
    (iii:test:newline t)
    (iii:test:message nil "[FAIL] Failed setting up for test '%s'." suite)))
