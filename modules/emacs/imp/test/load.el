;; -*- no-byte-compile: t; lexical-binding: t; -*-
;; -*- no-byte-compile: t; -*-
;;; emacs/imp/test/load.el


;;------------------------------------------------------------------------------
;; Test Requirements
;;------------------------------------------------------------------------------

(load! "base.el")

(load! "../feature.el")
(load! "../alist.el")
(load! "../tree.el")
(load! "../path.el")
(load! "../+timing.el")
(load! "../provide")
(load! "../load.el")


;;------------------------------------------------------------------------------
;; Test Debugging Helpers
;;------------------------------------------------------------------------------

(defvar test<imp/load>:test:root (test<imp>:path/dir:this)
  "This file's directory.")

(defvar test<imp/load>:loading:root (imp:path:join (test<imp>:path/dir:this)
                                                   "loading")
  "The \"root\" directory for our 'imp/test/loading/load.el' file.")


(defvar test<imp/load>:loading:feature :loading
  "The feature name for our 'imp/test/loading/' files.")


(defvar test<imp/load>:loading:load:file "load"
  "The \"root\" filename (or filepath) for our 'imp/test/loading/load.el' file.")


(defvar test<imp/load>:loading:load:feature '(:loading load)
  "The feature name for our 'imp/test/loading/load.el' file.")


(defvar test<imp/load>:loading:dont-load:file "dont-load"
  "The \"root\" filename (or filepath) for our 'imp/test/loading/dont-load.el' file.")


(defvar test<imp/load>:loading:dont-load:feature '(:loading dont-load)
  "The feature name for our 'imp/test/loading/dont-load.el' file.")


(defvar test<imp/load>:loading:doesnt-exist:feature '(:loading doesnt-exist)
  "A feature name for 'imp/test/loading/doesnt-exist.el', which doesn't exist.")


(defvar test<imp/load>:loading:doesnt-exist:file "doesnt-exist"
  "A file name for 'imp/test/loading/doesnt-exist.el', which doesn't exist.")


;;------------------------------
;; Set-Up / Tear-Down
;;------------------------------

