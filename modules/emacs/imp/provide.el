;;; eeeeemacs/imp/provide.el -*- lexical-binding: t; -*-

;; imp requirements:
;;   - :imp 'debug
;;   - :imp 'error
;;   - :imp 'path


;;------------------------------------------------------------------------------
;; Features
;;------------------------------------------------------------------------------

(defvar imp:features nil
  "Features that have been loaded by `iii:provide'.

Is an alist of alists of ... ad nauseam. Provided features are the leaves, and
their feature names should be built from the path traversed to get to them.
  - I.e. directory structures w/ files as leaves.

For example:
  '((:imp provide
          require
          (subthing (subthing-child0 subthing-child1))))
    (:jeff))
    - is a tree with 2 'roots':
      - :imp
        - provide
        - require
        - subthing
          - subthing-child0
          - subthing-child1
      - :jeff")
;; (setq imp:features nil)
;;
;; Apparently alists of alists are hard for me to grok:
;;   (alist-get :root '((:root . ((1) (2) (3)))))
;;   (alist-get 1 (alist-get :root '((:root . ((1) (2) (3))))))
;;     - ...might be right? Let's give 1 a child...
;;   (alist-get :root '((:root . ((1 . "one") (2) (3)))))
;;   (alist-get 1 (alist-get :root '((:root . ((1 . "one") (2) (3))))))
;;     - Yep. Have to put up with conses being smooshed into a list when I want
;;       to think about them as separate conses...





;;------------------------------------------------------------------------------
;; Feature Functions
;;------------------------------------------------------------------------------

(defun iii:feature:add (root &optional chain)
  "Add the feature ROOT and its CHAIN to the `imp:features' tree."
  (iii:debug "iii:feature:add" "Adding to imp:features...")
  (iii:debug "iii:feature:add" "  root:  %S" root)
  (iii:debug "iii:feature:add" "  chain: %S" chain)
  (if (null imp:features)
      ;; Simple case: just create the tree.
      (progn
        (iii:debug "iii:feature:add" "Creating imp:features...")
        (iii:debug "iii:feature:add" "  root:  %S" root)
        (iii:debug "iii:feature:add" "  chain: %S" chain)
        (iii:debug "iii:feature:add" "  <- %S"
                   (iii:tree:node-to-tree (iii:tree:create:node root chain)))
        (setq imp:features (iii:tree:create root chain))
        (iii:debug "iii:feature:add" "imp:features: %S" imp:features))

    ;; Need to insert into the tree without accidentally wiping anything else out.
    (iii:debug "iii:feature:add" "Adding to imp:features: %S %S" root chain)
    (iii:tree:set root chain)))
;; (setq imp:features nil)
;; (iii:feature:add :imp '((1 . "one") 2 3))
;; imp:features
;; (alist-get :imp imp:features)
;; (alist-get 1 (alist-get :imp imp:features))
;; (iii:tree:get imp:features :imp)
;; (iii:feature:add :imp '(jeff))
;; (iii:tree:get imp:features :imp)
;; (iii:feature:add :mis '(take quote))


(defun imp:features:print ()
  "Pretty print `imp:features' to a temp buffer."
  (interactive)
  (pp-display-expression imp:features "imp:features"))
;; (imp:features:print)


;;------------------------------------------------------------------------------
;; Provide
;;------------------------------------------------------------------------------

;; TODO: this
(defun imp:provided? (&rest symbols)
  "Checks for SYMBOLS in `imp:features'."
  ;; old; mis's version
  ;; (when-let ((feature (apply #'iii:load:name symbols)))
  ;;   ;; Check for the feature in our loaded features and convert to
  ;;   ;; a boolean (t/nil).
  ;;   (not (null (assoc-string feature imp:features))))
  )
;; (imp:provided? :imp 'provide)


;; TODO: this
(defun imp:provide (&rest symbols)
  "Record SYMBOLS as having been provided."
  ;; old; mis's version
  ;; (unless (apply #'imp:provided? symbols)
  ;;   (push (apply #'iii:path symbols) imp:features))
  )


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
;; TODO: provide this
;; (imp:provide :imp 'provide)
;; (provide 'imp:provide)
