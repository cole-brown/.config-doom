;; -*- no-byte-compile: t; -*-
;;; emacs/imp/test/suites.el

;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

;;------------------------------
;; Test Naming
;;------------------------------

;; ERT tests should be named according to this.
;; More specifically, they should be:
;;   test<SUITE-NAME>:<FUNC-NAME-MINUS-imp-OR-iii>
;; For example, the test for the `:tree' suite's `iii:node:add' should be named:
;;   test<tree>:node:add
(setq iii:test:suite/prefix-fmt "test<%s>:")

;; "Run All Tests" is special.
(setq iii:test:suite:all.name "[--all--]")
(setq iii:test:suite:all.keyword :all)


(setq iii:test:suite/all/regex
      (rx-to-string `(sequence line-start
                               ;; Test Suite Name Prefix
                               (group
                                "test<"
                                (one-or-more printing)
                                ">")
                               ;; Test Name
                               (one-or-more printing)
                               ;; Done
                               line-end)))


;;------------------------------
;; Files & Paths
;;------------------------------

(setq iii:test:path:root
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

(defun iii:test:path (relative)
  "Returns absolute path to RELATIVE file/directory by
prepending `iii:test:path:root'."
  (concat iii:test:path:root relative))
;; (iii:test:path "tree.el")
;; (iii:test:path "test/tree.el")


;;------------------------------
;; ERT Test Selector
;;------------------------------

(defun iii:test:suite/regex.create (suite-name)
  "Returns a regex based on `iii:test:suite/prefix-fmt' for finding ERT tests."
  (rx-to-string `(sequence line-start
                           (eval (format iii:test:suite/prefix-fmt suite-name))
                           (one-or-more printing)
                           line-end)))
;; (iii:test:suite/regex.create "tree")


;;------------------------------
;; Suite Name/Keyword
;;------------------------------

(defun iii:test:suite/name->keyword (suite-name)
  "Convert a suite name to a keyword symbol.

Handles the special 'all tests' string (currently '[--all--]') by returning
`:all'.

Other tests are just converted to a keyword: 'tree' -> `:tree'."
  (if (string= suite-name iii:test:suite:all.name)
      iii:test:suite:all.keyword
    (intern (concat ":" suite-name))))
;; (iii:test:suite/name->keyword iii:test:suite:all.name)
;; (iii:test:suite/name->keyword "tree")


(defun iii:test:suite/keyword->name (suite)
  "Convert a suite keyword to a string.

Handles the special 'all tests' keyword -> string; `:all' returns '[--all--]'."
  (if (eq suite iii:test:suite:all.keyword)
      iii:test:suite:all.name
    (string-remove-prefix ":" (symbol-name suite))))
;; (iii:test:suite/keyword->name iii:test:suite:all.keyword)
;; (iii:test:suite/keyword->name :tree)


;;------------------------------
;; Suite Creation
;;------------------------------

(defun iii:test:suite (suite-keyword depends-on-suites filepaths)
  "Helper to use if suite keyword is the same as the suite's prefix format,
which it should be...

Returns an alist of:
  - suite-keyword
  - A regex string for finding all of that suite's ERT test functions.
  - A list of suites this 'depends' on - that is a list of
    functionality that this test wants to already be working.
  - A list of file paths (relative to 'imp/' directory.
"
  (list suite-keyword
        (iii:test:suite/regex.create
         (string-remove-prefix ":" (symbol-name suite-keyword)))
        depends-on-suites
        filepaths))
;; (iii:test:suite :tree :alist '("tree.el" "test/tree.el"))


;;------------------------------------------------------------------------------
;;==============================================================================
;; TEST SUITES
;;==============================================================================
;;------------------------------------------------------------------------------

;;------------------------------
;; Always Load These!
;;------------------------------

;; Always load these regardless of test suite running.
;; Should be relative to "imp/" directory.
(setq iii:test:suites:files/load-always
      '("+debug.el"
        "error.el"))


;;------------------------------
;; The Test Suites Themselves
;;------------------------------

(setq iii:test:suites
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
             iii:test:suite/all/regex
             ;; No dependencies - it's running everything.
             nil
             ;; No list of files for all; it will generate from everyone else's.
             nil)

       ;;-----------------------------------------------------------------------
       ;; alist
       ;;-----------------------------------------------------------------------
       (iii:test:suite :alist
                       nil
                       '("alist.el"
                         "test/alist.el"))

       ;;-----------------------------------------------------------------------
       ;; tree
       ;;-----------------------------------------------------------------------
       (iii:test:suite :tree
                       :alist
                       '("path.el" ;; May consider moving path to defaults?
                         "tree.el"
                         "test/tree.el"))))


;;------------------------------
;; Suite Accessors
;;------------------------------

(defun iii:test:suite//regex.get (suite-keyword)
  "Returns the ERT test functions regex for the SUITE-KEYWORD."
  (nth 0 (alist-get suite-keyword iii:test:suites)))
;; (iii:test:suite//regex.get :tree)


(defun iii:test:suite//dependencies.get (suite-keyword)
  "Returns the dependencies list for the SUITE-KEYWORD."
  (nth 1 (alist-get suite-keyword iii:test:suites)))
;; (iii:test:suite//dependencies.get :tree)


(defun iii:test:suite//files.get (suite-keyword)
  "Returns the files list for the SUITE-KEYWORD."
  (nth 2 (alist-get suite-keyword iii:test:suites)))
;; (iii:test:suite//files.get :tree)


;;------------------------------
;; All Registered Suites
;;------------------------------

(defun iii:test:suite//get-all-names ()
  "Returns a list of the test suite names from `iii:test:suites'."
  (mapcar
   (lambda (suite)
     "Convert suite keyword to a name string."
     (iii:test:suite/keyword->name (car suite)))
   iii:test:suites))
;; (iii:test:suite//get-all-names)


(defun iii:test:suite//get-all-keywords ()
  "Returns a list of the test suite keywords from `iii:test:suites'."
  (mapcar #'car iii:test:suites))
;; (iii:test:suite//get-all-keywords)


;;------------------------------
;; Suite Files
;;------------------------------

(defun iii:test:suite/files (suite-name-or-keyword)
  "Returns the files to load for SUITE-NAME-OR-KEYWORD.

Does /not/ include `iii:test:suites:files/load-always'."
  (let* ((suite-keyword (if (keywordp suite-name-or-keyword)
                            suite-name-or-keyword
                          (iii:test:suite/name->keyword suite-name-or-keyword)))
         files)
    (cond ((not (memq suite-keyword (iii:test:suite/keywords)))
           (error "Invalid suite '%S'; valid choices are: %S or %S"
                  suite-name-or-keyword
                  (iii:test:suite/keywords)
                  (iii:test:suite/names)))

          ;; "All" has null files - need to return the sum of everyone else's.
          ((eq suite-keyword iii:test:suite:all.keyword)
           (dolist (each-suite iii:test:suites)
             (let ((each-keyword (car each-suite)))
               (unless (eq each-keyword iii:test:suite:all.keyword)
                 (dolist (file (iii:test:suite//files.get each-keyword))
                   (when (not (member file files))
                     (push file files))))))
               ;; Reverse in case there's some interdependency...
               ;; TODO: Sort out dependencies using `iii:test:suite//dependencies.get'?
               (setq files (nreverse files)))

          ;; Other tests: Get just the files for the test.
          (t
           (setq files (iii:test:suite//files.get suite-keyword))))

    files))
;; (iii:test:suite/files iii:test:suite:all.name)
;; (iii:test:suite/files "tree")
