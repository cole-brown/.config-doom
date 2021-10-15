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

(defvar test<keyboard/load>:debug:files nil
  "If true, will not delete files during tear-down.")


(defun test<keyboard/load>:debug/toggle (prefix)
  "Toggle debugging for ':input/keyboard' ERT unit testing,
and also set `test<keyboard/load>:debug:files' to on/off based on whether
debugging is on/off.

With prefix arg, will also toggle ':input/keyboard' debugging to same on/off
value as tests' debugging toggle."
  (interactive "P")
  (test<keyboard>:debug/toggle prefix)
  (setq test<keyboard/load>:debug:files test<keyboard>:debugging))


(defvar test<keyboard/load>:with:temps nil
  "Temp dirs & files to delete during tear-down.")


(defun test<keyboard/load>:random:string (length)
  "Create a random alphanumerics string of length LENGTH.
The possible chars are: A to Z, a to z, 0 to 9."
  (let* ((charset "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789")
         (charset.length (length charset))
         (output))
    ;; Convert the list into a string.
    (concat
     ;; Push random characters to a list.
     (dotimes (_ (abs length) output)
       (push (elt charset (random charset.length)) output)))))


(defun test<keyboard/load>:path:make-temp (directory? name-prefix &optional parent)
  "Creates a temp dir or file (depending on DIRECTORY?) and sets it up for
deletion in test teardown.

Will create a directory if DIRECTORY? is non-nil. Else creates a file.

Creates a file/dir with the filename prefixed by NAME-PREFIX.

If PARENT is nil, creates the temp file/dir using `make-temp-file' (will be
created in a temp directory like \"c:/Users/<user>/AppData/Local/Temp/\" on
Windows).

If PARENT is non-nil, creates the temp file/dir in the PARENT directory.

Returns the path to the dir/file."
  ;; Create the temp file/dir.
  (let ((path/temp (make-temp-file name-prefix directory?)))
    ;; Save so we can delete during tear-down.
    (push path/temp test<keyboard/load>:with:temps)
    path/temp))
;; (make-temp-file "foo")
;;   -> Windows 10:
;;      -> "c:/Users/<user>/AppData/Local/Temp/foo<random>"


(defun test<keyboard/load>:path:make/in-temp (directory? parent name)
  "Creates a temp dir or file (depending on DIRECTORY?).

Does not add it to the deletion list (`test<keyboard/load>:with:temps'), as it
is assumed that PARENT was created via `test<keyboard/load>:path:make'.

Will create a directory if DIRECTORY? is non-nil. Else creates a file.

Creates a file/dir named NAME.

Returns the path to the dir/file."
  (let ((path (int<keyboard>:path:join parent name)))
    ;; Create the temp file/dir.
    (if directory?
        (make-directory path)
      (make-empty-file path))

    ;; Return the full path.
    path))


(defun test<keyboard/load>:setup (_)
  "Set-up for 'load.el' tests."
  ;; If we failed to delete something last test, we should drop it.
  (setq test<keyboard/load>:with:temps nil))


(defun test<keyboard/load>:teardown (test-name)
  "Tear-down for 'load.el' tests."
  (if (not test<keyboard/load>:debug:files)
      ;; Not debugging - clean up our temp files.
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
                           path))))))

    ;; Debugging - don't delete files; inform about them instead.
    (test<keyboard>:debug test-name "Skipping file/folder deletion!")
    (test<keyboard>:debug test-name "Temp paths: %S" test<keyboard/load>:with:temps)))


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


;;------------------------------
;; int<keyboard>:load:file
;;------------------------------