(defun test<imp/load>:setup:vars ()
  "Deletes variable from 'test/loading/*.el' files."
  ;; These are fine to do even if they already don't exist.
  (makunbound 'test<imp>:file:loading?)
  (makunbound 'test<imp>:loading:load:loaded)
  (makunbound 'test<imp>:loading:dont-load:loaded))


;; ╔═════════════════════════════╤═══════════╤═════════════════════════════════╗
;; ╟─────────────────────────────┤ ERT TESTS ├─────────────────────────────────╢
;; ╠══════════╤══════════════════╧═══════════╧══════════════════╤══════════════╣
;; ╟──────────┤ Because Emacs needs to give Alists some love... ├──────────────╢
;; ╚══════════╧═════════════════════════════════════════════════╧══════════════╝


;;------------------------------------------------------------------------------
;; Tests: Imp Load Functions
;;------------------------------------------------------------------------------

;;------------------------------
;; int<imp>:load:file
;;------------------------------
;; Is just a wrapper around `load'; testing other `:imp/load' functions will test
;; this fine (until we encounter a bug in this function, I guess).


;;------------------------------
;; int<imp>:load
;;------------------------------

(ert-deftest test<imp/load>::int<imp>:load ()
  "Test that `int<imp>:load' behaves appropriately."
  (test<imp>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<imp/load>::int<imp>:load"
      nil
      nil

    ;;===
    ;; Run the test.
    ;;===

    (test<imp/load>:setup:vars)
    (should-error test<imp>:file:loading?)
    (should-error test<imp>:loading:load:loaded)
    (should-error test<imp>:loading:dont-load:loaded)

    ;;------------------------------
    ;; Load feature & root.
    ;;------------------------------

    ;;---
    ;; Supply a root:
    ;;---
    ;; For testing that it can load something it knows about but that hasn't been loaded yet.
    (imp:path:root test<imp/load>:loading:feature
                   test<imp/load>:loading:root)

    ;;---
    ;; Load a feature:
    ;;---
    ;; For testing that nothing happens when it's already loaded.

    ;;---
    ;; Set up variables:
    ;;---
    ;; First, set these variable to `nil' so they exist.
    (setq test<imp>:loading:load:loaded      nil  ;; If 'test/loading/load.el' is loaded, it will be set to `t'.
          test<imp>:loading:dont-load:loaded nil) ;; If 'test/loading/dont-load.el' is loaded, it will be set to `t'.

    ;;------------------------------
    ;; Load:
    ;;------------------------------

    ;;---
    ;; If feature is alredy loaded, nothing should happen.
    ;;---
    (should-not test<imp>:loading:dont-load:loaded)
    ;; Call `int<imp>:load on it's feature; shouldn't be loaded since we've loaded it already.
    (should (apply #'int<imp>:load
                     test<imp/load>:loading:dont-load:feature))
    (should-not test<imp>:loading:dont-load:loaded)

    ;;---
    ;; If we know the base feature, we should be able to load the file by the feature name.
    ;;---
    (should-not test<imp>:loading:load:loaded)
    (should (apply #'int<imp>:load
                     test<imp/load>:loading:load:feature))
    (should test<imp>:loading:load:loaded)
    (should test<imp>:file:loading?)

    ;;------------------------------
    ;; Errors:
    ;;------------------------------

    ;;---
    ;; Know the base feature, but can't find anything to load.
    ;;---
    (should-error test<imp>:loading:load:doesnt-exist)
    (should-error (apply #'int<imp>:load
                           test<imp/load>:loading:doesnt-exist:feature))
    (should-error test<imp>:loading:load:doesnt-exist)

    ;;---
    ;; Don't know the base feature.
    ;;---
    ;; We fallback to asking Emacs to `load' it, but it doesn't know anything about this either.
    ;; This won't error; it'll just return nil.
    (should-not (int<imp>:load 'something-that-doesnt-exist-in-emacs))))


;;------------------------------
;; int<imp>:load:paths
;;------------------------------

(ert-deftest test<imp/load>::int<imp>:load:paths ()
  "Test that `int<imp>:load:paths' behaves appropriately."
  (test<imp>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<imp/load>::int<imp>:load:paths"
      nil
      nil

    ;;===
    ;; Run the test.
    ;;===

    (test<imp/load>:setup:vars)
    (should-error test<imp>:file:loading?)
    (should-error test<imp>:loading:load:loaded)
    (should-error test<imp>:loading:dont-load:loaded)

    ;;------------------------------
    ;; Load feature & root.
    ;;------------------------------

    ;;---
    ;; +Supply a root:+
    ;;---
    ;; `int<imp>:load:path' doesn't care about features or `imp:path:roots';
    ;; everything is supplied in the params.

    ;;---
    ;; Load a feature:
    ;;---
    ;; Unlike `int<imp>:load', `int<imp>:load:paths' does not care about
    ;; provided features and will load regardless, and we'll test for that.
    (apply #'imp:provide test<imp/load>:loading:dont-load:feature)

    ;;---
    ;; Set up variables:
    ;;---
    ;; First, set these variable to `nil' so they exist.
    (setq test<imp>:loading:load:loaded      nil  ;; If 'test/loading/load.el' is loaded, it will be set to `t'.
          test<imp>:loading:dont-load:loaded nil) ;; If 'test/loading/dont-load.el' is loaded, it will be set to `t'.

    ;;------------------------------
    ;; Load:
    ;;------------------------------

    ;;---
    ;; If feature is alredy provided, I don't care - load it again.
    ;;---
    (should-not test<imp>:loading:dont-load:loaded)
    (should (file-exists-p (imp:path:join test<imp/load>:loading:root
                                          (concat test<imp/load>:loading:dont-load:file ".el"))))
    ;; Call `int<imp>:load:paths on it's feature; should now be be loaded.
    (should (int<imp>:load:paths test<imp/load>:loading:dont-load:feature
                                 test<imp/load>:loading:root
                                 (list test<imp/load>:loading:dont-load:file)))
    (should test<imp>:loading:dont-load:loaded)

    ;;---
    ;; If feature is not provided, also don't care - load it.
    ;;---
    (should-not test<imp>:loading:load:loaded)
    (should (int<imp>:load:paths test<imp/load>:loading:load:feature
                                 test<imp/load>:loading:root
                                 (list test<imp/load>:loading:load:file)))
    (should test<imp>:loading:load:loaded)

    ;;------------------------------
    ;; Errors:
    ;;------------------------------

    ;;---
    ;; Can't find the file to load.
    ;;---
    (should-error test<imp>:loading:load:doesnt-exist)
    (should-not (file-exists-p (imp:path:join test<imp/load>:loading:root
                                              test<imp/load>:loading:doesnt-exist:file)))
    (should-error (int<imp>:load:paths test<imp/load>:loading:load:feature
                                       test<imp/load>:loading:root
                                       (list test<imp/load>:loading:doesnt-exist:file)))
    (should-error test<imp>:loading:load:doesnt-exist)))


;;------------------------------
;; int<imp>:load:parse
;;------------------------------

;;---
;; Test Helper:
;;---
(defun test<imp/load>::helper::int<imp>:load:parse (test-name marker-name in expected)
  "Helper for testing `int<imp>:load:parse'.

MARKER-NAME should be a string for marking this sub-test.

IN should be a plist with keys:
  Required:
    - `:feature', `:filename', `:path'
  Optional:
    - `:error'
EXPECTED should be a plist with keys:
  `:feature', `:path'
    - `:error' is figured out based on IN plist's `:error' (or lack thereof)."
  (declare (indent 2))
  (test<imp>:should:marker test-name marker-name)

  (let* (;;---
         ;; Input Values for plist:
         ;;---
         (in:feature  (plist-get in :feature))  ;; symbol or list-of-symbols
         (in:filename (plist-get in :filename)) ;; string or `nil'
         (in:path     (plist-get in :path))     ;; string or `nil'
         (in:error    (plist-get in :error))    ;; `nil', `t', or don't supply in `plist'.
         ;;---
         ;; Inputs:
         ;;---
         (in:plist (list :feature  in:feature
                         :filename in:filename
                         :path     in:path
                         :error    in:error))
         (plist-symbol-name "in:plist")
         (path:current-dir test<imp/load>:test:root) ;; Used if path & filename are relative.
         ;;---
         ;; Expected Outputs:
         ;;---
         (out:expected:feature (plist-get expected :feature)) ;; Always a list-of-symbols.
         (out:supplied:path    (plist-get expected :path))
         (out:expected:path    (if (file-name-absolute-p out:supplied:path) ;; Always should be an absolute path.
                                   out:supplied:path
                                 (imp:path:join path:current-dir out:supplied:path)))
         (out:expected:error   (if (memq :error in:plist) ;; `in:error' if provided, else default is `t'.
                                   in:error
                                 t))
         (out:expected:keys    '(:path :feature :error))  ;; These keys (and no others) should be in `out:plist'.
         ;;---
         ;; Output:
         ;;---
         out:plist
         out:plist:feature
         out:plist:path
         out:plist:error
         out:plist:keys) ;; Found keys in `out:plist' go here to make sure we find all of them.

    ;;---
    ;; Shouldn't error.
    ;;---
    (setq out:plist (int<imp>:load:parse test-name
                                         path:current-dir
                                         plist-symbol-name
                                         in:plist))

    ;;---
    ;; Validate `out:plist'.
    ;;---
    (test<imp>:should:marker:small "Validate `out:plist'")

    ;; Should have valid output.
    (should out:plist)
    (should (listp out:plist))
    ;; A plist should have matching pairs of keys and values.
    (should (= 0
               (% (length out:plist) 2)))
    ;; A plist should have keywords as keys.
    (let ((loop-list in:plist)
          keys
          key
          value
          exists:path-or-filename)
      ;; Check plist keys & values.
      (while loop-list
        (setq key       (car loop-list)
              value     (cadr loop-list)
              loop-list (cddr loop-list))
        (test<imp>:should:marker:small (format "Validate key `%S'" key))

        (should (keywordp key))
        (push key out:plist:keys)
        ;; Check key is valid and key's value exists (if possible).
        (cond
         ;; `:feature' must be provided.
         ((eq key :feature)
          ;;
          (should value))

         ;; `:path' or `:filename' must be provided.
         ((memq key '(:path :filename))
          ;; Just checking that at least one exists right now.
          (setq exists:path-or-filename (or exists:path-or-filename
                                            (not (null key)))))

         ;; `:error' is an optional boolean.
         ((eq key :error)
          ;; Doesn't even have to exist so good for you.
          t)

         (t
          (should-not
           (format (concat "test<imp/load>::helper::int<imp>:load:parse:"
                           "unknown input key: %S")
                   key)))))

      (should exists:path-or-filename)

      ;; Did we find every expected key in the output and no unexpected?
      (should-not (seq-difference out:expected:keys out:plist:keys)))

    ;;---
    ;; Validate output values.
    ;;---
    (setq out:plist:feature (plist-get out:plist :feature)
          out:plist:path    (plist-get out:plist :path)
          out:plist:error   (plist-get out:plist :error))

    ;; `:feature'
    ;;---
    (should out:plist:feature)
    ;; `out:plist:feature' should always be a list of symbols.
    (should (listp out:plist:feature))
    ;; Does `out:plist:feature' match expected?
    ;; Must have correct symbols in correct order.
    (should (equal out:expected:feature
                   out:plist:feature))

    ;; `:path'
    ;;---
    (should out:plist:path)
    (should (stringp out:plist:path))
    (should (string= out:expected:path
                     out:plist:path))

    ;; `:error'
    ;;---
    ;; (should out:plist:error) ;; No; can be `nil'.
    (should (booleanp out:plist:error))
    (should (eq out:expected:error
                out:plist:error)))

  "[OK]")

;;---
;; Tests:
;;---

(ert-deftest test<imp/load>::int<imp>:load:parse ()
  "Test that `int<imp>:load:parse' behaves appropriately."
  (test<imp>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<imp/load>::int<imp>:load:parse"
      nil
      nil

    ;;===
    ;; Run the test.
    ;;===

    ;;------------------------------
    ;; Valid Parses.
    ;;------------------------------
    ;; Supply all.
    ;;   `:filename' nil
    ;;   `:error'    nil
    (test<imp/load>::helper::int<imp>:load:parse
        test-name
        "filename-nil-and-error-nil"
      ;; Inputs:
      (list :feature  :test ;; symbol or list-of-symbols
            :filename nil   ;; string or `nil'
            :path     "path/relative/file.el" ;; string or `nil'
            :error    nil   ;; `nil', `t', or don't supply at all.
            )
      ;; Expected Outputs:
      (list :feature '(:test) ;; Always a list-of-symbols.
            :path    "path/relative/file.el" ;; Helper will make this an absolute path if it is relative.
            ))

    ;; Supply all.
    ;;   `:error'    nil
    (test<imp/load>::helper::int<imp>:load:parse
        test-name
        "error-nil"
      ;; Inputs:
      (list :feature  :test ;; symbol or list-of-symbols
            :filename "file.el"   ;; string or `nil'
            :path     "path/relative" ;; string or `nil'
            :error    nil   ;; `nil', `t', or don't supply at all.
            )
      ;; Expected Outputs:
      (list :feature '(:test) ;; Always a list-of-symbols.
            :path    "path/relative/file.el" ;; Always absolute path.
            ))

    ;; Do not supply `:error'.
    (test<imp/load>::helper::int<imp>:load:parse
        test-name
        "error-dne"
      ;; Inputs:
      (list :feature  :test ;; symbol or list-of-symbols
            :filename "file.el"   ;; string or `nil'
            :path     "path/relative" ;; string or `nil')
            )
      ;; Expected Outputs:
      (list :feature '(:test) ;; Always a list-of-symbols.
            :path    "path/relative/file.el" ;; Always absolute path.
            ))

    ;;------------------------------
    ;; Errors:
    ;;------------------------------
    ;; Invalid input list (not a plist).
    (should-error (int<imp>:load:parse test-name
                                       test<imp/load>:test:root
                                       "in:plist"
                                       nil))
    (should-error (int<imp>:load:parse test-name
                                       test<imp/load>:test:root
                                       "in:plist"
                                       '(42)))
    (should-error (int<imp>:load:parse test-name
                                       test<imp/load>:test:root
                                       "in:plist"
                                       '(:filename "hello" :path)))

    ;; Unknown key in input plist.
    (should-error (int<imp>:load:parse test-name
                                       test<imp/load>:test:root
                                       "in:plist"
                                       '(:feature :greeting
                                         :filename "hello"
                                         :path "path/to"
                                         :jeff t)))


    ;; Duplicate key in input plist.
    (should-error (int<imp>:load:parse test-name
                                       test<imp/load>:test:root
                                       "in:plist"
                                       '(:feature :greeting
                                         :filename "hello"
                                         :path "path/to"
                                         :feature :greeting)))

    ;; No path in plist and no path:current-dir.
    (should-error (int<imp>:load:parse test-name
                                       nil
                                       "in:plist"
                                       '(:feature :greeting
                                         :filename "hello")))))



;; TODO:
;; imp:load
