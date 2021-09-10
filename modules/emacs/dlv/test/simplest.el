;; -*- no-byte-compile: t; -*-
;;; emacs/dlv/test/example.el

;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

(setq dlv//test/variable :test/default)

;; Backup of original caches.
(setq dlv//test/dir-locals-directory-cache dir-locals-directory-cache)
;; dlv//test/dir-locals-directory-cache
;; dir-locals-directory-cache
(setq dlv//test/safe-local-variable-values safe-local-variable-values)
;; dlv//test/safe-local-variable-values
;; safe-local-variable-values

;; Backup of original values.
(setq dlv//test/enable-local-variables enable-local-variables)


;;------------------------------------------------------------------------------
;; Set-Up / Tear-Down
;;------------------------------------------------------------------------------

(defun dlv//test/setup (path)
  "Create directory PATH unless it exists."
  (dlv//test/teardown path)

  (unless (and (file-exists-p path)
               (file-directory-p path))
    (make-directory path))

  ;; Backup DLV caches & settings.
  (setq dlv//test/dir-locals-directory-cache dir-locals-directory-cache)
  (setq dlv//test/safe-local-variable-values safe-local-variable-values)
  (setq dlv//test/enable-local-variables enable-local-variables)

  ;; Set vars to their defaults.
  (setq dlv//test/variable :test/default)

  ;; Clear out their `safe-local-variable' slots.
  (put dlv//test/variable 'safe-local-variable nil))


(defun dlv//test/teardown (path)
  "Remove all the files & dirs used in the test by deleting the PATH."
  ;; Delete all temp files & dirs.
  (delete-directory path :recursive)

  ;; Restore caches & settings back to pre-test state.
  (setq dir-locals-directory-cache dlv//test/dir-locals-directory-cache)
  (setq safe-local-variable-values dlv//test/safe-local-variable-values)
  (setq dlv//test/enable-local-variables enable-local-variables))


;;------------------------------------------------------------------------------
;; DLV Helpers
;;------------------------------------------------------------------------------

(defun dlv//test/delete-old-name (fn-symbol)
  "Delete an old test's name."
  (fmakunbound fn-symbol)
  (makunbound fn-symbol)
  (unintern fn-symbol))


(defun dlv//test/safe-p (&rest args)
  "A predicate to use for the `safe' input param. Returns `t' (valid VALUE
for variable) always, regardless of VALUE."
  (message "dlv//test/safe-p: %S" args)
  t)


(defun dlv//test/set/enable-local-variables (setting)
  "Change `enable-local-variables'."
  (if (memq setting '(t nil :safe :all))
      (setq enable-local-variables setting)
    (error "Invalid value for `enable-local-variables'! Valid: %S, got: %S"
           '(t nil :safe :all) setting)))


(defmacro dlv//test/let (dir file &rest body)
  "Run BODY forms with the common testing vars defined lexically."
  (declare (indent 2))
  `(let* ((dirpath ,dir)
          (filename ,file)
          (filepath (concat dirpath filename))
          (class 'dlv//test/class)
          (symbol 'dlv//test/variable)
          (mode nil)
          (value/local :test/local-value)
          (value/default :test/default)
          (safe? #'dlv//test/safe-p))
     (dlv//test/set/enable-local-variables t)

     ,@body))


(defun dlv//test/variable (dirpath filename)
  "Test that a variable is safe in FILENAME in DIRPATH."
  (dlv//test/setup dirpath)

  ;; Based off example from the manual:
  ;; https://www.gnu.org/software/emacs/manual/html_node/emacs/Directory-Variables.html
  (dir-locals-set-class-variables class
                                  (list (cons mode (list (cons symbol value/local)))))

  (dir-locals-set-directory-class dirpath
                                  class)

  ;; [SUCCESS]
  ;; Get the DLVs for the class and verify its value.
  (let ((dlv.class (dir-locals-get-class-variables class)))
    ;; Should have created... something
    (should dlv.class)

    ;; Validate the struct is correctly formatted w/ correct symbol & value.
    (should (equal dlv.class
                   (list (cons mode
                               (list (cons symbol value/local)))))))

  ;; [SUCCESS]
  ;; Get the DLV class for the file's path and verify it.
  (let ((file/dlv.classes (dir-locals-find-file filepath)))
    (should file/dlv.classes)
    (should (= 3 (length file/dlv.classes)))
    (should (string= (expand-file-name (nth 0 file/dlv.classes))
                     (expand-file-name dirpath)))
    (should (eq (nth 1 file/dlv.classes)
                class))
    ;; Don't care about nth 2.
    )

  ;; Validate the actual file has the actual symbol as the actual local value.
  (let ((buffer/local (get-buffer-create filepath)))
    ;; [FAILURE]
    (should (equal value/local
                   (buffer-local-value symbol buffer/local)))

    ;; [FAILURE]
    (should (safe-local-variable-p dlv//test/variable value/local)))

  (dlv//test/teardown dirpath))


;;------------------------------------------------------------------------------
;; Tests
;;------------------------------------------------------------------------------

;; [SUCCESS]
(ert-deftest test<dlv>:basic-assumptions ()
  "Validates PATH has SYMBOL as VALUE and can get its DLV CLASS variables struct.

Does nothing to ensure variable is safe for dir/file local use."
  ;; [SUCCESS]
  ;; A valid value?
  (should (memq enable-local-variables '(t nil :safe :all)))

  ;; [SUCCESS]
  ;; A /useful/ value?
  (should (memq enable-local-variables '(t :safe)))

  ;; [SUCCESS]
  ;; Is Doom or something fucking with me by setting it to `:safe' instead of `t'?
  ;; That's an actual question to the audience. :|
  ;; (should (eq enable-local-variables :safe))
  (should (eq enable-local-variables t)))


;; [SUCCESS]
(ert-deftest test<dlv>:dlv//test/let ()
  "Test our `let*' helper macro."
  (dlv//test/let
      "~/dlv-test/"
      "locals.txt"

    (should (string= dirpath "~/dlv-test/"))
    (should (string= filename "locals.txt"))
    (should (string= filepath "~/dlv-test/locals.txt"))
    (should (eq class 'dlv//test/class))
    (should (eq symbol 'dlv//test/variable))
    (should (eq mode nil))
    (should (eq value/default :test/default))
    (should (eq value/local :test/local-value))
    (should (eq safe? #'dlv//test/safe-p))

    (should (eq enable-local-variables t))))


;; [FALIURE]
(ert-deftest test<dlv>:simple/stupid/tilde ()
  "Validates PATH has SYMBOL as VALUE and can get its DLV CLASS variables struct.

Does nothing to ensure variable is safe for dir/file local use."
  (dlv//test/let
      "~/dlv-test/"
      "locals.txt"
    ;; (expand-file-name "~/dlv-test/")
    ;; "locals.txt"

    ;; No safing on my custom variable.
    (dlv//test/variable dirpath filename)))


;; [FALIURE]
(ert-deftest test<dlv>:simple/stupid/absolute ()
  "Validates PATH has SYMBOL as VALUE and can get its DLV CLASS variables struct.

Does nothing to ensure variable is safe for dir/file local use."
  (dlv//test/let
      (expand-file-name "~/dlv-test/")
      "locals.txt"

    ;; No safing on my custom variable.
    (dlv//test/variable dirpath filename)))


;; [FALIURE]
(ert-deftest test<dlv>:simple/safe-local-variable-slot/tilde ()
  "Validates PATH has SYMBOL as VALUE and can get its DLV CLASS variables struct.

Sets a predicate in the symbol's `safe-local-variable' slot."
  (dlv//test/let
      "~/dlv-test/"
      "locals.txt"
    ;; (expand-file-name "~/dlv-test/")
    ;; "locals.txt"

    ;; Safe the custom variable via its `safe-local-variable' slot.
    (put symbol 'safe-local-variable #'dlv//test/safe-p)
    ;; [SUCCESS]
    (should (eq safe?
                (get symbol 'safe-local-variable)))

    ;; ??? [SUCCESS]
    (should (safe-local-variable-p symbol :test/default))

    ;; [FAILURE] - And the message in `dlv//test/safe-p' never shows up?
    (dlv//test/variable dirpath filename)))


;; [FALIURE]
(ert-deftest test<dlv>:simple/safe-local-variable-slot/absolute ()
  "Validates PATH has SYMBOL as VALUE and can get its DLV CLASS variables struct.

Sets a predicate in the symbol's `safe-local-variable' slot."
  (dlv//test/let
      (expand-file-name "~/dlv-test/")
      "locals.txt"

    ;; Safe the custom variable via its `safe-local-variable' slot.
    (put symbol 'safe-local-variable #'dlv//test/safe-p)
    ;; [SUCCESS]
    (should (eq safe?
                (get symbol 'safe-local-variable)))

    ;; ??? [SUCCESS]
    (should (safe-local-variable-p symbol :test/default))

    ;; [FAILURE] - And the message in `dlv//test/safe-p' never shows up?
    (dlv//test/variable dirpath filename)))


;; [FALIURE]
(ert-deftest test<dlv>:simple/safe-local-variable-values/tilde ()
  "Validates PATH has SYMBOL as VALUE and can get its DLV CLASS variables struct.

Sets a symbol/value cons in the `safe-local-variable-values' alist."
  (dlv//test/let
      "~/dlv-test/"
      "locals.txt"
    ;; (expand-file-name "~/dlv-test/")
    ;; "locals.txt"

    (push (cons symbol value/local) safe-local-variable-values)

    ;; [SUCCESS]
    (should (eq safe?
                (get symbol 'safe-local-variable)))

    ;; [FAILURE]?!
    (dlv//test/variable dirpath filename)))


;; [FALIURE]
(ert-deftest test<dlv>:simple/safe-local-variable-values/absolute ()
  "Validates PATH has SYMBOL as VALUE and can get its DLV CLASS variables struct.

Sets a symbol/value cons in the `safe-local-variable-values' alist."
  (dlv//test/let
      (expand-file-name "~/dlv-test/")
      "locals.txt"

    (push (cons symbol value/local) safe-local-variable-values)

    ;; [SUCCESS]
    (should (eq safe?
                (get symbol 'safe-local-variable)))

    ;; [FAILURE]?!
    (dlv//test/variable dirpath filename)))


;;------------------------------------------------------------------------------
;; Run All These Tests
;;------------------------------------------------------------------------------

(defun test<dlv>:run ()
  "Runn all 'test<dlv>:[...]' tests."
  (interactive)
  (ert "test<dlv>:.*"))
