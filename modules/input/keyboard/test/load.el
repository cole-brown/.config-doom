;; -*- no-byte-compile: t; lexical-binding: t; -*-
;;; input/keyboard/test/debug.el

;;------------------------------------------------------------------------------
;; Test Debugging Helpers
;;------------------------------------------------------------------------------

(require 'cl-macs) ;; `cl-letf'

;;---
;; Testing Files:
;;---
(load! "base.el")

;;---
;; Keyboard Files:
;;---
(load! "../vars.el")
(load! "../load.el")


;;------------------------------------------------------------------------------
;; Test Helpers: Loading
;;------------------------------------------------------------------------------

;;------------------------------
;; Debugging
;;------------------------------

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
  "Temp dirs & files to delete during tear-down.

Alist of: (path . (:action-0 :action-1))
Actions should be:
  - :path/delete
  - :buffer/close")


;;------------------------------
;; Temp Paths, Files, Dirs
;;------------------------------

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
    ;; Save path and actions to take during tear-down.
    (push (cons path/temp (list :path/delete :buffer/close))
          test<keyboard/load>:with:temps)
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
  (let ((path/temp (int<keyboard>:path:join parent name)))
    ;; Create the temp file/dir.
    (if directory?
        (make-directory path/temp)
      (make-empty-file path/temp)) ;; Doesn't open a buffer.

    ;; Save path and actions to take during tear-down.
    ;;   - Making in a temp dir so no need to delete each file/folder.
    ;;     Temp dir will be deleted recursively.
    (push (cons path/temp (list :buffer/close))
          test<keyboard/load>:with:temps)


    ;; Return the full path.
    path/temp))


;;------------------------------
;; Symbols
;;------------------------------

(defun test<keyboard/load>:symbol/delete (test-name symbol/name)
  "Delete the SYMBOL/NAME string's symbol if exists.

TEST-NAME should be the test's name.

Unbinds and uninterns the symbol."
  (let ((symbol/symbol (intern-soft symbol/name))
        (symbol/DNE "<Does-Not-Exist>")
        symbol/value)
    (if (null symbol/symbol)
        ;; Symbol doesn't exist - nothing to do.
        (test<keyboard>:debug
            test-name
          '("\n"
            "  [NO-OP ]: symbol (exists? %S): %S -> value: %S")
          (not (null symbol/symbol))
          symbol/name
          symbol/DNE)

      ;; Symbol exists - need to delete it.
      (unwind-protect
          (condition-case err
              ;; Try to get symbol's value.
              (setq symbol/value (symbol-value symbol/symbol))
            ;; Handle expected error.
            (void-variable nil))
        ;; Debug either way.
        (test<keyboard>:debug
            test-name
          '("\n"
            "  [BEFORE]: symbol (exists? %S): %S -> value: %S")
          (not (null symbol/symbol))
          symbol/symbol
          (if symbol/value
              symbol/value
            symbol/DNE)))

      ;; Delete symbol's value and delete symbol from symbol table.
      (makunbound symbol/symbol)
      (unintern symbol/symbol)

      (setq symbol/symbol (intern-soft symbol/name))
      (unwind-protect
          (condition-case err
              ;; Try to get symbol's value.
              (setq symbol/value (symbol-value symbol/symbol))
            ;; Handle expected error.
            (void-variable nil))
        ;; Debug anyways.
        (test<keyboard>:debug
            test-name
          '("\n"
            "  [AFTER ]: symbol (exists? %S): %S -> value: %S")
          (not (null symbol/symbol))
          symbol/symbol
          (if symbol/symbol
              symbol/value
            symbol/DNE))))))
;; (let* ((layout/test/needs-normalized "+testing")
;;        (symbol/prefix     "test<keyboard/load>::int<keyboard>:load:file::")
;;        (symbol/test/name  (concat symbol/prefix layout/test/needs-normalized))
;;        (symbol/test/symbol (intern-soft symbol/test/name))
;;        (test-name "testing?"))
;;   (test<keyboard/load>:symbol/delete test-name symbol/test/name))


;;------------------------------
;; Set-Up / Tear-Down
;;------------------------------

(defun test<keyboard/load>:setup (_)
  "Set-up for 'load.el' tests."
  ;; If we failed to delete something last test, we should drop it.
  (setq test<keyboard/load>:with:temps nil))


