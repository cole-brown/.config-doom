;; -*- no-byte-compile: t; -*-
;;; emacs/imp/test/suites.el

;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

;;------------------------------
;; Test Naming
;;------------------------------

;; ERT tests should be named according to this.
;; More specifically, they should be one of:
;;   test<SUITE-NAME>::<FUNC-NAME>
;;   test<SUITE-NAME>::<DESCRIPTION>
;;   test<SUITE-NAME>::<FUNC-NAME>::<DESCRIPTION>
;; For example, the test for 'imp/tree.el' function `int<imp/tree>:chain'
;; should be named:
;;   test<imp/tree>::int<imp/tree>:chain
;; If there was a bug that was fixed, maybe you'd have:
;;   test<imp/tree>::int<imp/tree>:chain::regression/nil-bug
(setq test<imp>:suite/prefix-fmt "test<%s>::")

;; "Run All Tests" is special.
(setq test<imp>:suite:all.name "[--all--]")
(setq test<imp>:suite:all.keyword :all)


(setq test<imp>:suite/all/regex
      (rx-to-string `(sequence line-start
                               ;; Test Suite Name Prefix
                               (group
                                "test<"
                                (one-or-more printing)
                                ">::")
                               ;; Test Name
                               (one-or-more printing)
                               ;; Done
                               line-end)
                    :no-group))


;;------------------------------
;; Files & Paths
;;------------------------------

(setq test<imp>:path:root
      ;; Parent directory should be the base imp dir.
      (file-name-directory
       (directory-file-name
        ;; Directory path of this file ("imp/test" dir).
        (file-name-directory
         ;; Filepath of this, depending on if this is being loaded or looked at.
         (if load-in-progress
             (file-name-directory load-file-name)
           (buffer-file-name))))))


;;------------------------------
;; Test Suites
;;------------------------------

;; See down below.


;;------------------------------------------------------------------------------
;; Helpers
;;------------------------------------------------------------------------------

;;------------------------------
;; Files & Paths
;;------------------------------

