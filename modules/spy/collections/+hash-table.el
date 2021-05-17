;;; spy/collections/hash-table.el -*- lexical-binding: t; -*-

;;------------------------------------------------------------------------------
;; String Key Hash Tables
;;------------------------------------------------------------------------------

(defun sss:hash-table/test/string=/cmp (a b)
  "Compare strings (ignoring case) for `spy:hash-table/test/string='.
"
  ;; `compare-strings' returns t or integer.
  ;; Convert that to a bool t/nil.
  (eq t
      ;; Compare the strings, ignoring case.
      (compare-strings a nil nil b nil nil t)))


(defun sss:hash-table/test/string=/hash (key)
  "Get a hashed value for the (lowercased) key for
`jerky//repo.test.string='.
"
  (sxhash-equal (downcase key)))


;; String comparison, ignores case.
(define-hash-table-test 'spy:hash-table/test/string=
  'sss:hash-table/test/string=/cmp
  'sss:hash-table/test/string=/hash)


(defun spy:hash-table/string/make (&optional params-plist)
  "Creates a hash-table with optional PARAMS-PLIST.

See `make-hash-table' for acceptable params. This defaults to:
  :test 'spy:hash-table/test/string=
  :weakness nil

NOTE: if anything is provided in PARAMS-PLIST, no defaults are used. So provide
\":test 'spy:hash-table/test/string=\" or another string-compatible test."
  (let ((params (or params-plist
                    (list :test 'spy:hash-table/test/string=
                          :weakness nil))))
    (make-hash-table params)))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(spy:provide :spy 'collections 'hash-table)
