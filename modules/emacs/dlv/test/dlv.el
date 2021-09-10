;; -*- no-byte-compile: t; lexical-binding: t; -*-
;;; emacs/dlv/test/dlv.el

;;------------------------------------------------------------------------------
;; Test Directory Local Variables
;;------------------------------------------------------------------------------

;; Get all the DLV files we want to test.
(load "../init.el")


;;------------------------------------------------------------------------------
;; Constants & Variables
;;------------------------------------------------------------------------------

(setq dlv//test/const/path.root "~/dlv-test/"
      dlv//test/const/file.name "locals.txt")

(setq dlv//test/const/path.file (concat dlv//test/const/path.root
                                        dlv//test/const/file.name))

(setq dlv//test/const/path.dir-a (concat dlv//test/const/path.root "dir-a/")
      dlv//test/const/path.dir-b (concat dlv//test/const/path.root "dir-b/"))

(setq dlv//test/const/path.file-a (concat dlv//test/const/path.dir-a
                                          dlv//test/const/file.name)
      dlv//test/const/path.file-b (concat dlv//test/const/path.dir-b
                                          dlv//test/const/file.name))

;; Our DLVs.
(setq dlv//test/variable   :default
      dlv//test/variable-a :default
      dlv//test/variable-b :default)

;; A valid DLV struct from the Emacs docs:
;;
;;   '((nil . ((indent-tabs-mode . t)
;;             (fill-column . 80)
;;             (mode . auto-fill)))
;;     (c-mode . ((c-file-style . "BSD")
;;                (subdirs . nil)))
;;     ("src/imported"
;;      . ((nil . ((change-log-default-name
;;                  . "ChangeLog.local"))))))

;; Backup of original cache.
(setq dlv//test/dir-locals-directory-cache dir-locals-directory-cache)
;; dlv//test/class


;;------------------------------------------------------------------------------
;; Dirs & Files
;;------------------------------------------------------------------------------

;;------------------------------
;; Set-Up
;;------------------------------

(defun dlv//test/setup.file (path)
  "Ensure the file at PATH exist."
  (unless (file-exists-p path)
    (write-region "" nil path)))


(defun dlv//test/dir.create (path)
  "Create directory PATH unless it exists."
  (if (and (file-exists-p path)
           (file-directory-p path))
      :exists
    (make-directory path)))


(defun dlv//test/setup.dirs ()
  "Ensure the dirs and files exist."
  (dlv//test/dir.create dlv//test/const/path.root)
  (dlv//test/dir.create dlv//test/const/path.dir-a)
  (dlv//test/dir.create dlv//test/const/path.dir-b))
;; (dlv//test/setup.dirs)


(defun dlv//test/setup ()
  "Run setup for tests."
  ;; Save pre-test cache's state.
  (setq dlv//test/dir-locals-directory-cache dir-locals-directory-cache)

  ;; Create temp dirs.
  (dlv//test/setup.dirs)

  ;; Create temp files.
  (dlv//test/setup.file dlv//test/const/path.file)
  (dlv//test/setup.file dlv//test/const/path.file-a)
  (dlv//test/setup.file dlv//test/const/path.file-b)

  ;; Set vars to their defaults.
  (setq dlv//test/variable   :default
        dlv//test/variable-a :default
        dlv//test/variable-b :default)
  ;; Clear out their `safe-local-variable' slots.
  (put dlv//test/variable 'safe-local-variable nil)
  (put dlv//test/variable-a 'safe-local-variable nil)
  (put dlv//test/variable-b 'safe-local-variable nil))
;; (dlv//test/setup)


;;------------------------------
;; Tear-Down
;;------------------------------

(defun dlv//test/teardown.paths ()
  "Remove all the files & dirs used in the test by deleting the root dir."
  (delete-directory dlv//test/const/path.root :recursive))


(defun dlv//test/teardown ()
  "Run teardown for tests."
  ;; Restore cache back to pre-test state.
  (setq dir-locals-directory-cache dlv//test/dir-locals-directory-cache)

  ;; Delete all temp files & dirs.
  (dlv//test/teardown.paths))


;;------------------------------------------------------------------------------
;; DLV Helpers
;;------------------------------------------------------------------------------

(defun dlv//test/path/parent (path)
  "Returns the parent directory of PATH."
  (file-name-directory (directory-file-name path)))
;; (dlv//test/path/parent dlv//test/const/path.root)
;; (dlv//test/path/parent dlv//test/const/path.file)


(defun dlv//test/path/equal? (path-a path-b)
  "Returns true if PATH-A and PATH-B are equal after expanding."
  (string= (expand-file-name path-a)
           (expand-file-name path-b)))


(defun dlv//test/class-and-dir (class dir mode symbol value safe)
  "Create a directory-local variable CLASS using SYMBOL, VALUE, and SAFE.

Set for directory DIR."
  (message "dlv//test/class-and-dir: %S %S %S %S %S %S"
           class dir mode symbol value safe)
  (dlv/set class dir mode (list symbol value safe)))


(defun dlv//test/safe-p (&rest args)
  "A predicate to use for the `safe' input param. Returns `t' (valid VALUE
for variable) always, regardless of VALUE."
  (message "dlv//test/safe-p: %S" args)
  t)


(defun dlv//test/safe.get (symbol)
  "Returns the value in SYMBOL's `safe-local-variable' slot."
  (get symbol 'safe-local-variable))


;;------------------------------------------------------------------------------
;; Tests
;;------------------------------------------------------------------------------

(ert-deftest test<dlv>:manuals-example ()
  "Validates PATH has SYMBOL as VALUE and can get its DLV CLASS variables struct.

Returns nil on success."
  (let* ((dirpath/tilde "~/dlv-test/")
         (dirpath/abs (expand-file-name dirpath/tilde))
         (filename "locals.txt")
         (filepath/tilde (concat dirpath/tilde filename))
         (filepath/abs (concat dirpath/abs filename))
         (class 'dlv//test/class)
         (symbol 'dlv//test/variable)
        (mode 'dlv//test/mode)
        (value :test/symbol-and-value)
        (safe #'dlv//test/safe-p))

  ;; ;; Ham-fistedly say it's safe always for everything.
  ;; (put 'dlv//test/variable 'safe-local-variable (lambda (_) (message "hello there %S" _) t))
  (push '(dlv//test/variable . :test/local-value) safe-local-variable-values)
  (message "safe-local-variable-values: %S" safe-local-variable-values)

  ;; From the manual:
  ;; https://www.gnu.org/software/emacs/manual/html_node/emacs/Directory-Variables.html
  ;; Except using my dir instead of "/usr/include/"
  (dir-locals-set-class-variables 'unwritable-directory
                                  '((nil . ((dlv//test/variable . :test/local-value)))))

  (dir-locals-set-directory-class "~/dlv-test/"
                                  'unwritable-directory)

  (dir-locals-set-directory-class "d:/home/work/dlv-test/"
                                  'unwritable-directory)

  (let ((buffer/local (get-buffer-create "/home/work/dlv-test/locals.txt")))
    (should (equal :test/local-value
                   (buffer-local-value dlv//test/variable buffer/local))))
  (dir-locals-get-class-variables class)
  (dir-locals-find-file filepath)

  (let ((buffer/local (get-buffer-create "~/dlv-test/locals.txt")))
    (should (equal :test/local-value
                   (buffer-local-value dlv//test/variable buffer/local))))

  (dlv//test/teardown))


(ert-deftest test<dlv>:path/symbol-and-value ()
  "Validates PATH has SYMBOL as VALUE and can get its DLV CLASS variables struct.

Returns nil on success."
  (dlv//test/setup)

  (let ((filepath dlv//test/const/path.file)
        (class 'dlv//test/class)
        (symbol 'dlv//test/variable)
        (mode 'dlv//test/mode)
        (value :test/symbol-and-value)
        (safe #'dlv//test/safe-p))

    ;; Create the DLV for the file's parent dir.
    (dlv//test/class-and-dir class
                             (dlv//test/path/parent filepath)
                             mode
                             symbol
                             value
                             safe)

    ;; Did it create... something?
    (should (not (null (dlv//test/class-and-dir class
                                                (dlv//test/path/parent filepath)
                                                mode
                                                symbol
                                                value
                                                safe))))

    ;; Did the symbol get its safe function slotted?
    (should (eq safe
                (dlv//test/safe.get symbol)))

    ;; Get the DLVs for the class and verify its value.
    (let ((dlv.class (dir-locals-get-class-variables class)))
      ;; Validate the CLASS struct exists.
      (should (not (null dlv.class)))

      ;; Validate the struct is correctly formatted w/ correct symbol & value.
      (should (equal dlv.class
                     (cons mode
                           (list (cons symbol value))))))

    ;; Get the DLV class for the file's path and verify.
    (let ((file/dlv.classes (dir-locals-find-file filepath)))
      (should (not (null file/dlv.classes)))
      (should (= 3 (length file/dlv.classes)))
      (should (dlv//test/path/equal? (nth 0 file/dlv.classes)
                                     (dlv//test/path/parent filepath)))
      (should (eq (nth 1 file/dlv.classes)
                  class))
      ;; Don't care about nth 2.
      )

    ;; Validate the actual PATH has the SYMBOl as VALUE.
    (let ((buffer/local (get-buffer-create dlv//test/const/path.file)))
      ;; TODO: Make this work somehow - IDK.
      ;; T_T
      (should (equal value
                     (buffer-local-value symbol buffer/local)))))

  (dlv//test/teardown))

;; (setq dir-locals-directory-cache
;;       '(("d:/home/work/.emacs.d/" d:/home/work/\.emacs\.d/
;;          (24827 297 0 0))
;;         ("d:/home/work/.lily.d/logbook/home/" sss:dlv\.class/org nil)
;;         ("d:/home/work/.lily.d/logbook/work/" sss:dlv\.class/org nil)
;;         ("d:/home/work/.lily.d/logbook/home/" sss:dlv\.class/org nil)
;;         ("d:/home/work/.lily.d/logbook/work/" sss:dlv\.class/org nil)
;;         ("d:/home/work/.lily.d/logbook/work/" taskspace//dlv\.class/group nil)
;;         ("d:/home/work/.lily.d/taskspace/work/" taskspace//dlv\.class/group nil)
;;         ("d:/vault/programmer/work/2021_Drive/taskspace/" taskspace//dlv\.class/group nil)
;;         ("d:/home/work/.lily.d/logbook/home/" taskspace//dlv\.class/group nil)
;;         ("d:/home/work/.lily.d/taskspace/home/" taskspace//dlv\.class/group nil)
;;         ("d:/vault/taskspace/" taskspace//dlv\.class/group nil)
;;         ("d:/vault/programmer/work/2021_Drive/taskspace/" jerky//dlv\.class/namespace nil)
;;         ("d:/home/work/.lily.d/logbook/work/" jerky//dlv\.class/namespace nil)
;;         ("d:/home/work/.lily.d/logbook/work/" jerky//dlv\.class/namespace nil)
;;         ("d:/home/work/.lily.d/logbook/work/" taskspace//dlv\.class/group nil)
;;         ("d:/home/work/.lily.d/logbook/work/" taskspace//dlv\.class/group nil)
;;         ("d:/vault/programmer/work/" jerky//dlv\.class/namespace nil)
;;         ("d:/vault/programmer/work/" taskspace//dlv\.class/group nil)
;;         ("d:/vault/taskspace/" jerky//dlv\.class/namespace nil)
;;         ("d:/home/work/.lily.d/logbook/home/" jerky//dlv\.class/namespace nil)
;;         ("d:/home/work/.lily.d/logbook/home/" jerky//dlv\.class/namespace nil)
;;         ("d:/home/work/.lily.d/logbook/home/" taskspace//dlv\.class/group nil)
;;         ("d:/home/work/.lily.d/logbook/home/" taskspace//dlv\.class/group nil)))

;; Make a class for some dir.
;;   - Some random dir that isn't under any of the current dir classes.
;;   - With just some random variable that isn't used by anything currently.
;;   - [ ] Does that var work in that dir?
;;   - [ ] Does it work when the code is run during doom start-up?
;;   + As opposed to run when I'm coding/debugging.
;;   + So, obviously, put it somewhere in the init/config files.
;;
;; Add another dir, same class name.
;;   - [ ] Do both dirs still work after eval while coding/debugging?
;;   - [ ] Do both dirs still work after restarting emacs?
;;
;; Add different class name, different var to dir #0.
;;   - Maybe a third class/var to dir #1.
;;   - [ ] Do all vars work after eval?
;;   - [ ] Do all vars work after restarting?


;;------------------------------------------------------------------------------
;; Tests
;;------------------------------------------------------------------------------

;; TODO: Emacs test suite functions (ert-... ).
