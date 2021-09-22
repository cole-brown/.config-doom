;;; emacs/str/+case-hydra.el -*- lexical-binding: t; -*-

(require 'hydra)
(imp:require :str 'case)


;;------------------------------------------------------------------------------
;; Hydra
;;------------------------------------------------------------------------------

(setq int<str>:hydra:case:fmt
      (concat "%-" (format "%d" (length "Random (lOwEr or UpPeR)")) "s"))

(defhydra str:hydra:case (:color red  ;; Allow & quit on non-hydra-heads.
                          :hint none) ;; no hint - just docstr
  "
Convert region to:

^^simple^^                     │ ^^snake_case^^                   │ ^^CamelCase^^                   │ ^^AlTeRnAtInG^^                 │
^^──────^^─────────────────────┼─^^──────────^^───────────────────┼─^^─────────^^───────────────────┼─^^───────────^^─────────────────┼───────────
_l_: ?l? │ _sl_:  ?sl?^ │ _cl_: ?cl? │ _al_: ?al? │ _C-g_: ?C-g?
_u_: ?u? │ _su_:  ?su?^ │ _cu_: ?cu? │ _au_: ?au? │
_t_: ?t? │ _st_:  ?st?^ │ ^ ^  ^ ^                        │ _ar_: ?ar? │
^ ^  ^ ^                       │ _s-l_: ?s-l? │ ^ ^  ^ ^                        │ ^ ^  ^ ^                        │
^ ^  ^ ^                       │ _s-u_: ?s-u? │ ^ ^  ^ ^                        │ ^ ^  ^ ^                        │
^ ^  ^ ^                       │ _s-t_: ?s-t? │ ^ ^  ^ ^                        │ ^ ^  ^ ^                        │
"
  ;;------------------------------
  ;; Simple Cases
  ;;------------------------------
  ("l" #'str:case/region:to:lower (format int<str>:hydra:case:fmt "lowercase"))
  ("u" #'str:case/region:to:upper (format int<str>:hydra:case:fmt "UPPERCASE"))
  ("t" #'str:case/region:to:title (format int<str>:hydra:case:fmt "Title Case"))

  ;;------------------------------
  ;; Snake_Cases
  ;;------------------------------
  ("sl" #'str:case/region:to:snake.lower (format int<str>:hydra:case:fmt "lower_snake_case"))
  ("su" #'str:case/region:to:snake.upper (format int<str>:hydra:case:fmt "UPPER_SNAKE_CASE"))
  ("st" #'str:case/region:to:snake.title (format int<str>:hydra:case:fmt "Title_Snake_Case"))

  ("s-l" #'str:case/region:to:snake.lower (format int<str>:hydra:case:fmt "lower-snake-case"))
  ("s-u" #'str:case/region:to:snake.upper (format int<str>:hydra:case:fmt "UPPER-SNAKE-CASE"))
  ("s-t" #'str:case/region:to:snake.title (format int<str>:hydra:case:fmt "Title-Snake-Case"))

  ;;------------------------------
  ;; CamelCases
  ;;------------------------------
  ("cl" #'str:case/region:to:camel.lower (format int<str>:hydra:case:fmt "lower_camel_case"))
  ("cu" #'str:case/region:to:camel.upper (format int<str>:hydra:case:fmt "UPPER_CAMEL_CASE"))
  ("ct" #'str:case/region:to:camel.title (format int<str>:hydra:case:fmt "Title_Camel_Case"))

  ;;------------------------------
  ;; Alternating_Cases
  ;;------------------------------
  ("al" #'str:case/region:to:alternating.lower (format int<str>:hydra:case:fmt "lOwEr AlTeRnAtInG cAsE"))
  ("au" #'str:case/region:to:alternating.upper (format int<str>:hydra:case:fmt "UpPeR aLtErNaTiNg CaSe"))
  ("ar" #'str:case/region:to:alternating.title (format int<str>:hydra:case:fmt "Random (lOwEr or UpPeR)"))

  ;;------------------------------
  ;; Explicit Quit
  ;;------------------------------
  ("C-g" nil (format int<str>:hydra:case:fmt "quit")))
;; (str:hydra:case/body)


;;------------------------------------------------------------------------------
;; The End.
;;------------------------------------------------------------------------------
(imp:provide:with-emacs :str 'hydra 'case)
