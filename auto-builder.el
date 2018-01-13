(defvar auto-builder-default-context "Org::FRDCSA::AutoBuilder::CommandErrors")

(global-set-key "\C-cabrr" 'auto-builder-record-region-as-error)

(defun auto-builder-record-region-as-error ()
 ""
 (interactive)
 (let* ((error-text (buffer-substring-no-properties (point) (mark)))
	(command-invocation
	 (save-excursion
	  (comint-previous-prompt 1)
	  (set-mark (point))
	  (end-of-line)
	  (buffer-substring-no-properties (point) (mark)))))
  (freekbs2-assert
   (list "commandHasError" command-invocation error-text)
   auto-builder-default-context)))

;; command
;; ./configure --disable-dependency-tracking

;; error
;; configure: error: in `/var/lib/myfrdcsa/sandbox/ltsmin-2.1/ltsmin-2.1':
;; configure: error: popt not found.

;; solution
;; sudo apt-get install libpopt-dev
