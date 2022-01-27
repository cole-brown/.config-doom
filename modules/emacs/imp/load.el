;;; emacs/imp/load.el -*- lexical-binding: t; -*-

;;                                 ──────────                                 ;;
;; ╔════════════════════════════════════════════════════════════════════════╗ ;;
;; ║                               Load Files                               ║ ;;
;; ╚════════════════════════════════════════════════════════════════════════╝ ;;
;;                                   ──────                                   ;;
;;                    Load with, or without, timing info.
;;                                 ──────────                                 ;;


;;------------------------------------------------------------------------------
;; Internal Load Functions
;;------------------------------------------------------------------------------

(defun int<imp>:load:file (filepath)
  "Loads FILEPATH.

Lexically clears `file-name-handler-alist' for loading.

Calls `load' with errors allowed and `nomessage' set.

Returns result of `load' or signals error."
  (let ((func.name "int<imp>:load:file"))
    (int<imp>:debug func.name
                    "load filepath '%s'..."
                    filepath)

    (condition-case-unless-debug err
        ;; Set `file-name-handler-alist' to nil so we can `load' without it,
        ;; then load and save result for return value.
        (let* (file-name-handler-alist
               (loaded (load filepath nil 'nomessage)))
          (int<imp>:debug func.name
                          "loaded '%s': %S"
                          filepath
                          loaded)
          loaded)
      (error (int<imp>:error "int<imp>:load:file"
                             "imp fail to load filepath: %s\n  - error: %S"
                             filepath
                             err)))))


(defun int<imp>:load:paths (feature path:root paths:relative)
  "Load PATHS:RELATIVE files (list of path strings relative to PATH:ROOT path string).

Returns or'd result of loading feature's files if feature is found;
returns non-nil if feature's files were all loaded successfully.

FEATURE is only for `imp:timing' use."
  (let ((func.name "int<imp>:load:paths")
        (load-result t))
    (int<imp>:debug func.name
                    '("Inputs:\n"
                      "  feature:        %S\n"
                      "  path:root:      %s\n"
                      "  paths:relative: %S")
                    feature
                    path:root
                    paths:relative)

    ;; Get full path and load file.
    ;; Return `load-result' when done with loading.
    ;; TODO: map/reduce instead of dolist?
    (dolist (relative paths:relative load-result)
      (let ((path:absolute (int<imp>:path:normalize path:root relative :file:load)))
        (int<imp>:debug func.name
                        '("loading:\n"
                          "  root:             %s\n"
                          "  relative:         %s\n"
                          "-> `path:absolute': %s")
                        path:root
                        relative
                        path:absolute)
        (setq load-result (and load-result
                              ;; Time this load if timing is enabled.
                              (imp:timing
                                  feature
                                  (int<imp>:path:filename path:absolute)
                                  (int<imp>:path:parent   path:absolute)
                                (int<imp>:load:file path:absolute))))))))


