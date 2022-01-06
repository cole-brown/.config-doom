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
;; Set-Up / Tear-Down
;;------------------------------

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
      nil
      nil

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
      nil
      nil

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
      nil
      nil

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
      nil
      nil

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
      nil
      nil

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
      nil
      nil

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
      nil
      nil

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


;;------------------------------
;; int<imp/path>:append
;;------------------------------

(ert-deftest test<imp/path>::int<imp/path>:append ()
  "Test that `int<imp/path>:append' glues together path segments properly."
  (test<imp>:fixture
   ;;===
   ;; Test name, setup & teardown func.
   ;;===
   "test<imp/path>::int<imp/path>:append"
   nil
   nil

   ;;===
   ;; Run the test.
   ;;===

   (let ((parent/valid "foo")
         (next/valid   "bar"))
     ;;------------------------------
     ;; Invalid:
     ;;------------------------------

     ;; PARENT non-nil but not a string
     (should-error (int<imp/path>:append :foo next/valid))

     ;; NEXT is nil
     (should-error (int<imp/path>:append parent/valid nil))

     ;; NEXT not a string
     (should-error (int<imp/path>:append parent/valid :bar))

     ;;------------------------------
     ;; Valid:
     ;;------------------------------

     ;; PARENT is nil
     (should (string= next/valid
                      (int<imp/path>:append nil next/valid)))

     ;; Both PARENT and NEXT valid strings.
     (should (string= (concat parent/valid "/" next/valid)
                      (int<imp/path>:append parent/valid next/valid)))
     (should (string= "/foo/bar/baz"
                      (int<imp/path>:append "/foo" "bar/baz")))
     (should (string= "/foo/bar/baz/"
                      (int<imp/path>:append "/foo" "bar/baz/"))))))


;;------------------------------
;; imp:path:join
;;------------------------------

(ert-deftest test<imp/path>::imp:path:join ()
  "Test that `imp:path:join' glues together path segments properly."
  (test<imp>:fixture
   ;;===
   ;; Test name, setup & teardown func.
   ;;===
   "test<imp/path>::imp:path:join"
   nil
   nil

   ;;===
   ;; Run the test.
   ;;===

   (let ((parent/valid "foo")
         (next/valid   "bar"))
     ;;------------------------------
     ;; Invalid:
     ;;------------------------------

     ;; PARENT non-nil but not a string
     (should-error (imp:path:join :foo next/valid))

     ;; NEXT is nil
     (should-error (imp:path:join parent/valid nil))

     ;; NEXT not a string
     (should-error (imp:path:join parent/valid :bar))

     (should-error (imp:path:join "/foo" nil "baz/"))

     ;;------------------------------
     ;; Valid:
     ;;------------------------------

     (should (string= parent/valid
                      (imp:path:join parent/valid)))
     (should (string= next/valid
                      (imp:path:join next/valid)))

     ;; Both PARENT and NEXT valid strings.
     (should (string= (concat parent/valid "/" next/valid)
                      (imp:path:join parent/valid next/valid)))

     (should (string= "/foo/bar/baz"
                      (imp:path:join "/foo" "bar/baz")))

     (should (string= "/foo/bar/baz"
                      (imp:path:join "/foo" "bar" "baz")))

     (should (string= "/foo/bar/baz/"
                      (imp:path:join "/foo" "bar" "baz/"))))))


;;------------------------------
;; int<imp/path>:normalize:path
;;------------------------------

