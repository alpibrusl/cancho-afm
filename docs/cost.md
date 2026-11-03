# What build one costs: priced for France and Spain

> Priced 2026-11-01 for a private buyer in France or Spain, in euros **including VAT** (20% in France, 21% in Spain) unless a row says
> otherwise. **How each price was obtained is marked:** *opened* = read from the shop's own product page; *search* = from a search-result
> summary of a shop page, not opened; *guess* = my estimate, no price found. Shipping is **not** in the line prices: it is one line below,
> and it is a guess. Prices and stock move; nothing is bought.

"Build one" is the first build: the tuning-fork route of `shopping-list.md`, FPGA board (Tang Nano 20K) already owned, 3D printer owned.

## Where it comes from

| Line | Price (EUR incl. VAT) | Where, and what was seen |
|---|---|---|
| **Pmod AD1**, 1 | 28.41 ex VAT = **34.09** FR / 34.38 ES | [DigiKey France](https://www.digikey.fr/en/products/detail/digilent-inc/410-064/3902823): *opened*, 238 in stock, status Active, manufacturer lead time 4 weeks |
| **Pmod DA3**, 4 | 4 x 32.36 ex VAT = 129.44 = **155.33** FR / 156.62 ES | [DigiKey France](https://www.digikey.fr/en/products/detail/digilent-inc/410-241/4090066): *opened*, 262 in stock, Active, lead time 4 weeks |
| Tuning-fork crystals, 10 (32.768 kHz, 3 x 8 mm) | **3.00** (0.30 each) | [Reichelt, TC38](https://www.reichelt.com/de/en/mini-clock-crystal-32-768-khz-10-ppm-3x8-mm-tc38-0-032768-p1089.html): *opened*, 19% German VAT shown, limited stock; 10 pF load, which does not matter because the fork is driven, not used as an oscillator. [Amazon.fr 10 x 2x6 mm](https://www.amazon.fr/sourcing-map-Oscillateurs-R%C3%A9sonateurs-32-768KHz/dp/B07ZRCGPF1) 6.64 *(search)* |
| Tungsten wire 0.2 mm, 5 m | **10.39** | [Amazon.fr QUARKZMAN](https://www.amazon.fr/-/en/QUARKZMAN/dp/B0G1N1SG5M) *(search)*, only 2 left; a sourcing map 2 m reel 15.71, rated 2.1/5 (no link kept). 5 m is enough for hundreds of tips |
| Sodium hydroxide 1 kg | **8.11 to 12.50** | [ManoMano flakes](https://www.manomano.fr/p/flocons-de-soude-caustique-1-kg-debouchage-de-toilettes-nettoyage-de-machines-fabrication-de-savon-marque-90184071) 8.11; [Amazon.fr Algin](https://www.amazon.fr/Algin-caustique-Hydroxyde-sodium-Bo%C3%AEte/dp/B0BJVRBT7V) 12.50 *(search; the pages were years old)*. Gloves and goggles: *guess* 5 to 10 |
| Piezo disks 27 mm, 10 | **4.00** (0.40 each) | [Reichelt EPZ-27MS44](https://www.reichelt.com/de/en/shop/product/piezo_element_4_4_khz_400_ohm-145917): *opened*, 19% VAT, in stock |
| Coarse approach: NEMA 8 stepper with screw | **27 to 60** | [Reichelt JOY-IT linear actuator NEMA08-04LA](https://www.reichelt.com/de/en/shop/product/linear_actuator_stepper_motor_nema_08_1_8_0_24_a_5_28_v-335319) 59.99, *opened*, in stock, **screw pitch not listed**; [AliExpress NEMA 8 with Tr4.76 x 0.635 mm screw](https://www.aliexpress.com/item/32622031618.html) about US$30 *(search)*. Plain motor only: [Reichelt JOY-IT NEMA08-01](https://www.reichelt.com/fr/fr/shop/produit/moteur_pas-a-pas_nema_08_1_8_0_6_a_3_9_v-335316) 21.42 *(opened)* |
| Stepper driver (A4988, 5-pack) | **7 to 9.5** | Amazon.fr 5 x A4988 6.96 to 9.54 *(search)*; gotronic.fr DRV8825 single 16.90 |
| Screws and nuts kit, M2 to M5, 1,000+ | **16 to 26** | [Amazon.fr 1,430 pieces](https://www.amazon.fr/-/en/1/dp/B0DQ497896) 15.99; Leroy Merlin kits 17.70 to 25.83 *(search)* |
| PLA filament 1 kg | **14.4 to 26** | Amazon.fr ELEGOO 14.43; eSUN 25.99 *(search)* |
| Jumper wires, breadboards | **9 to 15** | Amazon.fr 120 wires 8.99; kit with 3 breadboards 14.99 *(search)* |
| Anti-vibration slab 600 x 600 x 8 mm | **10.90 to 12.90** | Leroy Merlin *(search)*; a heavy base to put it under (a tile or stone slab) is a *guess* of 10 to 30 |
| Circuit boards from a fab, a few | **10 to 25** | JLCPCB about US$2 for 5 small boards plus shipping reported at US$2 to 9, plus import VAT *(search of forum posts, not a live quote)*; *guess* for the total |
| **Electronics we design** | **55 to 80** | designed in `amplifier.md`: four OPA2134PA (6.33 incl. German VAT at Reichelt), an LM4040 reference (1.93), a +-12 V DC/DC module (about 6 to 7) *priced*; resistors, capacitors, protection, enclosure and connectors *guess* |

## Total

| | Low | High |
|---|---|---|
| Converters | 189 | 191 |
| Crystals, tungsten, chemicals, piezo disks | 30 | 52 |
| Electronics we design (partly priced) | 55 | 80 |
| Stepper, driver | 34 | 70 |
| Frame hardware, wiring | 39 | 67 |
| Boards, vibration | 31 | 68 |
| Shipping, 3 or 4 separate orders (guess) | 15 | 50 |
| **Subtotal** | **about 389** | **about 578** |
| Breakage and spares, 10% (tips and forks break) | +39 | +58 |
| **Build one, without a grating** | **about 430** | **about 640** |
| Add a real calibration grating | +260 | +300 |
| **Build one, with a grating** | **about 690** | **about 940** |

* **The grating is the biggest decision.** Priced: a TGZ-series step grating is [US$250 unmounted at Ted Pella](https://www.tedpella.com/calibration_html/AFM_STM_SPM_Calibration_Specimens.aspx)
  and a set of three is A$805 at an Australian retailer *(search)*; no euro price from a European seller was found, and NT-MDT's European
  office would have to be asked for a quote. **A cheaper first calibration is a CD or DVD**, which is a periodic structure of known pitch
  (the 2025 paper scanned DVD tracks); I have not looked up its stated pitch or tolerance, so check them before relying on it. The real
  grating can wait until the instrument produces images.
* **If you own none of the tools:** add about 80 to 165 (multimeter, soldering station, loupe, tweezers; *guess*, not repriced).
* **What is firm:** the converters (a bit under half of the low total) and about two thirds of the rest are from shop pages or search results.
  **What is guess:** the electronics we design, shipping, the base for the vibration slab, gloves and goggles, the boards.

## Found while pricing

1. **The two Pmods are not stocked everywhere.** [TME](https://www.tme.eu/en/details/410-241p/add-on-boards/digilent/pmodda3/) shows the DA3 as
   withdrawn and out of stock *(opened)*; TME also shows the AD1 withdrawn and Farnell Ireland shows it no longer stocked or made *(search)*.
   DigiKey France lists both Active and in stock with a 4-week manufacturer lead time *(opened)*. Digilent's own shop refuses automated
   fetches, so its stock was not seen. Order both from one place, soon, and keep a spare.
2. **The coarse step must be tiny.** The approach rule (`docs/tune-approach.md`) needs one motor step to be smaller than the Z range less
   the free amplitude. The 2025 paper's Z buzzer moved about 1 um for 0 to 10 V (their figure). A 0.635 mm lead screw at 1.8 degrees
   moves 3.2 um per full step *(derived from the AliExpress listing's pitch)*, which would be refused; at 1/16 microstepping it is 0.2 um,
   which passes. So the stepper must be microstepped (the A4988 does 1/16), and the screw pitch matters: Reichelt's actuator does not state
   it, so ask before buying that one.
3. **The DA3 output is an SMA connector.** Each of the four needs an SMA-to-wire lead, which was not priced (guess EUR 6 to 15 in all, inside the
   "electronics we design" line). Also check whether your Tang Nano's header pins are soldered. Order list with codes: `buy-now.md`.
4. **The fork crystal's load capacitance does not matter.** It is driven by the DAC and read by the detector, not placed in an oscillator,
   so the 10 pF versus 12.5 pF listings are equivalent here.
5. **Reichelt's German pages show German VAT (19%).** Their French shop (reichelt.com/fr/fr) shows French prices; the stepper link there
   gave 21.42 including 20% VAT.

## For scale

The 2022 open high-speed controller reports about USD 3,936 to 3,963 in parts (its own figure), but that includes a commercial simplified
AFM and a National Instruments controller that this project does not use.

## Second stage (cantilevers), on top, not repriced for Europe

A box of 10 Tap190 cantilevers was USD 210 on one page that also said it does not ship everywhere; a faster ADC module (AD9226, 12-bit,
65 MS/s) was USD 36 to 64 from unbranded sellers; the optical pickup is salvaged from a drive. Price these when the first stage works.
