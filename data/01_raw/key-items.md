# EES

## PID

| EES Voter Study | Item |
|------|------|
| 2024 | Q19 |
| 2019 | Q25 |
| 2014 | QPP21 |
| 2009 | Q87 |
| 2004 | Q30 |

## Vote choice

| EES Voter Study | Item EP | Item Nat |
|------|------|------|
| 2024 | Q6 | Q8 |
| 2019 | Q7 | Q9 |
| 2014 | QP2  | QPP5 |
| 2009 | Q25 | Q27 |
| 2004 | Q10 | Q11 |

## Like/Dislike rating

| EES Voter Study | Item |
|------|------|
| 2024 | Q20 |
| 2019 | / |
| 2014 | / |
| 2009 | / |
| 2004 | / |

## Propensity to vote

| EES Voter Study | Item |
|------|------|
| 2024 | Q9 |
| 2019 | Q10 |
| 2014 | QPP8 |
| 2009 | Q39 |
| 2004 | Q12 |

## LR Placement Parties

| EES Voter Study | Item |
|------|------|
| 2024 | Q11  |
| 2019 | Q13  |
| 2014 | QPP14 |
| 2009 | Q47 |
| 2004 | Q14 |

## EU Placement Parties

| EES Voter Study | Item |
|------|------|
| 2024 | Q18 |
| 2019 | Q24 |
| 2014 | QPP19 |
| 2009 | Q81 |
| 2004 | Q22  |

# CSES

## PID

### Overview

| CSES Module | Item | 
|------|------|
| 6 (2021–2026) | `f3023` | 
| 5 (2016–2021) | `IMD3005_1`–`_4` | 
| 4 (2011–2016) | `IMD3005_1`–`_4` | 
| 3 (2006–2011) | `IMD3005_1`–`_4` | 
| 2 (2001–2006) | `IMD3005_1`–`_4` |
| 1 (1996–2001) | `IMD3005_1`–`_4` | 

### Wording and Coding

#### IMD

---------------------------------------------------------------------------
IMD3005_1 >>> PARTY IDENTIFICATION: ARE YOU CLOSE TO ANY POLITICAL PARTY
---------------------------------------------------------------------------
Do you usually think of yourself as close to any particular
party?
..................................................................
0. NO
1. YES
7. VOLUNTEERED: REFUSED
8. VOLUNTEERED: DON'T KNOW
9. MISSING

---------------------------------------------------------------------------
IMD3005_2 >>> PARTY IDENTIFICATION: DO YOU FEEL CLOSER TO ONE PARTY
---------------------------------------------------------------------------
Do you feel yourself a little closer to one of the political
parties than the others?
..................................................................
0. NO
1. YES
7. VOLUNTEERED: REFUSED
8. VOLUNTEERED: DON'T KNOW
9. MISSING

---------------------------------------------------------------------------
IMD3005_3 >>> PARTY IDENTIFICATION: WHO
---------------------------------------------------------------------------
Which party do you feel closest to?
..................................................................
0000001-9000000. [SEE CODEBOOK PART 3 FOR PARTY AND LEADER
NUMERIC CODES]
9999988. NONE OF THE CANDIDATES/PARTIES
9999989. INDEPENDENT CANDIDATE
9999990. OTHER LEFT WING CANDIDATE/PARTY
(NOT FURTHER SPECIFIED)
9999991. OTHER RIGHT WING CANDIDATE/PARTY
(NOT FURTHER SPECIFIED)
9999992. OTHER CANDIDATE/PARTY (NOT FURTHER SPECIFIED)
9999997. VOLUNTEERED: REFUSED
9999998. VOLUNTEERED: DON'T KNOW
9999999. MISSING

---------------------------------------------------------------------------
IMD3005_4 >>> PARTY IDENTIFICATION: HOW CLOSE
---------------------------------------------------------------------------
Do you feel very close to this party, somewhat close, or
not very close?
..................................................................
1. VERY CLOSE
2. SOMEWHAT CLOSE
3. NOT VERY CLOSE
7. VOLUNTEERED: REFUSED
8. VOLUNTEERED: DON'T KNOW
9. MISSING

#### Mod6

---------------------------------------------------------------------------
F3023_1 >>> Q23a. PARTY ID: ARE YOU CLOSE TO ANY POLITICAL PARTY
---------------------------------------------------------------------------
Q23a. Do you usually think of yourself as close to any particular
party?
..................................................................
0. NO
1. YES -> GO TO Q23c
7. VOLUNTEERED: REFUSED
8. VOLUNTEERED: DON'T KNOW
9. MISSING

