;; -*- no-byte-compile: t; lexical-binding: t; -*-
;;; emacs/dlv/test/dlv.el

;;------------------------------------------------------------------------------
;; Test Directory Local Variables
;;------------------------------------------------------------------------------

(require 'dash)

;; Get all the DLV files we want to test.
(load "../init.el")

;;---
;; NOTE: A valid DLV struct from the Emacs docs:
;;
;;   '((nil . ((indent-tabs-mode . t)
;;             (fill-column . 80)
;;             (mode . auto-fill)))
;;     (c-mode . ((c-file-style . "BSD")
;;                (subdirs . nil)))
;;     ("src/imported"
;;      . ((nil . ((change-log-default-name
;;                  . "ChangeLog.local"))))))
;;---


;; TODO: ensure `dlv//test/' prefix.
;; TODO: colons not slashes


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

(setq dlv//test/const/path.root "~/dlv-test/")

(setq dlv//test/const/unique-paths? nil)

(setq dlv//fixture/dir.name nil)
(setq dlv//fixture/file.name nil)
(setq dlv//fixture/dir.path nil)
(setq dlv//fixture/file.path nil)


;;------------------------------
;; Backups
;;------------------------------

;; Backup of original caches.
(setq dlv//test/dir-locals-directory-cache dir-locals-directory-cache)
;; (setq dir-locals-directory-cache '(("d:/home/work/.emacs.d/" d:/home/work/\.emacs\.d/ (24827 297 0 0))))

(setq dlv//test/safe-local-variable-values safe-local-variable-values)
;; (setq safe-local-variable-values nil)

(setq dlv//test/dir-locals-class-alist dir-locals-class-alist)
;; (setq dir-locals-class-alist '((d:/home/work/\.emacs\.d/ (nil (git-commit-major-mode . git-commit-elisp-text-mode)) (org-mode (buffer-read-only . t)))))

;; Backup of original values.
(setq dlv//test/enable-local-variables enable-local-variables)


;; Unique Counters
(setq dlv//test/var.uid 0)
(setq dlv//test/path.uid 0)


;;------------------------------------------------------------------------------
;; DLV Helpers
;;------------------------------------------------------------------------------

;;------------------------------
;; Variables
;;------------------------------

(defun dlv//test/var/value.local (test-name &optional suffix)
  "Get a unique local value for the variable.

If SUFFIX is non-nil, appends it to the end of the value, prefixed with
a \"/\" separator."
  (let ((uid dlv//test/var.uid)
        (suffix-fmt (if suffix "/%s" "")))
    (setq dlv//test/var.uid (1+ dlv//test/var.uid))
    (intern (format (concat ":test/"
                            test-name "/"
                            "%s/%03d"
                            suffix-fmt)
                    (dlv//test/time.str)
                    uid
                    suffix))))
;; (dlv//test/var/value.local "test")
;; (dlv//test/var/value.local "test" "jeff")
;; (dlv//test/var/value.local "test" 0)


(defun dlv//test/var/value.default (test-name)
  "Get a default value for the variable."
  :test/default
  ;; (let ((uid dlv//test/var.uid))
  ;;   (setq dlv//test/var.uid (1+ dlv//test/var.uid))
  ;;   (intern (format (concat ":test/"
  ;;                           test-name "/"
  ;;                           "DEFAULT/"
  ;;                           "%s/%03d")
  ;;                   (dlv//test/time.str)
  ;;                   uid)))
  )
;; (dlv//test/var/value.default "test")

(defun dlv//test/var.create (test-name symbol &rest plist)
  "Create a variable named SYMBOL for testing TEST-NAME.

TEST-NAME should be a short, unique string.
e.g. `test<dlv>:example/do-specific-thing' might be \"specific-thing\".

PLIST can have these keywords:
  - `:safe-fn'
  - `:safe-value'
  - `:default-value'

If `:safe-fn' keyword's value is not nil, put it in the SYMBOL's `safe-local-variable' property.

If `:safe-value' keyword's value is not nil, put it in the `safe-local-variable-values' alist.

