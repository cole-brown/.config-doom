;;; emacs/imp/utils.el -*- lexical-binding: t; -*-


;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                              Imp Features                              ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;           I imagine some horns, a tail... maybe an evil cackle?            ;;
;;                                 ──────────                                 ;;


;;------------------------------------------------------------------------------
;; Loaded Features Tree
;;------------------------------------------------------------------------------

(defvar imp:features nil
  "Features that have been loaded by `imp:provide'.

It is a tree; an alist of alists of ... ad nauseam. Provided features are the
leaves, and their feature names should be built from the path traversed to get
to them.
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


(defvar imp:features:locate nil
  "Alist of imp features to paths/filenames.

'(normalized-feature . (file-path-0 ...))

Example:
  (list (list :imp \"init.el\")
        (list (imp:feature :imp path) \"path.el\")
        (list (imp:feature :imp multiple)
              \"multiple/foo.el\"
              \"multiple/subdir/bar.el\"
              \"multiple/subdir/baz.el\"
              \"common/baz.el\")
        ...)")
;; imp:path:roots
;; (setq imp:path:roots nil)


;;------------------------------------------------------------------------------
;; Feature Helpers
;;------------------------------------------------------------------------------

;; TODO:test: Make unit test.
(defun int<imp>:feature:exists? (features)
  "Checks for list of FEATURES in the `imp:features' tree."
  (not (null (int<imp>:tree:contains? features imp:features))))
;; (int<imp>:feature:exists? '(:imp))
;; (int<imp>:feature:exists? '(:imp path))


;;------------------------------------------------------------------------------
;; Normalization
;;------------------------------------------------------------------------------

(defconst int<imp>:feature:replace:rx
  '((":" ""))
  "Alist of regexs to replace and their replacement strings.

Using lists instead of cons for alist entries because `cons' doesn't like
strings.

Used symbol-by-symbol in `int<imp>:feature:normalize:imp->emacs' when translating an imp symbol
chain into one symbol for Emacs.")


(defconst int<imp>:feature:replace:separator
  ":"
  "String to use in between symbols when translating an imp symbol chain to
an Emacs symbol.")


(defun int<imp>:feature:normalize:imp->emacs (feature)
  "Translate the FEATURE (a list of keywords/symbols) to a single symbol
appropriate for Emacs' `provide'."
  ;; Create the symbol.
  (intern
   ;; Create the symbol's name.
   (mapconcat (lambda (symbol)
                "Translates each symbol based on replacement regexes."
                (let ((symbol/string (symbol-name symbol)))
                  (dolist (pair int<imp>:feature:replace:rx symbol/string)
                    (setq symbol/string
                          (replace-regexp-in-string (nth 0 pair)
                                                    (nth 1 pair)
                                                    symbol/string)))))
              feature
              int<imp>:feature:replace:separator)))
;; (int<imp>:feature:normalize:imp->emacs '(:imp test symbols))
;; (int<imp>:feature:normalize:imp->emacs '(:imp provide))


(defun int<imp>:feature:normalize (&rest input)
  "Normalize INPUT to a list of feature symbols/keywords.

If INPUT item is:
  - Keyword: Return as-is.
  - Symbol:  Return as-is.
  - String:  Convert to a keyword.
E.g.
  1) `:modules' -> `:modules'
  2) `feature' -> `feature'
  3) \"str-4874\" -> `:str-4874'"
  (let ((func.name "int<imp>:feature:normalize")
        output)
    (dolist (item input)
      (push
       ;; Keyword or symbol? -> no-op
       (cond ((symbolp item)
              item)

             ;; String? Convert to keyword and return.
             ((and (stringp item)
                   (not (string-empty-p item)))
              (message "string->symbol: %S->%S"
                       item
                       (intern
                        ;; Add leading ":" to make it a keyword.
                        (if (not (string-prefix-p ":" item))
                            (concat ":" item)
                          item)))
              (intern
               ;; Add leading ":" to make it a keyword.
               (if (not (string-prefix-p ":" item))
                   (concat ":" item)
                 item)))

             ;; Other? Error.
             (t
              (int<imp>:error func.name
                              (concat "Cannot convert INPUT item type to a symbol. "
                                      "Need a string or symbol/keyword. Got: %S")
                              item)))
       output))

    ;; Return the list or raise an error.
    (if (null output)
        (int<imp>:error func.name
                        "No normalized features produced from INPUT: %S"
                        input))

    (nreverse output)))
;; (int<imp>:feature:normalize '+layout/spydez)
;; (int<imp>:feature:normalize :spydez)
;; (int<imp>:feature:normalize "spydez")
;; (int<imp>:feature:normalize "+spydez")
;; (int<imp>:feature:normalize "+spydez" "foo" "bar")


(defun imp:feature:normalize (&rest input)
  "Normalize INPUT to feature in one of two ways.

If only one INPUT param, returns a symbol/keyword.
  - This is useful for converting strings to symbols for e.g. `imp:provide'.
If more than one INPUT param, returns a list of symbol/keywords.

If INPUT item is:
  - Keyword: Return as-is.
  - Symbol:  Return as-is.
  - String:  Convert to a keyword.
E.g.
  1) `:modules' -> `:modules'
  2) `feature' -> `feature'
  3) \"str-4874\" -> `:str-4874'"
  (let ((normalized (apply #'int<imp>:feature:normalize input)))
    ;; Return the list, the one item, or what?
    (cond ((null normalized)
           (int<imp>:error "imp:feature:normalize"
                           "No normalized features produced from INPUT: %S"
                           input))

          ((= 1 (length normalized))
           (nth 0 normalized))

          (t
           normalized))))
;; (imp:feature:normalize '+layout/spydez)
;; (imp:feature:normalize :spydez)
;; (imp:feature:normalize "spydez")
;; (imp:feature:normalize "+spydez")
;; (imp:feature:normalize "+spydez" "foo" "bar")


(defalias 'imp:feature 'imp:feature:normalize)


;;------------------------------------------------------------------------------
;; Add Feature.
;;------------------------------------------------------------------------------

(defun int<imp>:feature:add (feature)
  "Add the FEATURE (a list of keywords/symbols) to the `imp:features' tree."
  (int<imp>:debug "int<imp>:feature:add" "Adding to imp:features...")
  (int<imp>:debug "int<imp>:feature:add" "  feature: %S" feature)
  (int<imp>:debug "int<imp>:feature:add" "imp:features before:\n%S"
                  (pp-to-string imp:features))

  ;; Add features to `imp:features' tree & set updated tree back to `imp:features'.
  (int<imp>:tree:update feature nil imp:features)

  (int<imp>:debug "int<imp>:feature:add" "imp:features after:\n%S"
                  (pp-to-string imp:features))
  ;; Not sure what to return, but the updated features seems decent enough.
  imp:features)
;; (setq imp:features nil)
;; (int<imp>:feature:add :imp 'test)
;; imp:features
;; (int<imp>:feature:add :imp 'ort 'something 'here)
;; (int<imp>:alist:get/value :imp imp:features)
;; (int<imp>:tree:contains? '(:imp) imp:features)
;; (int<imp>:tree:contains? '(:imp ort something) imp:features)


;;------------------------------------------------------------------------------
;; Demand Features Exist!
;;------------------------------------------------------------------------------

;; TODO:test: Make unit test.
(defun imp:feature:assert (feature:base &rest feature)
  "A \"soft require\"; error if the feature is not already loaded.

Normalizes FEATURE:BASE and FEATURE into an imp feature
(via `imp:feature:normalize'), then checks if it's loaded or not.

Returns normalized feature symobl if loaded.
Raises an error signal if not found.
Only checks `imp:features' variable; does not check Emacs' `features' list."
  (if (int<imp>:feature:exists? (cons feature:base feature))
      t
    (int<imp>:error "imp:feature:assert"
                    "No `%S' feature exists in imp's features!"
                    (apply #'imp:feature:normalize feature:base feature))))


;;------------------------------------------------------------------------------
;; Features & Paths to them
;;------------------------------------------------------------------------------

;; TODO:test: Make unit test.
(defun int<imp>:feature:paths (feature:base &rest feature)
  "Find (relative) path(s) to files for FEATURE:BASE + FEATURE.

This only provides the paths for the feature itself, each of which may
`imp:require' more features.

Returns list of: '(path:root . (paths:relative))

Errors if:
  - No root path for FEATURE:BASE.
  - No paths found for input parameters."
  (let ((func.name "int<imp>:feature:get")
        (check (apply #'int<imp>:feature:normalize feature:base feature)))

    ;;------------------------------
    ;; Error Check Inputs
    ;;------------------------------
    ;; FEATURE:BASE must:
    ;; 1) Be an imp feature.
    (apply #'imp:feature:assert feature:base)

    ;; 2) Have registered a root path.
    (unless (int<imp>:path:root/contains? feature:base)
      (int<imp>:error func.name
                      "Feature `%S' does not have a root path in imp."
                      feature:base))

    ;;------------------------------
    ;; Get the paths and load them?
    ;;------------------------------
    (let* ((path:root (int<imp>:path:get feature:base))
           (feature:locations (int<imp>:alist:get/value feature:base imp:features:locate))
           (paths (int<imp>:alist:get/value check imp:features:locate)))

      ;;---
      ;; Error Checks
      ;;---
      (unless feature:locations
        (int<imp>:error func.name
                        "No feature locations found for: %S"
                        feature:base))

      (unless paths
        (int<imp>:error func.name
                        "No feature paths found for: %S"
                        check))

      ;;---
      ;; Done; return.
      ;;---
      (cons path:root paths))))


;; TODO:test: Make unit test.
(defun int<imp>:feature:load (feature:base &rest feature)
  "Load to files for FEATURE:BASE + FEATURE.

This only provides the paths for the feature itself, each of which may
`imp:require' more features.

Returns or'd result of loading feature's files if feature is found;
returns non-nil if feature's files were all loaded successfully.

Raises an error if feature was not found."
  (let ((feature:paths (apply #'int<imp>:feature:paths feature:base feature))
        (feature:full (apply #'int<imp>:feature:normalize feature:base feature)))
    ;; Error checks done by `int<imp>:feature:paths'.

    ;; Load all the feature paths.
    (int<imp>:load:paths feature:full
                         (car feature:paths)
                         (cdr feature:paths))))


;; TODO:test: Make unit test.
(defun imp:feature:at (feature:base feature:alist)
  "Provide imp with an alist of imp features to paths/filenames.

This is used when `imp:require' is called for a sub-feature that isn't loaded.
imp will look in the `imp:path:roots' entry for the features file, load that
file, and then use the provided alist to find what files are required for said
sub-feature. If there is no features file, imp will load the root file. If there
is no root file, imp will attempt to load based on path.
  TODO: Do we want to have the path loading thing in still?

FEATURE:BASE should be your base feature's keyword.
  example: `:imp' is imp's FEATURE:BASE.

FEATURE:ALIST should be an alist with each entry in this format:
  '(normalized-feature . (file-path-0 ...))
  Which is equal to:
  '(normalized-feature file-path-0 ...)

Paths in the FEATURE:ALIST should be relative to your `imp:path:root'.

The paths will be loaded in the order provided.

For example:
  (list (list :imp \"init.el\")
        (list (imp:feature :imp path) \"path.el\")
        (list (imp:feature :imp multiple)
              \"multiple/foo.el\"
              \"multiple/subdir/bar.el\"
              \"multiple/subdir/baz.el\"
              \"common/baz.el\")
        ...)"
  ;; TODO: Verify alist formatting?
  (int<imp>:alist:update feature:base feature:alist imp:features:locate))
