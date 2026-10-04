# Nemesis / Gradius (Konami, RC-742, 1986, MSX1) - disassembly
#
# The order of things: trace the flow -> generate the listing -> check that it
# gives back the ROM byte for byte -> the checks that the reassembly does NOT
# cover.
#
# WHAT CHANGES COMPARED TO A 16 KB CARTRIDGE: this is a 128 KB MegaROM with
# the Konami mapper WITHOUT SCC (Konami4), 16 banks of 8 KB. Each bank is a
# module (p00..p15) with its own org (the place where the mapper puts it to
# execute it, see tools/banks.py), its own trace, notes and listing.
# `make verify` reassembles all 16 and concatenates them: the whole ROM has to
# come out, byte for byte.
#
# And a piece that 16 KB cartridges do not need: tools/bank_tracer.py, which traces
# the WHOLE CARTRIDGE keeping track of which bank is in each slot. That is
# where the src/pNN.entries (the calls that cross the mapper) and the
# src/pNN.nocode (the dispatcher tables) come from. `make seeds`
# regenerates them.
#
# The ROM is not distributed. It is needed in the root as nemesis.rom, and
# `make check` verifies the sha256.

ROM      = nemesis.rom
SHA      = 3210f8a0f2309dd4b9a89fc2b24d0f178ce4393a0a1f2854fbce545c361261bc
SRC      = src
WORK     = work
TITLE    = NEMESIS / GRADIUS - Konami (1986) - MSX1 - 128 KB MegaROM RC-742 (Konami4)

BANKS    = 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15

# Where each bank executes. It is the same table as `python3 tools/banks.py
# list` (a test checks it); it is copied here so as not to launch python 32
# times on every make.
ORG_00 = 0x4000
ORG_01 = 0x6000
ORG_02 = 0x8000
ORG_03 = 0xa000
ORG_04 = 0x6000
ORG_05 = 0x8000
ORG_06 = 0xa000
ORG_07 = 0x8000
ORG_08 = 0xa000
ORG_09 = 0x8000
ORG_10 = 0xa000
ORG_11 = 0x8000
ORG_12 = 0xa000
ORG_13 = 0x8000
ORG_14 = 0x8000
ORG_15 = 0x8000
ORG    = $(ORG_$(1))

all: listing verify sanity test

$(ROM):
	@echo "=================================================================="
	@echo " $(ROM) is missing, and this repository does NOT distribute it."
	@echo ""
	@echo " It is Nemesis / Gradius (Konami, RC-742, 1986) for MSX,"
	@echo " exactly 131072 bytes. Put it here with that name."
	@echo " To check that it is the same one:"
	@echo "     shasum -a 256 $(ROM)"
	@echo "     $(SHA)"
	@echo ""
	@echo " Without it you can still read the listing already generated in $(SRC)/,"
	@echo " and the tests that do not depend on the binary still pass."
	@echo "=================================================================="
	@false

check: $(ROM)
	@echo "$(SHA)  $(ROM)" | shasum -a 256 -c -

# Survey: header, writes to the mapper, and the check that every write obeys
# the bank -> org rule. It is the foundation everything else rests on.
recon: $(ROM)
	@python3 tools/recon.py $(ROM)

# The mark Konami hid at the end of bank 3. The discovery is by
# Manuel Pazos (@ManuelPazosMSX), not ours.
mark: $(ROM)
	@python3 tools/konami_mark.py $(ROM)

# The 16 banks cut out of the ROM, one per file.
$(WORK)/p00.bin: $(ROM) tools/banks.py
	@mkdir -p $(WORK)
	python3 tools/banks.py split $(ROM) $(WORK)

banks: $(WORK)/p00.bin

# The seeds: the whole-cartridge trace, which is the only one that knows which
# bank is in each slot. It rewrites the .entries and the .nocode files.
seeds: $(ROM)
	python3 tools/bank_tracer.py $(ROM) write $(SRC)

# The trace follows the flow from the entry points OF EACH BANK.
define TRACE_RULE
$(WORK)/p$(1).trace.json: $(WORK)/p00.bin $(SRC)/p$(1).entries $(SRC)/p$(1).nocode tools/z80trace.py
	python3 tools/z80trace.py $(WORK)/p$(1).bin $(call ORG,$(1)) $(SRC)/p$(1).entries \
	        $(WORK)/p$(1) $(SRC)/p$(1).nocode
