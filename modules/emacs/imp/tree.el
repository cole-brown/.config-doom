;;; emacs/imp/tree.el -*- lexical-binding: t; -*-

;; imp requirements:
;;   - :imp 'debug
;;   - :imp 'error
;;   - :imp 'path


;; (setq iii:test:tree
;;       '((:imp (1 . "one")
;;               2
;;               3)
;;         (:boo ("a" . 0)
;;               ("aa" . 0)
;;               ("b" . 1)
;;               ("bb" . 1)
;;               ("c" . 2)
;;               ("cc" . 2)
;;               ("d" . 3)
;;               ("dd" . 3)
;;               ("e" . 4)
;;               ("ee" . 4)
;;               ("f" . 5)
;;               ("ff" . 5))
;;         (:pinky "narf"
;;                 "zort"
;;                 "poit"
;;                 "egad"
;;                 "troz"
;;                 "fiddely-posh")
;;         (:metasyntactic (foo (bar (baz (qux (quux (quuux (quuuux . quuuuux)))))
;;                                   (thud (grunt))
;;                                   fum
;;                                   zot))
;;                         (bazola ztesch)
;;                         (fred barney)
;;                         (corge grault flarp)
;;                         (zxc spqr wombat)
;;                         (shme)
;;                         (snork)
;;                         (blarg wibble)
;;                         (toto titi tata tutu)
;;                         (pippo pluto paperino)
;;                         (aap noot mies))))
;; (let ((keys '(:metasyntactic foo bar zot))
;;       (tree iii:test:tree)
;;       keydd)
;;   (dolist (key keys)
;;     (setq tree (alist-get key tree)
;;           keydd key)
;;     (message "%s ->\n%S\n" key tree))
;;   (message "done.\n  key: %S\n  tree:\n%S" keydd tree)
;;   nil)


;;------------------------------------------------------------------------------
;; Predicates: Types
;;------------------------------------------------------------------------------

(defun iii:node? (node)
  "Retuns t if NODE is a node; nil otherwise (including if NODE is a
tree or nil)."
  ;; A node is:
  ;;   - A list...
  ;;   - ...which has not-a-list as the first item (so not an alist).
  ;;   - First item should be a symbol/keyword.
  (and (not (null node))
       (listp node)
       (not (null (car node)))
       (not (listp (car node)))
       (symbolp (car node))))
