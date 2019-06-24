
BASENAMES = \
	GRCh38-ascending-aorta \
	GRCh38-gastrocnemius-medialis \
	GRCh38-heart-left-ventricle \
	GRCh38-lung-upper-lobe \
	GRCh38-pancreas-body \
	GRCh38-spleen \
	GRCh38-stomach \
	GRCh38-tibial-nerve \
	GRCh38-transverse-colon \
	GRCh38-uterus \
	mm10-forebrain-embryo-day11.5 \
	mm10-forebrain-embryo-day12.5 \
	mm10-forebrain-embryo-day13.5 \
	mm10-forebrain-embryo-day14.5 \
	mm10-forebrain-embryo-day15.5 \
	mm10-forebrain-embryo-day16.5 \
	mm10-heart-embryo-day14.5 \
	mm10-heart-embryo-day15.5 \
	mm10-hindbrain-embryo-day11.5 \
	mm10-hindbrain-embryo-day12.5 \
	mm10-hindbrain-embryo-day13.5 \
	mm10-hindbrain-embryo-day14.5 \
	mm10-hindbrain-embryo-day15.5 \
	mm10-hindbrain-embryo-day16.5 \
	mm10-kidney-embryo-day14.5 \
	mm10-kidney-embryo-day15.5 \
	mm10-kidney-embryo-day16.5 \
	mm10-limb-embryo-day14.5 \
	mm10-limb-embryo-day15.5 \
	mm10-liver-embryo-day11.5 \
	mm10-liver-embryo-day12.5 \
	mm10-liver-embryo-day13.5 \
	mm10-liver-embryo-day14.5 \
	mm10-liver-embryo-day15.5 \
	mm10-liver-embryo-day16.5 \
	mm10-lung-embryo-day14.5 \
	mm10-lung-embryo-day15.5 \
	mm10-lung-embryo-day16.5 \
	mm10-midbrain-embryo-day11.5 \
	mm10-midbrain-embryo-day12.5 \
	mm10-midbrain-embryo-day13.5 \
	mm10-midbrain-embryo-day14.5 \
	mm10-midbrain-embryo-day15.5 \
	mm10-midbrain-embryo-day16.5

TARGETS = \
	$(addsuffix /segmentation.bed.gz,$(BASENAMES)) \
	$(addsuffix -models.tar.bz2,$(BASENAMES)) \
	$(addsuffix .json,$(BASENAMES))

## -----------------------------------------------------------------------------

all: $(TARGETS) README.md

## config files
## -----------------------------------------------------------------------------

%.json:
	cp -Lpr ~/Source/modhmm-encode/$@ .

## segmentation
## -----------------------------------------------------------------------------

%/segmentation.bed.gz: | %
	zgrep -v chrEBV ~/Source/modhmm-encode/$@ > $(basename $@)
	gzip -9 $(basename $@)
	touch -r ~/Source/modhmm-encode/$@ $@

## posteriors
## -----------------------------------------------------------------------------

%/posterior-marginal-EA.bw: | %
	cp -Lpr ~/Source/modhmm-encode/$@ $@
%/posterior-marginal-PA.bw: | %
	cp -Lpr ~/Source/modhmm-encode/$@ $@
%/posterior-marginal-BI.bw: | %
	cp -Lpr ~/Source/modhmm-encode/$@ $@
%/posterior-marginal-PR.bw: | %
	cp -Lpr ~/Source/modhmm-encode/$@ $@

## models directory
## -----------------------------------------------------------------------------

%-models.tar.bz2: %\:models
	tar -cjvf $@ $<
	$(RM) -rf $<

%\:models:
	cp -Lpr ~/Source/modhmm-encode/$@ .

## directories
## -----------------------------------------------------------------------------

$(BASENAMES): %:
	mkdir $@

## directories
## -----------------------------------------------------------------------------

README.md: $(TARGETS)
	echo 'Tissue | Date |Segmentation | Posteriors | Config | Single-feature model | Comment' >> $@
	echo '-------|------|-------------|------------|--------|----------------------|--------' >> $@
	for i in $(BASENAMES); do \
		echo -n "$$i" | sed 's/-/ /g'; \
		echo -n " | $$(stat -c %y $$i/segmentation.bed.gz | sed 's/ .*$$//')"; \
		echo -n " | [Segmentation](https://github.com/pbenner/modhmm-segmentations/raw/master/$$i/segmentation.bed.gz)"; \
		echo -n " |   [Posteriors](https://owww.molgen.mpg.de/~benner/pool/modhmm/$$i/)"; \
		echo -n " |       [Config](https://github.com/pbenner/modhmm-segmentations/raw/master/$$i.json)"; \
		echo -n " |       [Models](https://github.com/pbenner/modhmm-segmentations/raw/master/$$i-models.tar.bz2)"; \
		if echo $$i | grep -q "mm10"; then echo " | poly-A RNA-seq"; else echo " | total RNA-seq"; fi; \
	done >> $@

## -----------------------------------------------------------------------------

.PRECIOUS: %\:models
.PHONY: all