(defun int<imp>:load:feature (&rest feature)
  "Load a FEATURE.

Loads the feature based on its entries in `imp:path:roots' and
`imp:features:locate'.

FEATURE must be a keyword or list of keywords/symbols.

Let `feature:base' be FEATURE (if just a keyword) or `(car FEATURE)' if a list.
Let `feature:rest' be nil (if FEATURE is just a keyword), or `(cdr FEATURE)'.
  - `feature:base' must be an entry in the `imp:path:roots' alist
    (set via the `imp:path:root'function).
  - `feature:base' must be an entry in the `imp:features:locate' alist, its
     value should be an alist, and `feature:rest' must exist in that value's
     alist.

For Example:
  When:
    (imp:path:root :imp \"/path/to/imp-root\")
    (imp:feature:at :imp
                    '((:imp           \"init.el\")
                      ((:imp provide) \"provide.el\")
                      ...))
  Then this:
    (int<imp>:load:feature :imp 'provide)
  Will try to load:
    \"/path/to/imp-root/provide.el\"

Does nothing if:
  1) `imp' already has the feature, or
  2) Emacs already has a feature named:
     `(int<imp>:feature:normalize:imp->emacs FEATURE:BASE FEATURE)'

Returns non-nil if loaded."
  (let* ((func.name "int<imp>:load:feature")
         (feature:normal (int<imp>:feature:normalize feature))
         (feature:base (car feature:normal))
         (feature:rest (cdr feature:normal))
         (feature:emacs (int<imp>:feature:normalize:imp->emacs feature:normal))
         (feature:emacs/base (int<imp>:feature:normalize:imp->emacs feature:base))
         (feature:emacs/rest (if feature:rest
                                 (int<imp>:feature:normalize:imp->emacs feature:rest)
                               nil)))
    (int<imp>:debug func.name
                    '("Inputs:\n"
                      "  - feature: %S\n"
                      "Normalized:\n"
                      "  - feature: %S\n"
                      "  - base:    %S\n"
                      "  - rest:    %S\n"
                      "  - emacs:   %S\n"
                      "    - feature:    %S\n"
                      "    - subfeature: %S")
                    feature
                    feature:normal
                    feature:base
                    feature:rest
                    feature:emacs
                    feature:emacs/base
                    feature:emacs/rest)

    ;;------------------------------
    ;; No path root?
    ;;------------------------------
    ;; If we don't even have the root, we can't really do anything. So just ask
    ;; for the root directory and allow the error if it's not in
    ;; `imp:path:roots'.
    (int<imp>:path:root/dir feature:base)

    ;;------------------------------
    ;; Load the features file?
    ;;------------------------------
    (unless (int<imp>:feature:locations feature:base)
      (int<imp>:debug func.name
                      "No feature locations for `%S'; looking for features file..."
                      feature:base)
      ;; `int<imp>:path:root/file/features' will error if no suitable file exists.
      (let ((path:features (int<imp>:path:root/file/features feature:base)))
        ;; This should error if file fails to load.
        (int<imp>:load:file path:features)
        (int<imp>:debug func.name
                        "Loaded features for `%S' from: %s"
                        feature:base
                        path:features)))

    (cond
     ;;------------------------------
     ;; Already Loaded?
     ;;------------------------------
     ;; Does imp already have the feature loaded?
     ((imp:provided? feature:normal)
      (int<imp>:debug func.name
                      "Feature is already provided by imp: %S"
                      feature:emacs)
      t)
     ;; Does Emacs already have full feature name?
     ((featurep feature:emacs)
      (int<imp>:debug func.name
                      "Feature is already provided by Emacs (not imp): %S"
                      feature:emacs)
      t)
     ;; Does Emacs already have `feature:base' with subfeature `feature:rest'?
     ((and feature:emacs/rest
           (featurep feature:emacs/base feature:emacs/rest))
      (int<imp>:debug func.name
                      "Feature & subfeature are already provided by Emacs (not imp): %S w/ %S"
                      feature:emacs/base
                      feature:emacs/rest)
      t)

     ;;------------------------------
     ;; imp: Attempt Loading...
     ;;------------------------------
     ((if-let* ((paths:feature (int<imp>:feature:paths feature:base feature:rest))
                (path:root (car paths:feature))
                (paths:load (cdr paths:feature)))
          ;; Required path(s) present; try to load the feature.
          (progn
            (int<imp>:debug func.name
                            '("Found feature paths for `%S': \n"
                            "  - root: %s\n"
                            "  - load-paths: %S")
                            feature:base
                            path:root
                            paths:load)
            ;; Try to load full feature using paths we found.
            (if-let ((result (int<imp>:load:paths feature:normal
                                                  path:root
                                                  paths:load)))
                (progn
                  (int<imp>:debug func.name
                                  "loaded `%S'"
                                  feature:normal)
                  result)

              (int<imp>:debug func.name
                              "failed loading `%S'"
                              feature:normal)
              result))
        ;; Required paths not present; can't load.
        (int<imp>:debug func.name
                        '("Required feature paths not found for `%S':\n"
                          "  - root: %s\n"
                          "  - load-paths: %S")
                        feature:base
                        path:root
                        paths:load)
        nil))

     ;;------------------------------
     ;; Final attempt: Try to just `require' it.
     ;;------------------------------
     ;; TODO: Not sure how to get here right now? Test doesn't reach this.
     (t
      (require feature:emacs
               nil
               'noerror)))))
;; (int<imp>:load:feature :imp 'something)
;; (int<imp>:load:feature :config 'spy 'system 'config)


;;------------------------------------------------------------------------------
;; Load API
;;------------------------------------------------------------------------------

(defun int<imp>:load:parse (caller path:current-dir plist-symbol-name plist)
  "Parses `imp:load' args. See `imp:load' for details.

