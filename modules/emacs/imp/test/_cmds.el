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

(setq iii:test:suite/current nil)


;;------------------------------
;; Info Messages Buffer
;;------------------------------

(setq iii:test:buffer:messages "*imp:test messages*")


(setq iii:test:buffer:separator "─")
(setq iii:test:buffer:separator.length 80)


;;------------------------------------------------------------------------------
;; Functions
;;------------------------------------------------------------------------------

;;------------------------------
;; Messages
;;------------------------------

(defun iii:test:info/buffer (&optional create?)
  "Get buffer and make sure point is at the end.

Get-or-create if CREATE? is non-nil."
  (when-let ((buffer
              (if create?
                  (get-buffer-create iii:test:buffer:messages)
                (get-buffer iii:test:buffer:messages))))
    (with-current-buffer buffer
      (end-of-buffer))

    buffer))


(defun iii:test:info/message (show? message &rest args)
  "Send MESSAGE with ARGS to the imp:test buffer (named by
`iii:test:buffer:messages').

Shows buffer (as popup) if SHOW? is non-nil, else leaves it however it is.

Uses `format' for the MESSAGE and ARGS."
  (with-current-buffer (iii:test:info/buffer t)
    (insert (apply #'format message args) "\n")
    (when show?
      ;; TODO: Un-doom-ify? Just use a normal 'other window' maybe?
      (+popup/buffer))))


(defun iii:test:info/newline (&optional show? number)
  "Inserts NUMBER of newlines into the test messages buffer.

If NUMBER is nil, inserts 1 newline.

Shows buffer (as popup) if SHOW? is non-nil, else leaves it however it is."
  (when-let ((buffer (iii:test:info/buffer)))
    (with-current-buffer buffer
      (insert (make-string (or number 1) (string-to-char "\n")))
      (when show?
        ;; TODO: Un-doom-ify? Just use a normal 'other window' maybe?
        (+popup/buffer)))))


(defun iii:test:info/section (&optional clear)
  "If test messages buffer has content in it, make a new section or clear.

If test messages buffer does not exist, does nothing.

If CLEAR is non-nil, clears the buffer. Else prints a newline, a line separator
(hypens, unicode box line, etc), and two more newlines."
  (when-let ((buffer (iii:test:info/buffer)))
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
;; Commands
;;------------------------------

(defun imp:test:info-buffer-toggle ()
  "Hide the imp:test message popup buffer."
  (interactive)
  ;; TODO: Un-doom-ify? Just use a normal 'other window' maybe?
  (+popup/toggle)
  ;; ;; Undoomed/hybrid would be something like...
  ;; (if-let ((buffer (get-buffer iii:test:buffer:messages)))
  ;;     (if-let ((window (get-buffer-window buffer)))
  ;;         ;; Is showing; hide.
  ;;         (if (+popup-window-p window)
  ;;             (+popup/close)
  ;;           ;; Not a popup; bury it.
  ;;           (with-current-buffer-window iii:test:buffer:messages
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

SUITE-NAME should be a valid key in `iii:test:choices' alist."
  (interactive (list (completing-read "Test Suite: "
                                      (iii:test:suite//get-all-names)
                                      nil
                                      ;; Must choose something in our list.
                                      t)))

  (let* ((suite-keyword (iii:test:suite/name->keyword suite-name))
         (success t)
         (error t)
         filename
         filepath)
    (when (not suite-name)
      (error "Unkown imp test suite #%s. Options: %S"
             suite-name
             (iii:test:suite//get-all-names)))

    ;; Save suite chosen for later commands.
    (setq iii:test:suite/current suite-keyword)

    ;; Hello there.
    (iii:test:info/section)
    (iii:test:info/message t "imp:test:init:\n  suite: %s\n" suite-name)

    ;; First, load the defaults.
    (iii:test:info/message nil "Loading default files...")
    (unwind-protect
        (progn
          (dolist (file iii:test:suites:files/load-always)
            (setq filepath (iii:test:path file))
            (if (load-file filepath)
                (iii:test:info/message nil "  %s: %s" "[ OK ]" file)
              (iii:test:info/message nil "  %s: %s" "[FAIL]" file)
              (setq success nil)))
          (setq error nil))
      (when error
        (iii:test:info/newline t 2)
        (iii:test:info/message nil "Errored loading: %s" filepath)
        (iii:test:info/newline)
        (iii:test:info/message nil "[FAIL] Failed setting up for test '%s'." suite-name)))

    (setq error t)
    (setq filename nil
          filepath nil)

    ;; Second, load the file(s) for the chose test.
    ;;   - Gotta figure out what those are...
    (iii:test:info/newline)
    (iii:test:info/message nil "Getting test suite file list for `%s'..." suite-keyword)
    (unwind-protect
        (progn
          (let ((files (iii:test:suite/files suite-keyword)))
            (iii:test:info/message nil "Loading test suite file list...")
            (dolist (file files)
              ;; Setting 'filename' for error message use.
              (setq filename file
                    filepath (iii:test:path file))
              (if (load-file filepath)
                  (iii:test:info/message nil "  %s: %s" "[ OK ]" file)
                (iii:test:info/message nil "  %s: %s (%s)" "[FAIL]" file filepath)
                (setq success nil))))
          (setq error nil))
      (when error
        (iii:test:info/newline t 2)
        (iii:test:info/message nil "Errored loading: %s\n  path: %s"  filename filepath)
        (iii:test:info/newline)
        (iii:test:info/message nil "[FAIL] Failed setting up for test '%s'." suite-name)))

    (iii:test:info/newline)
    (if success
        (iii:test:info/message nil "[ OK ] Done.")
      (iii:test:info/newline t)
      (iii:test:info/message nil "[FAIL] Failed setting up for test '%s'." suite-name))))


(defun imp:test:run (&optional suite-keyword-or-name)
  "Run a test suite defined by SUITE-KEYWORD-OR-NAME via ERT."
  (interactive (list (completing-read "Test Suite: "
                                      (iii:test:suite//get-all-names)
                                      nil
                                      ;; Must choose something in our list.
                                      t
                                      ;; Default to current suite.
                                      (when iii:test:suite/current
                                        (iii:test:suite/keyword->name iii:test:suite/current)))))
  (let ((suite-name (if (stringp suite-keyword-or-name)
                        suite-keyword-or-name
                      (iii:test:suite/keyword->name suite-keyword-or-name)))
        (suite-keyword (if (keywordp suite-keyword-or-name)
                           suite-keyword-or-name
                         (iii:test:suite/name->keyword suite-keyword-or-name))))
    (unless (eq suite-keyword iii:test:suite/current)
      (iii:test:info/section)
      (iii:test:info/message nil
                        "imp:test:run:\n  Changing suites:\n    from: %s\n      to: %s\n\n"
                        (iii:test:suite/keyword->name iii:test:suite/current)
                        suite-name)
      (iii:test:info/newline)

      ;; Init for the new suite.
      (imp:test:init suite-name))

   (iii:test:info/section)
   (iii:test:info/message nil "imp:test:run:\n  suite: %s\n\n" suite-name)
   (ert (iii:test:suite//regex.get suite-keyword))))
;; (imp:test:run :tree)
