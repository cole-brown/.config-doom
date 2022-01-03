;; -*- no-byte-compile: t; lexical-binding: t; -*-
;;; emacs/imp/test/path.el


;;------------------------------------------------------------------------------
;; Test Requirements
;;------------------------------------------------------------------------------

(load! "base.el")

(load! "../feature.el")
(load! "../alist.el")
(load! "../tree.el")
(load! "../path.el")


;;------------------------------------------------------------------------------
;; Test Debugging Helpers
;;------------------------------------------------------------------------------

(defvar test<imp/path>:path/dir:this (test<imp>:path/dir:this)
  "This file's directory path.")


(defvar test<imp/path>:path/file:this (test<imp>:path/file:this)
  "This file's path.")


;;------------------------------
;; `imp:path'.
;;------------------------------

(defvar test<imp/path>:path:roots:backup nil
  "Backup `imp:path:roots' so we can test it and then restore to its actual values.")


(defvar test<imp/path>:path:roots:test nil
  "Save `imp:path:roots' after a test so we can check it for debugging if needed.")


;;------------------------------
;; Set-Up / Tear-Down
;;------------------------------

(defun test<imp/path>:setup (_)
  "Backup `imp:path:roots' and clear it out for 'path.el' testing."
  (setq test<imp/path>:path:roots:backup imp:path:roots
        imp:path:roots                   nil
        test<imp/path>:path:roots:test   nil))


(defun test<imp/path>:setup:roots (&optional no-default-values &rest alist-entries)
  "Manually set `imp:path:roots' so we can test getting things out of it."
  (unless no-default-values
    ;; Add in a few defaults.
    (setq imp:path:roots
          '((:imp "/path/to/imp/"  "/path/to/imp/init.el")
            (:test "/another/path" "set-up.el"))))

  ;; And add in whatever the test wants (if provided).
  (when alist-entries
    (dolist (entry alist-entries)
      (push entry imp:path:roots))))


(defun test<imp/path>:teardown (test-name)
  "Restore `imp:path:roots'."
  ;; Save whatever testing did to `test<imp/path>:path:roots:test'
  (setq test<imp/path>:path:roots:test   imp:path:roots
        ;; Restore `imp:path:roots'.
        imp:path:roots                   test<imp/path>:path:roots:backup
        test<imp/path>:path:roots:backup nil))


;; ╔═════════════════════════════╤═══════════╤═════════════════════════════════╗
;; ╟─────────────────────────────┤ ERT TESTS ├─────────────────────────────────╢
;; ╠══════════╤══════════════════╧═══════════╧══════════════════╤══════════════╣
;; ╟──────────┤ Because Emacs needs to give Alists some love... ├──────────────╢
;; ╚══════════╧═════════════════════════════════════════════════╧══════════════╝


;;------------------------------------------------------------------------------
;; Tests: Imp Path Functions
;;------------------------------------------------------------------------------

;;------------------------------
;; int<imp/path>:root/dir
;;------------------------------