---------------------------------------------------------------------------
F3023_2 >>> Q23b. PARTY ID: DO YOU FEEL CLOSER TO ONE PARTY
---------------------------------------------------------------------------
Q23b. Do you feel yourself a little closer to one of the political
parties than the others?
..................................................................
0. NO -> GO TO QUESTION AFTER Q23d
1. YES
7. VOLUNTEERED: REFUSED -> GO TO QUESTION AFTER Q23d
8. VOLUNTEERED: DON'T KNOW -> GO TO QUESTION AFTER Q23d
9. MISSING

---------------------------------------------------------------------------
F3023_3 >>> Q23c. PARTY ID: WHICH PARTY DO YOU FEEL CLOSEST TO
---------------------------------------------------------------------------
Q23c. Which party do you feel closest to?
..................................................................
000001-999987. [PLEASE PROVIDE PARTY CODES]
999988. NONE OF THE CANDIDATES/PARTIES
999989. INDEPENDENT CANDIDATE
999990. OTHER LEFT-WING CANDIDATE/PARTY
(NOT FURTHER SPECIFIED)
999991. OTHER RIGHT-WING CANDIDATE/PARTY
(NOT FURTHER SPECIFIED)
999992. OTHER CANDIDATE/PARTY (NOT FURTHER SPECIFIED)
999997. VOLUNTEERED: REFUSED
999998. VOLUNTEERED: DON'T KNOW
999999. MISSING

---------------------------------------------------------------------------
F3023_4 >>> Q23d. PARTY ID: DEGREE OF CLOSENESS TO THIS PARTY
---------------------------------------------------------------------------
Q23d. Do you feel very close to this party, somewhat close, or not
very close?
..................................................................
1. VERY CLOSE
2. SOMEWHAT CLOSE
3. NOT VERY CLOSE
7. VOLUNTEERED: REFUSED
8. VOLUNTEERED: DON'T KNOW
9. MISSING

## Vote choice

### Overview

| CSES Module | Item |
|------|------|
| 6 | `f3011` | 
| 5 | `E3013_LH_PL` |
| 4 | `D3006_LH_PL` |
| 3 | `C3023_LH_PL` |
| 2 | `B3006_1` |
| 1 | `A2030` | 
| In IMD | `IMD3002_LH_PL` | `IMD3002_PR_1` | `IMD3004_LH_PL` |

#### IMD

---------------------------------------------------------------------------
IMD3002_LH_PL >>> VOTE CHOICE: CURRENT LOWER HOUSE ELECTION - PARTY LIST
---------------------------------------------------------------------------
Respondent's vote choice for party list in Lower House elections.
..................................................................
0000001-9000000. [SEE CSES IMD CODEBOOK PART 3 FOR HARMONIZED
PARTY /COALITION NUMERICAL CODES]
9999988. NONE OF THE CANDIDATES/PARTIES
9999989. INDEPENDENT CANDIDATE
9999990. OTHER LEFT WING CANDIDATE/PARTY
(NOT FURTHER SPECIFIED)
9999991. OTHER RIGHT WING CANDIDATE/PARTY
(NOT FURTHER SPECIFIED)
9999992. OTHER CANDIDATE/PARTY (NOT FURTHER SPECIFIED)
9999993. INVALID/BLANK BALLOT
9999995. NOT APPLICABLE: NOT A LIST SYSTEM
9999996. NOT APPLICABLE: NO LOWER HOUSE ELECTION
9999997. VOLUNTEERED: REFUSED
9999998. VOLUNTEERED: DON'T KNOW
9999999. MISSING/ABSTAINED (DID NOT VOTE)

---------------------------------------------------------------------------
IMD3004_LH_PL >>> VOTE CHOICE: PREVIOUS LOWER HOUSE ELECTION - PARTY LIST
---------------------------------------------------------------------------
Respondent's vote choice for party list in the PREVIOUS lower
house election.
..................................................................
0000001-9000000. [SEE CSES IMD CODEBOOK PART 3 FOR HARMONIZED
PARTY /COALITION NUMERICAL CODES]
9999988. NONE OF THE CANDIDATES/PARTIES
9999989. INDEPENDENT CANDIDATE
9999990. OTHER LEFT WING CANDIDATE/PARTY
(NOT FURTHER SPECIFIED)
9999991. OTHER RIGHT WING CANDIDATE/PARTY
(NOT FURTHER SPECIFIED)
9999992. OTHER CANDIDATE/PARTY (NOT FURTHER SPECIFIED)
9999993. INVALID/BLANK BALLOT
9999995. NOT APPLICABLE: NOT A LIST SYSTEM
9999996. NOT APPLICABLE: NO LOWER HOUSE ELECTION
9999997. VOLUNTEERED: REFUSED
9999998. VOLUNTEERED: DON'T KNOW
9999999. MISSING/ABSTAINED (DID NOT VOTE)

