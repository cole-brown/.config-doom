;; -*- no-byte-compile: t; lexical-binding: t; -*-
;;; input/keyboard/test/layout/derive.el

;;------------------------------------------------------------------------------
;; Test Layout
;;------------------------------------------------------------------------------

;;---
;; Test Files:
;;---
;; "test/layout/base.el" will load "test/base.el" and all tested files from "test/__.el" level.
(imp:test:load :filename "base.el")

;;---
;; Keyboard Layout Files:
;;---
(imp:test:load :feature:post '(:input keyboard layout derive)
               :path         int<keyboard>:path:dir/root
               :filename     "layout/derive.el")


;; ╔═════════════════════════════╤═══════════╤═════════════════════════════════╗
;; ╟─────────────────────────────┤ ERT TESTS ├─────────────────────────────────╢
;; ╠═════════════════════╤═══════╧═══════════╧════════╤════════════════════════╣
;; ╟─────────────────────┤ Input: Keyboards & Layouts ├────────────────────────╢
;; ╚═════════════════════╧════════════════════════════╧════════════════════════╝


;;------------------------------------------------------------------------------
;; Tests: Unbind Functions
;;------------------------------------------------------------------------------

;;------------------------------
;; int<keyboard>:layout/derive:normalize->modifier
;;------------------------------