endef
$(foreach p,$(BANKS),$(eval $(call TRACE_RULE,$(p))))

trace: $(foreach p,$(BANKS),$(WORK)/p$(p).trace.json)

# One listing per bank: src/nemesis_pNN.asm, with the org of that bank.
define LISTING_RULE
$(SRC)/nemesis_p$(1).asm: $(WORK)/p$(1).trace.json $(SRC)/p$(1).notes tools/mkasm.py
	python3 tools/mkasm.py $(WORK)/p$(1).bin $(call ORG,$(1)) $(WORK)/p$(1).trace.json \
	        $(SRC)/p$(1).notes $(WORK)/msx.sym $(SRC)/nemesis_p$(1).asm \
	        "$(TITLE) - bank $(1) (runs at $(call ORG,$(1)))"
endef
$(foreach p,$(BANKS),$(eval $(call LISTING_RULE,$(p))))

listing: $(foreach p,$(BANKS),$(SRC)/nemesis_p$(p).asm)

# The test that decides whether the disassembly is reliable: each bank
# reassembles to its 8192 bytes, and the 16 concatenated give the whole ROM.
verify: $(WORK)/p00.bin
	@for p in $(BANKS); do \
	  sh tools/verify_build.sh $(SRC)/nemesis_p$$p.asm $(WORK)/p$$p.bin \
	     `python3 tools/banks.py org $$p` $(WORK)/p$$p.out.bin || exit 1; \
	done
	@sh tools/verify_rom.sh $(WORK) $(ROM) $(SHA)

# What the reassembly can NOT catch: some data being read as code. The binary
# comes out identical anyway, because the bytes do not change; the only thing
# that changes is what we say about them.
sanity: trace
	@echo "=================================================================="
	@echo " every write to the mapper obeys the bank -> org rule"
	@echo "=================================================================="
	@python3 tools/recon.py $(ROM) | tail -1
	@echo "=================================================================="
	@echo " no byte declared as data can come out as code"
	@echo "=================================================================="
	@for p in $(BANKS); do \
	  python3 tools/check_trace.py $(WORK)/p$$p.trace.json $(SRC)/p$$p.nocode | tail -1 || exit 1; \
	done
	@python3 tools/check_data_as_code.py $(WORK) $(SRC)
	@echo "=================================================================="
	@echo " the per-bank trace and the whole-cartridge trace agree"
	@echo "=================================================================="
	@python3 tools/check_bank_tracer.py $(ROM) $(WORK) $(SRC)
	@echo "=================================================================="
	@echo " no entry point can fall inside a data area"
	@echo "=================================================================="
	@for p in $(BANKS); do \
	  python3 tools/check_entries.py $(SRC)/p$$p.entries $(SRC)/p$$p.notes \
	          $(SRC)/p$$p.nocode | tail -1 || exit 1; \
	done
	@echo "=================================================================="
	@echo " not a single byte of the cartridge unassigned (all 16 banks)"
	@echo "=================================================================="
	@python3 tools/budget.py $(WORK) $(SRC)

# Puts in both READMEs the figures that are really in the tree. The tests
# compare both, so this is run after every round of comments.
figures:
	@python3 tools/figures.py

density:
	@for p in $(BANKS); do \
	  echo "-- p$$p"; python3 tools/density.py $(SRC)/nemesis_p$$p.asm | tail -2; \
	done

test:
	@echo "=================================================================="
	@echo " Tests"
	@echo "=================================================================="
	@python3 -m unittest discover -s tests -v

# The website images are NOT screenshots: tools/graphics.py runs in Python the
# decompressor at 0x49B9, the character loader at 0x42FC and the column
# builder at 0x46AE, and draws the screens and the twelve maps from the ROM.
images: $(ROM)
	@python3 tools/graphics.py

web: images
	@python3 tools/md2html.py docs en
	@python3 tools/md2html.py docs/es es
	@python3 tools/make_web.py docs/images docs/index.html en
	@python3 tools/make_web.py docs/images docs/es/index.html es
	@python3 tools/check_links.py docs

clean:
	rm -f $(WORK)/p*.trace.json $(WORK)/p*.blocks $(WORK)/p*.out.bin \
	      $(WORK)/nemesis_reassembled.rom $(WORK)/pasmo.err

.PHONY: all check recon mark banks seeds trace listing verify \
        sanity figures density test images web clean