(ert-deftest test<imp/path>::int<imp/path>:root/dir ()
  "Test that `int<imp/path>:root/dir' behaves appropriately."
  (test<imp>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<imp/path>::int<imp/path>:root/dir"
      #'test<imp/path>:setup
      #'test<imp/path>:teardown

    ;;===
    ;; Run the test.
    ;;===

    ;; Manually set `imp:path:roots' so we can test the getter.
    (test<imp/path>:setup:roots)

    (let ((dir (int<imp/path>:root/dir :imp)))
      (should dir)
      (should (stringp dir))
      ;; `int<imp/path>:root/dir' should normalize "/path/to/imp/" to "/path/to/imp".
      (should (string= "/path/to/imp" ; "/path/to/imp/init.el"
                       dir)))

    (let ((dir (int<imp/path>:root/dir :test)))
      (should dir)
      (should (stringp dir))
      ;; `int<imp/path>:root/dir' should leave "/another/path" as-is.
      (should (string= "/another/path"
                       dir)))

    ;; Test that non-existant keyword throws an error.
    (should-error (int<imp/path>:root/dir :dne))))


;;------------------------------
;; int<imp/path>:root/file
;;------------------------------

(ert-deftest test<imp/path>::int<imp/path>:root/file ()
  "Test that `int<imp/path>:root/file' behaves appropriately."
  (test<imp>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<imp/path>::int<imp/path>:root/file"
      #'test<imp/path>:setup
      #'test<imp/path>:teardown

    ;;===
    ;; Run the test.
    ;;===

    ;; Manually set `imp:path:roots' so we can test this function.
    (test<imp/path>:setup:roots)

    (let ((dir (int<imp/path>:root/file :imp)))
      (should dir)
      (should (stringp dir))
      ;; `int<imp/path>:root/file' should just return the absolute path "/path/to/imp/init.el".
      (should (string= "/path/to/imp/init.el"
                       dir)))

    (let ((dir (int<imp/path>:root/file :test)))
      (should dir)
      (should (stringp dir))
      ;; `int<imp/path>:root/file' should add the root to relative file path.
      (should (string= "/another/path/set-up.el"
                       dir)))

    ;; Test that non-existant keyword throws an error.
    (should-error (int<imp/path>:root/file :dne))))


;;------------------------------
;; int<imp>:path:root/contains?
;;------------------------------

(ert-deftest test<imp/path>::int<imp>:path:root/contains? ()
  "Test that `int<imp>:path:root/contains?' behaves appropriately."
  (test<imp>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<imp/path>::int<imp>:path:root/contains?"
      #'test<imp/path>:setup
      #'test<imp/path>:teardown

    ;;===
    ;; Run the test.
    ;;===

    ;; Manually set `imp:path:roots' so we can test this function.
    (test<imp/path>:setup:roots)

    ;; Should return true for keywords that exist.
    (should (int<imp>:path:root/contains? :imp))

    (should (int<imp>:path:root/contains? :test))

    ;; Should just return false for keywords that do not exist.
    (should-not (int<imp>:path:root/contains? :dne))
    (should-not (int<imp>:path:root/contains? :also-does-not-exist))))


;;------------------------------
;; int<imp/path>:root/valid?
;;------------------------------

(ert-deftest test<imp/path>::int<imp/path>:root/valid?::dirs ()
  "Test that `int<imp/path>:root/valid?' behaves appropriately for directories."
  (test<imp>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<imp/path>::int<imp/path>:root/valid?::dirs"
      #'test<imp/path>:setup
      #'test<imp/path>:teardown

    ;;===
    ;; Run the test.
    ;;===

    ;;------------------------------
    ;; Create actual paths to actual files,
    ;; and actual paths to things that don't actually exist.
    ;;------------------------------
    (test<imp/path>:setup:roots :no-defaults
                                ;;---
                                ;; Exists/Valid
                                ;;---
                                (list :imp
                                      (expand-file-name ".."
                                                        )
                                      "init.el")
                                (list :test
                                      test<imp/path>:path/dir:this
                                      (file-name-nondirectory test<imp/path>:path/file:this))
                                ;;---
                                ;; DNE/Invalid
                                ;;---
                                ;; Valid directory, but file doesn't exist.
                                (list :dne/file
                                      test<imp/path>:path/dir:this
                                      "abcdefghijklmno.dne")
                                ;; Directory and file don't exist.
                                (list :dne/dir
                                      "/tmp/path/to/nowhere"
                                      "/tmp/path/to/nowhere/set-up.el"))

    ;;------------------------------
    ;; Test: `:imp' keyword's dir validity.
    ;;------------------------------
    ;; `:imp' has a valid dir and file.

    ;;---
    ;; Path can be dir, file, etc.
    ;;---
    ;; Path may or may not exist.
    (should (int<imp/path>:root/valid? test-name
                                       (int<imp/path>:root/dir :imp)
                                       :dir nil
                                       :exists nil))
    ;; Path must exist.
    (should (int<imp/path>:root/valid? test-name
                                       (int<imp/path>:root/dir :imp)
                                       :dir nil))
    ;; Path must exist.
    (should (int<imp/path>:root/valid? test-name
                                       (int<imp/path>:root/dir :imp)
                                       :dir nil
                                       :exists t))

    ;;---
    ;; Path must be a dir (which implies it must exist).
    ;;---
    ;; Path must exist and be a dir.
    (should (int<imp/path>:root/valid? test-name
                                       (int<imp/path>:root/dir :imp)
                                       :dir t))

    ;;------------------------------
    ;; Test: `:test' keyword's dir validity.
    ;;------------------------------
    ;; `:test' has a valid dir and file.

    ;;---
    ;; Path can be dir, file, etc.
    ;;---
    ;; Path may or may not exist.
    (should (int<imp/path>:root/valid? test-name
                                       (int<imp/path>:root/dir :test)
                                       :dir nil
                                       :exists nil))
    ;; Path must exist.
    (should (int<imp/path>:root/valid? test-name
                                       (int<imp/path>:root/dir :test)
                                       :dir nil))
    ;; Path must exist.
    (should (int<imp/path>:root/valid? test-name
                                       (int<imp/path>:root/dir :test)
                                       :dir nil
                                       :exists t))

    ;;---
    ;; Path must be a dir (which implies it must exist).
    ;;---
    ;; Path must exist and be a dir.
    (should (int<imp/path>:root/valid? test-name
                                       (int<imp/path>:root/dir :test)
                                       :dir t))

    ;;------------------------------
    ;; Test: `:dne/file' keyword's dir validity.
    ;;------------------------------
    ;; `:dne/file' has a valid dir, but an invalid file.

    ;;---
    ;; Path can be dir, file, etc.
    ;;---
    ;; Path may or may not exist.
    (should (int<imp/path>:root/valid? test-name
                                       (int<imp/path>:root/dir :dne/file)
                                       :dir nil
                                       :exists nil))
    ;; Path must exist.
    (should (int<imp/path>:root/valid? test-name
                                       (int<imp/path>:root/dir :dne/file)
                                       :dir nil))
    ;; Path must exist.
    (should (int<imp/path>:root/valid? test-name
                                       (int<imp/path>:root/dir :dne/file)
                                       :dir nil
                                       :exists t))

    ;;---
    ;; Path must be a dir (which implies it must exist).
    ;;---
    ;; Path must exist and be a dir.
    (should (int<imp/path>:root/valid? test-name
                                       (int<imp/path>:root/dir :dne/file)
                                       :dir t))

    ;;------------------------------
    ;; Test: `:dne/dir' keyword's dir validity.
    ;;------------------------------
    ;; `:dne/dir' has an invalid dir and file.

    ;;---
    ;; Path can be dir, file, etc.
    ;;---
    ;; Path may or may not exist.
    (should (int<imp/path>:root/valid? test-name
                                       (int<imp/path>:root/dir :dne/dir)
                                       :dir nil
                                       :exists nil))
    ;; Path must exist.
    (should-error (int<imp/path>:root/valid? test-name
                                             (int<imp/path>:root/dir :dne/dir)
                                             :dir nil))
    ;; Path must exist.
    (should-error (int<imp/path>:root/valid? test-name
                                             (int<imp/path>:root/dir :dne/dir)
                                             :dir nil
                                             :exists t))

    ;;---
    ;; Path must be a dir (which implies it must exist).
    ;;---
    ;; Path must exist and be a dir; invalid (doesn't exist)!
    (should-error (int<imp/path>:root/valid? test-name
                                             (int<imp/path>:root/dir :dne/dir)
                                             :dir t))))


(ert-deftest test<imp/path>::int<imp/path>:root/valid?::files ()
  "Test that `int<imp/path>:root/valid?' behaves appropriately for files."
  (test<imp>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<imp/path>::int<imp/path>:root/valid?::files"
      #'test<imp/path>:setup
      #'test<imp/path>:teardown

    ;;===
    ;; Run the test.
    ;;===

    ;;------------------------------
    ;; Create actual paths to actual files,
    ;; and actual paths to things that don't actually exist.
    ;;------------------------------
    (test<imp/path>:setup:roots :no-defaults
                                ;;---
                                ;; Exists/Valid
                                ;;---
                                (list :imp
                                      (expand-file-name ".."
                                                        )
                                      "init.el")
                                (list :test
                                      test<imp/path>:path/dir:this
                                      (file-name-nondirectory test<imp/path>:path/file:this))
                                ;;---
                                ;; DNE/Invalid
                                ;;---
                                ;; Valid directory, but file doesn't exist.
                                (list :dne/file
                                      test<imp/path>:path/dir:this
                                      "abcdefghijklmno.dne")
                                ;; Directory and file don't exist.
                                (list :dne/dir
                                      "/tmp/path/to/nowhere"
                                      "/tmp/path/to/nowhere/set-up.el"))

    ;;------------------------------
    ;; Test: `:imp' keyword's file validity.
    ;;------------------------------
    ;; `:imp' has a valid dir and file.

    ;;---
    ;; Path can be dir, file, etc.
    ;;---
    ;; Path may or may not exist.
    (should (int<imp/path>:root/valid? test-name
                                       (int<imp/path>:root/file :imp)
                                       :dir nil
                                       :exists nil))

    ;; Path must exist.
    (should (int<imp/path>:root/valid? test-name
                                       (int<imp/path>:root/file :imp)
                                       :dir nil))
    ;; Path must exist.
    (should (int<imp/path>:root/valid? test-name
                                       (int<imp/path>:root/file :imp)
                                       :dir nil
                                       :exists t))

    ;;---
    ;; Path must be a dir (which implies it must exist).
    ;;---
    ;; Path must exist and be a dir. It's a file, so expect an error.
    (should-error (int<imp/path>:root/valid? test-name
                                             (int<imp/path>:root/file :imp)
                                             :dir t))

    ;;------------------------------
    ;; Test: `:test' keyword's file validity.
    ;;------------------------------
    ;; `:test' has a valid dir and file.

    ;;---
    ;; Path can be dir, file, etc.
    ;;---
    ;; Path may or may not exist.
    (should (int<imp/path>:root/valid? test-name
                                       (int<imp/path>:root/file :test)
                                       :dir nil
                                       :exists nil))
    ;; Path must exist.
    (should (int<imp/path>:root/valid? test-name
                                       (int<imp/path>:root/file :test)
                                       :dir nil))
    ;; Path must exist.
    (should (int<imp/path>:root/valid? test-name
                                       (int<imp/path>:root/file :test)
                                       :dir nil
                                       :exists t))

    ;;---
    ;; Path must be a dir (which implies it must exist).
    ;;---
    ;; Path must exist and be a dir. It's a file, so expect an error.
    (should-error (int<imp/path>:root/valid? test-name
                                             (int<imp/path>:root/file :test)
                                             :dir t))

    ;;------------------------------
    ;; Test: `:dne/file' keyword's file validity.
    ;;------------------------------
    ;; `:dne/file' has a valid dir, but an invalid file.

    ;;---
    ;; Path can be dir, file, etc.
    ;;---
    ;; Path may or may not exist.
    (should (int<imp/path>:root/valid? test-name
                                       (int<imp/path>:root/file :dne/file)
                                       :dir nil
                                       :exists nil))
    ;; Path must exist. It does not, so expect an error.
    (should-error (int<imp/path>:root/valid? test-name
                                             (int<imp/path>:root/file :dne/file)
                                             :dir nil))
    ;; Path must exist. It does not, so expect an error.
    (should-error (int<imp/path>:root/valid? test-name
                                             (int<imp/path>:root/file :dne/file)
                                             :dir nil
                                             :exists t))

    ;;---
    ;; Path must be a dir (which implies it must exist).
    ;;---
    ;; Path must exist and be a dir. It's a file, so expect an error. It also doesn't exist, so also expect an error.
    (should-error (int<imp/path>:root/valid? test-name
                                             (int<imp/path>:root/file :dne/file)
                                             :dir t))

    ;;------------------------------
    ;; Test: `:dne/dir' keyword's file validity.
    ;;------------------------------
    ;; `:dne/dir' has an invalid dir and file.

    ;;---
    ;; Path can be dir, file, etc.
    ;;---
    ;; Path may or may not exist.
    (should (int<imp/path>:root/valid? test-name
                                       (int<imp/path>:root/file :dne/dir)
                                       :dir nil
                                       :exists nil))
    ;; Path must exist.
    (should-error (int<imp/path>:root/valid? test-name
                                             (int<imp/path>:root/file :dne/dir)
                                             :dir nil))
    ;; Path must exist.
    (should-error (int<imp/path>:root/valid? test-name
                                             (int<imp/path>:root/file :dne/dir)
                                             :dir nil
                                             :exists t))

    ;;---
    ;; Path must be a dir (which implies it must exist).
    ;;---
    ;; Path must exist and be a dir.
    ;;   - It's a file, so expect an error.
    ;;   - It also doesn't exist, so also expect an error.
    ;;   - And it's not a directory, so... keep expecting an error.
    (should-error (int<imp/path>:root/valid? test-name
                                             (int<imp/path>:root/file :dne/dir)
                                             :dir t))))


;;------------------------------
;; int<imp/path>:normalize:string
;;------------------------------

(ert-deftest test<imp/path>::int<imp/path>:normalize:string ()
  "Test that `int<imp/path>:normalize:string' translates feature names
to paths properly."
  (test<imp>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<imp/path>::int<imp/path>:normalize:string"
      #'test<imp/path>:setup
      #'test<imp/path>:teardown

    ;;===
    ;; Run the test.
    ;;===

    (should (string= "imp"
                     (int<imp/path>:normalize:string :imp)))

    ;; Should lose both slashes and ~:
    (should (string= "doom.d"
                     (int<imp/path>:normalize:string "~/doom.d/")))

    ;; Should remain the same:
    (should (string= "config"
                     (int<imp/path>:normalize:string "config")))))


;;------------------------------
;; int<imp/path>:normalize:list
;;------------------------------

(ert-deftest test<imp/path>::int<imp/path>:normalize:list ()
  "Test that `int<imp/path>:normalize:list' translates feature names
to paths properly."
  (test<imp>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<imp/path>::int<imp/path>:normalize:list"
      #'test<imp/path>:setup
      #'test<imp/path>:teardown

    ;;===
    ;; Run the test.
    ;;===

    ;; Should translate `:imp' to "imp".
    (let* ((expected '("imp"))
           (input    '(:imp))
           (output   (int<imp/path>:normalize:list input)))
      (should expected)
      (should input)
      (should output)

      (should (= (length expected)
                 (length input)
                 (length output)))

      ;; And make sure each string matches expected value.
      (dotimes (i (length expected))
        (should (string= (nth i expected)
                         (nth i output)))))

    ;; Should lose both slashes and ~:
    (let* ((expected '("doom.d"))
           (input    '("~/doom.d/"))
           (output   (int<imp/path>:normalize:list input)))
      (should expected)
      (should input)
      (should output)

      (should (= (length expected)
                 (length input)
                 (length output)))

      ;; And make sure each string matches expected value.
      (dotimes (i (length expected))
        (should (string= (nth i expected)
                         (nth i output)))))

    ;; Now do an actual list...
    (let* ((expected '("imp" "test" "normalize" "list"))
           (input    '(:imp "test/" "~normalize" :list))
           (output   (int<imp/path>:normalize:list input)))
      (should expected)
      (should input)
      (should output)

      (should (= (length expected)
                 (length input)
                 (length output)))

      ;; And make sure each string matches expected value.
      (dotimes (i (length expected))
        (should (string= (nth i expected)
                         (nth i output)))))))


;; int<imp/path>:append
;; imp:path:join
;; int<imp/path>:normalize:path
;; int<imp>:path:get
;; ;; TODO: Test `int<imp>:path:find' once it's been implemented.
;; imp:path:root