If `:default-value' keyword exists, use it as the default value.
  - Otherwise use `dlv//test/var/value.default' function's output."
  (-let [(&plist :safe-fn :safe-value :default-value) plist]
    ;; Set the default values.
    (set symbol (or default-value (dlv//test/var/value.default test-name)))

    ;; Set the `safe-local-variable' slots.
    (when safe-fn
      (put symbol 'safe-local-variable safe-fn))

    ;; Set the `safe-local-variable-values' pair.
    (when safe-value
      (push (cons symbol safe-value) safe-local-variable-values))))


(defun dlv//test/var.delete (symbol)
  "Unbinds the variable named SYMBOL.

Also removes it from the `safe-local-variable-values' alist if it was in there."
  ;; Unbind the symbol.
  (makunbound symbol)

  ;; Remove the `safe-local-variable-values' pair if it exists.
  (if (alist-get symbol safe-local-variable-values)
      (setf (alist-get symbol safe-local-variable-values nil :remove) nil)))


(defun dlv//test/always-safe? (value)
  "Predicate to declare that any and all values are safe for the variable.

Ignores VALUE; always returns t."
  (dlv//debug "dlv//test/always-safe?"
              "Safe predicated called for value: %S"
              value)
  t)


;;------------------------------
;; Strings
;;------------------------------

(defun dlv//test/time.str ()
  "Get a time str for creating var values, filenames, etc."
  (format-time-string "%FT%H-%M-%S-%3N%z"))


;;------------------------------
;; Paths
;;------------------------------

(defun dlv//test/path/parent.get (path)
  "Returns the parent directory of PATH."
  (file-name-directory (directory-file-name path)))
;; (dlv//test/path/parent.get dlv//test/const/path.root)
;; (dlv//test/path/parent.get dlv//test/const/path.file)


(defun dlv//test/dirname (&optional name)
  "Create a unique dirname using NAME, `dlv//test/time.str', and `dlv//test/path.uid'."
  (let ((name (or name "locals"))
        (uid  dlv//test/path.uid))
    (if dlv//test/const/unique-paths?
        (progn
          (setq dlv//test/path.uid (1+ dlv//test/path.uid))
          (format (concat name ".%s.%03d")
                  (dlv//test/time.str)
                  uid
                  "/"))
      name)))


(defun dlv//test/filename (&optional name ext)
  "Create a unique filename using NAME, EXT, `dlv//test/time.str', and `dlv//test/path.uid'."
  (let ((name (or name "locals"))
        (ext  (or ext "txt"))
        (uid  dlv//test/path.uid))
    (if dlv//test/const/unique-paths?
        (progn
          (setq dlv//test/path.uid (1+ dlv//test/path.uid))
          (format (concat name ".%s.%03d.%s")
                  (dlv//test/time.str)
                  uid
                  ext))
      (format (concat name ".%s")
              ext))))
;; (dlv//test/filename)


;;------------------------------------------------------------------------------
;; Test Fixture (Set-Up / Tear-Down) Functions
;;------------------------------------------------------------------------------

;;------------------------------
;; Set-Up
;;------------------------------

(defun dlv//test/dir.create (path)
  "Create directory PATH unless it exists."
  (if (and (file-exists-p path)
           (file-directory-p path))
      :exists
    (make-directory path)))


(defun dlv//test/setup.paths (name)
  "Ensure the dirs and files exist."
  (dlv//test/dir.create dlv//test/const/path.root)

  (if (null name)
      ;; No name provided - ensure the fixture dir/file vars are cleared.
      (setq dlv//fixture/dir.name nil
            dlv//fixture/file.name nil
            dlv//fixture/dir.path nil
            dlv//fixture/file.path nil)

    ;; Setup dir/file vars and ensure dir exists.
    (setq dlv//fixture/dir.name  (dlv//test/dirname name)
          dlv//fixture/file.name (dlv//test/filename name)
          dlv//fixture/dir.path  (file-name-as-directory (concat dlv//test/const/path.root dlv//fixture/dir.name))
          dlv//fixture/file.path (concat dlv//fixture/dir.path dlv//fixture/file.name))
    (dlv//test/dir.create dlv//fixture/dir.path)))
;; (dlv//test/setup.paths "test-setup-paths")


(defun dlv//test/setup.vars ()
  "Save pre-test values of DLV caches & settings so tests don't leave them messy."
  ;; Save DLV caches/settings.
  (setq dlv//test/dir-locals-directory-cache dir-locals-directory-cache)
  (setq dlv//test/safe-local-variable-values safe-local-variable-values)
  (setq dlv//test/enable-local-variables enable-local-variables)
  (setq dlv//test/dir-locals-class-alist dir-locals-class-alist))


(defun dlv//test/setup (name)
  "Run setup for tests."
  ;; Ensure data is cleaned from last test run (could have errored out and not finished).
  (dlv//test/teardown.paths)

  ;; Create temp dirs & files.
  (dlv//test/setup.paths name)
  ;; (dlv//test/setup.files)

  ;; Backup DLV caches & settings.
  ;; Set vars to their defaults.
  (dlv//test/setup.vars))
;; (dlv//test/setup)


;;------------------------------
;; Tear-Down
;;------------------------------

(defun dlv//test/teardown.paths ()
  "Remove all the files & dirs used in the test by deleting the root dir."
  (setq dlv//fixture/dir.name nil)
  (setq dlv//fixture/file.name nil)
  (setq dlv//fixture/dir.path nil)
  (setq dlv//fixture/file.path nil)

  (delete-directory dlv//test/const/path.root :recursive))


(defun dlv//test/teardown.vars ()
  "Restore vars to backed up values."
  ;; TODO: Do I need any of these?
  ;; (delete-file-local-variable ...)
  ;; (delete-file-local-variable-prop-line ...)

  ;; Restore caches & settings back to pre-test state.
  (setq dir-locals-directory-cache dlv//test/dir-locals-directory-cache)
  (setq safe-local-variable-values dlv//test/safe-local-variable-values)
  (setq enable-local-variables dlv//test/enable-local-variables)
  (setq dir-locals-class-alist dlv//test/dir-locals-class-alist))


(defun dlv//test/teardown ()
  "Run teardown for tests."
  (dlv//test/teardown.paths)
  (dlv//test/teardown.vars))
;; (dlv//test/teardown)


;;------------------------------
;; Test Fixture Macro
;;------------------------------

(defmacro dlv//with-fixture (name test-teardown-fn &rest body)
  "Run `dlv//test/setup', then BODY, then ensures `dlv//test/teardown' is run
no matter what happens in BODY. Binds NAME to `test-name'.

If NAME is non-nil, it is used to create a directory and file name (paths too), saved to:
 - `dlv//fixture/dir.name'
 - `dlv//fixture/file.name'
 - `dlv//fixture/dir.path'
 - `dlv//fixture/file.path'

If TEST-TEARDOWN-FN is non-nil, it is /always/ called after the test is run (even if it errors out/fails/etc).
TEST-TEARDOWN-FN should take one parameter: NAME."
  (declare (indent 2))
  ;; `unwind-protect' lets us run teardown even if errors, etc.
  `(let ((test-name ,name)
         (dlv//with-fixture/teardown-fn ,test-teardown-fn))
     (unwind-protect
         (progn
           (dlv//test/setup test-name)

           ,@body)
       (when dlv//with-fixture/teardown-fn
         (dlv//with-fixture/teardown-fn test-name))
       (dlv//test/teardown))))


;;------------------------------
;; File/Buffer Management
;;------------------------------

(defmacro dlv//with-file-buffer (path &rest body)
  "Create/open file PATH and run BODY with PATH's buffer as the current buffer.
Closes the buffer and deletes the file after BODY is run.

If you want the buffer in BODY, it is store in the lexical variable
`dlv//with-file-buffer/buffer'."
  (declare (indent 1))
  `(let ((dlv//with-file-buffer/path ,path)
         dlv//with-file-buffer/buffer)
     (unwind-protect
         (progn
           (setq dlv//with-file-buffer/buffer (find-file-noselect ,path))
           (with-current-buffer dlv//with-file-buffer/buffer
             ,@body))
       (kill-buffer dlv//with-file-buffer/buffer)
       (delete-file dlv//with-file-buffer/path))))


;;------------------------------------------------------------------------------
;; Reusable Test Assertions
;;------------------------------------------------------------------------------

(defun dlv//test/assert/valid-path (expected-parent path)
  "Returns true if PATH is a child of EXPECTED-PARENT after expanding."
  (let ((parent (expand-file-name expected-parent))
        (child (expand-file-name path))
        stuck
        found-parent?)
    (should parent)
    (should child)
    (should (stringp parent))
    (should (stringp child))
    ;; parent should be absolute and a directory.
    (should (file-name-absolute-p parent))
    (should (directory-name-p parent))
    ;; child should be absolute. Might be a dir; maybe a file.
    (should (file-name-absolute-p child))

    ;; Walk up from child looking for parent.
    (let ((loop-path child))
      (while (and loop-path
                  (not found-parent?)
                  (not stuck))
        (if (string= parent loop-path)
            (setq found-parent? t
                  loop-path nil)

          (let ((next (dlv//test/path/parent.get loop-path)))
            ;; Should not get stuck at the root.
            (if (string= loop-path next)
                (setq stuck t
                      loop-path nil)
              (setq loop-path next))))))

    ;; Did we find the parent?
    ;;   - Add paren/child on so we can see them in the ERT failure.
    (should (equal (list t parent child)
                   (list found-parent? parent child)))))


(defun dlv//test/assert/safe-local-variable (&rest kvp)
  "Assert for each KVP that symbol has the safe-fn.

KVPs are tuples of: '(symbol safe-fn)."
  (dolist (item kvp)
    (let ((symbol (nth 0 item))
          (safe-fn (nth 1 item)))
      ;; Both should exist.
      (should symbol)
      (should safe-fn)
      ;; Symbol should have `safe-fn' as its `safe-local-variable' prop.
      (should (eq safe-fn
                  (get symbol 'safe-local-variable))))))


(defun dlv//test/assert/dlv.class (&rest kvp)
  "Assert for each KVP that class has the mode and the mode has the symbol/value.

KVPs are tuples of: '(class-symbol mode var-symbol value)"
  (dolist (item kvp)
    (let* ((class  (nth 0 item))
           (mode   (nth 1 item))
           (symbol (nth 2 item))
           (value  (nth 3 item))
           (dlv.class (dir-locals-get-class-variables class)))

      ;; Validate the CLASS struct exists.
      (should (not (null dlv.class)))

      ;; Validate the struct is correctly formatted w/ correct symbol & value.
      ;; Don't want to require anything in a specific order in the alist, though.
      (let* ((dlv.class.mode-entry (assoc mode dlv.class))
             (dlv.class.mode (car dlv.class.mode-entry))
             (dlv.class.vars (cdr dlv.class.mode-entry)))
        (should dlv.class.mode-entry)

        (should (eq mode dlv.class.mode))

        ;; Verify that our symbol/value is somewhere in the class vars.
        (let* ((dlv.class.var-entry (assoc symbol dlv.class.vars))
               (dlv.class.var       (car dlv.class.var-entry))
               (dlv.class.value     (cdr dlv.class.var-entry)))
          (should dlv.class.var-entry)
          (should (eq symbol dlv.class.var))
          (should (eq value dlv.class.value)))))))


(defun dlv//test/assert/dlv.dir (&rest kvp)
  "Assert for each KVP that the filepath's parent dir has a DLV structure with
the class symbol in it.

KVPs are tuples of: '(filepath class-symbol)"
  (dolist (item kvp)
    (let* ((filepath (nth 0 item))
           (dirpath (dlv//test/path/parent.get filepath))
           (class   (nth 1 item)))

      ;; Get the DLV class for the file's path and verify.
      (let ((file/dlv.classes (dir-locals-find-file filepath)))
        (should file/dlv.classes)
        (should (= 3 (length file/dlv.classes)))
        (dlv//test/assert/valid-path (nth 0 file/dlv.classes)
                                     dirpath)
        (should (eq (nth 1 file/dlv.classes)
                    class))))))


;;------------------------------------------------------------------------------
;; Tests
;;------------------------------------------------------------------------------

;;------------------------------
;; Stupidest, simplest test.
;;------------------------------

(ert-deftest test<dlv>:simple//hard-coded ()
  "Test very basic DLV set. No DLV lib code."

  (dlv//with-fixture nil nil
    (let ((dir dlv//test/const/path.root)
          (file "locals.hard-coded.txt"))
      (defvar dlv-test-hard-coded-var :test/default)
      (put 'dlv-test-hard-coded-var 'safe-local-variable #'dlv//test/always-safe?)

      (dir-locals-set-class-variables
       'dlv-test-hard-coded-class
       '((nil . ((dlv-test-hard-coded-var . :test/local)))))

      (dir-locals-set-directory-class dir 'dlv-test-hard-coded-class)

      (dlv//with-file-buffer
          (concat dir file)
        (should (eq :test/local
                    dlv-test-hard-coded-var))))))


;;------------------------------
;; Variables instead of Hard-Coded, but still very stupid simple.
;;------------------------------

(ert-deftest test<dlv>:simple//variables ()
  "Test very basic DLV set. No DLV lib code."

  (dlv//with-fixture "simple-vars" nil
    (let* ((value.local   (dlv//test/var/value.local test-name))
           (class 'dlv-test-simple-class)
           (mode nil)
           (symbol 'dlv-test-simple-var))
      (dlv//test/var.create test-name
                            symbol
                            :safe-fn #'dlv//test/always-safe?
                            ;; :safe-value nil
                            ;; :default-value nil
                            )

      ;; Create the DLV.
      (let ((dlv.struct (list (cons mode (list (cons symbol value.local))))))
        (dir-locals-set-class-variables class dlv.struct))

      (dir-locals-set-directory-class dlv//fixture/dir.path class)

      ;; Test the DLV.
      (dlv//with-file-buffer dlv//fixture/file.path
        (should (eq value.local
                    (symbol-value symbol)))))))


;;------------------------------
;; Simple test of `dlv/set'.
;;------------------------------

(ert-deftest test<dlv>:simple//dlv/set ()
  "Test very basic use of DLV function `dlv/set'."

  (dlv//with-fixture "simple-dlv-set" nil
    (let* ((value.local   (dlv//test/var/value.local test-name))
           (class 'dlv-test-simple-dlv-set-class)
           (mode nil)
           (symbol 'dlv-test-simple-dlv-set-var))
      (dlv//test/var.create test-name
                            symbol
                            :safe-fn #'dlv//test/always-safe?
                            ;; :safe-value nil
                            ;; :default-value nil
                            )

      ;; Create the DLV.
      (dlv/set class dlv//fixture/dir.path mode
               (list symbol value.local #'dlv//test/always-safe?))

      ;; Test the DLV.
      (dlv//with-file-buffer dlv//fixture/file.path
        (should (eq value.local
                    (symbol-value symbol)))))))


;;------------------------------
;; Full test of `dlv/set'.
;;------------------------------

(ert-deftest test<dlv>:full//dlv/set ()
  "Test `dlv/set' more in-depth."

  (dlv//with-fixture "full-dlv-set" nil
    (let* ((class 'dlv-test-full-dlv-set-class)
           (mode nil)
           (symbol 'dlv-test-full-dlv-set-var)
           (value.local (dlv//test/var/value.local test-name)))
      (dlv//test/var.create test-name symbol)

      ;;------------------------------
      ;; Create the DLV.
      ;;------------------------------
      ;; Should return non-nil.
      (should (dlv/set class dlv//fixture/dir.path mode
                       (list symbol value.local #'dlv//test/always-safe?)))

      ;;------------------------------
      ;; Test the DLV.
      ;;------------------------------
      (dlv//test/assert/safe-local-variable (list symbol #'dlv//test/always-safe?))
      (dlv//test/assert/dlv.class (list class mode symbol value.local))
      (dlv//test/assert/dlv.dir (list dlv//fixture/file.path class))

      ;; Check the actual value in an actual file buffer.
      (dlv//with-file-buffer dlv//fixture/file.path
        (should (eq value.local
                    (symbol-value symbol)))))))


;;------------------------------
;; `dlv/set' test with multiple symbols.
;;------------------------------

(ert-deftest test<dlv>:multiple/vars//dlv/set ()
  "Test `dlv/set' with multiple tuples."

  (dlv//with-fixture "multi-vars-dlv-set" nil
    (let* ((class 'dlv-test-multi-vars-dlv-set-class)
           (mode nil)
           (symbol.0 'dlv-test-multi-vars-dlv-set-var0)
           (value.0.local (dlv//test/var/value.local test-name 0))
           (symbol.1 'dlv-test-multi-vars-dlv-set-var1)
           (value.1.local (dlv//test/var/value.local test-name 1)))
      (dlv//test/var.create test-name symbol.0)
      (dlv//test/var.create test-name symbol.1)

      ;;------------------------------
      ;; Create the DLV.
      ;;------------------------------
      ;; Should return non-nil.
      (should (dlv/set class dlv//fixture/dir.path mode
                       (list symbol.0 value.0.local #'dlv//test/always-safe?)
                       (list symbol.1 value.1.local #'dlv//test/always-safe?)))

      ;;------------------------------
      ;; Test the DLV.
      ;;------------------------------
      (dlv//test/assert/safe-local-variable (list symbol.0 #'dlv//test/always-safe?)
                                            (list symbol.1 #'dlv//test/always-safe?))
      (dlv//test/assert/dlv.class (list class mode symbol.0 value.0.local)
                                  (list class mode symbol.1 value.1.local))
      (dlv//test/assert/dlv.dir (list dlv//fixture/file.path class))

      ;; Check the actual value in an actual file buffer.
      (dlv//with-file-buffer dlv//fixture/file.path
        (should (eq value.0.local
                    (symbol-value symbol.0)))
        (should (eq value.1.local
                    (symbol-value symbol.1)))))))


;;------------------------------
;; `dlv/set' test with multiple dirs.
;;------------------------------

(ert-deftest test<dlv>:multiple/dir//dlv/set ()
  "Test `dlv/set' with multiple dirs."

  (dlv//with-fixture "multi-vars-dlv-set" nil
    (let* ((class.0 'dlv-test-multi-dir-dlv-set-class0)
           (class.1 'dlv-test-multi-dir-dlv-set-class1)
           (class.2 'dlv-test-multi-dir-dlv-set-class2)

           (mode.0 nil)
           (mode.1 nil)
           (mode.2 nil)

           (symbol.0 'dlv-test-multi-dir-dlv-set-var0)
           (symbol.1 'dlv-test-multi-dir-dlv-set-var1)
           (symbol.2 'dlv-test-multi-dir-dlv-set-var2)

           (value.0.local (dlv//test/var/value.local test-name 0))
           (value.1.local (dlv//test/var/value.local test-name 1))
           (value.2.local (dlv//test/var/value.local test-name 2))

           (dir.0.name "dir-0")
           (dir.1.name "dir-1")
           (dir.2.name "dir-2")
           (dir.0.path (file-name-as-directory (concat dlv//fixture/dir.path dir.0.name)))
           (dir.1.path (file-name-as-directory (concat dlv//fixture/dir.path dir.1.name)))
           (dir.2.path (file-name-as-directory (concat dlv//fixture/dir.path dir.2.name)))

           (file.0.name "file-0")
           (file.1.name "file-1")
           (file.2.name "file-2")
           (file.0.path (concat dir.0.path file.0.name))
           (file.1.path (concat dir.1.path file.1.name))
           (file.2.path (concat dir.2.path file.2.name)))

      (dlv//test/var.create test-name symbol.0)
      (dlv//test/var.create test-name symbol.1)
      (dlv//test/var.create test-name symbol.2)

      ;; Create dirs as subdirectories under the one setup created.
      (dlv//test/dir.create dir.0.path)
      (dlv//test/dir.create dir.1.path)
      (dlv//test/dir.create dir.2.path)

      ;;------------------------------
      ;; Create the DLVs.
      ;;------------------------------
      ;; Should return non-nil.
      (should (dlv/set class.0 dir.0.path mode.0
                       (list symbol.0 value.0.local #'dlv//test/always-safe?)))
      (should (dlv/set class.1 dir.1.path mode.1
                       (list symbol.1 value.1.local #'dlv//test/always-safe?)))
      (should (dlv/set class.2 dir.2.path mode.2
                       (list symbol.2 value.2.local #'dlv//test/always-safe?)))

      ;;------------------------------
      ;; Test the DLV.
      ;;------------------------------
      (dlv//test/assert/safe-local-variable (list symbol.0 #'dlv//test/always-safe?)
                                            (list symbol.1 #'dlv//test/always-safe?)
                                            (list symbol.2 #'dlv//test/always-safe?))
      (dlv//test/assert/dlv.class (list class.0 mode.0 symbol.0 value.0.local)
                                  (list class.1 mode.1 symbol.1 value.1.local)
                                  (list class.2 mode.2 symbol.2 value.2.local))
      (dlv//test/assert/dlv.dir (list file.0.path class.0)
                                (list file.1.path class.1)
                                (list file.2.path class.2))

      ;; Check the actual value in an actual file buffer.
      (dlv//with-file-buffer file.0.path
        (should (eq value.0.local
                    (symbol-value symbol.0))))
      (dlv//with-file-buffer file.1.path
        (should (eq value.1.local
                    (symbol-value symbol.1))))
      (dlv//with-file-buffer file.2.path
        (should (eq value.2.local
                    (symbol-value symbol.2)))))))


;;------------------------------
;; DLVs in a sub-dir.
;;------------------------------

(ert-deftest test<dlv>:subdir//dlv/set ()
  "Test `dlv/set' on a parent dir then get value in a subdir's file."

  (dlv//with-fixture "subdir-dlv-set" nil
    (let* ((class 'dlv-test-subdir-dlv-set-class)

           (mode nil)

           (symbol 'dlv-test-subdir-dlv-set-var)

           (value.local (dlv//test/var/value.local test-name))

           (parent.name "parent")
           (parent.path (file-name-as-directory (concat dlv//fixture/dir.path parent.name)))
           (subdir.name "subdir")
           (subdir.path (file-name-as-directory (concat parent.path subdir.name)))

           (file.name "subdir-file")
           (file.path (concat subdir.path file.name)))

      (dlv//test/var.create test-name symbol)

      ;; Create our dirs.
      (dlv//test/dir.create parent.path)
      (dlv//test/dir.create subdir.path)

      ;;------------------------------
      ;; Create the DLV in the parent dir.
      ;;------------------------------
      ;; Should return non-nil.
      (should (dlv/set class parent.path mode
                       (list symbol value.local #'dlv//test/always-safe?)))

      ;;------------------------------
      ;; Test the DLV.
      ;;------------------------------
      (dlv//test/assert/safe-local-variable (list symbol #'dlv//test/always-safe?))
      (dlv//test/assert/dlv.class (list class mode symbol value.local))
      (dlv//test/assert/dlv.dir (list file.path class))

      ;; Check the actual value in an actual file buffer.
      (dlv//with-file-buffer file.path
        (should (eq value.local
                    (symbol-value symbol)))))))


;;------------------------------------------------------------------------------
;; Run All These Tests
;;------------------------------------------------------------------------------

(defun test<dlv>:run ()
  "Runn all 'test<dlv>:[...]' tests."
  (interactive)
  (ert "test<dlv>:.*"))
