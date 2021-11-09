;;; input/keyboard/layout/search.el -*- lexical-binding: t; -*-

;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║             Layout Definition & Keybind Mapping Functions              ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;             Keyboard-Layout-Aware `map!' equivalent and stuff!             ;;
;;                                 ──────────                                 ;;


(imp:require :input 'keyboard 'vars)
(imp:require :input 'keyboard 'layout 'types 'define)


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

;;------------------------------
;; Constants
;;------------------------------

(defconst int<keyboard>:layout/derive:search/skips
  '((:after . 2)
    (:map . 2)
    (:prefix . 2)
    (:leader . 1)
    (:localleader . 1)
    (:mode . 2)
    (:prefix-map . 2)
    (:textobj . 4)
    (:when . 2)
    (:unless . 2))
  "List of keywords and number of items (including keyword) to skip.")


(defconst int<keyboard>:layout/derive:search/ignores
  '(:derive)
  "List of keywords used to ignore entire lists during search.")


;;------------------------------------------------------------------------------
;; Normalization
;;------------------------------------------------------------------------------

(defun int<keyboard>:layout/derive:normalize->modifier (symbol)
  "Normalizes a symbol, quoted symbol, or keyword to a modifier keyword."
  (let ((symbol/in (doom-unquote symbol)))
    (cond ((keywordp symbol/in)
           symbol/in)
          ((symbolp symbol/in)
           (intern (concat ":" (symbol-name symbol/in))))
          (t
           (int<keyboard>:output :error
                                 '("int<keyboard>:layout/derive:normalize->modifier"
                                   "Unknown input type: %S. Not a keyword or symbol.")
                                 symbol)))))
;; (int<keyboard>:layout/derive:normalize->modifier ':control)
;; (int<keyboard>:layout/derive:normalize->modifier 'control)
;; (int<keyboard>:layout/derive:normalize->modifier (quote (quote control)))
;; (int<keyboard>:layout/derive:normalize->modifier 'unshift)
;; (int<keyboard>:layout/derive:normalize->modifier 'jeff)


;;------------------------------------------------------------------------------
;; Layout Derivations
;;------------------------------------------------------------------------------

(defun int<keyboard>:layout/derive:search/registered:in-list (func-or-kwd keymaps keywords)
  "Search KEYMAPS for a match to the desired FUNC-OR-KWD.

FUNC-OR-KWD should be the function or keyword to search for.

KEYMAPS should be a list suitable for `input:keyboard/layout:map!'.

