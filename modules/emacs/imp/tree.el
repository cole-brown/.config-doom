;;; emacs/imp/tree.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Predicates: Types
;;------------------------------------------------------------------------------

(defun iii:tree:node? (node)
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


(defun iii:tree:tree? (tree)
  "Retuns t if TREE is a tree; nil otherwise (including if TREE is a node)."
  ;; A tree is:
  ;;   - A list...
  ;;   - ...which has nodes for each item in it (so an alist of nodes).
  (if (or (null tree)
          (not (listp tree)))
      nil
    ;; Each item in list must be a node.
    (not
     (seq-contains-p (mapcar #'iii:tree:node? tree)
                     nil))))
;; symbol: no
;;   (iii:tree? :root)
;; node: no
;;   (iii:tree? '(:root))
;; list of node: yes
;;   (iii:tree? '((:root)))
;;   (iii:tree? '((:root :ignored) (:root02) (:root03)))


(defun iii:tree:chain? (chain &optional rooted)
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
                     (seq-every-p #'symbolp chain)))

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


(defun iii:tree:key/exists? (key tree)
  "Returns non-nil if key exists in tree, even if it has no children.

Return value is KEY's entry in TREE, or nil if KEY does not exist."
  (iii:alist/general:entry key tree))
;; (iii:tree:key/exists? :root1 (iii:tree:update '(:root1) nil (iii:tree:create '(:root0 :one :two) :leaf)))


;;------------------------------------------------------------------------------
;; Helper Functions
;;------------------------------------------------------------------------------

(defun iii:tree:chain (chain value)
  "Create an alist entry for a tree from CHAIN and VALUE."
  (unless (listp chain) ;; nil ok too
    (int<imp>:error "iii:tree:chain"
                    "Chain cannot be created - expected list, got: %S"
                    chain))
  ;; Set-up: Need to build in reverse.
  (let* ((backwards (reverse chain))
         ;; Entry starts off as the final link w/ the value (if the value is not
         ;; nil).
         (entry (if value
                    (list (car backwards) (list value))
                  (list (car backwards))))
         ;; And we still need to process these.
         (link (cadr backwards))
         (remaining (cddr backwards)))

    (int<imp>:debug "iii:tree:chain" "entry:     %S" entry)
    (int<imp>:debug "iii:tree:chain" "link:      %S" link)
    (int<imp>:debug "iii:tree:chain" "remaining: %S" remaining)

    ;; Grow entry by remaining links.
    (while link
      ;; This makes entry an alist of alist(s).
      (setq entry (list link entry))
      ;; Cycle link/remaining to next.
      (setq link (car remaining))
      (setq remaining (cdr remaining)))

    ;; Return the chain of alists for chain/value.
    entry))
;; (iii:tree:chain '(:root) nil)
;; (iii:tree:chain '(:root :one :two :three) :leaf-node)
;; (alist-get :root (list (iii:tree:chain '(:root :one :two :three) :leaf-node)))
;; (alist-get :one (alist-get :root (list (iii:tree:chain '(:root :one :two :three) :leaf-node))))
;; (alist-get :two (alist-get :one (alist-get :root (list (iii:tree:chain '(:root :one :two :three) :leaf-node)))))
;; (alist-get :three (alist-get :two (alist-get :one (alist-get :root (list (iii:tree:chain '(:root :one :two :three) :leaf-node))))))


(defun iii:tree:create (chain value)
  "Creates a TREE with CHAIN and VALUE as the starting content."
  (list (iii:tree:chain chain value)))
;; (iii:tree:create '(:root :one :two :three) :leaf-node)


(defun iii:tree:branch/update (entry branch)
  "Add ENTRY to BRANCH.

ENTRY must be an alist entry for a tree; e.g. a return value from
`iii:tree:chain'.

BRANCH must be a tree - an alist of alists. ENTRY will be added to root of
BRANCH."
  (int<imp>:debug "iii:tree:branch/update" "->entry:  %S" entry)
  (int<imp>:debug "iii:tree:branch/update" "->branch: %S" branch)
  (let* ((key (car entry))
         ;; Need the entry, not the alist, of key's children.
         ;; Need '(:value), not '((:value)).
         (value (cadr entry))
         (siblings (iii:alist/general:get key branch)))
    (int<imp>:debug "iii:tree:branch/update" "  key:      %S" key)
    (int<imp>:debug "iii:tree:branch/update" "  vaule:    %S" value)
    (int<imp>:debug "iii:tree:branch/update" "  siblings: %S" siblings)

    ;; Add new value to its new siblings, update branch and done.
    (push value siblings)
    (int<imp>:debug "iii:tree:branch/update" "updated siblings: %S" siblings)
    (setq branch (iii:alist/general:update key siblings branch))
    (int<imp>:debug "iii:tree:branch/update" "updated branch: %S" branch)
    branch))
;; (iii:tree:branch/update '(:two (:leaf-node1)) '((:two (:three (:leaf-node0)))))
;; (alist-get :two (iii:tree:branch/update '(:two (:leaf-node1)) '((:two (:three (:leaf-node0))))))
;; (alist-get :leaf-node1 (alist-get :two (iii:tree:branch/update '(:two (:leaf-node1)) '((:two (:three (:leaf-node0)))))))


;;------------------------------------------------------------------------------
;; API for imp:
;;------------------------------------------------------------------------------

(defun iii:tree:update (chain value tree)
  "Adds CHAIN of symbols/keywords with final VALUE to alists TREE.

If VALUE is nil, just adds chain - does not add a nil child."
  ;;------------------------------
  ;; Error Checking
  ;;------------------------------
  ;; Don't allow a null chain.
  (when (or (null chain)
            (not (iii:tree:chain? chain)))
    (int<imp>:error "iii:tree:update" "CHAIN is not a chain: %S" chain))

  ;; Valid tree?
  (when (and (not (null tree)) ;; We can deal with a tree of nil.
             (not (iii:tree:tree? tree))) ;; We can't deal with an invalid tree.
    (int<imp>:error "iii:tree:update" "TREE is not a tree: %S" tree))

  ;;------------------------------
  ;; Create or update?
  ;;------------------------------
  (if (null tree)
      ;;------------------------------
      ;; Create a tree with chain.
      ;;------------------------------
      (iii:tree:create chain value)

    ;;------------------------------
    ;; Update tree with chain.
    ;;------------------------------

    ;; Need to splice this chain into the tree at whatever branch it shoots off
    ;; from existing.

    (let ((branch tree)
          (link (car chain))
          (remaining (cdr chain))
          ;; Keep track of upstream.
          parent-branches
          parent-links)
      (while (and branch
                  remaining)
        ;; Get branch for current link; save off branch/link.
        ;; 'parent-branch' for the 'parent-link' should include the link as an key
        ;; - we need it for easier updating on the way back up to the root.
        (push branch parent-branches)
        (setq branch (iii:alist/general:get link branch))
        (push link parent-links)
        (int<imp>:debug "iii:tree:update" "%S = %S" parent-links parent-branches)

        ;; Update link/remaining for next round.
        (setq link (car remaining))
        (setq remaining (cdr remaining)))

      (int<imp>:debug "iii:tree:update" "found final branch:")
      (int<imp>:debug "iii:tree:update" "  branch:    %S" branch)
      (int<imp>:debug "iii:tree:update" "  remaining: %S" remaining)
      (int<imp>:debug "iii:tree:update" "  link:      %S" link)

      ;;------------------------------
      ;; Error Check: Invalid chain after all?
      ;;------------------------------
      ;; Do not allow adding a chain that wants to continue off from a value

      ;; link and branch should now be at the end of the known existing chain in
      ;; tree. Need to add whatever the rest is to this branch now.
      (let ((entry (iii:tree:chain (cons link remaining) value))
            branch-update)

        ;;------------------------------
        ;; New Branch or Add Here?
        ;;------------------------------
        (if (iii:alist/general:get link branch)
            ;;------------------------------
            ;; Add Here.
            ;;------------------------------
            (setq branch-update (iii:tree:branch/update entry branch))

          ;;------------------------------
          ;; New Branch.
          ;;------------------------------
          (int<imp>:debug "iii:tree:update" "branch: %S" branch)
          (int<imp>:debug "iii:tree:update" "link: %S" link)
          (int<imp>:debug "iii:tree:update" "new: %S" entry)
          (int<imp>:debug "iii:tree:update" "  key:   %S" (car entry))
          (int<imp>:debug "iii:tree:update" "  value: %S" (cdr entry))
          (setq branch-update (iii:alist/general:update (car entry)
                                                        (cdr entry)
                                                        branch)))

        ;;------------------------------
        ;; Finish by updating tree.
        ;;------------------------------
        (int<imp>:debug "iii:tree:update" "branch-update: %S" branch-update)

        (int<imp>:debug "iii:tree:update" "Branch found/updated. Walk update up to root...\n")

        ;; Now backtrack up the tree to the root - have to update every branch
        ;; along the way to save the new value.
        ;; ;;
        ;; ;; First, drop the leading values from the parents lists. They are what we
        ;; ;; already updated.
        ;; (setq parent-links (cdr parent-links))
        ;; (setq parent-branches (cdr parent-branches))
        (while parent-links
          ;; Grab what this level is.
          (setq link (car parent-links))
          (setq parent-links (cdr parent-links))
          (setq branch (car parent-branches))
          (setq parent-branches (cdr parent-branches))
          (int<imp>:debug "iii:tree:update" "link: %S" link)
          (int<imp>:debug "iii:tree:update" "branch: %S" branch)

          ;; Push updated branch of tree into place.
          (setq branch-update (iii:alist/general:update link branch-update branch))
          (int<imp>:debug "iii:tree:update" "branch-update: %S" branch-update))
        branch-update))))
;; Chain splits from tree:
;; (iii:tree:update '(:root :one :two :free) :leaf-node1 (iii:tree:create '(:root :one :two :three) :leaf-node0))
;; Tree doesn't exist:
;; (iii:tree:update '(:root :one :two :free) :leaf-node1 nil)
;; Chain doesn't exist in tree:
;; (iii:tree:update '(:root1 :won :too :free) :leaf-node1 (iii:tree:create '(:root0 :one :two :three) :leaf-node0))
;; Chain pre-exists in tree:
;; (iii:tree:update '(:root :one :two) :leaf-node1 (iii:tree:create '(:root :one :two :three) :leaf-node0))
;; Reach end of tree before end of chain:
;; (iii:tree:update '(:root :one :two :three :four) :leaf-node1 (iii:tree:create '(:root :one :two :three) :leaf-node0))
;; Chain w/ null value:
;; (iii:tree:update '(:root :one :two :free) nil (iii:tree:create '(:root :one :two :three) :leaf-node0))


(defun iii:tree:contains? (chain tree)
  "Returns non-nil if TREE contains the CHAIN of symbols/keywords."
  ;;------------------------------
  ;; Error Checking
  ;;------------------------------
  ;; Don't allow a null chain.
  (when (or (null chain)
            (not (iii:tree:chain? chain)))
    (int<imp>:error "iii:tree:contains" "CHAIN is not a chain: %S" chain))

  ;; Valid tree?
  (when (or (null tree)
            (not (iii:tree:tree? tree)))
    (int<imp>:error "iii:tree:contains" "TREE is not a tree: %S" tree))

  (int<imp>:debug "iii:tree:contains?" "CHAIN and TREE verified as valid.\n  chain: %S\n  tree:\n    %S"
                  chain tree)

  ;;------------------------------
  ;; Does tree contain the chain?
  ;;------------------------------
  (let ((branch tree) ;; Start at root of the tree.
        entry)
    (dolist (link chain)
      (int<imp>:debug "iii:tree:contains?" "  link:   %S" link)
      (int<imp>:debug "iii:tree:contains?" "  branch: %S" branch)
      (setq entry (iii:tree:key/exists? link branch))
      (int<imp>:debug "iii:tree:contains?" "  entry: %S" entry)
      ;; Next branch will be entry's children.
      (setq branch (cdr entry)))

    ;; Final entry:
    (int<imp>:debug "iii:tree:contains?" "final entry for link '%S': %S"
                    (car (last chain)) entry)
    (int<imp>:debug "iii:tree:contains?" "final branch: %S"
                    branch)

    ;; Return whatever we found after walking that whole chain. Will be either
    ;; a tree entry or nil, so that satisfies our predicate nature.
    entry))
;; (iii:tree:contains? '(:root :one :two) (iii:tree:create '(:root :one :two :three) :leaf-node0))
;; (iii:tree:contains? '(:root :one :two :free) (iii:tree:create '(:root :one :two :three) :leaf-node0))
;; (iii:tree:contains? '(:root1 :one :two) (iii:tree:create '(:root :one :two :three) :leaf-node0))
;; (iii:tree:contains? '(:imp test) '((:imp (ort (something (here))) (test))))