#### Mod6

---------------------------------------------------------------------------
F3011_LH_PL >>> Q10LH-b. CURRENT LOWER HOUSE ELECTION: VOTE CHOICE - PARTY
LIST
---------------------------------------------------------------------------
Respondent's vote choice for party list in Lower House elections.
..................................................................
000001-999987. [SEE PART 3 OF CODEBOOK FOR NUMERICAL PARTY/
COALITION CODES]
999988. NONE OF THE CANDIDATES/PARTIES
999989. INDEPENDENT CANDIDATE
999990. OTHER LEFT-WING CANDIDATE/PARTY
999991. OTHER RIGHT-WING CANDIDATE/PARTY
999992. OTHER CANDIDATE/PARTY (NOT FURTHER SPECIFIED)
999993. INVALID/BLANK BALLOT
999995. NOT APPLICABLE: NOT A LIST SYSTEM
999996. NOT APPLICABLE: NO LOWER HOUSE ELECTION
999997. VOLUNTEERED: REFUSED
999998. VOLUNTEERED: DON'T KNOW
999999. MISSING/ABSTAINED (DID NOT VOTE)

---------------------------------------------------------------------------
F3011_LH_DC >>> Q10LH-c. CURRENT LOWER HOUSE ELECTION: VOTE CHOICE -
DISTRICT CANDIDATE
---------------------------------------------------------------------------
Respondent's vote choice for district candidate in Lower House
elections.
..................................................................
000001-999987. [SEE PART 3 OF CODEBOOK FOR NUMERICAL PARTY/
COALITION CODES]
999988. NONE OF THE CANDIDATES/PARTIES
999989. INDEPENDENT CANDIDATE
999990. OTHER LEFT-WING CANDIDATE/PARTY
999991. OTHER RIGHT-WING CANDIDATE/PARTY
999992. OTHER CANDIDATE/PARTY (NOT FURTHER SPECIFIED)
999993. INVALID/BLANK BALLOT
999995. NOT APPLICABLE: NO DISTRICT CANDIDATE VOTE
999996. NOT APPLICABLE: NO LOWER HOUSE ELECTION
999997. VOLUNTEERED: REFUSED
999998. VOLUNTEERED: DON'T KNOW
999999. MISSING/ABSTAINED (DID NOT VOTE)

## Like/Dislike rating

### Overview

| CSES Module | Item | In IMD |
|------|------|------|
| 6 | `f3018_a`–`f3018_i` | / |
| 5 | `E3017_A`–`E3017_I` | `IMD3008_A`–`_I` |
| 4 | `D3011_A`–`D3011_I` | `IMD3008_A`–`_I` |
| 3 | `C3009_A`–`C3009_I` | `IMD3008_A`–`_I` |
| 2 | `B3037_A`–`B3037_I` | `IMD3008_A`–`_I` |
| 1 | `A3020_A`–`A3020_I` | `IMD3008_A`–`_I` |

### Wording and Coding

#### IMD

---------------------------------------------------------------------------
IMD3008_A >>> LIKE-DISLIKE - PARTY A
IMD3008_B >>> LIKE-DISLIKE - PARTY B
IMD3008_C >>> LIKE-DISLIKE - PARTY C
IMD3008_D >>> LIKE-DISLIKE - PARTY D
IMD3008_E >>> LIKE-DISLIKE - PARTY E
IMD3008_F >>> LIKE-DISLIKE - PARTY F
IMD3008_G >>> LIKE-DISLIKE - PARTY G (OPTIONAL)
IMD3008_H >>> LIKE-DISLIKE - PARTY H (OPTIONAL)
IMD3008_I >>> LIKE-DISLIKE - PARTY I (OPTIONAL)
---------------------------------------------------------------------------
Likeability rating of Parties A-I on a 0-10 scale.
..................................................................
00. STRONGLY DISLIKE
01.
02.
03.
04.
05.
06.
07.
08.
09.
10. STRONGLY LIKE
96. HAVEN'T HEARD OF PARTY
97. VOLUNTEERED: REFUSED
98. DON'T KNOW ENOUGH ABOUT/DON'T KNOW WHERE TO RATE
99. MISSING