(ert-deftest test<imp/path>::int<imp/path>:normalize:path ()
  "Test that `int<imp/path>:normalize:path' normalizes a list of features
to a path properly."
  (test<imp>:fixture
   ;;===
   ;; Test name, setup & teardown func.
   ;;===
   "test<imp/path>::int<imp/path>:normalize:path"
   nil
   nil

   ;;===
   ;; Run the test.
   ;;===

   ;;------------------------------
   ;; Invalid:
   ;;------------------------------

   ;; Everything should be a symbol.
   (should-error (int<imp/path>:normalize:path '("foo" "bar" "baz")))
   (should-error (int<imp/path>:normalize:path '(:foo "bar" "baz")))
   (should-error (int<imp/path>:normalize:path '(:foo bar "baz")))
   (should-error (int<imp/path>:normalize:path '(:foo bar 'baz)))

   ;;------------------------------
   ;; Valid:
   ;;------------------------------
   (should (string= (imp:path:join "foo" "bar" "baz")
                    (int<imp/path>:normalize:path '(:foo bar baz))))))


;;------------------------------
;; int<imp>:path:get
;;------------------------------

(ert-deftest test<imp/path>::int<imp>:path:get ()
  "Test that `int<imp>:path:get' gets/normalizes a path from a list of features."
  (test<imp>:fixture
   ;;===
   ;; Test name, setup & teardown func.
   ;;===
   "test<imp/path>::int<imp>:path:get"
   nil
   nil

   ;;===
   ;; Run the test.
   ;;===

   ;; Manually set `imp:path:roots' so we can test `int<imp>:path:get'.
   (test<imp/path>:setup:roots)

   ;;------------------------------
   ;; Invalid:
   ;;------------------------------

   ;; Must have the root feature.
   (should-not (int<imp>:path:root/contains? :foo))
   (should-error (int<imp>:path:get '(:foo)))

   ;; Must have valid features (for `int<imp/path>:normalize:path') after root.
   (should-error (int<imp>:path:get '(:imp "invalid")))
   (should-error (int<imp>:path:get '(:imp 'invalid)))

   ;;------------------------------
   ;; Valid:
   ;;------------------------------
   (should (string= (imp:path:join (int<imp/path>:root/dir :imp) "foo" "bar" "baz")
                    (int<imp>:path:get '(:imp foo bar baz))))))


;; ;;------------------------------
;; ;; int<imp>:path:find
;; ;;------------------------------
;;
;; (ert-deftest test<imp/path>::int<imp>:path:find ()
;;   "Test that `int<imp>:path:find' finds a path properly from the features."
;;   (test<imp>:fixture
;;    ;;===
;;    ;; Test name, setup & teardown func.
;;    ;;===
;;    "test<imp/path>::int<imp>:path:find"
;;    nil
;;    nil
;;
;;    ;;===
;;    ;; Run the test.
;;    ;;===
;;
;;    (should-not "TODO:find: implement test when `int<imp>:path:find' is implemented.")))


;;------------------------------
;; imp:path:root
;;------------------------------

(ert-deftest test<imp/path>::imp:path:root ()
  "Test that `imp:path:root' sets the feature root's path root correctly."
  (test<imp>:fixture
   ;;===
   ;; Test name, setup & teardown func.
   ;;===
   "test<imp/path>::imp:path:root"
   nil
   nil

   ;;===
   ;; Run the test.
   ;;===

   ;; Manually set `imp:path:roots' so we can test `imp:path:root'.
   (test<imp/path>:setup:roots)

   ;;------------------------------
   ;; Invalid:
   ;;------------------------------

   ;; Must not the root feature.
   (should (int<imp>:path:root/contains? :test))
   (should-error (imp:path:root :test "."))

   ;; Root must be a keyword.
   (should-error (imp:path:root 'foo "."))
   (should-error (imp:path:root "foo" "."))
   (should-error (imp:path:root "/foo" "."))

   ;; Dir must exist.
   (should-error (int<imp/path>:root/valid? test-name
                                            "./does-not/exist"))
   (should-error (imp:path:root "/foo" "."))

   ;;------------------------------
   ;; Valid:
   ;;------------------------------
   ;; Valid; no file.
   ;; Returns new `imp:path:roots', so check for the thing we're adding.
   (let* ((feature :foo)
          (path    "../test")
          (result  (imp:path:root feature path)))
     (should result)
     (should (int<imp>:alist:get/value feature result))
     ;; Dir
     (should (string= "../test"
                      (nth 0 (int<imp>:alist:get/value feature result))))
     ;; File
     (should (eq nil
                 (nth 1 (int<imp>:alist:get/value feature result))))
     )

   ;; Valid path and file.
   ;; Returns new `imp:path:roots', so check for the thing we're adding.
   (let* ((feature :bar)
          (path    test<imp/path>:path/dir:this)
          (file    test<imp/path>:path/file:this)
          (result  (imp:path:root feature path file)))
     (should result)
     (should (int<imp>:alist:get/value feature result))
     ;; Dir
     (should (string= path
                      (nth 0 (int<imp>:alist:get/value feature result))))
     ;; File
     (should (string= file
                      (nth 1 (int<imp>:alist:get/value feature result)))))))