(defun test<keyboard/load>:teardown (test-name)
  "Tear-down for 'load.el' tests."
  ;; Clean up our temp files/folders.
  (while test<keyboard/load>:with:temps
    (let* ((path-and-actions (pop test<keyboard/load>:with:temps))
           (path (car path-and-actions))
           (actions (cdr path-and-actions)))
      ;; Do each action on the temp path.
      (dolist (action actions)
        (cond ((eq :path/delete action)
               (if (not test<keyboard/load>:debug:files)
                   ;; Not Debugging - delete temp file/folder.
                   (unwind-protect
                       (cond ((file-directory-p path)
                              (delete-directory path t))
                             ((file-exists-p path)
                              (delete-file path))
                             (t
                              ;; Path does not exist?
                              (warn "test<keyboard/load>:teardown: Path does not exist; cannot delete: %s"
                                    path))))

                 ;; Debugging - don't delete files; inform about them instead.
                 (test<keyboard>:debug test-name "Skipping file/folder deletion!")
                 (test<keyboard>:debug test-name "Temp paths: %S" test<keyboard/load>:with:temps)))

              ((eq :buffer/close action)
               ;; Close temp file/folder's buffer (if open).
               (when-let ((buffer (get-file-buffer path)))
                 (kill-buffer buffer))))))))


;;------------------------------
;; Test Fixture for Loading Layouts
;;------------------------------

