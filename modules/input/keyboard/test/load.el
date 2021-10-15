;; -*- no-byte-compile: t; lexical-binding: t; -*-
;;; input/keyboard/test/debug.el

;;------------------------------------------------------------------------------
;; Test Debugging Helpers
;;------------------------------------------------------------------------------

;;---
;; Testing Files:
;;---
(load! "base.el")

;;---
;; Keyboard Files:
;;---
(load! "../output.el")
(load! "../debug.el")
(load! "../load.el")


;;------------------------------------------------------------------------------
;; Test Helpers: Loading
;;------------------------------------------------------------------------------

(defvar test<keyboard/load>:with:temps nil
  "Temp dirs & files to delete during tear-down.")


(defun test<keyboard/load>:path:make-temp (directory? name-prefix)
  "Creates a temp dir or file (depending on DIRECTORY?) and sets it up for
deletion in test teardown.

Will create a directory if DIRECTORY? is non-nil. Else creates a file.

Creates a file/dir with the filename prefixed by NAME-PREFIX.

Returns the path to the dir/file."
  ;; Create the temp file/dir.
  (let ((path/temp (make-temp-file name-prefix directory?)))
    ;; Save so we can delete during tear-down.
    (push path/temp test<keyboard/load>:with:temps)
    path/temp))
;; (make-temp-file "foo")
;;   -> Windows 10:
;;      -> "c:/Users/<user>/AppData/Local/Temp/foo<random>"


(defun test<keyboard/load>:setup (_)
  "Set-up for 'load.el' tests."
  )


(defun test<keyboard/load>:teardown (_)
  "Tear-down for 'load.el' tests."
  (while test<keyboard/load>:with:temps
    (let ((path (pop test<keyboard/load>:with:temps)))
      (unwind-protect
          (cond ((file-directory-p path)
                 (delete-directory path t))
                ((file-exists-p path)
                 (delete-file path))
                (t
                 ;; Path does not exist?
                 (warn "test<keyboard/load>:teardown: Path does not exist; cannot delete: %s"
                       path)))))))


;; ╔═════════════════════════════╤═══════════╤═════════════════════════════════╗
;; ╟─────────────────────────────┤ ERT TESTS ├─────────────────────────────────╢
;; ╠═════════════════════╤═══════╧═══════════╧════════╤════════════════════════╣
;; ╟─────────────────────┤ Input: Keyboards & Layouts ├────────────────────────╢
;; ╚═════════════════════╧════════════════════════════╧════════════════════════╝


;;------------------------------------------------------------------------------
;; Tests: 'path' Functions
;;------------------------------------------------------------------------------

;;------------------------------
;; int<keyboard>:path:append
;;------------------------------

(ert-deftest test<keyboard/load>::int<keyboard>:path:append ()
  "Test that `int<keyboard>:path:append' behaves appropriately."
  (test<keyboard>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<keyboard/load>::int<keyboard>:path:append"
      #'test<keyboard/load>:setup
      #'test<keyboard/load>:teardown

    ;;===
    ;; Run the test.
    ;;===
    (let ((parent "d:")
          (child "foo"))
      (should (string= (int<keyboard>:path:append parent child)
                       (concat parent "/" child))))
    (let ((parent "d:\\")
          (child "foo"))
      (should (string= (int<keyboard>:path:append parent child)
                       (concat "d:/" child))))

    (let ((parent "/")
          (child "foo"))
      (should (string= (int<keyboard>:path:append parent child)
                       (concat parent child))))

    (let ((parent "/srv")
          (child "foo"))
      (should (string= (int<keyboard>:path:append parent child)
                       (concat parent "/" child))))

    (let ((parent "/srv/")
          (child "foo"))
      (should (string= (int<keyboard>:path:append parent child)
                       (concat parent child))))))


;;------------------------------
;; int<keyboard>:path:join
;;------------------------------

(ert-deftest test<keyboard/load>::int<keyboard>:path:join ()
  "Test that `int<keyboard>:path:append' behaves appropriately."
  (test<keyboard>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<keyboard/load>::int<keyboard>:path:append"
      #'test<keyboard/load>:setup
      #'test<keyboard/load>:teardown

    ;;===
    ;; Run the test.
    ;;===
    (should (string= (int<keyboard>:path:join "d:" "foo" "bar")
                     "d:/foo/bar"))
    (should (string= (int<keyboard>:path:join "d:/" "foo" "bar")
                     "d:/foo/bar"))
    (should (string= (int<keyboard>:path:join "d:\\" "foo" "bar")
                     "d:/foo/bar"))
    (should (string= (int<keyboard>:path:join "d:\\foo\\bar")
                     "d:/foo/bar"))

    (should (string= (int<keyboard>:path:join "/")
                     "/"))
    (should (string= (int<keyboard>:path:join "/foo/bar")
                     "/foo/bar"))
    (should (string= (int<keyboard>:path:join "/" "foo" "bar")
                     "/foo/bar"))))

;;------------------------------
;; int<keyboard>:path:join
;;------------------------------

(ert-deftest test<keyboard/load>::int<keyboard>:path:file/exists? ()
  "Test that `int<keyboard>:path:file/exists?' behaves appropriately."
  (test<keyboard>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<keyboard/load>::int<keyboard>:path:append"
      #'test<keyboard/load>:setup
      #'test<keyboard/load>:teardown

    ;;===
    ;; Run the test.
    ;;===
    (let* ((path/exists (test<keyboard/load>:path:make-temp nil "test-file-exists"))
           (path/dne (int<keyboard>:path:join path/exists ".does-not-exist")))
      (should (int<keyboard>:path:file/exists? path/exists))
      (should-not (int<keyboard>:path:file/exists? path/dne)))))


;;------------------------------------------------------------------------------
;; Tests: 'load' Functions
;;------------------------------------------------------------------------------

;;------------------------------
;; int<keyboard>:load:layout?
;;------------------------------

(ert-deftest test<keyboard/load>::int<keyboard>:load:layout? ()
  "Test that `int<keyboard>:load:layout?' behaves appropriately."
  (test<keyboard>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<keyboard/load>::int<keyboard>:load:layout?"
      #'test<keyboard/load>:setup
      #'test<keyboard/load>:teardown

    ;;===
    ;; Run the test.
    ;;===

    ;; Lexically bind input//kl:layout/desired for these tests.
    (let* ((layout/test/keyword          :testing)
           (layout/test/needs-normalized "+testing")
           (layout/not/keyword           :not-testing)
           (layout/not/needs-normalized  "+not-testing")
           (input//kl:layout/desired     layout/test/keyword))
      (should input//kl:layout/desired)
      (should (eq layout/test/keyword input//kl:layout/desired))

      (should-not (int<keyboard>:load:layout? layout/not/keyword))
      (should-not (int<keyboard>:load:layout? layout/not/needs-normalized))

      (should (int<keyboard>:load:layout? layout/test/keyword))
      (should (int<keyboard>:load:layout? layout/test/needs-normalized)))))
