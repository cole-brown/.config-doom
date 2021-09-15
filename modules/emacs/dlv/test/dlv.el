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


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

(setq test<dlv>:const/path.root "~/dlv-test/")

(setq test<dlv>:const/unique-paths? nil)

(setq test<dlv>:fixture/dir.name nil)
(setq test<dlv>:fixture/file.name nil)
(setq test<dlv>:fixture/dir.path nil)
(setq test<dlv>:fixture/file.path nil)


;;------------------------------
;; Backups
;;------------------------------

;; Backup of original caches.
(setq test<dlv>:dir-locals-directory-cache dir-locals-directory-cache)
;; (setq dir-locals-directory-cache '(("d:/home/work/.emacs.d/" d:/home/work/\.emacs\.d/ (24827 297 0 0))))

(setq test<dlv>:safe-local-variable-values safe-local-variable-values)
;; (setq safe-local-variable-values nil)

(setq test<dlv>:dir-locals-class-alist dir-locals-class-alist)
;; (setq dir-locals-class-alist '((d:/home/work/\.emacs\.d/ (nil (git-commit-major-mode . git-commit-elisp-text-mode)) (org-mode (buffer-read-only . t)))))

;; Backup of original values.
(setq test<dlv>:enable-local-variables enable-local-variables)


;; Unique Counters
(setq test<dlv>:var.uid 0)
(setq test<dlv>:path.uid 0)


;;------------------------------------------------------------------------------
;; DLV Helpers
;;------------------------------------------------------------------------------

;;------------------------------
;; Variables
;;------------------------------

(defun test<dlv>:var/value.local (test-name &optional suffix)
  "Get a unique local value for the variable.

If SUFFIX is non-nil, appends it to the end of the value, prefixed with
a \"/\" separator."
  (let ((uid test<dlv>:var.uid)
        (suffix-fmt (if suffix "/%s" "")))
    (setq test<dlv>:var.uid (1+ test<dlv>:var.uid))
    (intern (format (concat ":test/"
                            test-name "/"
                            "%s/%03d"
                            suffix-fmt)
                    (test<dlv>:time.str)
                    uid
                    suffix))))
;; (test<dlv>:var/value.local "test")
;; (test<dlv>:var/value.local "test" "jeff")
;; (test<dlv>:var/value.local "test" 0)


(defun test<dlv>:var/value.default (test-name)
  "Get a default value for the variable."
  :test:default
  ;; (let ((uid test<dlv>:var.uid))
  ;;   (setq test<dlv>:var.uid (1+ test<dlv>:var.uid))
  ;;   (intern (format (concat ":test/"
  ;;                           test-name "/"
  ;;                           "DEFAULT/"
  ;;                           "%s/%03d")
  ;;                   (test<dlv>:time.str)
  ;;                   uid)))
  )
;; (test<dlv>:var/value.default "test")

(defun test<dlv>:var/create (test-name symbol &rest plist)
  "Create a variable named SYMBOL for testing TEST-NAME.

TEST-NAME should be a short, unique string.
e.g. `test<dlv>:example:do-specific-thing' might be \"specific-thing\".

PLIST can have these keywords:
  - `:safe-fn'
  - `:safe-value'
  - `:default-value'

If `:safe-fn' keyword's value is not nil, put it in the SYMBOL's `safe-local-variable' property.

If `:safe-value' keyword's value is not nil, put it in the `safe-local-variable-values' alist.

If `:default-value' keyword exists, use it as the default value.
  - Otherwise use `test<dlv>:var/value.default' function's output."
  (-let [(&plist :safe-fn :safe-value :default-value) plist]
    ;; Set the default values.
    (set symbol (or default-value (test<dlv>:var/value.default test-name)))

    ;; Set the `safe-local-variable' slots.
    (when safe-fn
      (put symbol 'safe-local-variable safe-fn))

    ;; Set the `safe-local-variable-values' pair.
    (when safe-value
      (push (cons symbol safe-value) safe-local-variable-values))))


(defun test<dlv>:var/delete (symbol)
  "Unbinds the variable named SYMBOL.

Also removes it from the `safe-local-variable-values' alist if it was in there."
  ;; Unbind the symbol.
  (makunbound symbol)

  ;; Remove the `safe-local-variable-values' pair if it exists.
  (if (alist-get symbol safe-local-variable-values)
      (setf (alist-get symbol safe-local-variable-values nil :remove) nil)))


(defun test<dlv>:always-safe? (value)
  "Predicate to declare that any and all values are safe for the variable.

Ignores VALUE; always returns t."
  (int<dlv>:debug "test<dlv>:always-safe?"
                  "Safe predicated called for value: %S"
                  value)
  t)


;;------------------------------
;; Strings
;;------------------------------

(defun test<dlv>:time.str ()
  "Get a time str for creating var values, filenames, etc."
  (format-time-string "%FT%H-%M-%S-%3N%z"))


;;------------------------------
;; Paths
;;------------------------------

(defun test<dlv>:path/parent.get (path)
  "Returns the parent directory of PATH."
  (file-name-directory (directory-file-name path)))
;; (test<dlv>:path/parent.get test<dlv>:const/path.root)


(defun test<dlv>:path/dir.create (path)
  "Create directory PATH unless it exists."
  (if (and (file-exists-p path)
           (file-directory-p path))
      :exists
    (make-directory path)))


(defun test<dlv>:path/dirname (&optional name)
  "Create a unique dirname using NAME, `test<dlv>:time.str', and `test<dlv>:path.uid'."
  (let ((name (or name "locals"))
        (uid  test<dlv>:path.uid))
    (if test<dlv>:const/unique-paths?
        (progn
          (setq test<dlv>:path.uid (1+ test<dlv>:path.uid))
          (format (concat name ".%s.%03d")
                  (test<dlv>:time.str)
                  uid
                  "/"))
      name)))


(defun test<dlv>:path/filename (&optional name ext)
  "Create a unique filename using NAME, EXT, `test<dlv>:time.str', and `test<dlv>:path.uid'."
  (let ((name (or name "locals"))
        (ext  (or ext "txt"))
        (uid  test<dlv>:path.uid))
    (if test<dlv>:const/unique-paths?
        (progn
          (setq test<dlv>:path.uid (1+ test<dlv>:path.uid))
          (format (concat name ".%s.%03d.%s")
                  (test<dlv>:time.str)
                  uid
                  ext))
      (format (concat name ".%s")
              ext))))
;; (test<dlv>:path/filename)


;;------------------------------------------------------------------------------
;; Test Fixture (Set-Up / Tear-Down) Functions
;;------------------------------------------------------------------------------

;;------------------------------
;; Set-Up
;;------------------------------

(defun test<dlv>:setup/paths (name)
  "Ensure the dirs and files exist."
  (test<dlv>:path/dir.create test<dlv>:const/path.root)

  (if (null name)
      ;; No name provided - ensure the fixture dir/file vars are cleared.
      (setq test<dlv>:fixture/dir.name nil
            test<dlv>:fixture/file.name nil
            test<dlv>:fixture/dir.path nil
            test<dlv>:fixture/file.path nil)

    ;; Setup dir/file vars and ensure dir exists.
    (setq test<dlv>:fixture/dir.name  (test<dlv>:path/dirname name)
          test<dlv>:fixture/file.name (test<dlv>:path/filename name)
          test<dlv>:fixture/dir.path  (file-name-as-directory (concat test<dlv>:const/path.root test<dlv>:fixture/dir.name))
          test<dlv>:fixture/file.path (concat test<dlv>:fixture/dir.path test<dlv>:fixture/file.name))
    (test<dlv>:path/dir.create test<dlv>:fixture/dir.path)))
;; (test<dlv>:setup/paths "test-setup-paths")


(defun test<dlv>:setup/vars ()
  "Save pre-test values of DLV caches & settings so tests don't leave them messy."
  ;; Save DLV caches/settings.
  (setq test<dlv>:dir-locals-directory-cache dir-locals-directory-cache)
  (setq test<dlv>:safe-local-variable-values safe-local-variable-values)
  (setq test<dlv>:enable-local-variables enable-local-variables)
  (setq test<dlv>:dir-locals-class-alist dir-locals-class-alist))


(defun test<dlv>:setup (name)
  "Run setup for tests."
  ;; Ensure data is cleaned from last test run (could have errored out and not finished).
  (test<dlv>:teardown/paths)

  ;; Create temp dirs & files.
  (test<dlv>:setup/paths name)

  ;; Revert DLV caches & settings.
  ;; Set vars to their defaults.
  (test<dlv>:setup/vars))
;; (test<dlv>:setup)


;;------------------------------
;; Tear-Down
;;------------------------------

(defun test<dlv>:teardown/paths ()
  "Remove all the files & dirs used in the test by deleting the root dir."
  (setq test<dlv>:fixture/dir.name nil)
  (setq test<dlv>:fixture/file.name nil)
  (setq test<dlv>:fixture/dir.path nil)
  (setq test<dlv>:fixture/file.path nil)

  (delete-directory test<dlv>:const/path.root :recursive))


(defun test<dlv>:teardown/vars ()
  "Restore vars to backed up values."
  ;; Restore caches & settings back to pre-test state.
  (setq dir-locals-directory-cache test<dlv>:dir-locals-directory-cache)
  (setq safe-local-variable-values test<dlv>:safe-local-variable-values)
  (setq enable-local-variables test<dlv>:enable-local-variables)
  (setq dir-locals-class-alist test<dlv>:dir-locals-class-alist))


(defun test<dlv>:teardown ()
  "Run teardown for tests."
  (test<dlv>:teardown/paths)
  (test<dlv>:teardown/vars))
;; (test<dlv>:teardown)


;;------------------------------
;; Test Fixture Macro
;;------------------------------

(defmacro test<dlv>:with:fixture (name test-teardown-fn &rest body)
  "Run `test<dlv>:setup', then BODY, then ensures `test<dlv>:teardown' is run
no matter what happens in BODY. Binds NAME to `test-name'.

If NAME is non-nil, it is used to create a directory and file name (paths too), saved to:
 - `test<dlv>:fixture/dir.name'
 - `test<dlv>:fixture/file.name'
 - `test<dlv>:fixture/dir.path'
 - `test<dlv>:fixture/file.path'

If TEST-TEARDOWN-FN is non-nil, it is /always/ called after the test is run (even if it errors out/fails/etc).
TEST-TEARDOWN-FN should take one parameter: NAME."
  (declare (indent 2))
  ;; `unwind-protect' lets us run teardown even if errors, etc.
  `(let ((test-name ,name)
         (test<dlv>:with:fixture/teardown-fn ,test-teardown-fn))
     (unwind-protect
         (progn
           (test<dlv>:setup test-name)

           ,@body)
       (when test<dlv>:with:fixture/teardown-fn
         (test<dlv>:with:fixture/teardown-fn test-name))
       (test<dlv>:teardown))))


;;------------------------------
;; File/Buffer Management
;;------------------------------

(defmacro test<dlv>:with:file-buffer (path &rest body)
  "Create/open file PATH and run BODY with PATH's buffer as the current buffer.
Closes the buffer and deletes the file after BODY is run.

If you want the buffer in BODY, it is store in the lexical variable
`test<dlv>:with:file-buffer/buffer'."
  (declare (indent 1))
  `(let ((test<dlv>:with:file-buffer/path ,path)
         test<dlv>:with:file-buffer/buffer)
     (unwind-protect
         (progn
           (setq test<dlv>:with:file-buffer/buffer (find-file-noselect ,path))
           (with-current-buffer test<dlv>:with:file-buffer/buffer
             ,@body))
       (kill-buffer test<dlv>:with:file-buffer/buffer)
       (delete-file test<dlv>:with:file-buffer/path))))


;;------------------------------------------------------------------------------
;; Reusable Test Assertions
;;------------------------------------------------------------------------------

(defun test<dlv>:assert:valid-path (expected-parent path)
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

          (let ((next (test<dlv>:path/parent.get loop-path)))
            ;; Should not get stuck at the root.
            (if (string= loop-path next)
                (setq stuck t
                      loop-path nil)
              (setq loop-path next))))))

    ;; Did we find the parent?
    ;;   - Add parent/child on so we can see them in the ERT failure.
    (should (equal (list t parent child)
                   (list found-parent? parent child)))))


(defun test<dlv>:assert:safe-local-variable (&rest kvp)
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


(defun test<dlv>:assert:dlv.class (&rest kvp)
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


(defun test<dlv>:assert:dlv.dir (&rest kvp)
  "Assert for each KVP that the filepath's parent dir has a DLV structure with
the class symbol in it.

KVPs are tuples of: '(filepath class-symbol)"
  (dolist (item kvp)
    (let* ((filepath (nth 0 item))
           (dirpath (test<dlv>:path/parent.get filepath))
           (class   (nth 1 item)))

      ;; Get the DLV class for the file's path and verify.
      (let ((file/dlv.classes (dir-locals-find-file filepath)))
        (should file/dlv.classes)
        (should (= 3 (length file/dlv.classes)))
        (test<dlv>:assert:valid-path (nth 0 file/dlv.classes)
                                     dirpath)
        (should (eq (nth 1 file/dlv.classes)
                    class))))))


;;------------------------------------------------------------------------------
;; Tests
;;------------------------------------------------------------------------------

;;------------------------------
;; Stupidest, simplest test.
;;------------------------------

(ert-deftest test<dlv>:simple/hard-coded ()
  "Test very basic DLV set. No DLV lib code."

  (test<dlv>:with:fixture nil nil
    (let ((dir test<dlv>:const/path.root)
          (file "locals.hard-coded.txt"))
      (defvar dlv-test-hard-coded-var :test/default)
      (put 'dlv-test-hard-coded-var 'safe-local-variable #'test<dlv>:always-safe?)

      (dir-locals-set-class-variables
       'dlv-test-hard-coded-class
       '((nil . ((dlv-test-hard-coded-var . :test/local)))))

      (dir-locals-set-directory-class dir 'dlv-test-hard-coded-class)

      (test<dlv>:with:file-buffer
          (concat dir file)
        (should (eq :test/local
                    dlv-test-hard-coded-var))))))


;;------------------------------
;; Variables instead of Hard-Coded, but still very stupid simple.
;;------------------------------

(ert-deftest test<dlv>:simple/variables ()
  "Test very basic DLV set. No DLV lib code."

  (test<dlv>:with:fixture "simple-vars" nil
    (let* ((value.local   (test<dlv>:var/value.local test-name))
           (class 'dlv-test-simple-class)
           (mode nil)
           (symbol 'dlv-test-simple-var))
      (test<dlv>:var/create test-name
                            symbol
                            :safe-fn #'test<dlv>:always-safe?
                            ;; :safe-value nil
                            ;; :default-value nil
                            )

      ;; Create the DLV.
      (let ((dlv.struct (list (cons mode (list (cons symbol value.local))))))
        (dir-locals-set-class-variables class dlv.struct))

      (dir-locals-set-directory-class test<dlv>:fixture/dir.path class)

      ;; Test the DLV.
      (test<dlv>:with:file-buffer test<dlv>:fixture/file.path
        (should (eq value.local
                    (symbol-value symbol)))))))


;;------------------------------
;; Simple test of `dlv:set'.
;;------------------------------

(ert-deftest test<dlv>:simple::dlv:set ()
  "Test very basic use of DLV function `dlv:set'."

  (test<dlv>:with:fixture "simple-dlv-set" nil
    (let* ((value.local   (test<dlv>:var/value.local test-name))
           (class 'dlv-test-simple-dlv-set-class)
           (mode nil)
           (symbol 'dlv-test-simple-dlv-set-var))
      (test<dlv>:var/create test-name
                            symbol
                            :safe-fn #'test<dlv>:always-safe?
                            ;; :safe-value nil
                            ;; :default-value nil
                            )

      ;; Create the DLV.
      (dlv:set class test<dlv>:fixture/dir.path mode
               (list symbol value.local #'test<dlv>:always-safe?))

      ;; Test the DLV.
      (test<dlv>:with:file-buffer test<dlv>:fixture/file.path
        (should (eq value.local
                    (symbol-value symbol)))))))


;;------------------------------
;; Full test of `dlv:set'.
;;------------------------------

(ert-deftest test<dlv>:full::dlv:set ()
  "Test `dlv:set' more in-depth."

  (test<dlv>:with:fixture "full-dlv-set" nil
    (let* ((class 'dlv-test-full-dlv-set-class)
           (mode nil)
           (symbol 'dlv-test-full-dlv-set-var)
           (value.local (test<dlv>:var/value.local test-name)))
      (test<dlv>:var/create test-name symbol)

      ;;------------------------------
      ;; Create the DLV.
      ;;------------------------------
      ;; Should return non-nil.
      (should (dlv:set class test<dlv>:fixture/dir.path mode
                       (list symbol value.local #'test<dlv>:always-safe?)))

      ;;------------------------------
      ;; Test the DLV.
      ;;------------------------------
      (test<dlv>:assert:safe-local-variable (list symbol #'test<dlv>:always-safe?))
      (test<dlv>:assert:dlv.class (list class mode symbol value.local))
      (test<dlv>:assert:dlv.dir (list test<dlv>:fixture/file.path class))

      ;; Check the actual value in an actual file buffer.
      (test<dlv>:with:file-buffer test<dlv>:fixture/file.path
        (should (eq value.local
                    (symbol-value symbol)))))))


;;------------------------------
;; `dlv:set' test with multiple symbols.
;;------------------------------

(ert-deftest test<dlv>:multiple-vars::dlv:set ()
  "Test `dlv:set' with multiple tuples."

  (test<dlv>:with:fixture "multi-vars-dlv-set" nil
    (let* ((class 'dlv-test-multi-vars-dlv-set-class)
           (mode nil)
           (symbol.0 'dlv-test-multi-vars-dlv-set-var0)
           (value.0.local (test<dlv>:var/value.local test-name 0))
           (symbol.1 'dlv-test-multi-vars-dlv-set-var1)
           (value.1.local (test<dlv>:var/value.local test-name 1)))
      (test<dlv>:var/create test-name symbol.0)
      (test<dlv>:var/create test-name symbol.1)

      ;;------------------------------
      ;; Create the DLV.
      ;;------------------------------
      ;; Should return non-nil.
      (should (dlv:set class test<dlv>:fixture/dir.path mode
                       (list symbol.0 value.0.local #'test<dlv>:always-safe?)
                       (list symbol.1 value.1.local #'test<dlv>:always-safe?)))

      ;;------------------------------
      ;; Test the DLV.
      ;;------------------------------
      (test<dlv>:assert:safe-local-variable (list symbol.0 #'test<dlv>:always-safe?)
                                            (list symbol.1 #'test<dlv>:always-safe?))
      (test<dlv>:assert:dlv.class (list class mode symbol.0 value.0.local)
                                  (list class mode symbol.1 value.1.local))
      (test<dlv>:assert:dlv.dir (list test<dlv>:fixture/file.path class))

      ;; Check the actual value in an actual file buffer.
      (test<dlv>:with:file-buffer test<dlv>:fixture/file.path
        (should (eq value.0.local
                    (symbol-value symbol.0)))
        (should (eq value.1.local
                    (symbol-value symbol.1)))))))


;;------------------------------
;; `dlv:set' test with multiple dirs.
;;------------------------------

(ert-deftest test<dlv>:multiple-dirs::dlv:set ()
  "Test `dlv:set' with multiple dirs."

  (test<dlv>:with:fixture "multi-vars-dlv-set" nil
    (let* ((class.0 'dlv-test-multi-dir-dlv-set-class0)
           (class.1 'dlv-test-multi-dir-dlv-set-class1)
           (class.2 'dlv-test-multi-dir-dlv-set-class2)

           (mode.0 nil)
           (mode.1 nil)
           (mode.2 nil)

           (symbol.0 'dlv-test-multi-dir-dlv-set-var0)
           (symbol.1 'dlv-test-multi-dir-dlv-set-var1)
           (symbol.2 'dlv-test-multi-dir-dlv-set-var2)

           (value.0.local (test<dlv>:var/value.local test-name 0))
           (value.1.local (test<dlv>:var/value.local test-name 1))
           (value.2.local (test<dlv>:var/value.local test-name 2))

           (dir.0.name "dir-0")
           (dir.1.name "dir-1")
           (dir.2.name "dir-2")
           (dir.0.path (file-name-as-directory (concat test<dlv>:fixture/dir.path dir.0.name)))
           (dir.1.path (file-name-as-directory (concat test<dlv>:fixture/dir.path dir.1.name)))
           (dir.2.path (file-name-as-directory (concat test<dlv>:fixture/dir.path dir.2.name)))

           (file.0.name "file-0")
           (file.1.name "file-1")
           (file.2.name "file-2")
           (file.0.path (concat dir.0.path file.0.name))
           (file.1.path (concat dir.1.path file.1.name))
           (file.2.path (concat dir.2.path file.2.name)))

      (test<dlv>:var/create test-name symbol.0)
      (test<dlv>:var/create test-name symbol.1)
      (test<dlv>:var/create test-name symbol.2)

      ;; Create dirs as subdirectories under the one setup created.
      (test<dlv>:path/dir.create dir.0.path)
      (test<dlv>:path/dir.create dir.1.path)
      (test<dlv>:path/dir.create dir.2.path)

      ;;------------------------------
      ;; Create the DLVs.
      ;;------------------------------
      ;; Should return non-nil.
      (should (dlv:set class.0 dir.0.path mode.0
                       (list symbol.0 value.0.local #'test<dlv>:always-safe?)))
      (should (dlv:set class.1 dir.1.path mode.1
                       (list symbol.1 value.1.local #'test<dlv>:always-safe?)))
      (should (dlv:set class.2 dir.2.path mode.2
                       (list symbol.2 value.2.local #'test<dlv>:always-safe?)))

      ;;------------------------------
      ;; Test the DLV.
      ;;------------------------------
      (test<dlv>:assert:safe-local-variable (list symbol.0 #'test<dlv>:always-safe?)
                                            (list symbol.1 #'test<dlv>:always-safe?)
                                            (list symbol.2 #'test<dlv>:always-safe?))
      (test<dlv>:assert:dlv.class (list class.0 mode.0 symbol.0 value.0.local)
                                  (list class.1 mode.1 symbol.1 value.1.local)
                                  (list class.2 mode.2 symbol.2 value.2.local))
      (test<dlv>:assert:dlv.dir (list file.0.path class.0)
                                (list file.1.path class.1)
                                (list file.2.path class.2))

      ;; Check the actual value in an actual file buffer.
      (test<dlv>:with:file-buffer file.0.path
        (should (eq value.0.local
                    (symbol-value symbol.0))))
      (test<dlv>:with:file-buffer file.1.path
        (should (eq value.1.local
                    (symbol-value symbol.1))))
      (test<dlv>:with:file-buffer file.2.path
        (should (eq value.2.local
                    (symbol-value symbol.2)))))))


;;------------------------------
;; DLVs in a sub-dir.
;;------------------------------

(ert-deftest test<dlv>:subdir::dlv:set ()
  "Test `dlv:set' on a parent dir then get value in a subdir's file."

  (test<dlv>:with:fixture "subdir-dlv-set" nil
    (let* ((class 'dlv-test-subdir-dlv-set-class)

           (mode nil)

           (symbol 'dlv-test-subdir-dlv-set-var)

           (value.local (test<dlv>:var/value.local test-name))

           (parent.name "parent")
           (parent.path (file-name-as-directory (concat test<dlv>:fixture/dir.path parent.name)))
           (subdir.name "subdir")
           (subdir.path (file-name-as-directory (concat parent.path subdir.name)))

           (file.name "subdir-file")
           (file.path (concat subdir.path file.name)))

      (test<dlv>:var/create test-name symbol)

      ;; Create our dirs.
      (test<dlv>:path/dir.create parent.path)
      (test<dlv>:path/dir.create subdir.path)

      ;;------------------------------
      ;; Create the DLV in the parent dir.
      ;;------------------------------
      ;; Should return non-nil.
      (should (dlv:set class parent.path mode
                       (list symbol value.local #'test<dlv>:always-safe?)))

      ;;------------------------------
      ;; Test the DLV.
      ;;------------------------------
      (test<dlv>:assert:safe-local-variable (list symbol #'test<dlv>:always-safe?))
      (test<dlv>:assert:dlv.class (list class mode symbol value.local))
      (test<dlv>:assert:dlv.dir (list file.path class))

      ;; Check the actual value in an actual file buffer.
      (test<dlv>:with:file-buffer file.path
        (should (eq value.local
                    (symbol-value symbol)))))))


;;------------------------------------------------------------------------------
;; Run All These Tests
;;------------------------------------------------------------------------------

(defun test<dlv>:run ()
  "Runn all 'test<dlv>:[...]' tests."
  (interactive)
  (ert "test<dlv>:.*"))