(ert-deftest test<keyboard/load>::int<keyboard>:load:file ()
  "Test that `int<keyboard>:load:file' behaves appropriately."
  ;; Create two "layouts" for testing that one loads and not the other.
  (let* ((layout/test/keyword          :testing)
         (layout/test/needs-normalized "+testing")
         (layout/not/keyword           :not-testing)
         (layout/not/needs-normalized  "+not-testing")
         ;; Some symbol names to check after loading.
         (symbol/prefix     "test<keyboard/load>::int<keyboard>:load:file::")
         (symbol/test/name  (make-symbol (concat symbol/prefix layout/test/needs-normalized)))
         (symbol/not/name   (make-symbol (concat symbol/prefix layout/not/needs-normalized)))
         (symbol/test/value 42)
         (symbol/not/value  1337))

    (should-not (boundp symbol/test/name))
    (should-not (boundp symbol/not/name))

    (test<keyboard>:fixture
        ;;===
        ;; Test name, setup & teardown func.
        ;;===
        "test<keyboard/load>::int<keyboard>:load:file"
        #'test<keyboard/load>:setup
        ;; Test-specific teardown - make sure the symbols we check don't stick around.
        (lambda (test-name)
          "Tear-down for `test<keyboard/load>::int<keyboard>:load:file'."
          (makunbound symbol/test/name)
          (makunbound symbol/not/name)
          (test<keyboard/load>:teardown test-name))

      ;;===
      ;; Run the test.
      ;;===

      ;; Lexically bind to the desired `:testing' layout.
      (let* ((input//kl:layout/desired     layout/test/keyword)
             ;; Make a root and a 'layout' folder with two "layouts".
             (file/load        "init.el")
             (path/dir/root    (test<keyboard/load>:path:make-temp    :dir
                                                                      "test-load-file"))
             (path/dir/layouts (test<keyboard/load>:path:make/in-temp :dir
                                                                      path/dir/root
                                                                      "layout"))
             (path/dir/test    (test<keyboard/load>:path:make/in-temp :dir
                                                                      path/dir/layouts
                                                                      layout/test/needs-normalized))
             (path/file/test   (test<keyboard/load>:path:make/in-temp nil
                                                                      path/dir/test
                                                                      file/load))
             (path/dir/not     (test<keyboard/load>:path:make/in-temp :dir
                                                                      path/dir/layouts
                                                                      layout/not/needs-normalized))
             (path/file/not    (test<keyboard/load>:path:make/in-temp nil
                                                                      path/dir/not
                                                                      file/load))
             attributes)

        ;;------------------------------
        ;; Files exist and are empty?
        ;;------------------------------
        ;; Dirs should exist.
        (should (file-exists-p path/dir/root))
        (should (file-exists-p path/dir/layouts))
        (should (file-exists-p path/dir/test))
        (should (file-exists-p path/dir/not))

        (should (int<keyboard>:path:file/exists? path/file/test))
        (setq attributes (file-attributes path/file/test))
        (should (= 0 (file-attribute-size attributes)))

        (should (int<keyboard>:path:file/exists? path/file/not))
        (setq attributes (file-attributes path/file/not))
        (should (= 0 (file-attribute-size attributes)))

        ;;------------------------------
        ;; Write some lisp to our files.
        ;;------------------------------
        ;; We need to prove one was loaded but not the other,
        ;; so create different symbols for each that will get loaded when this is done.
        (with-current-buffer (find-file-noselect path/file/test)
          (insert "(setq " (symbol-name symbol/test/name) " " (number-to-string symbol/test/value) ")")
          (save-buffer))
        (with-current-buffer (find-file-noselect path/file/not)
          (insert "(setq " (symbol-name symbol/not/name) " " (number-to-string symbol/not/value) ")")
          (save-buffer))

        (should-not (boundp symbol/test/name))
        (should-not (boundp symbol/not/name))

        ;;------------------------------
        ;; Files exist and are no longer empty?
        ;;------------------------------
        (should (int<keyboard>:path:file/exists? path/file/test))
        (setq attributes (file-attributes path/file/test))
        (should (> (file-attribute-size attributes) 0))

        (should (int<keyboard>:path:file/exists? path/file/not))
        (setq attributes (file-attributes path/file/not))
        (should (> (file-attribute-size attributes) 0))

        (should-not (boundp symbol/test/name))
        (should-not (boundp symbol/not/name))

        ;;------------------------------
        ;; Load one of the files.
        ;;------------------------------

        ;; TODO: Trying to join some `nil' args together...
        (int<keyboard>:load:file layout/test/needs-normalized
                                 file/load
                                 path/dir/root
                                 :error)

        (test<keyboard>:assert:output :error test-name 0)

        (should (boundp symbol/test/name))
        (should (numberp symbol/test/name))
        (should (= (symbol-value symbol/test/name) symbol/test/value))
        (should-not (boundp symbol/not/name))))))
