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


;; TODO: Rename `int<imp>:load:feature'?
;; TODO: Delete entirely and just use newer `imp:feature:at' stuff?
;;         - Or rework into `int<imp>:load:all'?
(defun int<imp>:load (feature:base &rest feature)
  "Load a file relative to FEATURE:BASE based on FEATURE list of keywords/symbols.

FEATURE:BASE must be a keyword which exists in `imp:path:roots' (set via the
`imp:path:root'function).

E.g. (int<imp>:load :imp 'provide)
  Will try to load: \"/path/to/imp-root/provide.el\"

Returns non-nil if loaded."
  ;; TODO:load: 'load-all' functionality?

  (cond ((apply #'imp:provided? feature:base feature)
         t)

        ;; Not loaded, but we know where to find it?
        ((int<imp>:path:root/contains? feature:base)
         ;; imp knows about this - let's try to load it.
         (int<imp>:load:file (int<imp>:path:get (cons feature:base feature))))

        ;; Fallback: Try to let emacs require it:
        (t
         (require (int<imp>:feature:normalize:imp->emacs feature)
                 ;; TODO:load: guess at a file/path based on 'feature:base/feature-0/...'?
                 nil
                 'noerror))))
;; (int<imp>:load :imp 'something)
;; (int<imp>:load :config 'spy 'system 'config)


;; TODO:test: Make unit test.
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
               ;; Allow input FEATURE to be e.g. `:imp' instead of `(:imp)';
               ;; normalize to a list.
               (setq in:feature (if (listp value)
                                    value
                                  (list value))))
              ((eq key :error)
               (setq in:error value)))))

    ;;------------------------------
    ;; Prep Outputs:
    ;;------------------------------
    ;;---
    ;; Process PATH & FILENAME into single output path.
    ;;---

    ;; 0) Ease-of-use: Promote PATH to FILENAME if only PATH was provided.
    ;;---
    (unless in:filename
      (setq in:filename in:path
            in:path nil))

    ;; 1) Check PATH first so we can have it for FILENAME if needed.
    ;;---
    ;; Prefer provided path.
    (let ((path (or in:path path:current-dir)))
      (unless (stringp path)
        (int<imp>:error caller
                        '("Could not determine a path to look for filename: '%s'"
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
    ;; FEATURE & FEATURES
    ;;---
    ;; Normalize to a list.
    (setq out:feature (apply #'int<imp>:feature:normalize in:feature))
    (int<imp>:debug caller "out:feature: %S" out:feature)

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
  (let* ((macro:func.name "imp:load")
         (macro:parsed (int<imp>:load:parse macro:func.name
                                      (int<imp>:path:current:dir)
                                      (upcase "load-args-plist")
                                      load-args-plist))
         (macro:feature:raw   (plist-get macro:parsed :feature))
         (macro:path          (plist-get macro:parsed :path))
         (macro:path:filename (int<imp>:path:filename macro:path))
         (macro:path:parent   (int<imp>:path:parent   macro:path))
         ;; Invert for `load' parameter NO-ERROR.
         (macro:error? (plist-get macro:parsed :path)))
    ;; Avoid `void-function' error signal.
    `(let ((macro:feature:list (list ,@macro:feature:raw))
           ;; Set `file-name-handler-alist' to nil to speed up loading.
           file-name-handler-alist
           load-result)
       ;; Only load if it's not provided already.
       (if (imp:provided? ,@macro:feature:raw)
           ;; Skip w/ optional timing message.
           (imp:timing:already-provided macro:feature:list
                                        ,macro:path:filename
                                        ,macro:path:parent)

         ;; Load w/ timing info if desired.
         (imp:timing
             macro:feature:list
             ,macro:path:filename
             ,macro:path:parent
           ;; Actually do the load.
           (setq load-result (load ,macro:path
                                   (not ,macro:error?)
                                   'nomessage)))

         ;;---
         ;; Sanity Check: (obey ERROR flag though)
         ;;---
         ;; Does that feature exists now?
         ;;   - Prevent feature name drift, since this doesn't actually require
         ;;     the feature name for the actual loading.
         (unless (and ,macro:error?
                      (imp:provided? ,@macro:feature:raw))
           (int<imp>:error ,macro:func.name
                           '("Feature is still not defined after loading the file!\n"
                             "  feature:       %S\n"
                             "  path:          %S\n"
                             "  `load'-result: %S")
                           macro:feature:list
                           ,macro:path
                           load-result))))))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------

(defun int<imp>:load:init ()
  "Provide the imp:load feature."
  (imp:provide:with-emacs :imp 'load))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------