CALLER should be \"imp:load\".

PATH:CURRENT-DIR should be the return value of `(int<imp>:path:current:dir)',
executed in the context of the file calling CALLER.
  - That is, CALLER is probably a macro.

PLIST-SYMBOL-NAME should be \"load-args-plist\".
PLIST should be `load-args-plist'.

Returns a plist:
  - :path
    + Path string to load file.
  - :feature
    + imp feature keyword/symbol list
  - :error
    - t/nil"
  ;; Valid keys:
  (let ((keys:valid '(:path :filename :feature :error))
        ;; Parsing vars.
        keys:parsed
        parsing:done
        ;; Input parsed values:
        in:path
        in:filename
        in:feature
        in:error
        ;; Output default values:
        out:path
        out:feature
        (out:error t))

    (int<imp>:debug caller
                    '("inputs:\n"
                      "caller:            %S\n"
                      "path:current-dir:  %S\n"
                      "plist-symbol-name: %S\n"
                      "plist:\n"
                      "    %S\n")
                    caller
                    path:current-dir
                    plist-symbol-name
                    plist)

    ;;------------------------------
    ;; Parse Inputs
    ;;------------------------------
    ;; Parse PLIST for expected keys. Error on unexpected.
    ;; Dismantle PLIST itself as we parse.
    (while (and plist
                (not parsing:done))
      (int<imp>:debug caller
                      "  parse plist: \n      %S"
                      plist)

      (let ((key   (car plist))
            (value (cadr plist)))
        (int<imp>:debug caller
                        '("\n"
                          "    key:   %S\n"
                          "    value: %S\n")
                        key value)

        ;;---
        ;; Sanity checks:
        ;;---
        (unless (keywordp key)
          (int<imp>:error caller
                          '("Malformed %s plist! "
                            "Parsing plist expected a keyword but got: %S")
                          plist-symbol-name
                          key))
        (unless (memq key keys:valid)
          (int<imp>:error caller
                          '("Unknown keyword %S in %s plist! "
                            "Valid keywords are: %S")
                          key
                          plist-symbol-name
                          keys:valid))
        (when (memq key keys:parsed)
          (int<imp>:error caller
                          '("Duplicate key `%S' in %s plist! "
                            "Already have `%S' value: %S")
                          key
                          plist-symbol-name
                          key
                          (cond ((eq key :path)
                                 path)
                                ((eq key :filename)
                                 filename)
                                ((eq key :feature)
                                 feature)
                                ((eq key :error)
                                 error))))

        ;;---
        ;; Update variables for next loop's processing.
        ;;---
        (setq plist (cddr plist))
        (push key keys:parsed)

        ;;---
        ;; Valid `key'; just save value.
        ;;---
        ;; Verify value later if necessary.
        (cond ((eq key :path)
               (setq in:path value))
              ((eq key :filename)
               (setq in:filename value))
              ((eq key :feature)
               ;; Allow FEATURE to be a single thing, a flat list, or a list that needs flattened...
               (setq in:feature (int<imp>:list:flatten value)))
              ((eq key :error)
               (setq in:error value)))))

    ;;------------------------------
    ;; Check for required inputs.
    ;;------------------------------

    (unless (memq :feature keys:parsed)
      (int<imp>:error caller
                      '("Required `:feature' keyword not present in plist "
                        "`%s': %S")
                      plist-symbol-name
                      plist))
    (unless (or (memq :path keys:parsed)
                (memq :filename keys:parsed))
      (int<imp>:error caller
                      '("No file inputs? "
                        "Either `:path', `:filename', or both are required in plist "
                        "`%s': %S")
                      plist-symbol-name
                      plist))

    ;;------------------------------
    ;; Prep Outputs:
    ;;------------------------------
    ;;---
    ;; Process FEATURE.
    ;;---
    (unless in:feature
      (int<imp>:error caller
                        '("Required `:feature' value not present."
                          "PATH and current directory are not strings. path: %S, current-dir: %S")
                        in:filename
                        in:path
                        path:current-dir))

    ;; Normalize FEATURE to a list.
    (setq out:feature (int<imp>:feature:normalize in:feature))
    (int<imp>:debug caller "out:feature: %S" out:feature)

    ;;---
    ;; Process PATH & FILENAME into single output path.
    ;;---
    ;; Need FEATURE first.

    ;; 0) Ease-of-use: Promote PATH to FILENAME if only PATH was provided.
    ;;---
    (unless in:filename
      (setq in:filename in:path
            in:path nil))

    ;; 1) Check PATH first so we can have it for FILENAME if needed.
    ;;---
    ;; Prefer provided path, then look for the root, then use `path:current-dir'.
    (let ((path (or in:path
                    (int<imp>:path:root/dir (nth 0 out:feature) :no-error)
                    path:current-dir)))
      (unless (stringp path)
        (int<imp>:error caller
                        '("Could not determine a path to look for filename: '%s' "
                          "PATH and current directory are not strings. path: %S, current-dir: %S")
                        in:filename
                        in:path
                        path:current-dir))
      ;; Update input path to final value.
      (setq in:path path))

    ;; 2) Finalize output path, using PATH if FILENAME is a relative path.
    ;;---
    (setq out:path (expand-file-name in:filename in:path))
    (int<imp>:debug caller "out:path:    %S" out:path)

    ;;---
    ;; ERROR
    ;;---
    ;; It just needs to be nil or not.
    ;; NOTE: Make sure to use existing `out:error' as default value if no in:error!
    ;;   - So we need to know if that key was encountered.
    (if (not (memq :error keys:parsed))
        ;; Not encountered; leave as the default.
        (int<imp>:debug caller "out:error:   %S (default)" out:error)

      ;; Parsed explicitly - set exactly.
      (setq out:error (not (null in:error)))
      (int<imp>:debug caller "out:error:   %S (parsed)" out:error))

    ;;------------------------------
    ;; Return:
    ;;------------------------------
    (list :path     out:path
          :feature  out:feature
          :error    out:error)))
