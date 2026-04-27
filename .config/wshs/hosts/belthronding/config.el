;; [[file:../../workstation.org::*belthronding][belthronding:2]]
(after! org
  (jnm/org-common-config "~/EF/")

  (setq org-mobile-directory "~/Dropbox/Apps/MobileOrg")
  (setq org-mobile-files (org-agenda-files))
  (setq org-mobile-inbox-for-pull "~/EF/inbox-mobile.org"))
;; belthronding:2 ends here
