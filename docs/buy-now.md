# What to order now: links and reference codes

> 2026-11-01. For France or Spain. **Prices and stock are what I saw on that day and will change; check each page before paying.** Codes marked
> *page* were read from the shop's page; *search* from a search result I did not open. Shipping was not visible for any of them. Nothing here is
> an order: you place it.

## Order 1: DigiKey France (the converters; other European shops show them withdrawn)

| Qty | Part | Code | Link | Seen |
|---|---|---|---|---|
| 1 | Digilent Pmod AD1 (12-bit, 2 channels, 1 MS/s) | Digilent 410-064; DigiKey 1286-1001-ND | [digikey.fr](https://www.digikey.fr/en/products/detail/digilent-inc/410-064/3902823) | EUR 28.41 ex VAT, 238 in stock, Active, 4-week lead time *(page)* |
| 4 (5 for a spare) | Digilent Pmod DA3 (16-bit, SMA output) | Digilent 410-241 | [digikey.fr](https://www.digikey.fr/en/products/detail/digilent-inc/410-241/4090066) | EUR 32.36 ex VAT each, 262 in stock, Active, 4-week lead time *(page)* |

Five parts: EUR 157.85 ex VAT, about EUR 189 with French VAT (20%; Spanish VAT is 21%).

## Order 2: Reichelt (reichelt.com, French or Spanish shop)

| Qty | Part | Code | Link | Seen |
|---|---|---|---|---|
| 10 to 20 | Mini clock crystal 32.768 kHz, 3 x 8 mm, TC38 (the tuning forks) | Reichelt article `0,032768` | [reichelt.com](https://www.reichelt.com/de/en/mini-clock-crystal-32-768-khz-10-ppm-3x8-mm-tc38-0-032768-p1089.html) | EUR 0.30 each incl. 19% German VAT, limited stock *(page)* |
| 10 | Piezo element 27 mm, 4.4 kHz (scanner disks) | Reichelt `EPZ-27MS44` (article 145917) | [reichelt.com](https://www.reichelt.com/de/en/shop/product/piezo_element_4_4_khz_400_ohm-145917) | EUR 0.40 each incl. 19% German VAT, in stock *(page)* |

## Order 3: Amazon.fr (or .es)

| Qty | Part | Code | Link | Seen |
|---|---|---|---|---|
| 1 | Tungsten wire 0.2 mm x 5 m (the tips) | ASIN B0G1N1SG5M (QUARKZMAN) | [amazon.fr](https://www.amazon.fr/-/en/QUARKZMAN/dp/B0G1N1SG5M) | EUR 10.39, 2 left *(search)* |
| 1 | Sodium hydroxide 1 kg (tip etching) | ASIN B0BJVRBT7V (Algin) | [amazon.fr](https://www.amazon.fr/Algin-caustique-Hydroxyde-sodium-Bo%C3%AEte/dp/B0BJVRBT7V) | EUR 12.50 *(search; ManoMano had 8.11)* |
| 1 | Dupont jumper wires, 120 pieces, 20 cm (female-female and male-female are what the Pmods need) | ASIN B01JD5WCG2 (ELEGOO) | [amazon.fr](https://www.amazon.fr/-/en/ELEGOO-120pcs-Dupont-Breadboard-Cables/dp/B01JD5WCG2) | EUR 8.99 *(search)* |
| 1 | Eye protection and nitrile gloves (the etching bath) | not searched | | |

## Check or buy as well (not priced, or not yet findable)

* **SMA to bare-wire leads, 4:** the DA3's output is an SMA connector, so each needs a lead to reach a wire or a meter. Exact "SMA male, bare end" leads did
  not show a price; start from [AliExpress SMA pigtails](https://www.aliexpress.com/w/wholesale-sma-pigtail-connector.html) or an Amazon.fr search for
  "pigtail SMA mâle fil nu". Guess EUR 6 to 15 in all.
* **Is your Tang Nano 20K soldered?** Some listings are sold with the header pins unsoldered
  ([Amazon.fr listing "No Soldered Pin Header"](https://www.amazon.fr/Sipeed-d%C3%A9veloppement-den-t%C3%AAte-broches-soud%C3%A9es/dp/B0D8TRYXYL)). Look at your board: the
  pins in `gen/afm_top.cst` are positions on its two headers. If the headers are bare holes you need 2 x 20 pin headers (2.54 mm) and a soldering iron.
* **A second Tang Nano 20K** if the first is shared with the robot project (Amazon.fr listings about EUR 33 to 37, a 2023 to 2026 spread, search result).
  Check the live page.

## The amplifier parts (designed in `amplifier.md`; order when you are ready to build it)

| Qty | Part | Code | Link | Seen |
|---|---|---|---|---|
| 4 | OPA2134PA dual FET op-amp, DIP-8 | Reichelt `OPA 2134 PA` | [reichelt.com](https://reichelt.com/de/en/2-channel-audio-operational-amplifier-20-v-s-8-mhz-dip-8-opa-2134-pa-p73934.html) | EUR 6.33 incl. 19% German VAT *(search)* |
| 1 | LM4040AIZ-2.5 reference, TO-92 | Reichelt `LM 4040 AIZ2,5` | [reichelt.com](https://reichelt.com/de/en/shunt-voltage-reference-fixed-2-5-v-0-1-to-92-lm-4040-aiz2-5-p109411.html) | about EUR 1.93 *(search)* |
| 1 | +-12 V DC/DC module (see the supply note in `amplifier.md`: a 2 W part may be needed) | TRACO TMA 0512D | [reichelt.com](https://www.reichelt.com/de/en/shop/product/dc_dc_converter_tma_series_5_-12_v_dc-120447?r=1) | about EUR 6 *(search)*; unregulated, +-40 mA |
| 1 | trimmer capacitor 1.5 to 5 pF | Vishay BFC280823508 (Farnell 4143684) | [reichelt.com](https://www.reichelt.com/de/en/shop/product/trimmer_capacitor_1_5_-_5_pf_grey-21760) | price not seen |

Plus the resistors, capacitors and protection of its list, and a stepper driver module and motor: an A4988 (Amazon.fr 5-pack, about EUR 7 to 9.5) and a NEMA 8 stepper with its screw (`cost.md`).

## Order later, once designed

The screws and filament, the vibration slab, the PCBs, and the calibration grating (start with a CD or DVD).

## Total of the three orders now

About EUR 189 + 3 to 6 + 4 + 10.39 + 8 to 12.5 + 9 + eye protection and gloves = **about EUR 235 to 255** plus shipping and the SMA leads.