KEYWORDS will be used to normalize FUNC-OR-KWD to a function.
It should be `int<keyboard>:layout/types:keywords'.

Returns keybind string or nil."
  ;;------------------------------
  ;; Keymaps
  ;;------------------------------
  (let ((debug/tags '(:derive :derive/search))
        (debug/name "int<keyboard>:layout/derive:search/registered:in-list")
        (func (int<keyboard>:layout/types:normalize->func func-or-kwd keywords)))
    (int<keyboard>:debug:func debug/name debug/tags
                              :start
                              (list (cons 'func-or-kwd func-or-kwd)
                                    (cons 'keymaps keymaps)
                                    (cons 'keywords keywords)))

    (let ((keymaps/len (length keymaps))
          (index 0)
          found/start
          found/keybind
          return/value)

      (while (and (not found/start)
                  (not found/keybind)
                  (< index keymaps/len))
        (let ((item (nth index keymaps)))
          (int<keyboard>:debug
              debug/name
              debug/tags
            "Start search here? index: %d, item: %S"
            index item)

          ;; Get past any `:map' or such.
          (cond ((and (keywordp item) ;; Currently everything in skips is a keyword.
                      (alist-get item int<keyboard>:layout/derive:search/skips))
                 ;; `:after <mode-name>'
                 ;; `:map <map-name'
                 ;; etc.
                 (setq index (+ index (alist-get item int<keyboard>:layout/derive:search/skips))))

                ((and (listp item)
                      (memq (car item) int<keyboard>:layout/derive:search/ignores))
                 (setq index (1+ index)))

                ((listp item)
                 ;; Search down into this list...
                 (int<keyboard>:debug
                     debug/name
                     debug/tags
                   "Search into list first: %d -> %S"
                   index item)

                 (setq found/keybind (int<keyboard>:layout/derive:search/registered:in-list func item keywords))

                 ;; And prep for if it failed to find anything.
                 (setq index (1+ index)))

                (t
                 (setq found/start index)))))

      (int<keyboard>:debug
          debug/name
          debug/tags
        "Start search at index %d: %S"
        index (nth index keymaps))

      ;; Return something now or finish searching the KEYMAPS.
      (setq return/value
            (cond (found/keybind
                   (int<keyboard>:debug
                       debug/name
                       debug/tags
                     "Already found: %d; found: %S"
                     index found/keybind)
                   found/keybind)

                  (found/start
                   ;; Search through the rest of the list for the FUNC.
                   (while (and (not found/keybind)
                               (< index keymaps/len))

                     ;; Want something like:
                     ;;   :nvm "." :layout:evil:line-prev
                     ;;   "." #'func
                     (let* ((item (nth index keymaps)))
                       (int<keyboard>:debug
                           debug/name
                           debug/tags
                         "Searching at: %d -> %S"
                         index item)

                       (cond
                        ;; A thing to search down into?
                        ((listp item)
                         (int<keyboard>:debug
                             debug/name
                             debug/tags
                           "Searching into list at: %d -> %S"
                           index item)

                         ;; Search down into this list...
                         (setq found/keybind (int<keyboard>:layout/derive:search/registered:in-list func item keywords))

                         ;; And prep for if it failed to find anything.
                         (setq index (1+ index)))

                        ;; Are we looking at: <states-keyword> <keybind> <func/func-keyword>?
                        ((condition-case nil
                             (doom--map-keyword-to-states item)
                           ;; Ignore error signal from `doom--map-keyword-to-states'.
                           (error nil))

                         (let ((check/key (nth (+ index 1) keymaps))
                               (check/func (int<keyboard>:layout/types:normalize->func (nth (+ index 2) keymaps)
                                                                                       keywords)))
                           (int<keyboard>:debug
                               debug/name
                               debug/tags
                             "Found evil states/key/bind at: %d -> %S %S %S"
                             index item check/key check/func)
                           (when (eq (doom-unquote check/func) (doom-unquote func))
                             (setq found/keybind check/key)))

                         (setq index (+ index 3)))

                        ;; Are we looking at: <keybind> <func/func-keyword>?
                        ((stringp item)
                         (let ((check/key (nth index keymaps))
                               (check/func (int<keyboard>:layout/types:normalize->func (nth (1+ index) keymaps)
                                                                                       keywords)))
                           (int<keyboard>:debug
                               debug/name
                               debug/tags
                             "Found emacs states/key/bind at: %d -> %S %S"
                             index item check/key check/func)

                           (setq index (+ index 2))

                           (when (eq (doom-unquote check/func) (doom-unquote func))
                             (setq found/keybind check/key))))

                        ;; Dunno. Skip.
                        (t
                         (setq index (1+ index))))))

                   (int<keyboard>:debug
                       debug/name
                       debug/tags
                     "Search result for: %d -> %S"
                     index found/keybind)
                   ;; Done searching - return whatever we did (or didn't) find.
                   found/keybind)

                  (t
                   (int<keyboard>:debug
                       debug/name
                       debug/tags
                     "Nothing at: %d"
                     index)
                   ;; Nothing of note in this KEYMAPS list?
                   nil)))

      ;; Debug and return it.
      (int<keyboard>:debug:func debug/name debug/tags
                                :end return/value)

      return/value)))


(defun int<keyboard>:layout/derive:search/registered (func-or-kwd registered-binds keywords)
  "Search REGISTERED-BINDS for a match to the desired FUNC-OR-KWD.

FUNC-OR-KWD should be the function/keyword to search for.

REGISTERED-BINDS should be `(int<keyboard>:registrar:get registrar :keybinds)'.

KEYWORDS will be used to normalize FUNC-OR-KWD to a function.
It should be `int<keyboard>:layout/types:keywords'.

Returns keybind string or nil."
  (let ((debug/tags '(:derive :derive/search))
        (func (int<keyboard>:layout/types:normalize->func func-or-kwd keywords))
        keybind-found
        (types int<keyboard>:layout:types))
    ;;------------------------------
    ;; Types: :evil, :emacs, :common
    ;;------------------------------
    (while (and (not keybind-found)
                types)
      (let* ((type (caar types)) ;; types is alist, and we want the keys.
             (keymaps (alist-get type registered-binds)))
        (setq types (cdr types)) ;; Drop current type kvp from alist.
        (int<keyboard>:debug
            "int<keyboard>:layout/derive:search/registered"
            debug/tags
          "search type: %S" type)

        ;; Search this type's list.
        (setq keybind-found (int<keyboard>:layout/derive:search/registered:in-list func keymaps keywords))))

    ;; Done searching - return whatever we did (or didn't) find.
    (if keybind-found
        (int<keyboard>:debug
            "int<keyboard>:layout/derive:search/registered"
            debug/tags
          "\n>>> [FOUND!]: %S" keybind-found)
      (int<keyboard>:debug
          "int<keyboard>:layout/derive:search/registered"
          debug/tags
        "\n>>> [absent]: %S" keybind-found))
    keybind-found))
;; `registered-binds' example:
;; (pp (int<keyboard>:registrar:get registrar :keybinds))
;; (int<keyboard>:layout/derive:search/registered
;;  'evil-org-open-below
;;  ;; :layout:evil:state-insert-before
;;  '((:evil
;;     (:prefix ("s" . "Evil States")
;;      :nv "h" :layout:evil:state-insert-before
;;      :nv "n" :layout:evil:state-insert-after
;;      :n "t" :layout:evil:state-insert-line-open-below
;;      :n "c" :layout:evil:state-insert-line-open-above
;;      :n (:derive 'shift :layout:evil:state-insert-before) :layout:evil:state-insert-line-start
;;      :n (:derive 'shift :layout:evil:state-insert-after) :layout:evil:state-insert-line-end
;;      :n (:derive 'shift :layout:evil:state-insert-line-open-below) :layout:evil:state-replace
;;      :m "v" :layout:evil:state-visual-char-wise
;;      :m "V" :layout:evil:state-visual-line-wise)
;;     :nvm "." :layout:evil:line-prev
;;     :nvm "e" :layout:evil:line-next
;;     :nvm "o" :layout:evil:char-prev
;;     :nvm "u" :layout:evil:char-next
;;     :m "A" :layout:evil:word-prev-begin
;;     :m (:derive 'shift :layout:evil:char-prev) :layout:evil:word-prev-end
;;     :m (:derive 'shift :layout:evil:char-next) :layout:evil:word-next-begin
;;     :m "I" :layout:evil:word-next-end
;;     :m (:derive 'meta 'unshift :layout:evil:word-prev-begin) :layout:evil:word-prev-begin-bigword
;;     :m (:derive 'meta 'unshift :layout:evil:word-prev-end) :layout:evil:word-prev-end-bigword
;;     :m (:derive 'meta 'unshift :layout:evil:word-next-begin) :layout:evil:word-next-begin-bigword
;;     :m (:derive 'meta 'unshift :layout:evil:word-next-end) :layout:evil:word-next-end-bigword
;;     :m "(" :layout:evil:sentence-begin-prev
;;     :m ")" :layout:evil:sentence-begin-next
;;     :m "{" :layout:evil:paragraph-prev
;;     :m "}" :layout:evil:paragraph-next
;;     :m (:derive 'control :layout:evil:line-prev) :layout:evil:scroll-up
;;     :m (:derive 'control :layout:evil:line-next) :layout:evil:scroll-down
;;     :m (:derive 'control 'meta :layout:evil:line-prev) :layout:evil:scroll-page-up
;;     :m (:derive 'control 'meta :layout:evil:line-next) :layout:evil:scroll-page-down
;;     :m (:derive 'control :layout:evil:char-prev) :layout:evil:line-begin
;;     :m (:derive 'control :layout:evil:char-next) :layout:evil:line-end
;;     (:after org
;;      :after evil-org
;;      :map evil-org-mode-map
;;      (:prefix ("s" . "Evil States")
;;       :n "t" #'evil-org-open-below)))))


(defun int<keyboard>:layout/derive:search/in-progress (states func in-progress-map-forms)
  "Search `doom--map-batch-forms' for a match to the desired FUNC.

STATES should be a list of the evil state(s) of the existing keybind.

FUNC should be the function to search for.

IN-PROGRESS-MAP-FORMS should be `doom--map-batch-forms'.

Returns keybind string or nil."
  (let ((debug/tags '(:derive :derive/search))
        keybind-found)
    (while (and (not keybind-found)
                states)
      (let* ((state (car states))
             (search/bindings (alist-get state in-progress-map-forms)))
        (int<keyboard>:debug
            "int<keyboard>:layout/derive:search/in-progress"
            debug/tags
          "search state: %S" state)
        (setq states (cdr states))
        ;; Go through `search/bindings' until we run out or find something to return.
        (while (and (not keybind-found)
                    search/bindings)
          ;; Split the first `search/bindings' entry into key string and binding item (list or func).
          (let* ((key (nth 0 (car search/bindings)))
                 (binding (nth 1 (car search/bindings))))
            ;; Update `search/bindings' for next loop.
            (setq search/bindings (cdr search/bindings))

            ;; What is `binding', anyways?
            ;;     ;; Just the function; use it.
            (cond ((functionp (doom-unquote binding))
                   ;; (int<keyboard>:debug
                   ;;     "int<keyboard>:layout/derive:search/in-progress"
                   ;;     debug/tags
                   ;;   "functionp %S == %S?: %S"
                   ;;   binding func
                   ;;   (eq (doom-unquote binding) (doom-unquote func)))

                   ;; If it's a match, save the key.
                   ;; Else ignore.
                   (when (eq (doom-unquote binding) (doom-unquote func))
                     (int<keyboard>:debug
                         "int<keyboard>:layout/derive:search/in-progress"
                         debug/tags
                       "functionp found %S -> %S" (doom-unquote func) key)
                     (setq keybind-found key)))

                  ;; A list which includes the function.
                  ((listp binding)
                   (int<keyboard>:debug
                       "int<keyboard>:layout/derive:search/in-progress"
                       debug/tags
                     "listp %S: t" binding)
                   ;; Find the function to return.
                   (dolist (each binding)
                     ;; If it's a function and matches, save the key.
                     ;; Else ignore.
                     (when (and (functionp (doom-unquote each))
                                (eq (doom-unquote each) (doom-unquote func)))
                       (int<keyboard>:debug
                           "int<keyboard>:layout/derive:search/in-progress"
                           debug/tags
                         "listp found %S -> %S" (doom-unquote func) key)
                       (setq keybind-found key))))

                  ;; Don't know - ignore? error?
                  (t
                   ;; Error for now - want to know about un-encountered types.
                   (int<keyboard>:output :error
                                         '("int<keyboard>:layout/derive:search/in-progress"
                                           "Don't know how to process this keybind setting "
                                           "in order to search it for '%s': %S")
                                         func
                                         binding)
                   nil))))))

    ;; Done searching - return whatever we did (or didn't) find.
    (if keybind-found
        (int<keyboard>:debug
            "int<keyboard>:layout/derive:search/in-progress"
            debug/tags
          "\n>>> [FOUND!]: %S" keybind-found)
      (int<keyboard>:debug
          "int<keyboard>:layout/derive:search/in-progress"
          debug/tags
        "\n>>> [absent]: %S" keybind-found))
    keybind-found))
;; (let ((batch-forms '((motion
;;                       ("h" #'evil-backward-char)
;;                       ("n" #'evil-forward-char)
;;                       ("t"
;;                        (list :def #'evil-next-line :which-key "hello"))
;;                       ("c" #'evil-previous-line))
;;                      (visual
;;                       ("h" #'evil-backward-char)
;;                       ("n" #'evil-forward-char)
;;                       ("t"
;;                        (list :def #'evil-next-line :which-key "hello"))
;;                       ("c" #'evil-previous-line))
;;                      (normal
;;                       ("h" #'evil-backward-char)
;;                       ("n" #'evil-forward-char)
;;                       ("t"
;;                        (list :def #'evil-next-line :which-key "hello"))
;;                       ("c" #'evil-previous-line)))))
;;   (int<keyboard>:layout/derive:search/in-progress '(motion) #'evil-next-line batch-forms)
;;   (int<keyboard>:layout/derive:search/in-progress '(motion) #'evil-previous-line batch-forms))


(defun int<keyboard>:layout/derive:search/existing (states func)
  "Search existing keybinds for a match to the desired FUNC.

STATES should be a list of the evil state(s) of the existing keybind.

FUNC should be the function to search for.

Uses general's `general-keybindings.

Returns keybind string or nil."
  (let ((search/maps general-keybindings)
        (debug/tags '(:derive :derive/search))
        keybind-found)
    (while (and (not keybind-found)
                states)
      (let ((state (car states)))
        (setq states (cdr states))

        ;; Search each keymap...
        (while (and (not keybind-found)
                    search/maps)
          ;; Split the first entry in `search/maps' up.
          (let* (;; For this symbol, we only care about the keybinds of `state'.
                 ;; So just get that state from the cdr/alist.
                 (search/bindings (alist-get state (cdar search/maps))))
            (int<keyboard>:debug
                "int<keyboard>:layout/derive:search/existing"
                debug/tags
              "bindings? %S"
              (not (null search/bindings)))
            (int<keyboard>:debug
                "int<keyboard>:layout/derive:search/existing"
                debug/tags
              "search/bindings is: %S"
              search/bindings)
            ;; Search state's keybinds...
            (while (and (not keybind-found)
                        search/bindings)
              (int<keyboard>:debug
                  "int<keyboard>:layout/derive:search/existing"
                  debug/tags
                "  checking binding: %S"
                (car search/bindings))
              ;; Split the first `search/bindings' entry into key string/vector and function bound.
              (let* ((bound-key (nth 0 (car search/bindings)))
                     (bound-func (nth 1 (car search/bindings))))
                (int<keyboard>:debug
                    "int<keyboard>:layout/derive:search/existing"
                    debug/tags
                  "    %S -> %S"
                  (int<keyboard>:output:normalize/key bound-key) func)

                ;; Update `search/bindings' for next loop.
                (setq search/bindings (cdr search/bindings))

                ;; Check for match.
                (when (eq (doom-unquote bound-func) (doom-unquote func))
                  (int<keyboard>:debug
                      "int<keyboard>:layout/derive:search/existing"
                      debug/tags
                    "found %S -> %S"
                    (doom-unquote func) bound-key)
                  (setq keybind-found bound-key)))))

          ;; Update loop variable for next iteration.
          (setq search/maps (cdr search/maps)))))

    ;; Done searching - return whatever we did (or didn't) find.
    (if keybind-found
        (int<keyboard>:debug
            "int<keyboard>:layout/derive:search/existing"
            debug/tags
          "\n>>> [FOUND!]: %S" keybind-found)
      (int<keyboard>:debug
          "int<keyboard>:layout/derive:search/existing"
          debug/tags
        "\n>>> [absent]: %S" keybind-found))
    keybind-found))
;; (int<keyboard>:layout/derive:search/existing '(normal) #'evil-backward-char)


;;------------------------------------------------------------------------------
;; API
;;------------------------------------------------------------------------------

;; TODO: Newparam KEYWORDS/REGISTERED for `keywords` param of `int<keyboard>:layout/derive:search/registered` call(s).
;;   - Add to docstr.
;;   - Add to callers - it should be `int<keyboard>:layout/types:keywords' for the real call(s).
(defun int<keyboard>:layout:derive (states keybinds/in-progress keybinds/registered keywords/registered args)
  "Derive a `kbd' string from another function/layout-keyword's keybinding.

STATES should be a list of the evil state(s) of the existing keybind.

KEYBINDS/IN-PROGRESS should be all the current/in-progress
`input//kl:layout:map-process' keybinds.
  - Which, currently, should be `doom--map-batch-forms'.

KEYBINDS/REGISTERED should be all the registered-but-not-yet-applied
`input//kl:layout:map-process' keybinds.
  - Which should be `(int<keyboard>:registrar:get registrar :keybinds)'.

We will look through that and bound keys to figure out the correct derivation,
preferring `existing' over currently bound keys.

ARGS should be a list of:
  - Modifier key symbols:
    + `control'/`:control'
    + `shift'/`:shift'
    + `unshift'/`:unshift'
    + `meta'/`:meta'
    + `alt'/`:alt'
    + `super'/`:super'
    + `hyper'/`:hyper'
  - Keyword or function to derive the keybind from. E.g.:
    + :layout:evil:char-prev
    + #'evil-backward-char

`input:keyboard/layout:map!' Usage Examples:
    :nvm  \"o\"                                                 :layout:evil:char-prev
    :m    (:derive 'shift :layout:evil:char-prev)             :layout:evil:word-prev-end
    :m    (:derive 'meta 'unshift :layout:evil:word-prev-end) :layout:evil:word-prev-end-bigword

Returns the derived kbd string.
Examples:
  1. If `:layout:evil:word-prev-end' is \"A\":
    (:derive 'meta 'unshift :layout:evil:word-prev-end)
      -> \"M-a\"
  2. If `:layout:evil:word-prev-end' is \"C-A\":
    (:derive 'meta :layout:evil:word-prev-end)
      -> \"M-C-A\""
  (let ((debug/tags '(:derive))
        modifiers
        keys)
    (int<keyboard>:debug
        "int<keyboard>:layout:derive"
        debug/tags
      "INPUTS: \n  states: %S\n  args: %S\n  in-progress: %S\n  registered: %S"
      states args keybinds/in-progress keybinds/registered)

    ;; Work through our args to build binding.
    (dolist (arg args)
      ;; What kind of arg is it?
      (cond ((memq (int<keyboard>:layout/derive:normalize->modifier arg)
                   '(:control :shift :meta ;; Common Modifiers
                     :alt :super :hyper    ;; Uncommon Modifiers
                     :unshift))            ;; Cheating a bit...
             (int<keyboard>:debug
                 "int<keyboard>:layout:derive"
                 debug/tags
               "derive found modifier: %S"
               arg)
             (push (int<keyboard>:layout/derive:normalize->modifier arg) modifiers))

            ;; Our keyword/function we want to derive from.
            ;; Find its keybind string.
            ((or (functionp (doom-unquote arg))
                 (keywordp arg))
             (when-let* ((func (int<keyboard>:layout/types:normalize->func arg keywords))
                         ;; Search for a keybind in order of what will be the bind when everything is applied and done.
                         (found (or
                                 ;; Search the in-progress keybinds for a match.
                                 (int<keyboard>:layout/derive:search/in-progress states
                                                                                 func
                                                                                 keybinds/in-progress)
                                 ;; Search the registered-but-not-applied keybinds for a match...
                                 (int<keyboard>:layout/derive:search/registered func
                                                                                keybinds/registered
                                                                                keywords/registered)
                                 ;; Search for an existing keybind.
                                 (int<keyboard>:layout/derive:search/existing states func))))
               ;; Found the keybind - save it.
               (int<keyboard>:debug
                   "int<keyboard>:layout:derive"
                   debug/tags
                 "derive found key: %S"
                 arg)
               (push found keys)))

            ;; Fallthrough: Failed to parse arg - error.
            (t
             (int<keyboard>:debug
                 "int<keyboard>:layout:derive"
                 debug/tags
               "derive found nothing - error: %S"
               arg)
             (int<keyboard>:output :error"int<keyboard>:layout:derive"
                                   "Don't know how to process '%S' (type: %S) for deriving keybind. derivation: %S"
                                   arg
                                   (type-of arg)
                                   args))))

    (int<keyboard>:debug
        "int<keyboard>:layout:derive"
        debug/tags
      "\n  --> Final Modifiers: %S"
      modifiers)
    (int<keyboard>:debug
        "int<keyboard>:layout:derive"
        debug/tags
      "\n  --> Final Keys: %S"
      keys)

    ;; Not sure what to do about trying to derive a 'control' keybind from a base of e.g. "mtt".
    ;; Do they want "C-m tt"? "C-m C-t C-t"?
    (when (and (> (length keys) 1)
               (> (length modifiers) 0)
               ;; Can probably let shift through? Would end up as, I think, "Mtt" currently.
               ;; Maybe they want "MTT"?
               (not (eq modifiers '(shift))))
      ;; Error until a good solution is figured out.
      (int<keyboard>:output :error
                            "int<keyboard>:layout:derive"
                            '("Don't have a good solution for deriving from multi-key sequences... "
                              "modifiers: %S, original keybind: %S")
                            modifiers
                            keys))

    ;; Join together the modifiers and keys to create the derived keybind.
    (let (mod/string
          ;; nil - no change, :lower - downcase/lowercase, :upper - uppercase/upcase
          (string/case nil))
      ;; Process modifiers.
      (dolist (mod/symbol modifiers)
        ;; Convert 'control -> "C-", etc for other modifiers.
        ;; Don't know an actual Emacs function that does this.
        (cond ((eq mod/symbol :control)
               (setq mod/string (concat mod/string "C-")))
              ((eq mod/symbol :shift)
               ;; Shift should be capital "S"? But it isn't working for me.
               ;; (setq mod/string (concat mod/string "S-"))
               ;; Instead let's try upcasing.
               (setq string/case :upper))
              ((eq mod/symbol :unshift)
               ;; Unshift is for downcasing a capital letter "S"->"s".
               ;; Also needs to 'downcase' "S-s" to "s"?
               (setq string/case :lower))
              ((eq mod/symbol :meta)
               (setq mod/string (concat mod/string "M-")))
              ((eq mod/symbol :hyper)
               (setq mod/string (concat mod/string "H-")))
              ((eq mod/symbol :super)
               ;; Super is lowercase 's'.
               (setq mod/string (concat mod/string "s-")))
              ((eq mod/symbol :alt)
               (setq mod/string (concat mod/string "A-")))
              (t
               (int<keyboard>:output :error
                                     "int<keyboard>:layout:derive"
                                     "Don't know how to process modifier '%s' for deriving keybind: %S"
                                     mod/symbol
                                     args))))

      ;; Check our `keys'? Zero is bad; more than one might be weird...
      (cond ((= (length keys) 0)
             (int<keyboard>:output :error
                                   "int<keyboard>:layout:derive"
                                   "No keybind found for: %S"
                                   args))

            ((> (length keys) 1)
             (int<keyboard>:output :error
                                   "int<keyboard>:layout:derive"
                                   '("Not currently sure what to do with more than one keybind string. "
                                     "Found: %S, Args: %S")
                                   keys
                                   args))

            ;; Only one result in keys. Create and return resultant derived keybind string.
            (t
             ;; But do we first have to recurse because we're deriving from a derive?
             (cond
              ;; Nope; this is good.
              ((and (listp keys)
                    (stringp (car keys)))
               (int<keyboard>:debug
                   "int<keyboard>:layout:derive"
                   debug/tags
                 "\n[DERIVE]\n>>>>> %S <-- %S"
                 (concat mod/string (key-description
                                     (int<keyboard>:layout/derive:normalize-keys keys string/case)))
                 args)
               (concat mod/string (key-description
                                   (int<keyboard>:layout/derive:normalize-keys keys string/case))))

              ;; Yep; search for what this key is derived from.
              ((and (listp keys)
                    (eq (car keys) :derive))
               (int<keyboard>:debug
                   "int<keyboard>:layout:derive"
                   debug/tags
                 "\n  --> RECURSIVE DERIVE: %S\n[DERIVE:recurse-start]"
                 keys)

               ;; Get recursion result.
               (setq keys (int<keyboard>:layout:derive states
                                                   keybinds/in-progress
                                                   keybinds/registered
                                                   (cdr keys)))
               (int<keyboard>:debug
                   "int<keyboard>:layout:derive"
                   debug/tags
                 "\n[DERIVE:recurse-end]\n[DERIVE]\n>>>>> %S <-- %S"
                 (concat mod/string (key-description
                                     (int<keyboard>:layout/derive:normalize-keys keys string/case)))
                 args)
               (concat mod/string (key-description
                                   (int<keyboard>:layout/derive:normalize-keys keys string/case))))

              ;; No idea - error.
              (t
               (int<keyboard>:debug
                   "int<keyboard>:layout:derive"
                   debug/tags
                 "\n  --> RECURSIVE DERIVE: %S\n[DERIVE:recurse-start]"
                 keys))))))))
;; (let ((batch-forms '((motion
;;                       ("h" #'evil-backward-char)
;;                       ("n" #'evil-forward-char)
;;                       ("t"
;;                        (list :def #'evil-next-line :which-key "hello"))
;;                       ("C" #'evil-previous-line))
;;                      (visual
;;                       ("h" #'evil-backward-char)
;;                       ("n" #'evil-forward-char)
;;                       ("t"
;;                        (list :def #'evil-next-line :which-key "hello"))
;;                       ("C" #'evil-previous-line))
;;                      (normal
;;                       ("h" #'evil-backward-char)
;;                       ("n" #'evil-forward-char)
;;                       ("t"
;;                        (list :def #'evil-next-line :which-key "hello"))
;;                       ("C" #'evil-previous-line)))))
;;   ;; Should get "C-h" because char-prev is "h".
;;   (int<keyboard>:layout:derive '(motion) batch-forms '(control :layout:evil:char-prev))
;;   ;; Should get "c" from unshifting "C".
;;   (int<keyboard>:layout:derive '(motion) batch-forms '(unshift #'evil-previous-line)))


;; TODO: This?
;; (defun int<keyboard>:layout/derive:modifier-str? (key-str)
;;   "Returns non-nil if KEY-STR is a modifier string.
;;
;; Modifier strings are:
;;   - control: \"C-a\"
;;   - shift:   \"S-a\"
;;   - meta:    \"M-a\"
;;   - alt:     \"A-a\"
;;   - super:   \"s-a\"
;;   - hyper:   \"H-a\""
;;
;;   )

(defun int<keyboard>:layout/derive:normalize-keys (keys case)
  "Normalize input params to a key string.

KEYS should be a list of strings.

CASE should be:
  - nil (no change)
  - :upper (upcase/uppercase)
  - :lower (lowercase/downcase)"
  ;; Validate KEYS.
  (dolist (each keys)
    (unless (stringp each)
      (int<keyboard>:output :error
                            "int<keyboard>:layout/derive:normalize-key"
                            '("KEYS must contain all strings - found '%S' "
                              "(type '%S') in it: %S")
                            each
                            (type-of each)
                            keys)))

  ;; Normalize KEYS list to a string. Expecting it to be backwards from
  ;; `push'ing elements on.
  (let ((key (apply #'concat (reverse keys)))
        (debug/tags '(:derive :derive/normalize)))
    ;; "S-" doesn't work, turns out, so I'm removing it from the code in baby steps...
    ;; TODO: delete this
    ;; ;; Get rid of any "shift modifiers" in it.
    ;; (setq key (replace-regexp-in-string "S-" "" key))

    ;; Valid: To lower/upper cases.
    (cond ((eq case :upper)
           (int<keyboard>:debug "int<keyboard>:layout/derive:normalize-key"
               debug/tags
             "UPPERCASE: keys: %S, case: %S -> %S"
             keys case (upcase key))
           (upcase key))
          ((eq case :lower)
           (int<keyboard>:debug "int<keyboard>:layout/derive:normalize-key"
               debug/tags
             "lowercase: keys: %S, case: %S -> %S"
             keys case (upcase key))
           (downcase key))

          ;; Valid: "Do nothing" case.
          ((null case)
           (int<keyboard>:debug "int<keyboard>:layout/derive:normalize-key"
               debug/tags
             "As-Is: keys: %S, case: %S -> %S"
             keys case (upcase key))
           ;; No normalizing needs done; just return as-is.
           key)

          ;; Invalid: CASE is wrong.
          (t
           (int<keyboard>:output :error
                                 "int<keyboard>:layout/derive:normalize-key"
                                 "Unknown CASE input: %s. Valid inputs are: %S"
                                 case
                                 '(nil :lower :upper))))))
;; (int<keyboard>:layout/derive:normalize-keys '("LLO" "he") nil)
;; (int<keyboard>:layout/derive:normalize-keys '("LLO" "he") :lower)
;; (int<keyboard>:layout/derive:normalize-keys '("LLO" "he") :upper)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide :input 'keyboard 'layout 'derive)
