;;; emacs/imp/utils.el -*- lexical-binding: t; -*-


;;------------------------------------------------------------------------------
;; Loaded Features Tree
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
  (let (output)
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
              (int<imp>:error "imp:feature:normalize"
                              (concat "Cannot convert INPUT item type to a symbol. "
                                      "Need a string or symbol/keyword. Got: %S")
                              item)))
       output))

    ;; Return the list, the one item, or what?
    (cond ((null output)
           (int<imp>:error "imp:feature:normalize"
                           "No normalized features produced from INPUT: %S"
                           input))

          ((= 1 (length output))
           (nth 0 output))

          (t
           (nreverse output)))))
;; (imp:feature:normalize '+layout/spydez)
;; (imp:feature:normalize :spydez)
;; (imp:feature:normalize "spydez")
;; (imp:feature:normalize "+spydez")
;; (imp:feature:normalize "+spydez" "foo" "bar")


;;------------------------------------------------------------------------------
;; Add Feature.
;;------------------------------------------------------------------------------

(defun int<imp>:feature:add (feature)
  "Add the FEATURE (a list of keywords/symbols) to the `imp:features' tree."
  (int<imp>:debug "int<imp>:feature:add" "Adding to imp:features...")
  (int<imp>:debug "int<imp>:feature:add" "  feature: %S" feature)
  (int<imp>:debug "int<imp>:feature:add" "imp:features before:\n%S"
                  (pp-to-string imp:features))
  (setq imp:features (int<imp>:tree:update feature nil imp:features))
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