;; (let ((load-args-plist '(:feature (:foo bar)
;;                          :path "init.el"
;;                          ;; :path
;;                          ;; :filename
;;                          ;; :error nil
;;                          )))
;;   ;; (message "%S" load-args-plist))
;;   (int<imp>:load:parse "imp:load"
;;                        (int<imp>:path:current:dir)
;;                        (upcase "load-args-plist")
;;                        load-args-plist))


;; Based off of Doom's `load!' macro.
(defmacro imp:load (&rest load-args-plist)
  "Load a file relative to the current executing file (`load-file-name').

LOAD-ARGS-PLIST is a plist of load args:
  - Required:
    + `:feature'
  - One or both:
    + `:filename'
    + `:path'
  - Optional:
    + `:error'
      - Defaults to `t'; supply `:error nil' to change.

`:feature' value should be a list of keywords and symbols.
  - example: '(:imp load)

`:filename' value (aka FILENAME) can be:
  - A path string (to a file).
  - A list of strings to join into a path (to a file).
  - A form that should evaluate to one of the above.

When FILENAME is a relative path and PATH is nil, this looks
for FILENAME relative to the 'current file' (see below).

`:path' value (aka PATH) can be:
  - A path string.
  - A list of strings to join into a path.
  - A form that should evaluate to one of the above.

PATH is (nominally) where to look for the file (a string representing a
directory path). If omitted, the lookup is relative to either
`load-file-name', `byte-compile-current-file' or `buffer-file-name'
(checked in that order).

NOTE: If FILENAME is nil but PATH refers to a file, PATH will be use as FILENAME.

`:error' value (aka ERROR) can be:
  - nil
  - non-nil (default)
If ERROR is nil, the function will not raise an error if:
  - The file doesn't exist.
  - The FEATURE isn't provided after loading the file.
It will still raise an error if:
  - It cannot parse the inputs.
  - It cannot determine where to /look/ for the file.

Only loads the file if the FEATURE is not already provided in `imp:features'."
  (let ((macro:path:current-dir (int<imp>:path:current:dir)))
    `(let* ((macro:func.name "imp:load")
            (macro:parsed (int<imp>:load:parse macro:func.name
                                               ,macro:path:current-dir
                                               (upcase "load-args-plist")
                                               (list ,@load-args-plist)))
            (macro:path          (plist-get macro:parsed :path))
            (macro:path:filename (int<imp>:path:filename macro:path))
            (macro:path:parent   (int<imp>:path:parent   macro:path))
            (macro:feature (plist-get macro:parsed :feature))
            ;; Invert for `load' parameter NO-ERROR.
            (macro:error? (plist-get macro:parsed :error))
            ;; Set `file-name-handler-alist' to nil to speed up loading.
            file-name-handler-alist
            load-result)
       (int<imp>:debug macro:func.name
                       '("parsed:\n"
                         "  path: %s\n"
                         "    -> dir:  %s\n"
                         "    -> file: %s\n"
                         "  feature: %S\n"
                         "  error?:  %S")
                       macro:path
                       macro:path:parent
                       macro:path:filename
                       macro:feature
                       macro:error?)

       ;;------------------------------
       ;; Provide Check
       ;;------------------------------
       ;; Only load if it's not provided already.
       (if (imp:provided? macro:feature)
           ;; Skip w/ optional timing message.
           (progn
             (imp:timing:already-provided macro:feature
                                          macro:path:filename
                                          macro:path:parent)
             ;; Return nil for 'did not load'.
             (setq load-result nil))

         ;;------------------------------
         ;; Load!
         ;;------------------------------
         ;; Load w/ timing info if desired.
         (imp:timing
             macro:feature
             macro:path:filename
             macro:path:parent
           ;; Actually do the load.
           (setq load-result (load macro:path
                                   (not macro:error?)
                                   'nomessage)))

         ;;------------------------------
         ;; Sanity Check: (obey ERROR flag though)
         ;;------------------------------
         ;; Does that feature exists now?
         ;;   - Prevent feature name drift, since this doesn't actually require
         ;;     the feature name for the actual loading.
         (when (not (imp:provided? macro:feature))
           (if macro:error?
               (int<imp>:error macro:func.name
                               '("Feature is still not defined after loading the file!\n"
                                 "  feature:       %S\n"
                                 "  path:          %S\n"
                                 "  `load'-result: %S")
                               macro:feature
                               macro:path
                               load-result)
             (setq load-result nil))))

       ;;------------------------------
       ;; Return
       ;;------------------------------
       load-result)))
;; (imp:load :feature :test
;;           :path     test<imp/load>:loading:root
;;           :filename test<imp/load>:loading:dont-load:file
;;           :error    nil)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------

(defun int<imp>:load:init ()
  "Provide the imp:load feature."
  (imp:provide:with-emacs :imp 'load))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