(ert-deftest test<keyboard>::int<keyboard>:layout/derive:normalize->modifier ()
  "Test that `int<keyboard>:layout/derive:normalize->modifier' behaves appropriately."
  (test<keyboard>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<keyboard/alist>::int<keyboard>:layout/derive:normalize->modifier"
      ;; Clear out keybinds before test.
      #'test<keyboard/layout>:setup
      #'test<keyboard/layout>:teardown


    ;;===
    ;; Run the test.
    ;;===

    ;;------------------------------
    ;; Invalid Inputs
    ;;------------------------------
    (should-error (int<keyboard>:layout/derive:normalize->modifier "control"))
    (should-error (int<keyboard>:layout/derive:normalize->modifier (quote "control")))

    (should-error (int<keyboard>:layout/derive:normalize->modifier (list :control)))

    (let ((control "control"))
      (should-error (eq :control (int<keyboard>:layout/derive:normalize->modifier control))))

    ;;------------------------------
    ;; Valid Inputs
    ;;------------------------------
    (should (eq :control (int<keyboard>:layout/derive:normalize->modifier ':control)))
    (should (eq :control (int<keyboard>:layout/derive:normalize->modifier 'control)))
    (should (eq :control (int<keyboard>:layout/derive:normalize->modifier (quote (quote control)))))
    (should (eq :unshift (int<keyboard>:layout/derive:normalize->modifier 'unshift)))
    (should (eq :jeff (int<keyboard>:layout/derive:normalize->modifier 'jeff)))))


;;------------------------------
;; int<keyboard>:layout/derive:search/registered:in-list
;;------------------------------

(ert-deftest test<keyboard>::int<keyboard>:layout/derive:search/registered:in-list ()
  "Test that `int<keyboard>:layout/derive:search/registered:in-list' behaves appropriately."
  (test<keyboard>:fixture
      ;;===
      ;; Test name, setup & teardown func.
      ;;===
      "test<keyboard/alist>::int<keyboard>:layout/derive:search/registered:in-list"
      ;; Clear out keybinds before test.
      #'test<keyboard/layout>:setup
      #'test<keyboard/layout>:teardown


    ;;===
    ;; Run the test.
    ;;===

    ;;------------------------------
    ;; Register some keybinds to search.
    ;;------------------------------
    (let ((register/registrar :debug)
          (register/type      :common)
          ;; We pass in the `registered-binds', so we don't actually have to register...
          ;; Just create a list of 'em.
          (register/binds '((:common .
                             (:n "s" :layout:common:undefined
                              :e "u" #'ignore
                              :nvm "o" :layout:common:char-prev))
                            (:evil .
                             ((:prefix ("s" . "Evil States")
                               :nv "h" :layout:evil:state-insert-before)
                              :nvm "." :layout:evil:line-prev
                              :nvm "e" :layout:evil:line-next
                              :nvm "o" :layout:evil:char-prev
                              :nvm "u" :layout:evil:char-next
                              :m "A" :layout:evil:word-prev-begin
                              (:after org
                               :after evil-org
                               :map evil-org-mode-map
                               (:prefix ("s" . "Evil States")
                                :n "t" #'evil-org-open-below))))))
          ;; alist to use for translating keywords.
          (keyword->func  '((:evil   . ((:layout:evil:state-insert-before . evil-insert)
                                        (:layout:evil:line-prev . evil-previous-line)
                                        (:layout:evil:line-next . evil-next-line)
                                        (:layout:evil:char-prev . evil-backward-char)
                                        (:layout:evil:char-next . evil-forward-char)
                                        (:layout:evil:word-prev-begin . evil-backward-word-begin)))
                            (:common . ((:layout:common:undefined . nil)
                                        (:layout:common:not-bound . some-func-name)
                                        (:layout:common:char-prev . backward-char))))))

      ;;------------------------------
      ;; Valid Searches
      ;;------------------------------
      (should (string= "u"
                       (int<keyboard>:layout/derive:search/registered:in-list
                        #'ignore
                        register/binds
                        keyword->func)))
      (should (string= "u"
                       (int<keyboard>:layout/derive:search/registered:in-list
                        :layout:evil:char-next
                        register/binds
                        keyword->func)))
      (should (string= "t"
                       (int<keyboard>:layout/derive:search/registered:in-list
                        #'evil-org-open-below
                        register/binds
                        keyword->func)))

      ;;------------------------------
      ;; Invalid Searches
      ;;------------------------------
      ;; Unregistered keyword -> error.
      (should-error (int<keyboard>:layout/derive:search/registered:in-list
                     :layout:common:does-not-exist
                     register/binds
                     keyword->func))
      ;; Failed to find during search -> nil.
      (should-not (int<keyboard>:layout/derive:search/registered:in-list
                   #'func-does-not-exist
                   register/binds
                   keyword->func))
      (should-not (int<keyboard>:layout/derive:search/registered:in-list
                   :layout:common:not-bound
                   register/binds
                   keyword->func)))))


;; TODO: continue with unit testing...
;; ;;------------------------------
;; ;; int<keyboard>:layout/derive:search/registered
;; ;;------------------------------

;; (ert-deftest test<keyboard>::int<keyboard>:layout/derive:search/registered ()
;;   "Test that `int<keyboard>:layout/derive:search/registered' behaves appropriately."
;;   (test<keyboard>:fixture
;;       ;;===
;;       ;; Test name, setup & teardown func.
;;       ;;===
;;       "test<keyboard/alist>::int<keyboard>:layout/derive:search/registered"
;;       ;; Clear out keybinds before test.
;;       #'test<keyboard/layout>:setup
;;       #'test<keyboard/layout>:teardown


;;     ;;===
;;     ;; Run the test.
;;     ;;===

;;     ;;------------------------------
;;     ;; Register some keybinds to search.
;;     ;;------------------------------
;;     (let ((register/registrar :debug)
;;           (register/type      :common)
;;           ;; We pass in the `registered-binds', so we don't actually have to register...
;;           ;; Just create a list of 'em.
;;           (register/binds '((:evil   . (:nvm "C-o" :layout:evil:line-prev))
;;                             (:common . (:n "s" :layout:common:undefined
;;                                         :e "u" #'ignore
;;                                         :nvm "o" :layout:common:char-prev))))
;;           ;; alist to use for translating keywords.
;;           (keyword->func  '((:evil   . ((:layout:evil:line-prev . evil-previous-line)
;;                                         (:layout:evil:line-next . evil-next-line)
;;                                         (:layout:evil:char-prev . evil-backward-char)
;;                                         (:layout:evil:char-next . evil-forward-char)))
;;                             (:common . ((:layout:common:undefined . nil)
;;                                         (:layout:common:char-prev . backward-char))))))

;;       (int<keyboard>:layout/derive:search/registered #'ignore
;;                                                      register/binds
;;                                                      keyword->func)

;;   '((:evil
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

;;       )

;;     ))