;; (iii:node? :root)
;; (iii:node? '(:root))


(defun iii:tree? (tree)
  "Retuns t if TREE is a tree; nil otherwise (including if TREE is a node)."
  ;; A tree is:
  ;;   - A list...
  ;;   - ...which has nodes for each item in it (so an alist of nodes).
  (if (or (null tree)
          (not (listp tree)))
      nil
    ;; Each item in list must be a node.
    (-all? #'iii:node? tree)))
;; symbol: no
;;   (iii:tree? :root)
;; node: no
;;   (iii:tree? '(:root))
;; list of node: yes
;;   (iii:tree? '((:root)))
;;   (iii:tree? '((:root :ignored) (:root02) (:root03)))


(defun iii:chain? (chain &optional rooted)
  "Retuns t if CHAIN is a chain of tree keys; nil otherwise (including if CHAIN
is nil)."
  (let (is-chain
        (is-rooted t)) ;; default to true for when not interested in rootedness.

    ;; A tree is:
    ;;   - A list...
    ;;   - ...which has symbols as the only items in it.
    ;; A
    (setq is-chain (if (or (null chain)
                           (not (listp chain)))
                       nil
                     ;; Each item in chain must be a symbol.
                     (-all? #'symbolp chain)))

    ;; Additionally, a rooted chain must have a keyword as the first symbol.
    (when (and is-chain rooted)
      (setq is-rooted (keywordp (car chain))))

    ;; Chain?
    (and is-chain is-rooted)))
;; symbol: no
;;   (iii:chain? :root)
;; list: yes
;;   (iii:chain? '(:root))
;;   (iii:chain? '(root))
;;   (iii:chain? '(:root) t)
;; list, but not rooted: no
;;   (iii:chain? '(root) t)


;;------------------------------------------------------------------------------
;; Nodes
;;------------------------------------------------------------------------------

(defun iii:node:get (tree name)
  "Get NAME from TREE's direct children.

Returns alist assoc if NAME is found in tree's immediate children.
Returns nil if no NAME in TREE's immediate children or TREE is nil."
  (if (not (iii:tree? tree))
      (iii:error "iii:node:get" "Input TREE is not a tree: %S" tree)

    (assoc name tree)))
;; (iii:node:get '(:root (:one (:two (:three (:four))))) :root)
;; (iii:node:get '((:root (:one (:two (:three (:four))))) (:jeff)) :root)
;; (iii:node:get '((:root (:one (:two (:three (:four))))) (:jeff)) :jeff)


(defun iii:node:name (node)
  "Get NODE's name.

Returns name or nil if node is nil."
  (car node))


(defun iii:node:children (node)
  "Get NODE's alist of children.

Returns alist or nil."
  (cdr node))


(defun iii:node:create (name &optional children)
  "Create a node for NAME with a list of CHILDREN."
  (unless (listp children) ;; nil ok too
    (iii:error "iii:node:create"
               "Node '%s' cannot be created - expected list of children, got: %S"
               name children))
  (cons name children))
;; (iii:node:create :root '((1 . "one") 2 3))
;; (iii:node:create :root)
;;
;; Just a node; not an alist on its own.
;;   (alist-get :root (iii:node:create :root '((1 . "one") 2 3)))


(defun iii:node:add (parent new)
  "Add NEW node into PARENT node's immediate children.

NOTE: Assumes NEW does not already exist in PARENT!
  - Use `iii:node:update' if you need a check!"
  ;; Parent is a node with possible children, and we want to add one. A node is
  ;; a list starting with the name symbol/keyword, so we cannot do normal lispy
  ;; 'put on the front' things. Instead add it as the new final item.
  (-snoc parent new))
;; (iii:node:add (iii:node:create :root '((:one) (:two))) (iii:node:create :three '((:four))))


(defun iii:node:update (parent new)
  "Put NEW node into PARENT node's immediate children.

If the node already exists in PARENT's children, this will replace it with
NEW node.

NOTE: YOU MUST USE RETURN VALUE. It is the new parent."
  (iii:debug "iii:node:update" "parent: %S" parent)
  (iii:debug "iii:node:update" "new:    %S" new)

  (let* ((name (iii:node:name new))
         (children (iii:node:children parent))
         (existing (iii:node:get children name)))
    (iii:debug:newline)
    (iii:debug "iii:node:update" "  name:     %S" name)
    (iii:debug "iii:node:update" "  children: %S" children)
    (iii:debug "iii:node:update" "  existing: %S" existing)

    ;; Remove existing node?
    (when existing
      (iii:debug "iii:node:update" "Deleting existing node...")

      (setq children (delq existing children))
      (iii:debug "iii:node:update" "Deleted; children: %S" children))

    ;; Add node to tree.
    (iii:debug "iii:node:update" "Adding new node...")
    (setq parent (iii:node:add parent new))
    (iii:debug "iii:node:update" "Added; parent: %S" parent)

    ;; And... return the new, updated parent.
    parent))


;;------------------------------
;; Node -> Tree
;;------------------------------

(defun iii:node:tree (node)
  "Convert node to full tree in its own right."
  (if (not (iii:node? node))
      (iii:error "iii:node:tree" "Input NODE is not a node! %S" node)
    (list node)))
;; (iii:node:tree :root)
;; (iii:node:tree (iii:node:create :root))
;; (alist-get :imp (iii:node:tree (iii:node:create :imp '((1 . "one") 2 3)))
;; (alist-get 1 (alist-get :imp (iii:node:tree (iii:node:create :imp '((1 . "one") 2 3))))


;;------------------------------------------------------------------------------
;; Chains
;;------------------------------------------------------------------------------

(defun iii:node:chain:create (name &optional chain)
  "Create an alist entry for NAME with a list where each subsequent item is a
  child of the previous.

Example:
  (iii:node:chain:create :root '(1 2 3 4))
    - The supplied args represent this tree:
      + :root
        + 1
          + 2
            + 3
              + 4"
  (when (and (not (null chain))
             (not (iii:chain? chain)))
    (iii:error "iii:node:chain:create" "CHAIN is not a chain: %S" chain))

  (let (tree)
    (dolist (link (reverse chain))
      ;; Each chain is a full tree, not simply a node.
      (setq tree (iii:node:tree (iii:node:create link tree)))
      (iii:debug "iii:node:chain:create"
                 "link: %S -> %S" link tree))

    ;; Top it off with the root name.
    ;; Just a node though, as it is likely getting inserted into an existing alist.
    (iii:node:create name tree)))
;; (iii:node:chain:create :root '(:one :two :three :four))
;; (car (iii:node:chain:create :root '(:one :two :three :four)))
;; (cdr (iii:node:chain:create :root '(:one :two :three :four)))

;; (defun iii:tree:get (tree child)
;;   "Get CHILD node from TREE's immediate children."
;; Is iii:node:get good enough?


(defun iii:tree:chain:get (tree chain)
  "Return tuple of (tree chain-remaining).

Returns nil if CHAIN is not in TREE at all.

Walks down TREE looking for names in CHAIN. Stops when a name is not found and
returns the current tree and the remaining chain it cannot fulfill."
  (iii:debug "iii:tree:chain:get" "tree:  %S" tree)
  (iii:debug "iii:tree:chain:get" "chain: %S" chain)

  ;; Don't allow a null chain.
  (when (or (null chain)
            (not (iii:chain? chain)))
    (iii:error "iii:tree:chain:get" "CHAIN is not a chain: %S" chain))

  ;; Valid tree?
  (when (or (null tree)
            (not (iii:tree? tree)))
    (iii:error "iii:tree:chain:get" "TREE is not a tree: %S" tree))

  ;; Init link/chain for first iteration.
  (let* ((link (car chain))
         (chain (cdr chain))
         (node (iii:node:get tree link))
         done)

    (if (not node)
        ;; None of chain is in tree. We're already done.
        ;; Just need to un-split the original chain.
        (list tree (cons link chain))

      ;; Walk into tree following chain until we get to end of chain or nil node
      ;; in tree.
      (while (and link node tree (not done))
        (iii:debug:newline)
        (iii:debug "iii:tree:chain:get" "Get for %S in: %S" link tree)
        (setq node (iii:node:get tree link))
        (iii:debug "iii:tree:chain:get" "  set node(%s): %S" link node)
        (let ((node-tree (iii:node:children node)))
          (iii:debug "iii:tree:chain:get" "  node-tree(%s): %S" link node-tree)
          (iii:debug "iii:tree:chain:get" "  done(%s)? %S" link (not node-tree))

          (if (not node-tree)
              (progn
                ;; Didn't find this link - quit without changing anything.
                ;; Our current tree, (link & chain) are the return values.
                (iii:debug "iii:tree:chain:get" "Done; node not found!")
                (setq done t)
                (when (not (eq (iii:node:name node) link))
                  (iii:debug "iii:tree:chain:get" "Adding link back to chain.")
                  ;; And push this link back into the chain for the return.
                  (setq chain (cons link chain)))
                (iii:debug "iii:tree:chain:get" "returning chain: %S" chain))

            ;; Found this link in the tree; continue.
            (setq tree node-tree)
            (iii:debug "iii:tree:chain:get" "  tree(%s): %S" link tree)

            ;; Set up link & chain for next loop.
            (setq link (car chain)
                  chain (cdr chain))
            (iii:debug "iii:tree:chain:get" "  setq:")
            (iii:debug "iii:tree:chain:get" "    link:     %S" link)
            (iii:debug "iii:tree:chain:get" "    chain:    %S" chain))))

      ;; Finished walk; return result.
      (iii:debug "iii:tree:chain:get" "got tree: %S" tree)
      (iii:debug "iii:tree:chain:get" "chain:    %S" chain)
      ;; If nothing remaining in chain, return `nil' instead of `(nil)'.
      (when (null (car chain))
        (setq chain nil))
      (iii:debug "iii:tree:chain:get" "chain remainin: %S" chain)
      (list tree chain))))
;; (iii:tree:chain:get (iii:node:tree (iii:node:chain:create :root '(:one :two :three :four))) '(:root :one :two :three :fore))
;; (iii:tree:chain:get (iii:node:tree (iii:node:chain:create :root '(:one :two :three :four))) '(:root :one :two :three :four))
;; (iii:tree:chain:get (iii:node:tree (iii:node:chain:create :root '(:one :two :three :four))) '(:root :one :two))
;; (iii:tree:chain:get (iii:node:tree (iii:node:chain:create :root '(:one :two :three :four))) '(:too :tutu))
;; (iii:tree:chain:get (iii:node:tree (iii:node:chain:create :root '(:one :two :three :four))) nil)


(defun iii:tree:update (tree chain subtree)
  "Follow CHAIN down TREE, insert SUBTREE there, and update all branches back up
to the root."
  (iii:debug "iii:tree:update" "tree:    %S" tree)
  (iii:debug "iii:tree:update" "chain:   %S" chain)
  (iii:debug "iii:tree:update" "subtree: %S" subtree)

  ;;---
  ;; Validate Inputs
  ;;---

  ;; Don't allow a null chain.
  (when (or (null chain)
            (not (iii:chain? chain)))
    (iii:error "iii:tree:update" "CHAIN is not a chain: %S" chain))

  ;; Valid tree?
  (when (or (null tree)
            (not (iii:tree? tree)))
    (iii:error "iii:tree:update" "TREE is not a tree: %S" tree))

  ;; Valid subtree?
  (when (or (null subtree)
            (not (iii:tree? subtree)))
    (iii:error "iii:tree:update" "SUBTREE is not a tree: %S" subtree))

  ;;---
  ;; Do the update.
  ;;---
  (let* ((link (car chain))
         (chain (cdr chain))
         (link-tree (iii:node:children (iii:node:get tree link))))
    (iii:debug:newline)
    (iii:debug "iii:tree:update" "link:      %S" link)
    (iii:debug "iii:tree:update" "chain:     %S" chain)
    (iii:debug "iii:tree:update" "link-tree: %S" link-tree)
    ;; Keep following chain or have we arrived?
    (if (null chain)
        ;; Can't recurse anymore; do last link and add subtree there.
        (progn
          (iii:debug "iii:tree:update" "Finished chain; adding subtree...")
          (iii:debug "iii:tree:update" "  link: %S" link)

          ;; Follow last link.
          (setq link-tree (iii:node:children (iii:node:get tree link)))
          (iii:debug "iii:tree:update" "  link-tree(before): %S" link-tree)

          ;; Add subtree as child.
          (setq link-tree (iii:node:add link-tree subtree))
          (iii:debug "iii:tree:update" "  link-tree(after):  %S" link-tree)
          link-tree)


      ;; Follow this link - the return value will be what we need to update our
      ;; link-tree with.
      (iii:debug "iii:tree:update" "Continue on chain...")
      (setq link-tree (iii:tree:update link-tree chain subtree))
      (iii:debug "iii:tree:update" "link-tree(recurse): %S" link-tree)
      link-tree
    )))
(iii:tree:update (iii:node:tree (iii:node:chain:create :root '(:one :two :three)))
                 '(:root :one :two :three)
                 '((:four :fore)))


(defun iii:tree:chain:create (tree chain)
  "Walk TREE following CHAIN.

If at a leaf node of TREE, insert an element in chain. Then
update root/chain, and recurse either way.

Signal an error if we cannot insert anything from CHAIN into the
TREE.

Returns tree, possibly updated."
  (iii:debug "iii:tree:chain:create" "tree:  %S" tree)
  (iii:debug "iii:tree:chain:create" "chain: %S" chain)

  ;; Don't allow a null chain.
  (when (or (null chain)
            (not (iii:chain? chain)))
    (iii:error "iii:tree:chain:create" "CHAIN is not a chain: %S" chain))

  ;; Valid tree?
  (when (or (null tree)
            (not (iii:tree? tree)))
    (iii:error "iii:tree:chain:create" "TREE is not a tree: %S" tree))

  ;; Find where in the tree we need to insert, and what we need to insert.
  (-let (((subtree remaining) (iii:tree:chain:get tree chain)))
    (iii:debug "iii:tree:chain:create" "chain:get: subtree: %S" subtree)
    (iii:debug "iii:tree:chain:create" "chain:get: remaining: %S" remaining)

    (when (null remaining)
        ;; Everything in chain already exists - signal error.
        (iii:error "iii:tree:chain:create"
                   (concat "Cannot create anything for chain - "
                           "all nodes present in tree already! "
                           "chain: %S, tree: %S")
                   chain tree))

    ;; Now create the part of the chain we need to add to the subtree.
    (let ((created (iii:node:chain:create (car remaining) (cdr remaining)))
          rchain)
      (iii:debug "iii:tree:chain:create" "node:chain:create: created: %S" created)

      ;; TODO: here?

      ;; Need to insert this into the subtree...
      (setq subtree (iii:node:add subtree created))
      (iii:debug "iii:tree:chain:create" "new subtree: %S" subtree)

      ;; Create an existing branch list to walk up.
      (dolist (link chain)
        (when (not (memq link remaining))
          (push link rchain)))
      (iii:debug "iii:tree:chain:create" "rchain:     %S" rchain)
      (iii:debug "iii:tree:chain:create" "remaining:  %S" remaining)
      (iii:debug "iii:tree:chain:create" "orig chain: %S" chain)

      ;; TODO: or here?

      ;; Finally, walk up the tree, replacing branches as we go in order to get
      ;; it all updated.
      (let ((working-tree tree))
        (dolist (link (nreverse rchain))
          (iii:debug "iii:tree:chain:create" "link:        %S" link)
          (iii:debug "iii:tree:chain:create" "update tree: %S" working-tree)


      ;; TODO:
      ;; loop rchain in /forward/ order:
      ;;   Get node's children from tree.
      ;;   Call "Update This tree With This New Child node.
      ;;     - Start @ base tree.
      ;;     - 'New Child node' will have to be recursion call? I think?
      ;; TODO OR...?
      ;;   Thread macro? Somehow?

        ;;
      ;; TODO
    )))
;; (iii:tree:chain:create (iii:node:tree (iii:node:chain:create :root '(:one :two :three :four))) '(:root :one :two :three :fore))

  ;; TODO: use remaining from iii:tree:chain:get to call iii:node:chain:create.
  ;; TODO: insert result from iii:node:chain:create into parent
  ;; TODO: go up levels, replacing things if that insert didn't update the actual full tree.

  (let (links-create
        links-exist
        ;; Init to non-nil for while check.
        (link (car chain))  ;; Allows skipping tree walk if no initial key.
        (links chain)  ;; Start as full chain so first while set works as expected.
        (branch t)
        (start-branch tree))

    ;;------------------------------
    ;; Find existing links.
    ;;------------------------------

    ;; First, walk into tree following chain until we get to something it doesn't have.
    (while (and (not links-create)
                link branch)
      ;; Pop link we're looking for off, and see if we can find in the tree.
      (setq link (car links)
            links (cdr links)
            branch (iii:node:get start-branch link))
      (iii:debug "iii:tree:chain:create"
                 "walk tree:\n  link: %S\n  links: %S\n  branch:\n    %S"
                 link links branch)
      ;; Found the link in the tree; look deeper.
      (if branch
          (progn
            (setq start-branch branch)
            (push link links-exist))
        (setq links-create (cons link links))))

    ;; Ok; did we end up being able to create anything?
    (if (null (car links-create))
        (progn
      (iii:debug "iii:tree:chain:create"
                 "All links already exist in tree! links: %S, tree %S"
                 chain tree)
      tree)

    (iii:debug "iii:tree:chain:create"
               (concat
                "Done walking existing branches.\n"
                "  chain:   %S\n"
                "    ->exist: %S\n"
                "    ->make:  %S\n"
                "    ->@branch:\n"
                "      %S")
               chain links-exist links-create start-branch)

    ;;------------------------------
    ;; Create new links.
    ;;------------------------------
    ;; Create it.
    (let ((new (iii:tree:chain:create (car links-create) (cdr links-create)))
          (siblings (iii:node:children start-branch)))
      (iii:debug "iii:tree:chain:create"
                 "Created chain for insertion: %S"
                 new)
      (iii:debug "iii:tree:chain:create"
                 "Siblings: %S"
                 siblings)

      ;; Stick it in with its new siblings and assign back to tree.
      (push new siblings)
      (iii:debug "iii:tree:chain:create"
                 "Added to siblings:\n  %S"
                 siblings)
      (dolist (branch links-exist)
        (iii:debug "iii:tree:chain:create"
                   "Update branch: %S" branch)
        (
        ;;(setf (iii:tree:get foo

      ;;(pp-macroexpand-expression tree)
      )))))
;; (iii:tree:chain:create (iii:tree:chain:create :root '(:one :two :three :four)) '(:one :two :three 4))

;; (iii:tree:chain:create iii:test:tree '(:metasyntactic foo bar fuck))

;;   ;; Second, start creating/inserting leaves from the rest of the chain.
;;   (let ((this (car chain))
;;         (remaining (cdr chain)))
;;     (iii:debug "iii:tree:chain:create" "this link: %S" this)
;;     (iii:debug "iii:tree:chain:create" "links remaining: %S" remaining)

;;     (if (null this)
;;         ;; Stop recursing.
;;         (progn
;;           (iii:debug "iii:tree:chain:create" "null link; stop recursing: %S" this)
;;           nil)

;;     ;; Create this node and recurse for creating its child.
;;     (iii:node:create this
;;                           (list (iii:tree:chain:create subtree
;;                                                       remaining)))
;;     ;; Update tree/chain and recurse.
;;     (let ((subtree (iii:tree:chain:create (iii:tree:get tree this)
;;                                          remaining)))
;;       (iii:debug "iii:tree:chain:create" "Set-up for recursion...")
;;       (iii:debug "iii:tree:chain:create" "  this:      %S" this)
;;       (iii:debug "iii:tree:chain:create" "  remaining: %S" remaining)
;;       (iii:debug "iii:tree:chain:create" "  subtree:   %S" subtree)
;;       (if (null subtree)
;;           ;; We are a leaf on the +wind+ tree.
;;           ;; TODO: error checking
;;           (iii:node:create this)

;;         ;; Branch; add our subtree...
;;         (push (iii:node:create this (list subtree)) tree))))))
;; (iii:tree:chain:create iii:test:tree '(:metasyntactic foo bar fuck))


(defun iii:tree:set:chain (tree chain value)
  "Set VALUE in TREE at CHAIN from TREE root."
  (iii:debug "iii:tree:set:chain"
             (concat "set:\n"
                     "  chain: %S\n"
                     "  value: %S\n"
                     "  tree:  %S")
             chain value tree)

  ;; Stop recursing?
  (if (null (car chain))
      nil

    ;; Get to the end of the chain in order to set subtree.
    (let ((link (car chain))
          (remaining (cdr chain))
          subtree)
      (if (null remaning)
          ;; At the end of the chain - insert value.
          (

        (setq subtree (iii:tree:set:chain (iii:tree:get tree link)
                                        remaining))
        ;; And now set this level as the result of the recursion.
        (setf (iii:tree:get tree link) subtree))))))


;;------------------------------------------------------------------------------
;; Tree
;;------------------------------------------------------------------------------

(defun iii:tree:get (tree name)
  "Get NAME's children from tree in manner usable by `setf'.

Returns nil if no NAME in TREE or TREE is nil."
  (alist-get name tree))
;; imp:features
;; (iii:tree:get imp:features :imp)
;; (iii:tree:get (iii:tree:get imp:features :imp) 1)


(defun iii:tree:set (root &optional chain)
  "Add all of ROOT, CHAIN that do not exist to `imp:features'.

If final leaf in CHAIN already exists, signals an error."
  (iii:debug "iii:tree:set" "Setting in `imp:features':")
  (iii:debug "iii:tree:set" "  root:  %S" root)
  (iii:debug "iii:tree:set" "  chain: %S" chain)

  (if (null imp:features)
      (iii:error "iii:tree:set"
                 "Empty tree; use `iii:tree:create'.")

    ;; Ok; check/add root first, then on to chain.
    (let ((parent root)
          siblings)
      (if (null imp:features)
          ;; Easy case: root is not in tree yet; just add everything.
          (progn
            (push (iii:tree:chain:create root chain) imp:features)
            (iii:debug "iii:tree:set" "Created chain for %S at root %S."
                       chain root))

        ;; Else, walk down the chain and check against imp:features until we
        ;; figure out what to do.
        (setq siblings (iii:tree:get imp:features parent))
        (dolist (link chain)
          ;; Found the spot to insert this link in the chain.
          (when (null siblings)
            ;; Set link as leaf (currently) child node here in the tree.
            (iii:debug "iii:tree:set"
                       "Link '%S' needs inserted as child of '%S', sibling of: %S"
                       link parent
                       (iii:tree:get parent root))
            (setf (iii:tree:get tree link)
                  (iii:node:tree (iii:node:create link)))
            (iii:debug "iii:tree:set"
                       "Added child '%S' to tree: %S"
                       link tree))

          ;; Already (or now) have this link; keep looking at next level.
          (setq tree (iii:tree:get tree link)))))))
;; imp:features
;; (iii:tree:set :imp '(jeff))