(defmacro test<keyboard/load>:fixture:layouts (test-name/test test-name/directory
                                               func/setup func/teardown
                                               layout/file/name layout/file/testing layout/file/not-testing
                                               &rest body)
  "Does normal `test<keyboard>:fixture' things and also creates two layouts for testing:
  - `:testing'     / \"+testing\"
  - `:not-testing' / \"+not-testing\"

Lexically binds `input//kl:layout/desired' to the `:testing' layout for the duration of the BODY.

TEST-NAME/TEST should be test function's name (e.g. `test<keyboard/load>::int<keyboard>:load:file').
TEST-NAME/DIRECTORY should be a valid dir name (e.g. `test-load-file').

FUNC/SETUP should be one of:
  - nil (for default `test<keyboard/load>:setup')
  - A test-specific set-up function (that does _not_ call `test<keyboard/load>:setup').
FUNC/TEARDOWN should be one of:
  - nil (for default `test<keyboard/load>:teardown')
  - A test-specific tear-down function (that does _not_ call `test<keyboard/load>:teardown').

LAYOUT/FILE/NAME should be a filename string ending in \".el\" - like \"init.el\".

Created \"layouts\" will have the contents of these strings in their LAYOUT/FILE/NAME files:
  - `:testing':     LAYOUT/FILE/TESTING
  - `:not-testing': LAYOUT/FILE/NOT-TESTING"
  (declare (indent 7))

  ;; Eval our inputs only once.
  `(let* ((test/name                                      ,test-name/test)
          (test/dir                                       ,test-name/directory)
          (test<keyboard/load>:fl:func/setup              ,func/setup)
          (test<keyboard/load>:fl:func/teardown           ,func/teardown)
          (test<keyboard/load>:fl:layout/file/testing     ,layout/file/testing)
          (test<keyboard/load>:fl:layout/file/not-testing ,layout/file/not-testing)
          (file/load                                      ,layout/file/name)
          ;; Layout vars.
          (layout/test/keyword          :testing)
          (layout/test/needs-normalized "+testing")
          (layout/not/keyword           :not-testing)
          (layout/not/needs-normalized  "+not-testing")
          ;; Lexically bind desired for the duration of the test.
          (input//kl:layout/desired     layout/test/keyword)
          ;; Make a root and a 'layout' folder with two "layouts".
          (path/dir/root    (test<keyboard/load>:path:make-temp    :dir
                                                                   test/dir))
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

     ;; Make sure our inputs are valid.
     (should (stringp test/name))
     (should (stringp test/dir))
     (should (or (null      test<keyboard/load>:fl:func/setup)
                 (functionp test<keyboard/load>:fl:func/setup)))
     (should (or (null      test<keyboard/load>:fl:func/teardown)
                 (functionp test<keyboard/load>:fl:func/teardown)))
     (should (stringp test<keyboard/load>:fl:layout/file/testing))
     (should (stringp test<keyboard/load>:fl:layout/file/not-testing))
     (should (stringp file/load))
     (should (string= (file-name-extension file/load) "el"))

     (test<keyboard>:fixture
         ;;===
         ;; Test name, setup & teardown func.
         ;;===
         test/name
         test<keyboard/load>:fl:func/setup
         test<keyboard/load>:fl:func/teardown

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

       (test<keyboard>:debug
           test/name
         '("Paths exist:\n"
           "  - path/dir/root:    %S %s\n"
           "  - path/dir/layouts: %S %s\n"
           "  - path/dir/test:    %S %s\n"
           "  - path/file/test:   %S %s\n"
           "  - path/dir/not:     %S %s\n"
           "  - path/file/not:    %S %s")
         (int<keyboard>:path:file/exists? path/dir/root)    path/dir/root
         (int<keyboard>:path:file/exists? path/dir/layouts) path/dir/layouts
         (int<keyboard>:path:file/exists? path/dir/test)    path/dir/test
         (int<keyboard>:path:file/exists? path/file/test)   path/file/test
         (int<keyboard>:path:file/exists? path/dir/not)     path/dir/not
         (int<keyboard>:path:file/exists? path/file/not)    path/file/not)

       ;;------------------------------
       ;; Write some lisp to our files.
       ;;------------------------------
       ;; We need to prove one was loaded but not the other,
       ;; so create different symbols for each that will get loaded when this is done.
       (test<keyboard>:with:file-buffer
           path/file/test
           :buffer/kill
           nil ;; Don't delete file yet.
         (insert test<keyboard/load>:fl:layout/file/testing)
         (save-buffer))
       (test<keyboard>:with:file-buffer
           path/file/not
           :buffer/kill
           nil ;; Don't delete file yet.
         (insert test<keyboard/load>:fl:layout/file/not-testing)
         (save-buffer))

       ;;------------------------------
       ;; Files exist and are no longer empty?
       ;;------------------------------
       (should (int<keyboard>:path:file/exists? path/file/test))
       (setq attributes (file-attributes path/file/test))
       (should (> (file-attribute-size attributes) 0))

       (should (int<keyboard>:path:file/exists? path/file/not))
       (setq attributes (file-attributes path/file/not))
       (should (> (file-attribute-size attributes) 0))

       ;;------------------------------
       ;; Run Caller's Tests!
       ;;------------------------------
       ;; Should now have the lisp from the file evaluated/loaded. Run the caller's tests.
       ,@body)))


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
  ;; Some symbol names to check after loading.
  (let* ((name                 "test<keyboard/load>::int<keyboard>:load:file")
         (name/dir             "test-load-file")
         (symbol/prefix        (concat name "::"))
         (symbol/test/name     (concat symbol/prefix "+testing"))
         (symbol/not/name      (concat symbol/prefix "+not-testing"))
         (symbol/test/expected 42)
         (symbol/not/expected  1337))

    ;; Create two "layouts" for testing that one loads and not the other.
    (test<keyboard/load>:fixture:layouts
        ;;===
        ;; Test names.
        ;;===
        name     ;; `test/name'
        name/dir ;; `test/dir' - for a directory name

        ;;===
        ;; Set-up & tear-down funcs.
        ;;===
        ;; Test-specific set-up - make sure the symbols we check are not around yet.
        (lambda (name)
          "Set-up for `test<keyboard/load>::int<keyboard>:load:file'."
          (test<keyboard/load>:setup name)
          (should-not (intern-soft symbol/test/name))
          (should-not (intern-soft symbol/not/name)))

        ;; Test-specific tear-down - make sure the symbols we check don't stick around.
        (lambda (name)
          "Tear-down for `test<keyboard/load>::int<keyboard>:load:file'."
          (let ((symbol/test/symbol (intern-soft symbol/test/name))
                (symbol/not/symbol  (intern-soft symbol/not/name))
                symbol/value)
            (test<keyboard>:debug
                name
              '("\n"
                "Teardown: [BEFORE]:\n"
                "  - unbinding: %s\n"
                "    + exists?: %S\n"
                "  - unbinding: %s\n"
                "    + exists?: %S")
              symbol/test/name
              (intern-soft symbol/test/name)
              symbol/not/name
              (intern-soft symbol/not/name))

            ;; Unbind if they are bound.
            (test<keyboard/load>:symbol/delete name symbol/test/name)
            (test<keyboard/load>:symbol/delete name symbol/not/name)

            (test<keyboard>:debug
                name
              '("\n"
                "Teardown: [AFTER]:\n"
                "  - unbinding: %s\n"
                "    + exists?: %S\n"
                "  - unbinding: %s\n"
                "    + exists?: %S")
              symbol/test/name
              (intern-soft symbol/test/name)
              symbol/not/name
              (intern-soft symbol/not/name))

            ;; And do normal keyboard/load teardown too.
            (test<keyboard/load>:teardown name)))

        ;;===
        ;; Layouts' "init.el" file contents.
        ;;===
        "init.el"
        (concat "(setq " symbol/test/name " " (number-to-string symbol/test/expected) ")")
        (concat "(setq " symbol/not/name  " " (number-to-string symbol/not/expected)  ")")

      ;;===
      ;; Run the test.
      ;;===

      ;;------------------------------
      ;; Sanity check!
      ;;------------------------------
      (should-not (intern-soft symbol/test/name))
      (should-not (intern-soft symbol/not/name))

      ;;------------------------------
      ;; Load one of the files.
      ;;------------------------------
      (test<keyboard>:debug
          test/name
        '("Paths exist:\n"
          "  - path/dir/root:    %S %s\n"
          "  - path/dir/layouts: %S %s\n"
          "  - path/dir/test:    %S %s\n"
          "  - path/file/test:   %S %s\n"
          "  - path/dir/not:     %S %s\n"
          "  - path/file/not:    %S %s")
        (int<keyboard>:path:file/exists? path/dir/root)    path/dir/root
        (int<keyboard>:path:file/exists? path/dir/layouts) path/dir/layouts
        (int<keyboard>:path:file/exists? path/dir/test)    path/dir/test
        (int<keyboard>:path:file/exists? path/file/test)   path/file/test
        (int<keyboard>:path:file/exists? path/dir/not)     path/dir/not
        (int<keyboard>:path:file/exists? path/file/not)    path/file/not)

      ;; Load should return something truthy.
      (should (int<keyboard>:load:file layout/test/needs-normalized
                                       (file-name-sans-extension file/load)
                                       path/dir/root
                                       :error))
      ;; Should not have errored loading file.
      (test<keyboard>:assert:output :error test/name 0)

      ;; Should now have the symbol & value from the file we loaded.
      (setq symbol/test/symbol (intern-soft symbol/test/name))
      (should symbol/test/symbol)

      (setq symbol/value (symbol-value symbol/test/symbol))
      (should (numberp symbol/value))
      (should (= symbol/value symbol/test/expected))

      ;; Still should /not/ have the symbol & value from the file we did /not/ load.
      (should-not (intern-soft symbol/not/name)))))


