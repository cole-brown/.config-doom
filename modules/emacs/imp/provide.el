;;; emacs/imp/provide.el -*- lexical-binding: t; -*-

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
  '((:imp
     (provide)
     (require))
    (:metasyntactic
     (foo (bar (baz (qux (quux (quuux (quuuux (quuuuux))))))
               (thud (grunt))
               (bletch)
               (fum)
               (bongo)
               (zot)))
     (bazola (ztesch))
     (fred (jim (sheila (barney))))
     (corge (grault (flarp)))
     (zxc (spqr (wombat)))
     (shme)
     (spam (eggs))
     (snork)
     (blarg (wibble))
     (toto (titi (tata (tutu))))
     (pippo (pluto (paperino)))
     (aap (noot (mies)))
     (oogle (foogle (boogle (zork (gork (bork)))))))
    (:pinky (narf (zort (poit (egad (troz (fiddely-posh))))))))
    - is a tree with 3 'roots':
      - :imp
        - provide
        - require
      - :metasyntactic
        - ...
      - :pinky
        - ...")
;; (setq imp:features nil)


;;------------------------------------------------------------------------------
;; Private Functions
;;------------------------------------------------------------------------------

(defun iii:feature:imp->emacs (feature)
  "Translate the FEATURE (a list of keywords/symbols) to a single symbol
appropriate for Emacs' `provide'."
  ;; Create the symbol.
  (intern
   ;; Create the symbol's name.
   (mapconcat (lambda (symbol)
                "Translates each symbol based on replacement regexes."
                (let ((symbol/string (symbol-name symbol)))
                  (dolist (pair imp:translate-to-emacs:replace symbol/string)
                    (setq symbol/string
                          (replace-regexp-in-string (nth 0 pair)
                                                    (nth 1 pair)
                                                    symbol/string)))))
              feature
              imp:translate-to-emacs:separator)))
;; (iii:feature:imp->emacs '(:imp test symbols))
;; (iii:feature:imp->emacs '(:imp provide))


(defun iii:feature:add (feature)
  "Add the FEATURE (a list of keywords/symbols) to the `imp:features' tree."
  (iii:debug "iii:feature:add" "Adding to imp:features...")
  (iii:debug "iii:feature:add" "  feature: %S" feature)
  (iii:debug "iii:feature:add" "imp:features before:\n%S"
             (pp-to-string imp:features))
  (setq imp:features (iii:tree:update feature nil imp:features))
  (iii:debug "iii:feature:add" "imp:features after:\n%S"
             (pp-to-string imp:features))
  ;; Not sure what to return, but the updated features seems decent enough.
  imp:features)
;; (setq imp:features nil)
;; (iii:feature:add :imp 'test)
;; imp:features
;; (iii:feature:add :imp 'ort 'something 'here)
;; (iii:alist/general:get :imp imp:features)
;; (iii:tree:contains? '(:imp) imp:features)
;; (iii:tree:contains? '(:imp ort something) imp:features)


(defun imp:features:print ()
  "Pretty print `imp:features' to a temp buffer."
  (interactive)
  (pp-display-expression imp:features imp:features:buffer))
;; (imp:features:print)


;;------------------------------------------------------------------------------
;; Public API: Provide
;;------------------------------------------------------------------------------

(defalias 'imp:feature? 'imp:provided?
  "Checks for FEATURE in `imp:features'.")
(defalias 'imp:featurep 'imp:provided?
  "Checks for FEATURE in `imp:features'.")
(defalias 'imp:providedp 'imp:provided?
  "Checks for FEATURE in `imp:features'.")


(defun imp:provided? (&rest feature)
  "Checks for FEATURE in `imp:features'."
  (iii:tree:contains? feature imp:features))
;; (imp:provided? :imp)
;; (imp:providedp :imp)
;; (imp:feature? :imp)
;; (imp:featurep :imp)


(defun imp:provide (&rest feature)
  "Record FEATURE in `imp:features' as having been provided.

If you want to provide the feature to emacs as well, you can either:
  1. Use `imp:provide:with-emacs' instead of this to have it automatically
     happen.
     - imp will translate the FEATURE symbol chain via `iii:feature:imp->emacs'.
  2. Do it yourself by also calling Emacs' `provide' with a symbol of your
     choosing."
  (iii:debug "imp:provide" "Providing feature '%S'..."
             feature)
  (iii:feature:add feature))
;; (imp:provide :package 'module 'submodule 'feature)


(defun imp:provide:with-emacs (&rest feature)
  "Record FEATURE in `imp:features' and in Emacs' `features' (via
Emacs' `provide') as having been provided.

imp will translate the FEATURE symbol chain via `iii:feature:imp->emacs' and use
the result for the call to Emacs' `provide'."
  (apply #'imp:provide feature)
  (let ((feature/emacs (iii:feature:imp->emacs feature)))
    (iii:debug "imp:provide:with-emacs" "Providing to emacs as '%S'..."
               feature/emacs)
    (provide feature/emacs)))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide:with-emacs :imp 'provide)
