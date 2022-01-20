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

NOTE: Use `equal' for the `imp<alist>:[...]' EQUAL-FN params!

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
;; (pp imp:features:locate)
;; (setq imp:features:locate nil)


(defconst int<imp>:features:locate:equal #'equal
  "Supply as EQUAL-FN param to all 'imp/alist.el' functions used
by `imp:features:locate'.")


;;------------------------------------------------------------------------------
;; Feature Helpers
;;------------------------------------------------------------------------------

(defun int<imp>:feature:exists? (features)
  "Checks for list of FEATURES in the `imp:features' tree."
  ;; When not `imp:features', always return `nil'.
  (when imp:features
    (not (null (int<imp>:tree:contains? features imp:features)))))
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


(defun int<imp>:feature:normalize:imp->emacs (feature &rest features)
  "Translate the feature to a single symbol appropriate for Emacs' `provide'.

FEATURE should be:
  1) A keyword/symbol,
  2) or a list of keywords/symbols.

FEATURES should be:
  1) A keyword/symbol,
  2) or a list of keywords/symbols.

FEATURE & FEATURES will be combined & flattened into a single list of keywords
and/or symbols."
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
              (int<imp>:list:flatten feature features)
              int<imp>:feature:replace:separator)))
;; (int<imp>:feature:normalize:imp->emacs '(:imp test symbols))
;; (int<imp>:feature:normalize:imp->emacs '(:imp test) 'symbols)
;; (int<imp>:feature:normalize:imp->emacs '(:imp provide))
;; (int<imp>:feature:normalize:imp->emacs :imp 'provide)
;; (int<imp>:feature:normalize:imp->emacs '(((:imp))) '((provide)))


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
        (flattened (int<imp>:list:flatten input)) ;; Flatten max of 10 times.
        output)
    (dolist (item flattened)
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
;; (int<imp>:feature:normalize '("+spydez" "foo" "bar"))
;; (int<imp>:feature:normalize '(("+spydez" "foo" "bar")))
;; (int<imp>:feature:normalize '(((:test))) '(("+spydez" "foo" "bar")))


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
  (let* ((normalized (int<imp>:feature:normalize input)))
    ;; Return the list, the one item, or error?
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
;; (imp:feature:normalize '("+spydez" "foo" "bar"))


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
                    (imp:feature:normalize (list feature:base feature)))))


;;------------------------------------------------------------------------------
;; Features & Paths to them
;;------------------------------------------------------------------------------

(defun int<imp>:feature:paths (feature:base &rest feature)
  "Find (relative) path(s) to files for FEATURE:BASE + FEATURE.

This only provides the paths for the feature itself, each of which may
`imp:require' more features.

Returns list of: '(path:root . (paths:relative))

Errors if:
  - No root path for FEATURE:BASE.
  - No paths found for input parameters."
  (let ((func.name "int<imp>:feature:paths")
        (check (int<imp>:feature:normalize feature:base feature)))

    ;;------------------------------
    ;; Error Check Inputs
    ;;------------------------------
    ;; FEATURE:BASE must:
    ;; 1) Be an imp feature.
    ;; (imp:feature:assert feature:base)
    ;;   ...must it be a feature? Not so sure. All I /think/ we need is the entries in
    ;;   `imp:path:roots' and `imp:features:locate' and the

    ;; 2) Have registered a root path.
    (unless (int<imp>:path:root/contains? feature:base)
      (int<imp>:error func.name
                      "Feature `%S' does not have a root path in imp."
                      feature:base))

    ;;------------------------------
    ;; Get the paths and load them?
    ;;------------------------------
    (let* ((path:root (int<imp>:path:root/dir feature:base))
           ;; TODO: Fix alist to work for lists of keywords/symbols
           (feature:locations (int<imp>:alist:get/value feature:base
                                                        imp:features:locate
                                                        int<imp>:features:locate:equal))
           (paths (int<imp>:alist:get/value check
                                            feature:locations
                                            int<imp>:features:locate:equal)))

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


(defun imp:feature:at (feature:base feature:alist)
  "Provide imp with an alist of imp features to paths/filenames.

This is used when `imp:require' is called for a sub-feature that isn't loaded.
imp will look in the `imp:path:roots' entry for the features file, load that
file, and then use the provided alist to find what files are required for said
sub-feature. If there is no features file, imp will load the root file.

FEATURE:BASE should be your base feature's keyword.
  example: `:imp' is imp's FEATURE:BASE.

FEATURE:ALIST should be an alist with each entry in this format:
  '(feature-keyword-or-list . (file-path-0 ...))
  Which is equal to:
  '(feature-keyword-or-list file-path-0 ...)

Features in the FEATURE:ALIST should:
  1) Not be normalized:
     e.g. '(:imp path) instead of (imp:feature :imp path)
  2) Be either:
     a) The base feature keyword (e.g. `:imp').
     b) A list of the base feature keyword plus other symbols (e.g. `(:imp path)').

Paths in the FEATURE:ALIST should be relative to your `imp:path:root'.

The paths will be loaded in the order provided.

For example:
  '((:imp        \"init.el\")
    ((:imp path) \"path.el\")
    ((:imp multiple)
     \"common/foo.el\"
     \"multiple/bar.el\"
     \"multiple/subdir/baz.el\"
     \"multiple/subdir/qux.el\")
    ...)"
  (let ((func.name "imp:feature:at")
        features:at)
    ;;------------------------------
    ;; Verify Inputs.
    ;;------------------------------

    ;;---
    ;; FEATURE:BASE root path needs to exist already.
    ;;---
    (unless (keywordp feature:base)
      (int<imp>:error func.name
                      "FEATURE:BASE must be a keyword! Got: %S"
                      feature:base))
    (if-let ((feature:base:path (int<imp>:path:root/dir feature:base)))
        (unless (stringp feature:base:path)
          (int<imp>:error func.name
                          "Registered root path for FEATURE:BASE must be a string! Got: %S"
                          feature:base:path))
      (int<imp>:error func.name
                      '("FEATURE:BASE must have a registered root path! "
                        "Did not find it in `imp:path:roots'.")))

    ;;---
    ;; FEATURE:ALIST must be valid format.
    ;;---
    ;; Massage into shape for adding to alist while we verify.
    (dolist (entry feature:alist)
      (let ((feature (car entry))
            (paths   (cdr entry)))
        ;; Must have either just a keyword, or a list of symbols (starting with keyword).
        (unless (or (keywordp feature)
                    (and (listp feature)
                         (keywordp (car feature))
                         (seq-each #'symbolp feature)))
          (int<imp>:error func.name
                          '("FEATURE:ALIST entry `%S' has an invalid feature! "
                            "Must be a keyword or list of symbols (starting w/ keyword). "
                            "Got: %S")
                          entry
                          feature))
        ;; Must have one string or list of strings for the paths.
        (unless (or (stringp paths)
                    (and (listp paths)
                         (seq-each #'stringp paths)))
          (int<imp>:error func.name
                          '("FEATURE:ALIST entry `%S' has invalid path(s)! "
                            "Must be a path string or a list of path strings. "
                            "Got: %S")
                          entry
                          paths))

        ;; Valid; finalize and add to alist.
        (push (cons (int<imp>:feature:normalize feature)
                    (seq-map #'int<imp>:path:sans-extension paths))
              features:at)))

    ;; We should have created something. Error if not.
    (unless features:at
      (int<imp>:error func.name
                      '("Nothing created to be added.. No input? FEATURE:ALIST: %S -> `features:at': %S")
                      feature:alist
                      features:at))

    ;;------------------------------
    ;; Add to the features locations alist.
    ;;------------------------------
    ;; Return their created alist if we succeeded. `nil' if failed.
    (if (int<imp>:alist:update feature:base
                               features:at
                               imp:features:locate
                               int<imp>:features:locate:equal)
        features:at
      nil)))