;;------------------------------
;; int<keyboard>:load:active?
;;------------------------------

(ert-deftest test<keyboard/load>::int<keyboard>:load:active? ()
  "Test that `int<keyboard>:load:active?' behaves appropriately."
  (let* ((name                 "test<keyboard/load>::int<keyboard>:load:active?")
         (name/dir             "test-load-active-p")
         (symbol/prefix        (concat name "::"))
         (symbol/test/name     (concat symbol/prefix "+testing"))
         (symbol/not/name      (concat symbol/prefix "+not-testing"))
         (symbol/test/expected 42)
         (symbol/not/expected  1337)
         (test/loading?-yes (lambda ()
                              "Mock loading for testing."
                              (test<keyboard>:debug name "Mock `input//kl:loading?' == !!!YES!!!")
                              t))
         (test/loading?-no (lambda ()
                              "Mock loading/not-loading for testing."
                              (test<keyboard>:debug name "Mock `input//kl:loading?' == no")
                              nil)))

      ;; Create two "layouts" for testing that one loads and not the other.
      ;; Lexically bind `input//kl:layout/desired' to one of those layouts.
      (test<keyboard/load>:fixture:layouts
          ;;===
          ;; Test names.
          ;;===
          name     ;; `test/name'
          name/dir ;; `test/dir' - for a directory name

          ;;===
          ;; Set-up & tear-down funcs.
          ;;===
          ;; Test-specific set-up - make sure the symbols we check are not around yet.
          (lambda (test/name)
            "Set-up for `test<keyboard/load>::int<keyboard>:load:file'."
            (test<keyboard/load>:setup test/name)
            (should-not (intern-soft symbol/test/name))
            (should-not (intern-soft symbol/not/name)))

          ;; Test-specific tear-down - make sure the symbols we check don't stick around.
          (lambda (test/name)
            "Tear-down for `test<keyboard/load>::int<keyboard>:load:file'."
            (let ((symbol/test/symbol (intern-soft symbol/test/name))
                  (symbol/not/symbol  (intern-soft symbol/not/name))
                  symbol/value)
              (test<keyboard>:debug
                  test/name
                '("\n"
                  "Teardown: [BEFORE]:\n"
                  "  - unbinding: %s\n"
                  "    + exists?: %S\n"
                  "  - unbinding: %s\n"
                  "    + exists?: %S")
                symbol/test/name
                (intern-soft symbol/test/name)
                symbol/not/name
                (intern-soft symbol/not/name))

              ;; Unbind if they are bound.
              (test<keyboard/load>:symbol/delete test/name symbol/test/name)
              (test<keyboard/load>:symbol/delete test/name symbol/not/name)

              (test<keyboard>:debug
                  test/name
                '("\n"
                  "Teardown: [AFTER]:\n"
                  "  - unbinding: %s\n"
                  "    + exists?: %S\n"
                  "  - unbinding: %s\n"
                  "    + exists?: %S")
                symbol/test/name
                (intern-soft symbol/test/name)
                symbol/not/name
                (intern-soft symbol/not/name))

              ;; And do normal keyboard/load teardown too.
              (test<keyboard/load>:teardown test/name)))

          ;;===
          ;; Layouts' "init.el" file contents.
          ;;===
          "init.el"
          (concat "(setq " symbol/test/name " " (number-to-string symbol/test/expected) ")")
          (concat "(setq " symbol/not/name  " " (number-to-string symbol/not/expected)  ")")

        ;;===
        ;; Run the test.
        ;;===

        ;;------------------------------
        ;; Sanity check!
        ;;------------------------------
        (test<keyboard>:should:marker test/name "Sanity.")
        (should-not (intern-soft symbol/test/name))
        (should-not (intern-soft symbol/not/name))

        ;;------------------------------
        ;; Load the active layout's file.
        ;;------------------------------
        (test<keyboard>:debug
            test/name
          '("Paths exist:\n"
            "  - path/dir/root:    %S %s\n"
            "  - path/dir/layouts: %S %s\n"
            "  - path/dir/test:    %S %s\n"
            "  - path/file/test:   %S %s\n"
            "  - path/dir/not:     %S %s\n"
            "  - path/file/not:    %S %s")
          (int<keyboard>:path:file/exists? path/dir/root)    path/dir/root
          (int<keyboard>:path:file/exists? path/dir/layouts) path/dir/layouts
          (int<keyboard>:path:file/exists? path/dir/test)    path/dir/test
          (int<keyboard>:path:file/exists? path/file/test)   path/file/test
          (int<keyboard>:path:file/exists? path/dir/not)     path/dir/not
          (int<keyboard>:path:file/exists? path/file/not)    path/file/not)

        ;;------------------------------
        ;; Disable start-up init and then try to load during "start-up".
        ;;------------------------------
        (cl-letf (((symbol-function 'input//kl:loading?) test/loading?-no))
          (test<keyboard>:should:marker test/name "NOT LOADING!")
          (should-not (input//kl:loading?))

          ;;---
          ;; Try to load for the not-desired layout.
          ;;---
          ;; Should fail because not-desired and not-loading.
          (test<keyboard>:should:marker test/name "Not loading the undesired layout...")
          (should-not (int<keyboard>:load:active? layout/not/needs-normalized
                                                  (file-name-sans-extension file/load)
                                                  path/dir/root
                                                  :error))

          ;; Should not have errored trying loading file.
          (test<keyboard>:assert:output :error test/name 0)

          (should-not (intern-soft symbol/not/name))
          (should-not (intern-soft symbol/test/name))

          ;;---
          ;; Try to load for the desired layout.
          ;;---
          ;; Should fail because not-loading.
          (test<keyboard>:should:marker test/name "Not loading the active/desired layout...")
          (should-not (int<keyboard>:load:active? layout/test/needs-normalized
                                                  (file-name-sans-extension file/load)
                                                  path/dir/root
                                                  :error))

          ;; Should not have errored trying loading file.
          (test<keyboard>:assert:output :error test/name 0)

          (should-not (intern-soft symbol/not/name))
          (should-not (intern-soft symbol/test/name)))

        ;;------------------------------
        ;; Enable start-up init and try loading again.
        ;;------------------------------

        (cl-letf (((symbol-function 'input//kl:loading?) test/loading?-yes))
          (test<keyboard>:should:marker test/name "LOADING!")
          (should (input//kl:loading?))

          ;;---
          ;; Try to load for the not-desired layout.
          ;;---
          ;; Should fail because not-desired.
          (should-not (int<keyboard>:load:active? layout/not/needs-normalized
                                                  (file-name-sans-extension file/load)
                                                  path/dir/root
                                                  :error))

          ;; Should not have errored trying loading file.
          (test<keyboard>:assert:output :error test/name 0)

          (should-not (intern-soft symbol/not/name))
          (should-not (intern-soft symbol/test/name))

          ;;---
          ;; Try to load for the desired layout.
          ;;---
          ;; Should _succeed_ because desired /and/ loading.
          (should (int<keyboard>:load:active? layout/test/needs-normalized
                                              (file-name-sans-extension file/load)
                                              path/dir/root
                                              :error))

          ;; Should not have errored trying loading file.
          (test<keyboard>:assert:output :error test/name 0)

          (should-not (intern-soft symbol/not/name))

          ;; Now we should finally have our expected file loaded.
          ;; Should now have the symbol & value from the file we loaded.
          (setq symbol/test/symbol (intern-soft symbol/test/name))
          (should symbol/test/symbol)

          (setq symbol/value (symbol-value symbol/test/symbol))
          (should (numberp symbol/value))
          (should (= symbol/value symbol/test/expected))))))


;;------------------------------
;; keyboard:load:active
;;------------------------------

(ert-deftest test<keyboard/load>::keyboard:load:active ()
  "Test that `keyboard:load:active' finds and loads the file for the correct (active/desired) layout."
  (let* ((name                 "test<keyboard/load>::keyboard:load:active")
         (name/dir             "test-load-active-api")
         (symbol/prefix        (concat name "::"))
         (symbol/test/name     (concat symbol/prefix "+testing"))
         (symbol/not/name      (concat symbol/prefix "+not-testing"))
         (symbol/test/expected 42)
         (symbol/not/expected  1337)
         (test/loading?-yes (lambda ()
                              "Mock loading for testing."
                              (test<keyboard>:debug name "Mock `input//kl:loading?' == !!!YES!!!")
                              t))
         (input//kl:testing:disable-start-up-init t))
    (cl-letf (((symbol-function 'input//kl:loading?) test/loading?-yes))

      ;; Create two "layouts" for testing that one loads and not the other.
      ;; Lexically bind `input//kl:layout/desired' to one of those layouts.
      (test<keyboard/load>:fixture:layouts
          ;;===
          ;; Test names.
          ;;===
          name     ;; `test/name'
          name/dir ;; `test/dir' - for a directory name

          ;;===
          ;; Set-up & tear-down funcs.
          ;;===
          ;; Test-specific set-up - make sure the symbols we check are not around yet.
          (lambda (test/name)
            "Set-up for `test<keyboard/load>::int<keyboard>:load:file'."
            (test<keyboard/load>:setup test/name)
            (should-not (intern-soft symbol/test/name))
            (should-not (intern-soft symbol/not/name)))

          ;; Test-specific tear-down - make sure the symbols we check don't stick around.
          (lambda (test/name)
            "Tear-down for `test<keyboard/load>::int<keyboard>:load:file'."
            (let ((symbol/test/symbol (intern-soft symbol/test/name))
                  (symbol/not/symbol  (intern-soft symbol/not/name))
                  symbol/value)
              (test<keyboard>:debug
                  test/name
                '("\n"
                  "Teardown: [BEFORE]:\n"
                  "  - unbinding: %s\n"
                  "    + exists?: %S\n"
                  "  - unbinding: %s\n"
                  "    + exists?: %S")
                symbol/test/name
                (intern-soft symbol/test/name)
                symbol/not/name
                (intern-soft symbol/not/name))

              ;; Unbind if they are bound.
              (test<keyboard/load>:symbol/delete test/name symbol/test/name)
              (test<keyboard/load>:symbol/delete test/name symbol/not/name)

              (test<keyboard>:debug
                  test/name
                '("\n"
                  "Teardown: [AFTER]:\n"
                  "  - unbinding: %s\n"
                  "    + exists?: %S\n"
                  "  - unbinding: %s\n"
                  "    + exists?: %S")
                symbol/test/name
                (intern-soft symbol/test/name)
                symbol/not/name
                (intern-soft symbol/not/name))

              ;; And do normal keyboard/load teardown too.
              (test<keyboard/load>:teardown test/name)))

          ;;===
          ;; Layouts' "init.el" file contents.
          ;;===
          "init.el"
          (concat "(setq " symbol/test/name " " (number-to-string symbol/test/expected) ")")
          (concat "(setq " symbol/not/name  " " (number-to-string symbol/not/expected)  ")")

        ;;===
        ;; Run the test.
        ;;===

        ;;------------------------------
        ;; Sanity check!
        ;;------------------------------
        (test<keyboard>:should:marker test/name "Sanity.")
        (should-not (intern-soft symbol/test/name))
        (should-not (intern-soft symbol/not/name))

        ;;------------------------------
        ;; Load the active layout's file.
        ;;------------------------------
        (test<keyboard>:debug
            test/name
          '("Paths exist:\n"
            "  - path/dir/root:    %S %s\n"
            "  - path/dir/layouts: %S %s\n"
            "  - path/dir/test:    %S %s\n"
            "  - path/file/test:   %S %s\n"
            "  - path/dir/not:     %S %s\n"
            "  - path/file/not:    %S %s")
          (int<keyboard>:path:file/exists? path/dir/root)    path/dir/root
          (int<keyboard>:path:file/exists? path/dir/layouts) path/dir/layouts
          (int<keyboard>:path:file/exists? path/dir/test)    path/dir/test
          (int<keyboard>:path:file/exists? path/file/test)   path/file/test
          (int<keyboard>:path:file/exists? path/dir/not)     path/dir/not
          (int<keyboard>:path:file/exists? path/file/not)    path/file/not)

        ;;------------------------------
        ;; Disable start-up init and then try to load during "start-up".
        ;;------------------------------
        (let ((input//kl:testing:disable-start-up-init t))
          (test<keyboard>:should:marker test/name "NOT LOADING!")

          ;;---
          ;; Try to load for the layout.
          ;;---
          ;; Should fail because not-loading.
          (test<keyboard>:should:marker test/name "Not loading the layout...")
          (should-not (keyboard:load:active (file-name-sans-extension file/load)
                                            path/dir/root
                                            :error))

          ;; Should not have errored trying loading file.
          (test<keyboard>:assert:output :error test/name 0)

          (should-not (intern-soft symbol/not/name))
          (should-not (intern-soft symbol/test/name)))

        ;;------------------------------
        ;; Enable start-up init and try loading again.
        ;;------------------------------

        (let ((input//kl:testing:disable-start-up-init nil))
          (test<keyboard>:should:marker test/name "LOADING!")

          ;;---
          ;; Try to load for the layout.
          ;;---
          ;; Should _succeed_ because we are loading now.
          (should (keyboard:load:active (file-name-sans-extension file/load)
                                        path/dir/root
                                        :error))

          ;; Should not have errored trying loading file.
          (test<keyboard>:assert:output :error test/name 0)

          (should-not (intern-soft symbol/not/name))

          ;; Now we should finally have our expected file loaded.
          ;; Should now have the symbol & value from the file we loaded.
          (setq symbol/test/symbol (intern-soft symbol/test/name))
          (should symbol/test/symbol)

          (setq symbol/value (symbol-value symbol/test/symbol))
          (should (numberp symbol/value))
          (should (= symbol/value symbol/test/expected)))))))


;;------------------------------
;; keyboard:load:layouts/list
;;------------------------------

(ert-deftest test<keyboard/load>::keyboard:load:layouts/list ()
  "Test that `keyboard:load:layouts/list' finds and loads the file for the correct (active/desired) layout."
  (let* ((name                 "test<keyboard/load>::keyboard:load:layouts/list")
         (name/dir             "test-load-active-api")
         (symbol/prefix        (concat name "::"))
         (symbol/test/name     (concat symbol/prefix "+testing"))
         (symbol/not/name      (concat symbol/prefix "+not-testing"))
         (symbol/test/expected 42)
         (symbol/not/expected  1337))

    ;; Create two "layouts" for testing that one loads and not the other.
    ;; Lexically bind `input//kl:layout/desired' to one of those layouts.
    (test<keyboard/load>:fixture:layouts
        ;;===
        ;; Test names.
        ;;===
        name     ;; `test/name'
        name/dir ;; `test/dir' - for a directory name

        ;;===
        ;; Set-up & tear-down funcs.
        ;;===
        ;; Test-specific set-up - make sure the symbols we check are not around yet.
        (lambda (test/name)
          "Set-up for `test<keyboard/load>::int<keyboard>:load:file'."
          (test<keyboard/load>:setup test/name)
          (should-not (intern-soft symbol/test/name))
          (should-not (intern-soft symbol/not/name)))

        ;; Test-specific tear-down - make sure the symbols we check don't stick around.
        (lambda (test/name)
          "Tear-down for `test<keyboard/load>::int<keyboard>:load:file'."
          (let ((symbol/test/symbol (intern-soft symbol/test/name))
                (symbol/not/symbol  (intern-soft symbol/not/name))
                symbol/value)
            (test<keyboard>:debug
                test/name
              '("\n"
                "Teardown: [BEFORE]:\n"
                "  - unbinding: %s\n"
                "    + exists?: %S\n"
                "  - unbinding: %s\n"
                "    + exists?: %S")
              symbol/test/name
              (intern-soft symbol/test/name)
              symbol/not/name
              (intern-soft symbol/not/name))

            ;; Unbind if they are bound.
            (test<keyboard/load>:symbol/delete test/name symbol/test/name)
            (test<keyboard/load>:symbol/delete test/name symbol/not/name)

            (test<keyboard>:debug
                test/name
              '("\n"
                "Teardown: [AFTER]:\n"
                "  - unbinding: %s\n"
                "    + exists?: %S\n"
                "  - unbinding: %s\n"
                "    + exists?: %S")
              symbol/test/name
              (intern-soft symbol/test/name)
              symbol/not/name
              (intern-soft symbol/not/name))

            ;; And do normal keyboard/load teardown too.
            (test<keyboard/load>:teardown test/name)))

        ;;===
        ;; Layouts' "init.el" file contents.
        ;;===
        "init.el"
        (concat "(setq " symbol/test/name " " (number-to-string symbol/test/expected) ")")
        (concat "(setq " symbol/not/name  " " (number-to-string symbol/not/expected)  ")")

      ;;===
      ;; Run the test.
      ;;===

      ;;------------------------------
      ;; Sanity check!
      ;;------------------------------
      (test<keyboard>:should:marker test/name "Sanity.")
      (should-not (intern-soft symbol/test/name))
      (should-not (intern-soft symbol/not/name))

      (test<keyboard>:debug
          test/name
        '("Paths exist:\n"
          "  - path/dir/root:    %S %s\n"
          "  - path/dir/layouts: %S %s\n"
          "  - path/dir/test:    %S %s\n"
          "  - path/file/test:   %S %s\n"
          "  - path/dir/not:     %S %s\n"
          "  - path/file/not:    %S %s")
        (int<keyboard>:path:file/exists? path/dir/root)    path/dir/root
        (int<keyboard>:path:file/exists? path/dir/layouts) path/dir/layouts
        (int<keyboard>:path:file/exists? path/dir/test)    path/dir/test
        (int<keyboard>:path:file/exists? path/file/test)   path/file/test
        (int<keyboard>:path:file/exists? path/dir/not)     path/dir/not
        (int<keyboard>:path:file/exists? path/file/not)    path/file/not)

      ;;------------------------------
      ;; Get the list of layouts.
      ;;------------------------------
      (let ((layouts (keyboard:load:layouts/list path/dir/root)))
        (should layouts)
        (should (listp layouts))
        (should (seq-every-p #'keywordp layouts))
        (should (= 2 (length layouts)))
        (should (memq layout/test/keyword layouts))
        (should (memq layout/not/keyword  layouts))))))
