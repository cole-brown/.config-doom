;;; emacs/str/case.el -*- lexical-binding: t; -*-


(require 'rx)
(imp:require :str 'string)
(imp:require :str 'regex)


;;------------------------------------------------------------------------------
;; Regexes
;;------------------------------------------------------------------------------

;;------------------------------
;; regex string builders
;;------------------------------

(defun int<str>:case:rx:build.flags (flags)
  "Build optional keyword/string FLAGS into an `rx' expr."
  (declare (pure t) (side-effect-free t))
  (let (regex)
    (dolist (flag flags)
      (cond ((eq :whitespace flag)
             (push 'whitespace regex))
            ((eq :punctuation flag)
             (push 'punctuation regex))
            ((stringp flag)
             (push flag regex))
            (t
             (error "int<str>:case:rx:build.flags: Flag '%S' not implemented."
                    flag))))

    (cond
     ((= (length flags) 1)
      (nth 0 regex))
     ((> (length flags) 1)
      (apply #'list 'any regex))
     (t
      (error "int<str>:case:rx:build.flags: No regex items to build? %S -> %S"
             flags regex)))))
;; (int<str>:case:rx:build.flags '(:whitespace))
;; (int<str>:case:rx:build.flags '(:punctuation))
;; (int<str>:case:rx:build.flags '(:whitespace :punctuation))
;; (int<str>:case:rx:build.flags '(:whitespace :punctuation "-"))


(defun int<str>:case:rx:build.separators (separators)
  "Returns a regex string or list of word separators for use in
`rx' or `rx-to-string'.

SEPARATORS should be:
  - a separator (regex) string,
  - a keyword for `int<str>:case:rx:build.flags',
  - a list of separator strings,
  - a list for `rx',
  - the keyword `:none' (for 'no separators allowed'),
  - `:default' or nil (to use defaults)."
  (declare (pure t) (side-effect-free t))

  (cond
   ((and (keywordp separators)
         (eq :none separators))
    "")

   ;; String: assume it's a regex already.
   ((stringp separators)
    separators)
   ;; Keyword: use `int<str>:case:rx:build.flags'.
   ((keywordp separators)
    (int<str>:case:rx:build.flags separators))
   ;; List of all strings: create a regex `any' out of it.
   ((and (listp separators)
         (> (length separators) 0) ;; `-all?' just always returns `t' for empty lists/nil.
         (-all? #'stringp separators))
    (cons 'any separators))
   ;; List of not-all-strings: assume it's a list for `rx'.
   ((and (listp separators)
         (not (null separators)))
    separators)
   ;; Else use the default separators.
   (t
    str:rx:default:separators.word)))
;; (int<str>:case:rx:build.separators nil)
;; (int<str>:case:rx:build.separators :none)


(defun int<str>:case:rx:build.words (regex word-separators docstr)
  "Build a predicate for matching an entire string where each word must meet REGEX.

REGEX should be a regex string or an rx expression list.

WORD-SEPARATORS should be:
  - a separator (regex) string,
  - a keyword for `int<str>:case:rx:build.flags',
  - a list of separator strings,
  - a list for `rx',
  - or nil (to use defaults).

Returns a lambda function to use to match a string with the document
string DOCSTR and a return value of `string-match-p' function's return value."
  (declare (pure t)
           (side-effect-free t)
           (doc-string 3))
  ;; What regex lambda do we want to create?
  ;; With allowed WORD-SEPARATORS or without?
  ;; Return a lambda that does the regex checking and returns match/nil.
  (if (and (keywordp word-separators)
           (eq :none word-separators))
      ;; Build lambda for regex match /WITHOUT/ WORD-SEPARATORS.
      (lambda (check/string)
        docstr
        (save-match-data
          ;; Check the string with our regex.
          (string-match-p
           ;; Skip the word separators part of the regex.
           (rx-to-string `(sequence
                           string-start
                           (one-or-more word-boundary
                                        ;; The passed in regex for each word:
                                        (group ,regex)
                                        ;; NO WORD SEPARATORS!
                                        word-boundary)
                           string-end)
                         :no-group)
           check/string)))

    ;; Build lambda for regex match with WORD-SEPARATORS.
    (lambda (check/string)
      docstr
      (save-match-data
        ;; Check the string with our regex.
        (string-match-p
         ;; Use optional word separators in the regex.
         (rx-to-string `(sequence
                         string-start
                         (one-or-more word-boundary
                                      ;; The passed in regex for each word:
                                      (group ,regex)
                                      ;; Word separator?
                                      (optional ,(int<str>:case:rx:build.separators word-separators))
                                      word-boundary)
                         string-end)
                       :no-group)
         check/string)))))
;; (int<str>:case:rx:build.words '(or "hi" "hello") nil "hi")
;; (int<str>:case:rx:build.words '(or "hi" "hello") :none "hi")
;; (funcall (int<str>:case:rx:build.words (rx "hello") nil "docstr") "hello there")
;; (funcall (int<str>:case:rx:build.words (rx "hello") nil "docstr") "hello")
;; (funcall (int<str>:case:rx:build.words (rx "hello") nil "docstr") "hello hello")
;; (let ((string "hello hello"))
;;   (funcall (int<str>:case:rx:build.words (rx "hello") nil "docstr") string)
;;   (list (match-string 0 string)
;;         (match-string 1 string)
;;         (match-string 2 string)))


(defun int<str>:case:rx:build.no-separators (regex word-separators docstr)
  "Build a predicate for matching an alternating case regex to a string of words.
The WORD-SEPARATORS will be removed from the string befoer the REGEX is run on the string.

REGEX should be a regex string or an rx expression list.

WORD-SEPARATORS should be:
  - a separator (regex) string,
  - a keyword for `int<str>:case:rx:build.flags',
  - a list of separator strings,
  - a list for `rx',
  - or nil (to use defaults).

Returns a lambda function to use to match a string with the document
string DOCSTR and a return value of `string-match-p' function's return value."
  (declare (pure t)
           (side-effect-free t)
           (doc-string 3))
  (lambda (check/string)
    docstr
    (save-match-data
      ;; Check the string with our regex.
      (string-match-p
       ;; Regex with the allowed WORD-SEPARATORS.
       (rx-to-string `(sequence
                       string-start
                       (one-or-more word-boundary
                                    ;; The passed in regex for each word:
                                    (group ,regex)
                                    ;; No word separator. We delete them before checking instead.
                                    ;; (optional ,(int<str>:case:rx:build.separators word-separators))
                                    word-boundary)
                       string-end)
                     :no-group)
       ;; Remove the word separators before checking so that the alternating regexes work correctly.
       (save-match-data
         (replace-regexp-in-string (rx-to-string word-separators :no-group)
                                   ""
                                   check/string
                                   :fixedcase))))))


;;------------------------------
;; `rx' plists
;;------------------------------

(defun int<str>:case:rx:get (str-rx-case property)
  "Get PROPERTY (`:rx' or `:separators') from a `int<str>:case:rx:___' const."
  (declare (pure t) (side-effect-free t))
  (plist-get str-rx-case property))


;;---
;; Case Type: Simple (lower, UPPER, Title)
;;---

(defconst int<str>:case:rx:lower
  '(:rx (one-or-more (any lower-case digit)))
  "An rx sexpr for lowercase words.")


(defconst int<str>:case:rx:upper
  '(:rx (one-or-more (any upper-case digit)))
  "An rx sexpr for UPPERCASE WORDS.")


(defconst int<str>:case:rx:title
  `(:rx (sequence
         (zero-or-more digit)
         ;; Each word must start with one capital.
         upper-case
         ;; ...and the rest are not capital.
         (one-or-more ,(int<str>:case:rx:get int<str>:case:rx:lower :rx))))
  "An rx sexpr for Title Cased Words.")


;;;---
;; Case Type: CamelCase
;;---

(defconst int<str>:case:rx:camel/grouping.upper
  '((zero-or-more digit)
    ;; Exactly one uppercase letter.
    upper-case
    ;; After first uppercase, must have at least one lowercase.
    (zero-or-more digit)
    (one-or-more lower-case))
  "An `rx' list of a CamelCase group of letters.
e.g. 'Camel'Case or Camel'Case'

NOTE: Does not match \"IPAddress / DNSConn\" type of BASTARDIZEDCamelCase.")


(defconst int<str>:case:rx:camel.upper
  `(:rx (sequence
         ;; UpperCaseCamel must start with a camel hump.
         ,@int<str>:case:rx:camel.grouping
         ;; Then it can continue on with the same 'one upper then some lower' pattern.
         (zero-or-more
          ,@int<str>:case:rx:camel.grouping))
    :separators :none)
  "An rx sexpr for lower-cased CamelCaseWords.")


(defconst int<str>:case:rx:camel.lower
  `(:rx (sequence
         ;; lowerCaseCamel must start with a lowercase group before the camel humps.
         (zero-or-more digit)
         (one-or-more lower-case)
         ;; Then it can continue on with the same 'one upper then some lower' pattern.
         (zero-or-more
          ,@int<str>:case:rx:camel.grouping))
    :separators :none)
  "An rx sexpr for lower-cased CamelCaseWords.")


(defconst int<str>:case:rx:camel.any
  `(:rx (or ,(int<str>:case:rx:get int<str>:case:rx:camel.lower :rx)
            ,(int<str>:case:rx:get int<str>:case:rx:camel.upper :rx))
    :separators :none)
  "An rx sexpr for camel_case_words, either lowerCamelCase or UpperCamelCase.")


;;---
;; Case Type: snake_case
;;---

(defconst int<str>:case:rx:snake.lower
  `(:rx ,(int<str>:case:rx:get int<str>:case:rx:lower :rx)
    :separators ("_"))
  "An rx sexpr for lower-cased snake_case_words.")


(defconst int<str>:case:rx:snake.upper
  `(:rx ,(int<str>:case:rx:get int<str>:case:rx:upper :rx)
    :separators ("_"))
  "An rx sexpr for upper-cased SNAKE_CASE_WORDS.")


(defconst int<str>:case:rx:snake.title
  `(:rx ,(int<str>:case:rx:get int<str>:case:rx:title :rx)
    :separators ("_"))
  "An rx sexpr for title-cased Snake_Case_Words.")


(defconst int<str>:case:rx:snake.any
  `(:rx (or ,(int<str>:case:rx:get int<str>:case:rx:snake.lower :rx)
            ,(int<str>:case:rx:get int<str>:case:rx:snake.upper :rx)
            ,(int<str>:case:rx:get int<str>:case:rx:snake.title :rx))
    :separators ("_"))
  "An rx sexpr for snake_case_words, either all upper-case or all lower-case.")


;;---
;; Case Type: aLtErNaTiNg
;;---

(defconst int<str>:case:rx:alternating.lower
  ;; Can start off with not-a-letter, but first letter must be lowercase.
  '(:rx (sequence
         (zero-or-more digit)
         lower-case
         ;; After first lowercase, must have at least one upper.
         (zero-or-more digit)
         upper-case
         ;; Then it can continue on with alternating lower, upper.
         ;;   - It must be able to end on either lower or upper.
         (zero-or-more
          (zero-or-more digit)
          (or lower-case word-end)
          (zero-or-more digit)
          (or upper-case word-end)))
    :separators :default)
  "An rx sexpr for \"lOwErCaSe AlTeRnAtInG WoRdS\".")


(defconst int<str>:case:rx:alternating.upper
  ;; Can start off with not-a-letter, but first letter must be uppercase.
  '(:rx (sequence
         (zero-or-more digit)
         upper-case
         ;; After first lowercase, must have at least one upper.
         (zero-or-more digit)
         lower-case
         ;; Then it can continue on with alternating lower, upper.
         ;;   - It must be able to end on either lower or upper.
         (zero-or-more
          (zero-or-more digit)
          (or upper-case word-end)
          (zero-or-more digit)
          (or lower-case word-end)))
    :separators :default)
  "An rx sexpr for \"UpPeRcAsE aLtErNaTiNg wOrDs\".")


(defconst int<str>:case:rx:alternating.any
  `(:rx (or ,(int<str>:case:rx:get int<str>:case:rx:alternating.lower :rx)
            ,(int<str>:case:rx:get int<str>:case:rx:alternating.upper :rx))
    :separators :default)
  "An rx sexpr for \"UpPeRcAsE aLtErNaTiNg wOrDs\" or \"lOwErCaSe AlTeRnAtInG WoRdS\".")


;;---
;; Case Types
;;---

(defconst int<str>:rx:plist/cases
  (list
   ;;------------------------------
   ;; Cases: Simple
   ;;------------------------------
   :lower (int<str>:case:rx:build.words
           (int<str>:case:rx:get int<str>:case:rx:lower :rx)
           (int<str>:case:rx:get int<str>:case:rx:lower :separators)
           "Match 'lowercase' strings.")

   :upper (int<str>:case:rx:build.words
           (int<str>:case:rx:get int<str>:case:rx:upper :rx)
           (int<str>:case:rx:get int<str>:case:rx:upper :separators)
           "Match 'UPPERCASE' strings.")

   :title (int<str>:case:rx:build.words
           (int<str>:case:rx:get int<str>:case:rx:title :rx)
           (int<str>:case:rx:get int<str>:case:rx:title :separators)
           "Match 'Title Case' strings.")

   ;;------------------------------
   ;; Cases: Camel
   ;;------------------------------
   :camel (int<str>:case:rx:build.words
           (int<str>:case:rx:get int<str>:case:rx:camel.any :rx)
           (int<str>:case:rx:get int<str>:case:rx:camel.any :separators)
           "Match 'CamelCase' strings.")

   :camel.lower (int<str>:case:rx:build.words
                 (int<str>:case:rx:get int<str>:case:rx:camel.lower :rx)
                 (int<str>:case:rx:get int<str>:case:rx:camel.lower :separators)
                 "Match 'CamelCase' strings.")

   :camel.upper (int<str>:case:rx:build.words
                 (int<str>:case:rx:get int<str>:case:rx:camel.upper :rx)
                 (int<str>:case:rx:get int<str>:case:rx:camel.upper :separators)
                 "Match 'CamelCase' strings.")

   ;;------------------------------
   ;; Cases: Snake
   ;;------------------------------
   :snake (int<str>:case:rx:build.words
           (int<str>:case:rx:get int<str>:case:rx:snake.any :rx)
           (int<str>:case:rx:get int<str>:case:rx:snake.any :separators)
           "Match any type of 'snake_case' strings.")

   :snake.lower (int<str>:case:rx:build.words
                 (int<str>:case:rx:get int<str>:case:rx:snake.lower :rx)
                 (int<str>:case:rx:get int<str>:case:rx:snake.lower :separators)
                 "Match 'lower_snake_case' strings.")

   :snake.upper (int<str>:case:rx:build.words
                 (int<str>:case:rx:get int<str>:case:rx:snake.upper :rx)
                 (int<str>:case:rx:get int<str>:case:rx:snake.upper :separators)
                 "Match 'UPPER_SNAKE_CASE' strings.")

   :snake.title (int<str>:case:rx:build.words
                 (int<str>:case:rx:get int<str>:case:rx:snake.title :rx)
                 (int<str>:case:rx:get int<str>:case:rx:snake.title :separators)
                 "Match 'UPPER_SNAKE_CASE' strings.")

   ;;------------------------------
   ;; Cases: Alternating
   ;;------------------------------
   :alternating.lower (int<str>:case:rx:build.no-separators
                       (int<str>:case:rx:get int<str>:case:rx:alternating.lower :rx)
                       (int<str>:case:rx:get int<str>:case:rx:alternating.lower :separators)
                       "Match 'aLtErNaTiNg LoWeRcAsE' strings.")

   :alternating.upper (int<str>:case:rx:build.no-separators
                       (int<str>:case:rx:get int<str>:case:rx:alternating.upper :rx)
                       (int<str>:case:rx:get int<str>:case:rx:alternating.upper :separators)
                       "Match 'AlTeRnAtInG uPpErCaSe' strings."))
  "A plist of all our fully-qualified case keywords and their identifying regex functions.")
;; (pp int<str>:rx:plist/cases)


(defconst str:cases:rx/types
  '(:lower :upper :title :snake :camel :alternating)
  "A list of keywords of our general types of cases.")


(defconst str:cases:rx/all
  '(;; simple types
    :lower
    :upper
    :title
    ;; snake_case_types
    :snake
    :snake.lower
    :snake.upper
    :snake.title
    ;; CamelCaseTypes
    :camel
    :camel.lower
    :camel.upper
    ;; AlTeRnAtInG cAsE tYpEs
    :alternating
    :alternating.lower
    :alternating.upper)
  "A list of keywords of our general types of cases.")


;;------------------------------
;; General
;;------------------------------

(defun str:case:identify (string)
  "Returns identifying list of keywords for STRING's case.

See:
  - `str:cases:rx/all' for all possible keywords.
  - `str:cases:rx/types' for all the case type keywords.

TODO: Returning the delimiter for types with one.

Example:
  (str:case:identify \"test\")
    -> '(:lower)
  (str:case:identify \"TEST\")
    -> '(:upper)
  (str:case:identify \"Test\")
    -> '(:title)
  (str:case:identify \"Test String\")
    -> '(:title)
  (str:case:identify \"test_string\")
    -> '(:snake \"_\" :lower)"
  (declare (pure t) (side-effect-free t))

  (str:rx:with/case.sensitive
   ;; Force to a string.
   (let ((str (format "%s" string))
         (plist/cases int<str>:rx:plist/cases)
         matches)
     ;; Check all regexs in `int<str>:case:rx'.
     (while plist/cases
       (let ((type (car plist/cases))
             (string/matches? (cadr plist/cases)))
         ;; Jump to next plist kvp.
         (setq plist/cases (cddr plist/cases))

         ;; Does it match this case?
         (when (funcall string/matches? str)
           (push type matches))))

     ;; Return whatever we matched.
     matches)))
;; (str:case:identify "hello_there")
;; (str:case:identify "HelloThere")
;; (str:case:identify "hello there")
;; (str:case:identify "Hello")
;; (str:case:identify "hElL")
;; (str:case:identify "hElLo")
;; (str:case:identify "HeLl")
;; (str:case:identify "HeLlO")


;;------------------------------------------------------------------------------
;; Case Conversion - Strings
;;------------------------------------------------------------------------------

(defun int<str>:case:normalize->str (caller string-or-list)
  "Takes a string or list of strings, and returns a string

If STRING-OR-LIST is a string, returns STRING-OR-LIST.
If STRING-OR-LIST is a list, joins the list together with spaces.

CALLER is used when signaling an error message."
  (declare (pure t) (side-effect-free t))
  (cond ((listp string-or-list)
         (apply #'str:join " " string-or-list))
        ((stringp string-or-list)
         string-or-list)
        (t
         (error "%s: Expected a string or list of strings, got: %S"
                caller
                string-or-list))))
;; (int<str>:case:normalize->str "test" "hello world")
;; (int<str>:case:normalize->str "test" '("hello" "there"))
;; (int<str>:case:normalize->str "test" :hi)


(defun int<str>:case:normalize->list (caller string-or-list)
  "Takes a string or list of strings, and returns a list of strings.

If STRING-OR-LIST is a string, returns STRING-OR-LIST.
If STRING-OR-LIST is a list, joins the list together with spaces.

CALLER is used when signaling an error message."
  (declare (pure t) (side-effect-free t))
  (cond ((listp string-or-list)
         string-or-list)
        ((stringp string-or-list)
         (str:split (rx whitespace) string-or-list))
        (t
         (error "%s: Expected a string or list of strings, got: %S"
                caller
                string-or-list))))
;; (int<str>:case:normalize->list "test" "hello world")
;; (int<str>:case:normalize->list "test" '("hello" "there"))
;; (int<str>:case:normalize->list "test" :hi)


;;------------------------------
;; Simple
;;------------------------------

(defun str:case/string:to:lower (string-or-list)
  "Convert STRING-OR-LIST to lowercase."
  (declare (pure t) (side-effect-free t))
  (downcase (int<str>:case:normalize->str "str:case/string:to:lower" string-or-list)))
;; (str:case/string:to:lower "HELLO")


(defun str:case/string:to:upper (string-or-list)
  "Convert STRING-OR-LIST to uppercase."
  (declare (pure t) (side-effect-free t))
  (upcase (int<str>:case:normalize->str "str:case/string:to:upper" string-or-list)))
;; (str:case/string:to:upper "hello")
;; (str:case/string:to:upper '("hello" "world"))


;;------------------------------
;; Title Case
;;------------------------------

(defun str:case/string:to:title (string-or-list)
  "Convert STRING-OR-LIST from \"title case\" to \"Title Case\"."
  (declare (pure t) (side-effect-free t))
  (apply #'str:join " "
         (mapcar #'capitalize
                 (int<str>:case:normalize->list "str:case/string:to:title"
                                                string-or-list))))
;; (str:case/string:to:title "hello there")
;; (str:case/string:to:title '("hello" "there"))


;;------------------------------
;; CamelCase
;;------------------------------

(defun str:case/string:to:camel.lower (string-or-list)
  "Convert STRING-OR-LIST from \"lower camel case\" to \"lowerCamelCase\"."
  (declare (pure t) (side-effect-free t))
  (let ((words (int<str>:case:normalize->list "str:case/string:to:camel.lower" string-or-list)))
    (apply #'str:join ""
           (car words) ;; Leave first lowercased.
           ;; Titlecase the rest for CamelHumps.
           (mapcar #'capitalize (cdr words)))))
;; (str:case/string:to:camel.lower "hello there")


(defun str:case/string:to:camel.upper (string-or-list)
  "Convert STRING-OR-LIST from \"upper camel case\" to \"UpperCamelCase\"."
  (declare (pure t) (side-effect-free t))
  (apply #'str:join ""
         (mapcar #'capitalize
                 (int<str>:case:normalize->list "str:case/string:to:camel.string"
                                                string-or-list))))
;; (str:case/string:to:camel.upper "hello there")


;;------------------------------
;; snake_case
;;------------------------------

(defun str:case/string:from:snake (string)
  "Convert STRING from \"snake_case\" to \"snake case\"."
  (declare (pure t) (side-effect-free t))
  (save-match-data
    (replace-regexp-in-string (rx (one-or-more "_"))
                              " "
                              string)))


(defun str:case/string:to:snake.lower (string-or-list)
  "Convert STRING-OR-LIST list or string from '(\"snake\" \"case\") or \"snake case\" to \"snake_case\"."
  (declare (pure t) (side-effect-free t))
  (if (listp string-or-list)
      (string-join string-or-list "_")
    (save-match-data
      (replace-regexp-in-string (rx (one-or-more space))
                                "_"
                                string-or-list))))
;; (str:case/string:to:snake.lower "lower snake case")


(defun str:case/string:to:snake.upper (string-or-list)
  "Convert STRING-OR-LIST from \"upper snake case\" to \"UPPER_SNAKE_CASE\"."
  (declare (pure t) (side-effect-free t))
  (save-match-data
    (replace-regexp-in-string (rx (one-or-more space))
                              "_"
                              (str:case/string:to:upper string-or-list))))
;; (str:case/string:to:snake.upper "upper snake case")


(defun str:case/string:to:snake.title (string-or-list)
  "Convert STRING-OR-LIST from \"title snake case\" to \"Title_Snake_Case\"."
  (declare (pure t) (side-effect-free t))
  (save-match-data
    (replace-regexp-in-string (rx (one-or-more space))
                              "_"
                              (str:case/string:to:title string-or-list))))
;; (str:case/string:to:snake.title "title snake case")


;;------------------------------
;; AlTeRnAtInG cAsE
;;------------------------------

(defun str:case/string:to:alternating.general (string-or-list first-char-lower)
  "Convert STRING-OR-LIST from \"alternating case\" to \"AlTeRnAtInG cAsE\".

If FIRST-CHAR-LOWER is non-nil, alternating case will start off with a
lower case character."
  (declare (pure t) (side-effect-free t))
  ;; Case conversion toggle on only visible characters.
  (let* ((string (int<str>:case:normalize->str "str:case/string:to:alternating.general"
                                               string-or-list))
         (string.length (length string))
         (index 0)
         next
         (upper? (null first-char-lower))
         chars)
    (while (and index
                (< index string.length))
      (message "next: %s, index: %s, char: %s"
               next index (string (elt string index)))
      ;; Should we search for something to change?
      (when (or (null next)
                (< next index))
        ;; Find next character to change.
        (save-match-data
          (setq next (string-match (rx letter)
                                   string
                                   index)))
        (message "find next `next'! index: %S, next: %S" index next))

      ;; Should we uppercase/lowercase this char or just pass it on?
      (if (and index
               next
               (= index next))
          (progn
            (if upper?
                (push (upcase (elt string index)) chars)
              (push (downcase (elt string index)) chars))
            (setq upper? (not upper?)))

        (push (elt string index) chars))

      (message "chars: %S" chars)
      (setq index (1+ index)))

    (apply #'string (nreverse chars))))
;; (str:case/string:to:alternating.general "hello" t)
;; (str:case/string:to:alternating.general "hello" nil)


(defun str:case/string:to:alternating.upper (string-or-list)
  "Convert STRING-OR-LIST from \"alternating case\" to \"AlTeRnAtInG cAsE\"."
  (declare (pure t) (side-effect-free t))
  (str:case/string:to:alternating.general string-or-list nil))


(defun str:case/string:to:alternating.lower (string-or-list)
  "Convert STRING-OR-LIST from \"alternating case\" to \"aLtErNaTiNg CaSe\"."
  (declare (pure t) (side-effect-free t))
  (str:case/string:to:alternating.general string-or-list t))


(defun str:case/string:to:alternating.random (string-or-list)
  "Convert STRING-OR-LIST from \"alternating case\" to either
\"AlTeRnAtInG cAsE\" or \"aLtErNaTiNg CaSe\"."
  (declare (pure t) (side-effect-free t))
  (str:case/string:to:alternating.general string-or-list
                                          (= (% (random) 2) 0)))


;;------------------------------
;; General Conversion
;;------------------------------

(defconst int<str>:case:from:converted-by-lowercasing
  '(:lower
    :upper
    :title
    :alternating
    :alternating.lower
    :alternating.upper)
  "Case types that are taken care of in the 'convert from' step by the conversion to lower-case.")


(defun str:case/string:from (string)
  "Process string for conversion by converting it from whatever it is into a list of string words."
  (declare (pure t) (side-effect-free t))

  ;; We want to get to lowercase for processing, so start off by just lowercasing the entire string.
  ;; This takes care of: (:lower :upper :title :alternating)
  (let ((str.working (str:case/string:to:lower string)))
    ;; Convert from anything known into list of lowercased words.
    ;; Return `str.working' when we're done.
    (dolist (from (str:case:identify str.working) str.working)
      (cond
       ((memq from int<str>:case:from:converted-by-lowercasing)
        ;; This is fine; already taken care of in `let'.
        str.working)

       (:snake
        (setq str.working (str:case/string:from:snake str.working)))

       (t
        ;; Haven't coded a conversion for that yet...
        (error "str:case/string:to:from: Encountered a case type (%S) that was unexpected! Working String: '%s'"
               from str.working))))))
;; (str:case/string:from "HELLO_THERE")


(defun str:case/string:to (string &rest cases)
  "Convert STRING according to CASES keywords.

Can print unused CASES keywords if `:print' CASE keyword is used."
  (declare (pure t) (side-effect-free t))

  (unless cases
    (error (concat "%s: Require CASES keywords to convert string! "
                   "string: '%s', cases: %S")
           "str:case/string:to"
           string
           cases))

  (let ((words.lower (str:case/string:from string))
        (cases.remaining cases))
    (prog1
        ;; Return the string created from this:
        (cond
         ;;------------------------------
         ;; UPPER/Title/LOWER cases
         ;;------------------------------
         ((memq :upper cases)
          (setq cases.remaining (remove :upper cases.remaining))
          (str:case/string:to:upper words.lower))

         ((memq :title cases)
          (setq cases.remaining (remove :title cases.remaining))
          (str:case/string:to:title words.lower))

         ((memq :lower cases)
          (setq cases.remaining (remove :lower cases.remaining))
          (str:case/string:to:lower words.lower))

         ;;------------------------------
         ;; snake_cases
         ;;------------------------------
         ;; Check non-default for a case type first. e.g. UPPER_SNAKE_CASE.
         ((and (memq :snake cases)
               (memq :upper cases))
          (setq cases.remaining (remove :snake cases.remaining))
          (setq cases.remaining (remove :upper cases.remaining))
          (str:case/string:to:snake.upper words.lower))

         ((and (memq :snake cases)
               (memq :title cases))
          (setq cases.remaining (remove :snake cases.remaining))
          (setq cases.remaining (remove :title cases.remaining))
          (str:case/string:to:snake.title words.lower))

         ;; Default snake_case.
         ((memq :snake cases)
          (setq cases.remaining (remove :snake cases.remaining))
          (setq cases.remaining (remove :lower cases.remaining))
          (str:case/string:to:snake.lower words.lower))

         ;;------------------------------
         ;; CamelCases
         ;;------------------------------
         ((and (memq :camel cases)
               (memq :upper cases))
          (setq cases.remaining (remove :camel cases.remaining))
          (setq cases.remaining (remove :upper cases.remaining))
          (str:case/string:to:camel.upper words.lower))


         ;; Default camel_case.
         ((memq :camel cases)
          (setq cases.remaining (remove :camel cases.remaining))
          (setq cases.remaining (remove :lower cases.remaining))
          (str:case/string:to:camel.lower words.lower))

         ;;------------------------------
         ;; AlTeRnAtInG cases
         ;;------------------------------
         ((or (memq :alternating.upper cases)
              (and  (memq :alternating cases)
                    (memq :upper cases)))
          (setq cases.remaining (remove :alternating.upper cases.remaining))
          (setq cases.remaining (remove :alternating cases.remaining))
          (setq cases.remaining (remove :upper cases.remaining))
          (str:case/string:to:alternating.upper words.lower))

         ;; Default aLtErNaTiNg CaSe.
         ((or (memq :alternating.lower cases)
              (and  (memq :alternating cases)
                    (memq :lower cases))
              (memq :alternating cases))
          (setq cases.remaining (remove :alternating.lower cases.remaining))
          (setq cases.remaining (remove :alternating cases.remaining))
          (setq cases.remaining (remove :lower cases.remaining))
          (str:case/string:to:alternating.lower words.lower))

         ((or (memq :alternating.random cases)
              (and (memq :alternating cases)
                   (memq :random cases)))
          (setq cases.remaining (remove :alternating.random cases.remaining))
          (setq cases.remaining (remove :alternating cases.remaining))
          (setq cases.remaining (remove :random cases.remaining))
          (str:case/string:to:alternating.random words.lower)))

      ;; Print unused cases?
      (when (memq :print cases)
        (setq cases.remaining (remove :print cases.remaining))
        (message "str:case/string:to: Unused cases keywords: %S"
                 cases.remaining)))))
;; (str:case/string:to "Hello_There" :snake :upper)
;; (str:case/string:to "Hello_There" :snake :upper :print)


;;------------------------------------------------------------------------------
;; Case Conversion - Region
;;------------------------------------------------------------------------------

;;------------------------------
;; Simple
;;------------------------------

(defun str:case/region:to:lower (start end)
  "Convert region in current buffer described by START and END
integers/markers to lowercase."
  (downcase-region start end))


(defun str:case/region:to:upper (start end)
  "Convert region in current buffer described by START and END
integers/markers to uppercase."
  (upcase-region start end))


;;------------------------------
;; Title Case
;;------------------------------

(defun str:case/region:to:title (start end)
  "Convert region in current buffer described by START and END
integers/markers from \"title case\" to \"Title Case\"."
  (int<str>:region->region start end #'str:case/string:to:title))


;;------------------------------
;; CamelCase
;;------------------------------

(defun str:case/region:to:camel.lower (start end)
  "Convert region in current buffer described by START and END
integers/markers from \"lower camel case\" to \"lowerCamelCase\"."
  (int<str>:region->region start end #'str:case/string:to:camel.lower))


(defun str:case/region:to:camel.upper (start end)
  "Convert region in current buffer described by START and END
integers/markers from \"upper camel case\" to \"UpperCamelCase\"."
  (int<str>:region->region start end #'str:case/string:to:camel.upper))


;;------------------------------
;; snake_case
;;------------------------------

(defun str:case/region:from:snake (start end)
  "Convert region in current buffer described by START and END
integers/markers from \"snake_case\" to \"snake case\"."
  (int<str>:region->region start end #'str:case/string:from:snake))


(defun str:case/region:to:snake.lower (start end)
  "Convert region in current buffer described by START and END
integers/markers list or string from '(\"snake\" \"case\") or \"snake case\" to \"snake_case\"."
  (int<str>:region->region start end #'str:case/string:from:snake.lower))
;; (str:case/region:to:snake.lower "lower snake case")


(defun str:case/region:to:snake.upper (start end)
  "Convert region in current buffer described by START and END
integers/markers from \"upper snake case\" to \"UPPER_SNAKE_CASE\"."
  (int<str>:region->region start end #'str:case/string:from:snake.upper))


(defun str:case/region:to:snake.title (start end)
  "Convert region in current buffer described by START and END
integers/markers from \"title snake case\" to \"Title_Snake_Case\"."
  (int<str>:region->region start end #'str:case/string:from:snake.title))


;;------------------------------
;; AlTeRnAtInG cAsE
;;------------------------------

(defun str:case/region:to:alternating.general (start end first-char-lower)
  "Convert region in current buffer described by START and END
integers/markers from \"alternating case\" to \"AlTeRnAtInG cAsE\".

If FIRST-CHAR-LOWER is non-nil, alternating case will start off with a
lower case character."
  (int<str>:region->region start end #'str:case/string:to:alternating.general first-char-lower))


(defun str:case/region:to:alternating.upper (start end)
  "Convert region in current buffer described by START and END
integers/markers from \"alternating case\" to \"AlTeRnAtInG cAsE\"."
  (int<str>:region->region start end #'str:case/string:to:alternating.upper))


(defun str:case/region:to:alternating.lower (start end)
  "Convert region in current buffer described by START and END
integers/markers from \"alternating case\" to \"aLtErNaTiNg CaSe\"."
  (int<str>:region->region start end #'str:case/string:to:alternating.lower))


(defun str:case/region:to:alternating.random (start end)
  "Convert region in current buffer described by START and END
integers/markers from \"alternating case\" to either
\"AlTeRnAtInG cAsE\" or \"aLtErNaTiNg CaSe\"."
  (int<str>:region->region start end #'str:case/string:to:alternating.random))


;;------------------------------
;; General Conversion
;;------------------------------

(defun str:case/region:to (start end &rest cases)
  "Convert region in current buffer described by START and END
integers/marker according to CASES keywords."
  (apply #'int<str>:region->region start end #'str:case/string:to cases))


;;------------------------------------------------------------------------------
;; from Ye Olde .emacs.d
;;------------------------------------------------------------------------------

;; (defun spydez/case/alternating/region (start end)
;;   "Use this function to display how very serious and unmockable you find
;; something.
;; Will convert the region selected between point and mark (START
;; and END) into alternating case. Randomly decides between starting
;; off with first letter as uppercase or lowercase.
;; aka Alternating Caps
;; aka Studly Caps
;; aka 'Mocking SpongeBob'
;; "
;;   (interactive "r")

;;   (if (not (use-region-p))
;;       (message "No active region to change.")

;;     ;; Do the conversion.
;;     (save-excursion
;;       (let ((to-upper (spydez/random/bool))
;;             (string (buffer-substring-no-properties start end)))
;;         (dotimes (i (length string))
;;           (goto-char (+ start i))
;;           ;; Case conversion toggle on only visible characters.
;;           (when (string-match (rx graphic) string i)
;;             (if to-upper
;;                 (spydez/case/upper/char 1)
;;               (spydez/case/lower/char 1))

;;             ;; Toggle case for next letter.
;;             (setq to-upper (not to-upper))))))))


;; (defun spydez/case/alternating/word ()
;;   "Use this function to display how very serious and unmockable you find
;; something.
;; Will convert starting at point. Randomly decides between starting
;; off with first letter as uppercase or lowercase.
;; aka Alternating Caps
;; aka Studly Caps
;; aka 'Mocking SpongeBob'
;; "
;;   (interactive)

;;   ;; Do the conversion.
;;   (save-excursion
;;     (let ((pos (point))
;;           (to-upper (spydez/random/bool)))

;;       ;; Case conversion toggle on only visible characters.
;;       (while (string-match (rx graphic) (char-to-string (char-after)))
;;         ;; Actually convert.
;;         (if to-upper
;;             (spydez/case/upper/char 1)
;;           (spydez/case/lower/char 1))
;;         ;; Set-up for next char.
;;         (goto-char pos)
;;         (setq pos (1+ pos)
;;               ;; Toggle case for next letter.
;;               to-upper (not to-upper))))))


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide:with-emacs :str 'case)
