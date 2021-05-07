;; -*- no-byte-compile: t; -*-
;;; emacs/imp/test/tree.el

;;------------------------------------------------------------------------------
;; Set-Up
;;------------------------------------------------------------------------------

(let* ((dir-test (dir!))
       (testing "../tree.el")
       (requirements (list "../+debug.el"
                           "../error.el"
                           "../path.el"
                           testing)))
  (dolist (file requirements)
    (let ((path (iii:path:join dir-test file)))
      (load-file path))))


;;------------------------------------------------------------------------------
;; Tests: Predicates
;;------------------------------------------------------------------------------

;;------------------------------
;; iii:node?
;;------------------------------
(ert-deftest test:node? ()
  "Tests that the `iii:node?' predicate functions correctly."
  ;;---
  ;; Not node or tree - false.
  ;;---
  (should (equal (iii:node? nil)
                 nil))
  (should (equal (iii:node? :root)
                 nil))

  ;;---
  ;; A node - true.
  ;;---
  (should (equal (iii:node? '(:root))
                 t))

  ;;---
  ;; A tree - false.
  ;;---
  (should (equal (iii:node? '((:root)))
                 nil)))


;;------------------------------
;; iii:tree?
;;------------------------------
(ert-deftest test:tree? ()
  "Tests that the `iii:tree?' predicate functions correctly."
  ;;---
  ;; Not node or tree - false.
  ;;---
  (should (equal (iii:tree? nil)
                 nil))
  (should (equal (iii:tree? :root)
                 nil))

  ;;---
  ;; A node - false.
  ;;---
  (should (equal (iii:tree? '(:root))
                 nil))

  ;;---
  ;; A tree - true/false depending on if all children are nodes.
  ;;---
  (should (equal (iii:tree? '((:root)))
                 t))
  ;; Currently only checks direct children, so this is true.
  (should (equal (iii:tree? '((:root (:one (:two))) (:boo (:a :b :c))))
                 t)))


;;------------------------------
;; iii:chain?
;;------------------------------
(ert-deftest test:chain? ()
  "Tests that the `iii:chain?' predicate functions correctly."
  ;;---
  ;; Just a symbol - false.
  ;;---
  (should (equal (iii:chain? :root)
                 nil))
  (should (equal (iii:chain? 'root)
                 nil))

  ;;---
  ;; A list (don't care about rooted) - true.
  ;;---
  (should (equal (iii:chain? '(:root))
                 t))
  (should (equal (iii:chain? '(root))
                 t))
  (should (equal (iii:chain? '(:root :beer root beer))
                 t))

  ;;---
  ;; A list (/do/ care about rooted) - depends.
  ;;---
  (should (equal (iii:chain? '(:root) t)
                 t))
  (should (equal (iii:chain? '(root) t)
                 nil))
  (should (equal (iii:chain? '(:root :beer root beer) t)
                 t))
  (should (equal (iii:chain? '(root beer :root :beer) t)
                 nil)))


;;------------------------------------------------------------------------------
;; Tests: Nodes
;;------------------------------------------------------------------------------

;;------------------------------
;; iii:node:create
;;------------------------------
(ert-deftest test:node:create ()
  "Tests that `iii:node:create' creates a node correctly."
  ;;---
  ;; No children.
  ;;---
  (should (equal
           (iii:node:create :root)
           ;; Node with no children is just a list of that node's name.
           '(:root)))

  ;;---
  ;; Error case: One simple child.
  ;;   - Children must always be a list.
  ;;---
  (should-error (equal
                 (iii:node:create :root :child)
                 '(:root :child)))

  ;;---
  ;; One simple child - not actually a valid tree per-say as result is not an
  ;; alist of children.
  ;;---
  ;; TODO: should-error?
  (should (equal
           (iii:node:create :root '(:child))
           '(:root :child)))

  ;;---
  ;; A node, with a simple tree of children.
  ;;---
  (should (equal
           (iii:node:create :root
                            (list (iii:node:create :child-0)
                                  (iii:node:create :child-1)))
           '(:root (:child-0) (:child-1)))))


;;------------------------------
;; iii:node:get
;;------------------------------
(ert-deftest test:node:get ()
  "Tests that `iii:node:get' gets a child correctly from a tree."
  ;;---
  ;; Not a tree -> error
  ;;---
  (should-error (iii:node:get :root :one))
  (should-error (iii:node:get '(:root) :one))
  (should-error (iii:node:get (iii:node:create :root) :root))

  ;;---
  ;; No children = nil
  ;;---
  (let ((tree (iii:node:tree (iii:node:create :root))))
    (should (equal (iii:node:get tree :one)
                   nil))
    (should (equal (iii:node:get tree nil)
                   nil)))

  ;;---
  ;; Children
  ;;---
  (let ((tree '((:root (:one (:two (:three (:four))))))))
    ;; `:root' is the only child, so that will work, others will return nil.
    (should (equal (iii:node:get tree :root)
                   ;; Result is `assoc' of `:root'.
                   '(:root (:one (:two (:three (:four)))))))
    (should (equal (iii:node:get tree :one)
                   nil))))


;;------------------------------
;; iii:node:name
;;------------------------------
(ert-deftest test:node:name ()
  "Tests that `iii:node:name' gets the name of the node correctly from
the node."
  ;;---
  ;; No node = no name.
  ;;---
  (should (equal (iii:node:name nil)
                 nil))
  (should (equal (iii:node:name '())
                 nil))

  ;;---
  ;; Simple node.
  ;;---
  (should (equal (iii:node:name (iii:node:create :root))
                 :root))

  ;;---
  ;; Node with children.
  ;;---
  (should (equal (iii:node:name '(:root (:one (:two (:three (:four))))))
                 :root)))


;;------------------------------
;; iii:node:children
;;------------------------------
(ert-deftest test:node:children ()
  "Tests that `iii:node:children' gets the children alist correctly from a
node."
  ;;---
  ;; No children = nil
  ;;---
  (should (equal (iii:node:children (iii:node:create :root))
                 nil))

  ;;---
  ;; Children = alist
  ;;---
  (let ((tree '(:root (:one (:two (:three (:four)))))))
    ;; `:one' is the only child, so we should get an alist with only that in it.
    (should-not (null (iii:node:children tree)))
    (should (equal (iii:node:children tree)
                   '((:one (:two (:three (:four)))))))))


;;------------------------------
;; iii:node:add
;;------------------------------
(ert-deftest test:node:add ()
  "Tests that `iii:node:add' adds a node correctly to an existing node's children."
  (let* ((children (list (iii:node:create :child-0)
                         (iii:node:create :child-1)))
         (parent (iii:node:create :root
                                  (list (iii:node:create :child-0)
                                        (iii:node:create :child-1))))
         (new (iii:node:create :child-2))
         (expected (iii:node:create :root (list (iii:node:create :child-0)
                                                (iii:node:create :child-1)
                                                (iii:node:create :child-2)))))
    (should (equal (iii:node:add parent new)
                   expected))))


;;------------------------------
;; iii:node:update
;;------------------------------
(ert-deftest test:node:update ()
  "Tests that `iii:node:update' updates a node correctly with a new child."
  ;;---
  ;; Non-pre-existing new - same result as just `iii:node:add'.
  ;;---
  (let* ((children (list (iii:node:create :child-0)
                         (iii:node:create :child-1)))
         (parent (iii:node:create :root
                                  children))
         (new (iii:node:create :child-2))
         (expected (iii:node:add parent new)))
    (iii:debug "TEST:NODE:UPDATE" "<TEST>")
    (should (equal (iii:node:update parent new)
                   expected)))
    (iii:debug "TEST:NODE:UPDATE" "</TEST>")

  ;;---
  ;; Pre-existing new - existing gone; replaced with the new one.
  ;;---
  (let* ((children (list
                    (iii:node:create :child-0)
                    (iii:node:create :child-1)
                    (iii:node:create :child-2
                                     (list
                                      (iii:node:create :c2-child-0)))))
         (parent (iii:node:create :root
                                  children))
         ;; New one has no kids of its own.
         (new (iii:node:create :child-2))
         (expected-children (list (iii:node:create :child-0)
                                  (iii:node:create :child-1)
                                  (iii:node:create :child-2)))
         (expected (iii:node:create :root
                                    expected-children)))
    (iii:debug "TEST:NODE:UPDATE" "<TEST>")
    (should (equal (iii:node:update parent new)
                   expected))
    (iii:debug "TEST:NODE:UPDATE" "orig parent: %S" parent)
    (iii:debug "TEST:NODE:UPDATE" "</TEST>")))


;;------------------------------
;; iii:node:tree
;;------------------------------
(ert-deftest test:node:tree ()
  "Test that `iii:node:tree' creates a tree from a supplied node."
  ;;---
  ;; Not a node -> error.
  ;;---
  (should-error (iii:node:tree :root))

  ;;---
  ;; Node -> Tree.
  ;;---
  (let ((node (iii:node:create :root)))
    (should (iii:node? node))
    (should-not (iii:tree? node))
    (should (iii:tree? (iii:node:tree node)))))


;;------------------------------------------------------------------------------
;; Tests: Chains
;;------------------------------------------------------------------------------


;;------------------------------
;; iii:node:chain:create
;;------------------------------
(ert-deftest test:node:chain:create ()
  "Tests that `iii:node:chain:create' creates a node w/ a tree of children
from a chain of node names."
  ;;---
  ;; Not-a-chain -> Error
  ;;---
  (should-error (iii:node:chain:create :root :one))

  ;;---
  ;; No chain = create just the node.
  ;;---
  (should (equal
           (iii:node:chain:create :root)
           '(:root)))
  (should (equal
           (iii:node:chain:create :root)
           (iii:node:create :root)))
  (should (equal
           (iii:node:chain:create :root nil)
           (iii:node:create :root)))

  ;;---
  ;; With chain = create node w/ child, which is alist of alist of...
  ;;---
  (should-not (equal (iii:node:chain:create :root '(:one :two :three :four))
                     nil))
  (should (equal (car (iii:node:chain:create :root '(:one :two :three :four)))
                 :root))
  (should (equal (cdr (iii:node:chain:create :root '(:one :two :three :four)))
                 '((:one (:two (:three (:four)))))))

  ;; `iii:node:chain:create' should have as child: an alist of alist of...
  (let* ((result (iii:node:chain:create :root '(:one :two :three :four)))
         (children (cdr result)))
    (should (equal (alist-get :one children)
                   '((:two (:three (:four))))))
    (should (equal (alist-get :two
                              (alist-get :one children))
                   '((:three (:four)))))
    (should (equal (alist-get :three
                              (alist-get :two
                                         (alist-get :one children)))
                   '((:four))))
    (should (equal (alist-get :four
                              (alist-get :three
                                         (alist-get :two
                                                    (alist-get :one children))))
                   nil))))


;;------------------------------
;; iii:tree:update
;;------------------------------
(ert-deftest test:tree:update ()
  "Tests that `iii:tree:update' updates and returns a tree, as intended."
  ;; TODO: test this!
  (should (equal t nil)
  )


;;------------------------------
;; iii:tree:chain:get
;;------------------------------
(ert-deftest test:tree:chain:get ()
  "Tests that `iii:tree:chain:get' returns a tree node or nil, as intended."
  (let* ((node (iii:node:chain:create :root '(:one :two :three :four)))
         (tree (iii:node:tree node)))
    ;;---
    ;; Invalid chain -> error!
    ;;---
    (should-error (iii:tree:chain:get tree nil))
    (should-error (iii:tree:chain:get tree :root))

    ;;---
    ;; Invalid tree -> error!
    ;;---
    ;; Give it a `node' instead of a `tree'.
    (should-error (iii:tree:chain:get node '(:one :two)))

    ;;---
    ;; No `:root' in chain - get back full tree and full chain.
    ;;---
    (let ((chain '(:one :two)))
      (should (equal (iii:tree:chain:get tree '(:one :two))
                     (list tree chain))))

    ;;---
    ;; Entire chain in tree - get back subtree and nil.
    ;;---
    (should (equal (iii:tree:chain:get tree '(:root :one :two))
                   '(((:three (:four))) nil))))

  ;;------------------------------
  ;; `iii:tree:chain:create' bug check
  ;;------------------------------
  (let* ((tree (iii:node:tree (iii:node:chain:create :root '(:one :two :three :four))))
         (chain '(:root :one :two :three :fore)))
    (iii:debug "TEST:TREE:CHAIN:CREATE" "<TEST name=\"bug: `:fore'\">")
    (should (equal (iii:tree:chain:get tree chain)
                   '(((:four)) (:fore))))
    (iii:debug "TEST:TREE:CHAIN:CREATE" "</TEST name=\"bug: `:fore'\">"))


;;------------------------------
;; iii:tree:chain:create
;;------------------------------
(ert-deftest test:tree:chain:create ()
  "Test that `iii:tree:chain:create' walks a tree following the chain until it
can create a new leaf node w/ remaining links in the chain."
  ;;---
  ;; Error cases.
  ;;---


  (let ((tree (iii:node:tree (iii:node:chain:create :root '(:one :two :three :four)))))
    (iii:debug "TEST:TREE:CHAIN:CREATE" "<TEST name='null tree'>")
    (should-not (null tree))
    (iii:debug "TEST:TREE:CHAIN:CREATE" "</TEST name='null tree'>")

    ;;---
    ;; No chain - error.
    ;;---
    (iii:debug "TEST:TREE:CHAIN:CREATE" "<TEST name='chain error'>")
    (should-error (iii:tree:chain:create tree nil))
    (iii:debug "TEST:TREE:CHAIN:CREATE" "</TEST name='chain error'>")

    ;;---
    ;; Existing chain - error.
    ;;---
    (iii:debug "TEST:TREE:CHAIN:CREATE" "<TEST name='tree error' number=00>")
    (should-error (iii:tree:chain:create tree '(:root :one :two)))
    (iii:debug "TEST:TREE:CHAIN:CREATE" "</TEST name='tree error' number=00>")
    (iii:debug "TEST:TREE:CHAIN:CREATE" "<TEST name='tree error' number=01>")
    (should-error (iii:tree:chain:create tree '(:root :one :two :three :four)))
    (iii:debug "TEST:TREE:CHAIN:CREATE" "</TEST name='tree error' number=01>")

    ;;---
    ;; New leaf node.
    ;;---
    (iii:debug "TEST:TREE:CHAIN:CREATE" "</TEST name='new leaf' number=00>")
    (should (equal (iii:tree:chain:create tree '(:root :one :two :three :fore))
                   '(:root (:one (:two (:three (:four :fore)))))))
    (iii:debug "TEST:TREE:CHAIN:CREATE" "</TEST name='new leaf' number=00>")))