---------------------------------------------------------------------------
IMD3009_A >>> LIKE-DISLIKE - LEADER A
IMD3009_B >>> LIKE-DISLIKE - LEADER B
IMD3009_C >>> LIKE-DISLIKE - LEADER C
IMD3009_D >>> LIKE-DISLIKE - LEADER D
IMD3009_E >>> LIKE-DISLIKE - LEADER E
IMD3009_F >>> LIKE-DISLIKE - LEADER F
IMD3009_G >>> LIKE-DISLIKE - LEADER G (OPTIONAL)
IMD3009_H >>> LIKE-DISLIKE - LEADER H (OPTIONAL)
IMD3009_I >>> LIKE-DISLIKE - LEADER I (OPTIONAL)
---------------------------------------------------------------------------
Likeability rating of Leaders A-I on a 0-10 scale.
..................................................................
00. STRONGLY DISLIKE
01.
02.
03.
04.
05.
06.
07.
08.
09.
10. STRONGLY LIKE
96. HAVEN'T HEARD OF LEADER
97. VOLUNTEERED: REFUSED
98. DON'T KNOW ENOUGH ABOUT/DON'T KNOW WHERE TO RATE
99. MISSING

#### Mod6

---------------------------------------------------------------------------
F3018_A >>> Q16a. LIKE-DISLIKE - PARTY A
F3018_B >>> Q16b. LIKE-DISLIKE - PARTY B
F3018_C >>> Q16c. LIKE-DISLIKE - PARTY C
F3018_D >>> Q16d. LIKE-DISLIKE - PARTY D
F3018_E >>> Q16e. LIKE-DISLIKE - PARTY E
F3018_F >>> Q16f. LIKE-DISLIKE - PARTY F
F3018_G >>> Q16g. LIKE-DISLIKE - ADDITIONAL - PARTY G
F3018_H >>> Q16h. LIKE-DISLIKE - ADDITIONAL - PARTY H
F3018_I >>> Q16i. LIKE-DISLIKE - ADDITIONAL - PARTY I
---------------------------------------------------------------------------
Q16a-i. I'd like to know what you think about each of our
political parties. After I read the name of a political
party, please rate it on a scale from 0 to 10, where 0
means you strongly dislike that party and 10 means that
you strongly like that party. If I come to a party you
haven't heard of or you feel you do not know enough about,
just say so. The first party is [PARTY A].
Using the same scale, where would you place, [PARTY B]?
Using the same scale, where would you place, [PARTY C]?
Using the same scale, where would you place, [PARTY D]?
Using the same scale, where would you place, [PARTY E]?
Using the same scale, where would you place, [PARTY F]?
..................................................................
00. STRONGLY DISLIKE
01.
02.
03.
04.
05.
06.
07.
08.
09.
10. STRONGLY LIKE
96. HAVEN'T HEARD OF PARTY
97. VOLUNTEERED: REFUSED
98. DON'T KNOW ENOUGH ABOUT/DON'T KNOW WHERE TO RATE
99. MISSING

---------------------------------------------------------------------------
F3019_A >>> Q17a. LIKE-DISLIKE - LEADER A
F3019_B >>> Q17b. LIKE-DISLIKE - LEADER B
F3019_C >>> Q17c. LIKE-DISLIKE - LEADER C
F3019_D >>> Q17d. LIKE-DISLIKE - LEADER D
F3019_E >>> Q17e. LIKE-DISLIKE - LEADER E
F3019_F >>> Q17f. LIKE-DISLIKE - LEADER F
F3019_G >>> Q17g. LIKE-DISLIKE - ADDITIONAL - LEADER G
F3019_H >>> Q17h. LIKE-DISLIKE - ADDITIONAL - LEADER H
F3019_I >>> Q17i. LIKE-DISLIKE - ADDITIONAL - LEADER I
---------------------------------------------------------------------------
Q17a-i. And what do you think of the Presidential candidates/party
leaders? After I read the name of a Presidential
candidate/party leader, please rate them on a scale from 0
to 10, where 0 means you strongly dislike that candidate
and 10 means that you strongly like that candidate. If I
come to a Presidential candidate/party leader you haven't
heard of or you feel you do not know enough about, just
say so. The first is [LEADER A].
Using the same scale, where would you place, [LEADER B]?
Using the same scale, where would you place, [LEADER C]?
Using the same scale, where would you place, [LEADER D]?
Using the same scale, where would you place, [LEADER E]?
Using the same scale, where would you place, [LEADER F]?
..................................................................
00. STRONGLY DISLIKE
01.
02.
03.
04.
05.
06.
07.
08.
09.
10. STRONGLY LIKE
96. HAVEN'T HEARD OF LEADER
97. VOLUNTEERED: REFUSED
98. DON'T KNOW ENOUGH ABOUT/DON'T KNOW WHERE TO RATE
99. MISSING

