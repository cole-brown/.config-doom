;; -*- no-byte-compile: t; lexical-binding: t; -*-
;;; emacs/imp/test/tree.el


;;------------------------------------------------------------------------------
;; Tests: Predicates
;;------------------------------------------------------------------------------

;;------------------------------
;; int<imp/tree>:node?
;;------------------------------
(ert-deftest test<imp/tree>:node? ()
  "Tests that the `int<imp/tree>:node?' predicate functions correctly."
  ;;---
  ;; Not node or tree - false.
  ;;---
  (should (equal (int<imp/tree>:node? nil)
                 nil))
  (should (equal (int<imp/tree>:node? :root)
                 nil))

  ;;---
  ;; A node - true.
  ;;---
  (should (equal (int<imp/tree>:node? '(:root))
                 t))

  ;;---
  ;; A tree - false.
  ;;---
  (should (equal (int<imp/tree>:node? '((:root)))
                 nil)))


;;------------------------------
;; int<imp/tree>:tree?
;;------------------------------
(ert-deftest test<imp/tree>:tree? ()
  "Tests that the `int<imp/tree>:tree?' predicate functions correctly."
  ;;---
  ;; Not node or tree - false.
  ;;---
  (should (equal (int<imp/tree>:tree? nil)
                 nil))
  (should (equal (int<imp/tree>:tree? :root)
                 nil))

  ;;---
  ;; A node - false.
  ;;---
  (should (equal (int<imp/tree>:tree? '(:root))
                 nil))

  ;;---
  ;; A tree - true/false depending on if all children are nodes.
  ;;---
  (should (equal (int<imp/tree>:tree? '((:root)))
                 t))
  ;; Currently only checks direct children, so this is true.
  (should (equal (int<imp/tree>:tree? '((:root (:one (:two))) (:boo (:a :b :c))))
                 t)))


;;------------------------------
;; int<imp/tree>:chain?
;;------------------------------
(ert-deftest test<imp/tree>:chain? ()
  "Tests that the `int<imp/tree>:chain?' predicate functions correctly."
  ;;---
  ;; Just a symbol - false.
  ;;---
  (should (equal (int<imp/tree>:chain? :root)
                 nil))
  (should (equal (int<imp/tree>:chain? 'root)
                 nil))

  ;;---
  ;; A list (don't care about rooted) - true.
  ;;---
  (should (equal (int<imp/tree>:chain? '(:root))
                 t))
  (should (equal (int<imp/tree>:chain? '(root))
                 t))
  (should (equal (int<imp/tree>:chain? '(:root :beer root beer))
                 t))

  ;;---
  ;; A list (/do/ care about rooted) - depends.
  ;;---
  (should (equal (int<imp/tree>:chain? '(:root) t)
                 t))
  (should (equal (int<imp/tree>:chain? '(root) t)
                 nil))
  (should (equal (int<imp/tree>:chain? '(:root :beer root beer) t)
                 t))
  (should (equal (int<imp/tree>:chain? '(root beer :root :beer) t)
                 nil)))


;;------------------------------
;; int<imp/tree>:key/exists?
;;------------------------------
(ert-deftest test<imp/tree>:key/exists? ()
  "Tests that the `int<imp/tree>:key/exists?' predicate functions correctly."
  (let ((tree '((:root1) (:root0 (:one (:two (:leaf)))))))
    ;;---
    ;; TODO: Test `int<imp/tree>:key/exists?'.
    ;;---
    (should (equal t
                   nil))
    ))




;; TODO: More tests.
;;   - `int<imp>:tree:contains?'
;;   - Whatever other functions are missing from here.
