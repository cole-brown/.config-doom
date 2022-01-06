;; -*- no-byte-compile: t; -*-
;;; emacs/imp/test/_cmds.el

(require 'cl-lib)

;; Need stuff from here.
(load! "_suites.el")


;;------------------------------------------------------------------------------
;; Variables & Constants
;;------------------------------------------------------------------------------

;;------------------------------
;; Currently Testing
;;------------------------------

(setq test<imp>:suite/current nil)


;;------------------------------
;; Info Messages Buffer
;;------------------------------

(setq test<imp>:buffer:messages "*imp:test messages*")


(setq test<imp>:buffer:separator "─")
(setq test<imp>:buffer:separator.length 80)


;;------------------------------------------------------------------------------
;; Functions
;;------------------------------------------------------------------------------

;;------------------------------
;; Messages
;;------------------------------

(defun test<imp>:info/buffer (&optional create?)
  "Get buffer and make sure point is at the end.

Get-or-create if CREATE? is non-nil."
  (when-let ((buffer
              (if create?
                  (get-buffer-create test<imp>:buffer:messages)
                (get-buffer test<imp>:buffer:messages))))
    (with-current-buffer buffer
      (end-of-buffer))

    buffer))


(defun test<imp>:info/message (show? message &rest args)
  "Send MESSAGE with ARGS to the imp:test buffer (named by
`test<imp>:buffer:messages').

Shows buffer (as popup) if SHOW? is non-nil, else leaves it however it is.

Uses `format' for the MESSAGE and ARGS."
  (with-current-buffer (test<imp>:info/buffer t)
    (insert (apply #'format message args) "\n")
    (when show?
      ;; TODO: Un-doom-ify? Just use a normal 'other window' maybe?
      (+popup/buffer))))


(defun test<imp>:info/newline (&optional show? number)
  "Inserts NUMBER of newlines into the test messages buffer.

If NUMBER is nil, inserts 1 newline.

Shows buffer (as popup) if SHOW? is non-nil, else leaves it however it is."
  (when-let ((buffer (test<imp>:info/buffer)))
    (with-current-buffer buffer
      (insert (make-string (or number 1) (string-to-char "\n")))
      (when show?
        ;; TODO: Un-doom-ify? Just use a normal 'other window' maybe?
        (+popup/buffer)))))


(defun test<imp>:info/section (&optional clear)
  "If test messages buffer has content in it, make a new section or clear.

If test messages buffer does not exist, does nothing.

If CLEAR is non-nil, clears the buffer. Else prints a newline, a line separator
(hypens, unicode box line, etc), and two more newlines."
  (when-let ((buffer (test<imp>:info/buffer)))
    (with-current-buffer buffer
      (if (not clear)
          ;; Just want to separate sections.
          (insert (concat "\n"
                          (make-string test<imp>:buffer:separator.length
                                       (string-to-char test<imp>:buffer:separator))
                          "\n\n"))

        ;; Nuke it from orbit.
        (erase-buffer)))))


;;------------------------------
;; Commands
;;------------------------------

(defun imp:test:info-buffer-toggle ()
  "Hide the imp:test message popup buffer."
  (interactive)
  ;; TODO: Un-doom-ify? Just use a normal 'other window' maybe?
  (+popup/toggle)
  ;; ;; Undoomed/hybrid would be something like...
  ;; (if-let ((buffer (get-buffer test<imp>:buffer:messages)))
  ;;     (if-let ((window (get-buffer-window buffer)))
  ;;         ;; Is showing; hide.
  ;;         (if (+popup-window-p window)
  ;;             (+popup/close)
  ;;           ;; Not a popup; bury it.
  ;;           (with-current-buffer-window test<imp>:buffer:messages
  ;;               (bury-buffer)))
  ;;
  ;;       ;; Is hidden; show.
  ;;       ;; TODO: show buffer or popup, depending.
  ;;       )
  ;;
  ;;   ;; No imp:test buffer currently.
  ;;   (message "No 'imp:test' buffer exists right now."))
  )


(defun imp:test:init (suite-name)
  "Load base imp files like debug, path, etc. in prep for running a test suite.

SUITE-NAME should be a valid key in `test<imp>:choices' alist."
  (interactive (list (completing-read "Test Suite: "
                                      (test<imp>:suite//get-all-names)
                                      nil
                                      ;; Must choose something in our list.
                                      t)))

  (let* ((suite-keyword (test<imp>:suite/name->keyword suite-name))
         (success t)
         (error t)
         filename
         filepath)
    (when (not suite-name)
      (error "Unkown imp test suite #%s. Options: %S"
             suite-name
             (test<imp>:suite//get-all-names)))

    ;; Save suite chosen for later commands.
    (setq test<imp>:suite/current suite-keyword)

    ;; Hello there.
    (test<imp>:info/section)
    (test<imp>:info/message t "imp:test:init:\n  suite: %s\n" suite-name)

    ;; First, load the defaults.
    (test<imp>:info/message nil "Loading default files...")
    (unwind-protect
        (progn
          (dolist (file test<imp>:suites:files/load-always)
            (setq filepath (test<imp>:path file))
            (if (load-file filepath)
                (test<imp>:info/message nil "  %s: %s" "[ OK ]" file)
              (test<imp>:info/message nil "  %s: %s" "[FAIL]" file)
              (setq success nil)))
          (setq error nil))
      (when error
        (test<imp>:info/newline t 2)
        (test<imp>:info/message nil "Errored loading: %s" filepath)
        (test<imp>:info/newline)
        (test<imp>:info/message nil "[FAIL] Failed setting up for test '%s'." suite-name)))

    (setq error t)
    (setq filename nil
          filepath nil)

    ;; Second, load the file(s) for the chose test.
    ;;   - Gotta figure out what those are...
    (test<imp>:info/newline)
    (test<imp>:info/message nil "Getting test suite file list for `%s'..." suite-keyword)
    (unwind-protect
        (progn
          (let ((files (test<imp>:suite/files suite-keyword)))
            (test<imp>:info/message nil "Loading test suite file list...")
            (dolist (file files)
              ;; Setting 'filename' for error message use.
              (setq filename file
                    filepath (test<imp>:path file))
              (if (load-file filepath)
                  (test<imp>:info/message nil "  %s: %s" "[ OK ]" file)
                (test<imp>:info/message nil "  %s: %s (%s)" "[FAIL]" file filepath)
                (setq success nil))))
          (setq error nil))
      (when error
        (test<imp>:info/newline t 2)
        (test<imp>:info/message nil "Errored loading: %s\n  path: %s"  filename filepath)
        (test<imp>:info/newline)
        (test<imp>:info/message nil "[FAIL] Failed setting up for test '%s'." suite-name)))

    (test<imp>:info/newline)
    (if success
        (test<imp>:info/message nil "[ OK ] Done.")
      (test<imp>:info/newline t)
      (test<imp>:info/message nil "[FAIL] Failed setting up for test '%s'." suite-name))))


(defun imp:test:run (&optional suite-keyword-or-name)
  "Run a test suite defined by SUITE-KEYWORD-OR-NAME via ERT."
  (interactive (list (completing-read "Test Suite: "
                                      (test<imp>:suite//get-all-names)
                                      nil
                                      ;; Must choose something in our list.
                                      t
                                      ;; Default to current suite.
                                      (when test<imp>:suite/current
                                        (test<imp>:suite/keyword->name test<imp>:suite/current)))))
  (let ((suite-name (if (stringp suite-keyword-or-name)
                        suite-keyword-or-name
                      (test<imp>:suite/keyword->name suite-keyword-or-name)))
        (suite-keyword (if (keywordp suite-keyword-or-name)
                           suite-keyword-or-name
                         (test<imp>:suite/name->keyword suite-keyword-or-name))))
    (unless (eq suite-keyword test<imp>:suite/current)
      (test<imp>:info/section)
      (test<imp>:info/message nil
                        "imp:test:run:\n  Changing suites:\n    from: %s\n      to: %s\n\n"
                        (test<imp>:suite/keyword->name test<imp>:suite/current)
                        suite-name)
      (test<imp>:info/newline)

      ;; Init for the new suite.
      (imp:test:init suite-name))

   (test<imp>:info/section)
   (test<imp>:info/message nil "imp:test:run:\n  suite: %s\n\n" suite-name)
   (ert (test<imp>:suite//regex.get suite-keyword))))
;; (imp:test:run :tree)
