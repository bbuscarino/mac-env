(setq
 inhibit-startup-message t inhibit-startup-echo-area-message (user-login-name)
 initial-major-mode 'fundamental-mode initial-scratch-message nil
 fill-column 120
 locale-coding-system 'utf-8)

;; Ripped from better-defaults 
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(horizontal-scroll-bar-mode -1)
(save-place-mode 1)
(show-paren-mode 1)
(setq-default indent-tabs-mode nil)
(setq save-interprogram-paste-before-kill t
      apropos-do-all t
      mouse-yank-at-point t
      require-final-newline t
      select-enable-clipboard t
      select-enable-primary t
      save-interprogram-paste-before-kill t
      visible-bell t
      load-prefer-newer t
      ediff-window-setup-function 'ediff-setup-windows-plain)

;; Stop creating annoying files
(setq
 make-backup-files nil
 auto-save-default nil
 create-lockfiles nil
) 

;; Fonts
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
(global-hl-line-mode t)

;; Use straight from nixpkgs
(require 'straight)
(straight--make-build-cache-available)

(straight-use-package 'use-package)
(setq straight-use-package-by-default +1)

(straight-use-package 'use-package)

(use-package all-the-icons)
(add-to-list 'default-frame-alist
  '(font . "Fira Mono-12"))

(use-package doom-themes
  :after (all-the-icons treemacs)
  :config
  (setq
   doom-themes-enable-bold t
   doom-themes-enable-italic t
   )
  (load-theme 'doom-vibrant t)
  (doom-themes-visual-bell-config)

  (setq doom-themes-treemacs-theme "doom-colors")
  (doom-themes-treemacs-config)

  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

(use-package doom-modeline
  :init (doom-modeline-mode 1))

(use-package dashboard
  :after evil
  :init
  (setq
   initial-buffer-choice (lambda () (get-buffer "*dashboard*"))
   dashboard-center-content t
   dashboard-set-heading-icons t
   dashboard-set-file-icons t
   dashboard-items '((recents  . 10) (projects . 10))
   dashboard-startup-banner 'logo
   )

  :config
  (dashboard-setup-startup-hook)
  (defun dashboard-goto-recent-files ()
    "Go to recent files."
    (interactive)
    (funcall (local-key-binding "r"))
    )

  (defun dashboard-goto-projects ()
    "Go to projects."
    (interactive)
    (funcall (local-key-binding "p"))
    )

  (evil-define-key 'normal dashboard-mode-map
    "g" 'dashboard-refresh-buffer
    "}" 'dashboard-next-section
    "{" 'dashboard-previous-section
    "p" 'dashboard-goto-projects
    "r" 'dashboard-goto-recent-files
    )
  )

(use-package emojify
  :hook (after-init . global-emojify-mode)
  :config
  (emojify-set-emoji-styles '(ascii github unicode))
)

(use-package evil
  :init ;; tweak evil's configuration before loading it
  (setq
   evil-search-module 'evil-search
   evil-vsplit-window-right t
   evil-split-window-below t
   evil-want-integration t
   evil-want-keybinding nil)
  :config ;; tweak evil after loading it
  (evil-mode)
  )

(use-package evil-leader
  :after evil
  :config
  (evil-leader/set-leader "<SPC>")
  (global-evil-leader-mode)
  (evil-leader/set-key
    "<SPC>" 'counsel-M-x
    "bd" 'kill-buffer
    "br" 'revert-buffer
    "qq" 'kill-buffers-kill-terminal
    "qs" 'save-buffers-kill-emacs
    "sa" 'counsel-ag
    "w" evil-window-map
    )
  )

(use-package evil-goggles
  :after evil
  :config
  (evil-goggles-mode)
  (evil-goggles-use-diff-faces))

(use-package which-key
  :init
  (declare-function which-key-prefix-then-key-order "which-key")
  (declare-function which-key-mode "which-key")

  (setq
   which-key-sort-order #'which-key-prefix-then-key-order
   which-key-sort-uppercase-first nil
   which-key-add-column-padding 1
   which-key-max-display-columns nil
   which-key-min-display-lines 6
   which-key-side-window-slot -10
   )
  :config
  (which-key-mode +1)
  )

(use-package helm
  :config
  (helm-mode 1)
  (require 'helm-config)
  (evil-leader/set-key
    "<SPC>" 'helm-M-x
    "ff" 'helm-find-files
    "fr" 'helm-recentf
    "bb" 'helm-buffers-list
    "qq" 'kill-emacs
    )
  )

(use-package helm-projectile
  :after (helm projectile)
  :config
  (evil-leader/set-key
    "pp" 'helm-projectile-switch-project
    "pr" 'helm-projectile-recentf
    "pd" 'helm-projectile-find-dir
    "pf" 'helm-projectile-find-file
    "po" 'helm-projectile-find-file-other
    "pb" 'helm-projectile-switch-to-buffer
    "pg" 'helm-projectile-rg
    "pq" 'projectile-kill-buffers
    ))

(use-package vi-tilde-fringe
  :config ((prog-mode-hook text-mode-hook conf-mode-hook) . vi-tilde-fringe-mode))

(use-package git-gutter-fringe
  :config 
  (global-git-gutter-mode +1))

(use-package hl-todo
  :hook (prog-mode . hl-todo-mode)
  :config
  (setq hl-todo-highlight-punctuation ":"
        hl-todo-keyword-faces
        `(;; For things that need to be done, just not today.
          ("TODO" warning bold)
          ;; For problems that will become bigger problems later if not
          ;; fixed ASAP.
          ("FIXME" error bold)
          ;; For tidbits that are unconventional and not intended uses of the
          ;; constituent parts, and may break in a future update.
          ("HACK" font-lock-constant-face bold)
          ;; For things that were done hastily and/or hasn't been thoroughly
          ;; tested. It may not even be necessary!
          ("REVIEW" font-lock-keyword-face bold)
          ;; For especially important gotchas with a given implementation,
          ;; directed at another user other than the author.
          ("NOTE" success bold)
          ;; For things that just gotta go and will soon be gone.
          ("DEPRECATED" font-lock-doc-face bold)
          ;; For a known bug that needs a workaround
          ("BUG" error bold)
          ;; For warning about a problematic or misguiding code
          ("XXX" font-lock-constant-face bold))))

(use-package ligature
  :load-path "@ligature@"
  :config
  ;; Enable the "www" ligature in every possible major mode
  (ligature-set-ligatures 't '("www"))
  ;; Enable traditional ligature support in eww-mode, if the
  ;; `variable-pitch' face supports it
  (ligature-set-ligatures 'eww-mode '("ff" "fi" "ffi"))
  ;; Enable all Cascadia Code ligatures in programming modes
  (ligature-set-ligatures 'prog-mode '("|||>" "<|||" "<==>" "<!--" "####" "~~>" "***" "||=" "||>"
                                       ":::" "::=" "=:=" "===" "==>" "=!=" "=>>" "=<<" "=/=" "!=="
                                       "!!." ">=>" ">>=" ">>>" ">>-" ">->" "->>" "-->" "---" "-<<"
                                       "<~~" "<~>" "<*>" "<||" "<|>" "<$>" "<==" "<=>" "<=<" "<->"
                                       "<--" "<-<" "<<=" "<<-" "<<<" "<+>" "</>" "###" "#_(" "..<"
                                       "..." "+++" "/==" "///" "_|_" "www" "&&" "^=" "~~" "~@" "~="
                                       "~>" "~-" "**" "*>" "*/" "||" "|}" "|]" "|=" "|>" "|-" "{|"
                                       "[|" "]#" "::" ":=" ":>" ":<" "$>" "==" "=>" "!=" "!!" ">:"
                                       ">=" ">>" ">-" "-~" "-|" "->" "--" "-<" "<~" "<*" "<|" "<:"
                                       "<$" "<=" "<>" "<-" "<<" "<+" "</" "#{" "#[" "#:" "#=" "#!"
                                       "##" "#(" "#?" "#_" "%%" ".=" ".-" ".." ".?" "+>" "++" "?:"
                                       "?=" "?." "??" ";;" "/*" "/=" "/>" "//" "__" "~~" "(*" "*)"
                                       "\\" "://"))
  ;; Enables ligature checks globally in all buffers. You can also do it
  ;; per mode with `ligature-mode'.
  (global-ligature-mode t))

(use-package minimap
  :config
  (setq minimap-window-location 'right
        minimap-update-delay 0
        minimap-width-fraction 0.09
        minimap-minimum-width 15)
  (pushnew! minimap-major-modes 'text-mode 'conf-mode))

(use-package treemacs
  :init
  (setq treemacs-follow-after-init t
        treemacs-is-never-other-window t
        treemacs-sorting 'alphabetic-case-insensitive-asc
        treemacs-persist-file (concat doom-cache-dir "treemacs-persist")
        treemacs-last-error-persist-file (concat doom-cache-dir "treemacs-last-error-persist"))
  :config
  ;; Don't follow the cursor
  (treemacs-follow-mode -1))
(use-package treemacs-projectile
  :after treemacs)
(use-package treemacs-persp
  :after treemacs
  :config (treemacs-set-scope-type 'Perspectives))
(use-package treemacs-magit
  :after (treemacs magit))

(use-package ace-window)

(use-package centaur-tabs
  :hook (after-init . centaur-tabs-mode)
  :init
  (setq centaur-tabs-set-icons t
        centaur-tabs-gray-out-icons 'buffer
        centaur-tabs-set-bar 'left
        centaur-tabs-set-modified-marker t
        centaur-tabs-close-button "✕"
        centaur-tabs-modified-marker "•"
        ;; Scrolling (with the mouse wheel) past the end of the tab list
        ;; replaces the tab list with that of another Doom workspace. This
        ;; prevents that.
        centaur-tabs-cycle-scope 'tabs)

  :config
  (add-hook '+doom-dashboard-mode-hook #'centaur-tabs-local-mode)
  (add-hook '+popup-buffer-mode-hook #'centaur-tabs-local-mode))

(use-package magit)
