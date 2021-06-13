(doom! 
 :ui
 doom
 doom-dashboard
 (emoji +unicode +ascii +github)
 modeline
 ophints
 minimap
 (:if IS-MAC (ligatures +fira))
 hl-todo
 workspaces
 (window-select +numbers)
 vi-tilde-fringe
 vc-gutter
 tabs
 (popups +defaults +all)
 treemacs
 nav-flash
 unicode

 :config
 (default +bindings +smartparens)

 :editor
 evil
 fold
 (format +onsave)
 (parinfer +rust)
 snippets

 :emacs
 (dired +ranger +icons)
 (ibuffer +icons)
 (undo +tree)
 vc

 :completion
 (company +childframe)
 (ivy +childframe +fuzzy +icons +prescient)

 :checkers
 (spell +aspell)
 (syntax +childframe)

 :term
 vterm

 :tools
 debugger
 direnv
 (docker +lsp)
 (lsp +peek)
 (magit +forge)
 terraform
 ;;jira

 :os
 (:if IS-MAC macos)

 :app
 calendar
 (:if IS-LINUX everywhere)
 irc

 :lang
 (cc +lsp)
 (haskell +lsp)
 (javascript +lsp)
 (markdown +grip)
 (org +brain +dragndrop +pandoc +present +pretty +roam)
 (python +lsp +pyright +poetry +cython (:if IS-MAC +pyenv))
 (sh +lsp)
 (web +lsp)
 emacs-lisp
 json
 nix
 ;;tdf
 yaml)