## Propensity to vote

| CSES Module | Item |
|------|------|
| 1–6 | / |

CSES never fielded a per-party PTV item; the like/dislike battery is its substitute.

## LR Placement Parties

| CSES Module | Item | In IMD |
|------|------|------|
| 6 | `f3020_a`–`f3020_i` | / |
| 5 | `E3019_A`–`E3019_I` | `IMD3007_A`–`_I` |
| 4 | `D3013_A`–`D3013_I` | `IMD3007_A`–`_I` |
| 3 | `C3011_A`–`C3011_I` | `IMD3007_A`–`_I` |
| 2 | `B3038_A`–`B3038_I` | `IMD3007_A`–`_I` |
| 1 | `A3032_A`–`A3032_I` | `IMD3007_A`–`_I` |

## EU Placement Parties

| CSES Module | Item |
|------|------|
| 1–6 | / |

No EU-placement item exists. The nearest thing is the **optional alternative scale**,
fielded in Modules 5 and 6 only (`E3021_A`–`E3021_I` / `f3021_a`–`f3021_i`, self at
`E3022` / `f3021_r`). Its content is study-specific — EU integration in only some studies
— and it is not carried into the IMD.

## Coverage

IMD Phase 4 stacks Modules 1–5 (395,797 × 406; 230 studies; elections 1996–2021), and
Module 5 is **fully contained** in it (114,714 rows, `IMD1008_MOD_5 == 1`), so the two are
never stacked. Module 6 is an **advance release** (33,871 × 676; 18 studies), its names are
**lowercase**, and it **renumbers** the PID battery to `f3023_*` — `f3005_*` there is an
unrelated item. The PID battery was not fielded in `BELW1999`, `LVA_2018`, `TUN_2019`.
Code `9` conflates "missing" with "not asked", so per-study availability has to be read off
the data: see `data/03_final/cses_item_availability.csv` and
`data/03_final/cses_item_wording.csv`.

# Eurobarometer

Rows are the four collected files, newest coverage first. See
`data/01_raw/external-data.md` for provenance and `data/03_final/eb_item_wording.csv` for
wording and value codes.

## PID

| EB file | Item |
|------|------|
| EB 95.3 (2021) | / |
| Harmonised 2004–2021 | `party_att_deg` (EB71.3, 2009 only) |
| CEEB 1990–1997 | / |
| Mannheim trend 1970–2002 | `closepty` (status + strength); `feelclo` (party named) |

## Vote choice

| EB file | Item EP | Item Nat |
|------|------|------|
| EB 95.3 (2021) | / | / |
| Harmonised 2004–2021 | / | / |
| CEEB 1990–1997 | / | `V79`–`V100` (intention, per country); `V101`–`V117` (inclined to); `V118` (last national) |
| Mannheim trend 1970–2002 | `euvonext` | `voteint`; `inclvote`; `lastvote` |

## Like/Dislike rating

| EB file | Item |
|------|------|
| all four | / |

No party-rating battery exists in any collected Eurobarometer file.

## Propensity to vote

| EB file | Item |
|------|------|
| all four | / |

The near-misses are **turnout** propensity, not per-party PTV: `voteprob_nat_sc` and
`voteprob_sc` (harmonised, 2002–2004), `particip` (Mannheim, EP), `V78` (CEEB).

## LR Placement Parties

| EB file | Item |
|------|------|
| all four | / |

Self-placement only: `lrs` (Mannheim), `lr` (harmonised and EB 95.3), `V74`/`V75`/`V76`
(CEEB).

## EU Placement Parties

| EB file | Item |
|------|------|
| all four | / |

## Coverage

The attachment item runs **1975–1994** (EB4–EB42) in the Mannheim file, plus the single
**EB71.3 (2009)** point in the harmonised file — and the 2009 delivered value labels are
the *involvement* family, not *closeness*, so that point is not strictly comparable.
There is a further wording break inside the Mannheim series: EB4–EB9 ask about
*supporter/involvement*, EB10 onward about *closeness*, and English versions ask the
absolute form where French-derived ones ask the relative (codebook fn. 119). Not asked in
FI for EB39–41, nor in FI/SE/AT for EB42. The **CEEB carries no attachment item at all**.
`attach_cntry` / `attach_eur` in EB 95.3 and the harmonised file are attachment to country
and to Europe, not to a party. `data/01_raw/eb/` is git-ignored (1.4 GB) — re-download
from GESIS using the links in the inventory.