(defun test<imp>:path (relative)
  "Returns absolute path to RELATIVE file/directory by
prepending `test<imp>:path:root'."
  (concat test<imp>:path:root relative))
;; (test<imp>:path "tree.el")
;; (test<imp>:path "test/tree.el")


;;------------------------------
;; ERT Test Selector
;;------------------------------

(defun test<imp>:suite/regex.create (suite-name)
  "Returns a regex based on `test<imp>:suite/prefix-fmt' for finding ERT tests."
  (rx-to-string `(sequence line-start
                           (eval (format test<imp>:suite/prefix-fmt suite-name))
                           (one-or-more printing)
                           line-end)
                :no-group))
;; (test<imp>:suite/regex.create "imp/tree")


;;------------------------------
;; Suite Name/Keyword
;;------------------------------

(defun test<imp>:suite/name->keyword (suite-name)
  "Convert a suite name to a keyword symbol.

Handles the special 'all tests' string (currently '[--all--]') by returning
`:all'.

Other tests are just converted to a keyword: 'tree' -> `:tree'."
  (if (string= suite-name test<imp>:suite:all.name)
      test<imp>:suite:all.keyword
    (intern (concat ":" suite-name))))
;; (test<imp>:suite/name->keyword test<imp>:suite:all.name)
;; (test<imp>:suite/name->keyword "imp/tree")


(defun test<imp>:suite/keyword->name (suite)
  "Convert a suite keyword to a string.

Handles the special 'all tests' keyword -> string; `:all' returns '[--all--]'."
  (if (eq suite test<imp>:suite:all.keyword)
      test<imp>:suite:all.name
    (string-remove-prefix ":" (symbol-name suite))))
;; (test<imp>:suite/keyword->name test<imp>:suite:all.keyword)
;; (test<imp>:suite/keyword->name :imp/tree)


;;------------------------------
;; Suite Creation
;;------------------------------

(defun test<imp>:suite (suite-keyword depends-on-suites filepaths)
  "Helper to use if suite keyword is the same as the suite's prefix format,
which it should be...

Returns an alist of:
  - suite-keyword
  - A regex string for finding all of that suite's ERT test functions.
  - A list of suites this 'depends' on - that is a list of
    functionality that this test wants to already be working.
  - A list of file paths (relative to 'imp/' directory. "
  (list suite-keyword
        (test<imp>:suite/regex.create
         (string-remove-prefix ":" (symbol-name suite-keyword)))
        depends-on-suites
        filepaths))
;; (test<imp>:suite :imp/tree :imp/alist '("tree.el" "test/tree.el"))


;;------------------------------------------------------------------------------
;;==============================================================================
;; TEST SUITES
;;==============================================================================
;;------------------------------------------------------------------------------


;;------------------------------
;; The Test Suites Themselves
;;------------------------------

(setq test<imp>:suites
      ;; An alist of:
      ;;   - A symbol we'll use to identify a test suite.
      ;;   - A regex string for finding all of that suite's ERT test functions.
      ;;   - A list of suites this 'depends' on - that is a list of
      ;;     functionality that this test wants to already be working.
      ;;   - A list of file paths (relative to "imp/" directory.
      (list
       ;;-----------------------------------------------------------------------
       ;; Special Case: ALL TESTS!!!
       ;;-----------------------------------------------------------------------
       (list :all
             test<imp>:suite/all/regex
             ;; No dependencies - it's running everything.
             nil
             ;; No list of files for all; it will generate from everyone else's.
             nil)

       ;;-----------------------------------------------------------------------
       ;; alist
       ;;-----------------------------------------------------------------------
       (test<imp>:suite :alist
                       nil
                       '("alist.el"
                         "test/alist.el"))

       ;;-----------------------------------------------------------------------
       ;; tree
       ;;-----------------------------------------------------------------------
       (test<imp>:suite :tree
                       :alist
                       '("path.el" ;; May consider moving path to defaults?
                         "tree.el"
                         "test/tree.el"))))


;;------------------------------
;; Suite Accessors
;;------------------------------

(defun test<imp>:suite//regex.get (suite-keyword)
  "Returns the ERT test functions regex for the SUITE-KEYWORD."
  (nth 0 (alist-get suite-keyword test<imp>:suites)))
;; (test<imp>:suite//regex.get :tree)


(defun test<imp>:suite//dependencies.get (suite-keyword)
  "Returns the dependencies list for the SUITE-KEYWORD."
  (nth 1 (alist-get suite-keyword test<imp>:suites)))
;; (test<imp>:suite//dependencies.get :tree)


(defun test<imp>:suite//files.get (suite-keyword)
  "Returns the files list for the SUITE-KEYWORD."
  (nth 2 (alist-get suite-keyword test<imp>:suites)))
;; (test<imp>:suite//files.get :tree)


;;------------------------------
;; All Registered Suites
;;------------------------------

(defun test<imp>:suite//get-all-names ()
  "Returns a list of the test suite names from `test<imp>:suites'."
  (mapcar
   (lambda (suite)
     "Convert suite keyword to a name string."
     (test<imp>:suite/keyword->name (car suite)))
   test<imp>:suites))
;; (test<imp>:suite//get-all-names)


(defun test<imp>:suite//get-all-keywords ()
  "Returns a list of the test suite keywords from `test<imp>:suites'."
  (mapcar #'car test<imp>:suites))
;; (test<imp>:suite//get-all-keywords)


;;------------------------------
;; Suite Files
;;------------------------------

(defun test<imp>:suite/files (suite-name-or-keyword)
  "Returns the files to load for SUITE-NAME-OR-KEYWORD.

Does /not/ include `test<imp>:suites:files/load-always'."
  (let* ((suite-keyword (if (keywordp suite-name-or-keyword)
                            suite-name-or-keyword
                          (test<imp>:suite/name->keyword suite-name-or-keyword)))
         files)
    (cond ((not (memq suite-keyword (test<imp>:suite//get-all-keywords)))
           (error "Invalid suite '%S'; valid choices are: %S or %S"
                  suite-name-or-keyword
                  (test<imp>:suite/keywords)
                  (test<imp>:suite/names)))

          ;; "All" has null files - need to return the sum of everyone else's.
          ((eq suite-keyword test<imp>:suite:all.keyword)
           (dolist (each-suite test<imp>:suites)
             (let ((each-keyword (car each-suite)))
               (unless (eq each-keyword test<imp>:suite:all.keyword)
                 (dolist (file (test<imp>:suite//files.get each-keyword))
                   (when (not (member file files))
                     (push file files))))))
               ;; Reverse in case there's some interdependency...
               ;; TODO: Sort out dependencies using `test<imp>:suite//dependencies.get'?
               (setq files (nreverse files)))

          ;; Other tests: Get just the files for the test.
          (t
           (setq files (test<imp>:suite//files.get suite-keyword))))

    files))
;; (test<imp>:suite/files test<imp>:suite:all.name)
;; (test<imp>:suite/files "tree")
;; (test<imp>:suite/files :alist)
