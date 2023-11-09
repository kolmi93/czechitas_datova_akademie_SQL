------------------------------------------------------------------------------------------------------------------
-- LEKCE 7: UNION, WINDOW FCE
------------------------------------------------------------------------------------------------------------------
--- Opakování Vytváření dočasných tabulek, CTE, subselectů
--- Nová látka: UNION ALL, UNION (spojování tabulek pod sebe)
--- Opakování JOINů
--- Nová látka: WINDOW funkce (analytické funkce)
---------------------------------------------------------------
--Opakování Vytváření dočasných tabulek, CTE, subselectů
---------------------------------------------------------------
--Občas si data musíme nejdříve připravit, nějakým SELECTem.
--Následně pracujeme už nad předpřipravenými daty.
--Předpřípravu můžeme učinit třemi způsoby: (dočasná) tabulka, CTE, subselect.
---------- SYNTAXE
-- 1. Vytvoření (dočasné) tabulky
CREATE OR REPLACE (TEMPORARY) TABLE jmeno_predpripravy AS
--** Přípravný dotaz **
;
--** Následný dotaz **
;
-- 2. CTE
WITH jmeno_predpripravy AS
    ( ** Přípravný dotaz ** )
--** Následný dotaz **
;
-- 3. SubSELECT (vnořený SELECT)
--** Následný dotaz ** JOIN/FROM/WHERE/SELECT ( ** Přípravný dotaz ** )
;
---------- POUŽITÍ - Všechny tři metody umožňují dosáhnout "stejné věci".
---- 1. Vytvoření (dočasné) tabulky
--- Přehledný kód pro mě i pro další uživatele, snadnější testování po jednotlivých krocích.
--- Více psaní - Občas se nám nemusí chtít vytvářet celou tabulku pro něco, co se dá napsat subselectem uvnitř kódu.
--- Pokud využívám data z přípravného dotazu na více místech následného dotazu nebo i v dalších dotazech, stačí mi si je vypočítat jednou. (výhoda proti CTE i subselectu)
--- Efektivnější z pohledu náročnosti na paměť - vždy mám v paměti jen jednu část dat, pak ji zapomenu a pracuji s další. Osobně používám u větších projektů jako primární metodu.
---- 2. CTE
--- Pokud potřebuji celý skript vložit do jednoho dotazu nebo nemohu vytvářet (dočasné) tabulky.
--- Pokud využívám data z přípravného dotazu na více místech následného dotazu, stačí mi si je vypočítat jednou. (výhoda proti subselectu)
---- 3. SubSELECT (vnořený SELECT)
--- Pokud potřebuji celý skript vložit do jednoho dotazu nebo nemohu vytvářet (dočasné) tabulky.
--- Vše mám na jednom místě přímo v kódu - tedy kouknu a vidím, nemusím hledat v jiné části kódu.
--- Pozor na vícenásobné zanoření, je to nepřehledné a výpočetně náročné.
---------- TVOŘÍME KONKRÉTNÍ DATA pro nahrazení (Vyberte si správné schéma!)
--** Přípravný dotaz **;
SELECT datum, pacient_id, COUNT(datum) AS pocet_navstev
FROM navstevy
GROUP BY datum, pacient_id
;
--** Následný dotaz **
SELECT telefon, MAX(pocet_navstev)
FROM pacienti
LEFT JOIN jmeno_predpripravy ON id = pacient_id
GROUP BY telefon
;
---------- VKLÁDÁME DATA DO STRUKTURY
-- 1. Vytvoření (dočasné) tabulky
CREATE OR REPLACE TABLE jmeno_predpripravy AS
SELECT datum, pacient_id, COUNT(datum) AS pocet_navstev
FROM navstevy
GROUP BY datum, pacient_id
;
SELECT telefon, MAX(pocet_navstev)
FROM pacienti
LEFT JOIN jmeno_predpripravy ON id = pacient_id
GROUP BY telefon
;
-- 2. CTE
WITH jmeno_predpripravy AS
    ( SELECT datum, pacient_id, COUNT(*) AS pocet_navstev
    FROM navstevy
    GROUP BY datum, pacient_id )
SELECT telefon, MAX(pocet_navstev)
FROM pacienti
LEFT JOIN jmeno_predpripravy ON id = pacient_id
GROUP BY telefon
;
-- 3. SubSELECT (vnořený SELECT)
SELECT telefon, MAX(pocet_navstev)
FROM pacienti
LEFT JOIN (SELECT datum, pacient_id, COUNT(*) AS pocet_navstev FROM navstevy GROUP BY datum, pacient_id) ON id = pacient_id
GROUP BY telefon
;
---------- VYZKOUŠEJ SI
--V rámci přípravného dotazu si z tabulky Navstevy vyber id_pacienta a pro každé id_pacienta spočítej počet návštěv (COUNT *) a urči datum poslední návštěvy (MAX datum).
--V rámci následného dotazu vyjdi z tabulky Pacienti, vyber z ní sloupce jmeno a telefon. Přes LEFT JOIN připoj předpřipravený dotaz a z něj ve výsledku zobraz sloupce počtu návštěv a data poslední návštěvy.
--Vyzkoušej si příklad na dočasné tabulce, CTE i vnořeném selectu.

-- Přípravný dotaz
SELECT pacient_id, COUNT(*), MAX(datum)
FROM navstevy
GROUP BY pacient_id
;
-- Následný dotaz
SELECT jmeno, telefon
FROM pacienti
-- LEFT JOIN priprava ON priprava.pacient.id = pacienti.id
;
-- 1. Dočasná tabulka
CREATE OR REPLACE TEMPORARY TABLE priprava AS -- Nejdříve si připravíme dočasnou tabulku "priprava"
SELECT pacient_id, COUNT(*) AS pocet_navstev, MAX(datum) AS posledni_navsteva
FROM navstevy
GROUP BY pacient_id
;
-- Následný dotaz
SELECT jmeno, telefon, pocet_navstev, posledni_navsteva
FROM pacienti
LEFT JOIN priprava ON priprava.pacient_id = pacienti.id
;
-- 2. CTE
-- CTE část
WITH priprava AS
(SELECT pacient_id, COUNT(*) AS pocet_navstev, MAX(datum) AS posledni_navsteva
FROM navstevy
GROUP BY pacient_id)
-- Následný dotaz, který využívá CTE
SELECT jmeno, telefon, pocet_navstev, posledni_navsteva
FROM pacienti
LEFT JOIN priprava ON priprava.pacient_id = pacienti.id
;
-- 3. Vnořený SELECT
-- Začínám následným dotazem
SELECT jmeno, telefon, pocet_navstev, posledni_navsteva
FROM pacienti
LEFT JOIN (SELECT pacient_id, COUNT(*) AS pocet_navstev, MAX(datum) AS posledni_navsteva
FROM navstevy
GROUP BY pacient_id) -- zde vkládám pripravu
ON pacient_id = pacienti.id
;
---------------------------------------------------------
-- UNION, UNION ALL
---------------------------------------------------------
-- UNION ALL operator spoji tabulky pod sebe (na rozdil od joinu, ktery je poji vedle sebe)
-- tabulky musi mit stejnou strukturu (stejne sloupce a stejne poradi sloupcu) - muzeme si tabulku upravit v selectu a pokud napriklad v jedne tabulce chybi sloupec, muzeme si ho vytvorit (a dosadit nejakou defaultni hodnotu)
-- Ukazka na dummy datech
-- Tabulka 1:
SELECT
1 AS TAB1_PRVNI_SLOUPEC
, 1 AS TAB1_DRUHY_SLOUPEC
;
-- Tabulka 2:
SELECT
2 AS TAB2_PRVNI_SLOUPEC
, 2 AS TAB2_DRUHY_SLOUPEC
;
-- spojime dohromady pomoci UNION ALL
SELECT
1 AS TAB1_PRVNI_SLOUPEC
, 1 AS TAB1_DRUHY_SLOUPEC
UNION ALL
SELECT
2 AS TAB2_PRVNI_SLOUPEC
, 2 AS TAB2_DRUHY_SLOUPEC
;
-- Spojime stejne sloupce pod sebe
SELECT
1 AS TAB1_PRVNI_SLOUPEC
, 1 AS TAB1_DRUHY_SLOUPEC
UNION ALL
SELECT
1 AS TAB1_PRVNI_SLOUPEC
, 1 AS TAB1_DRUHY_SLOUPEC
;
-- Muzeme jich pod sebe napsat kolik chceme
SELECT
1 AS TAB1_PRVNI_SLOUPEC
, 2 AS TAB1_DRUHY_SLOUPEC
UNION ALL
SELECT
5 AS TAB1_PRVNI_SLOUPEC
, 6 AS TAB1_DRUHY_SLOUPEC
UNION ALL
SELECT
7 AS TAB1_PRVNI_SLOUPEC
, 8 AS TAB1_DRUHY_SLOUPEC
UNION ALL
SELECT
9 AS TAB1_PRVNI_SLOUPEC
, 10 AS TAB1_DRUHY_SLOUPEC
;
-- Výsledek přebíra názvy sloupců z první tabulky
SELECT
1 AS TAB1_PRVNI_SLOUPEC
, 1 AS TAB1_DRUHY_SLOUPEC
UNION ALL
SELECT
11 AS DVACATY_OSMY_SLOUPEC
, 11 AS DVACATY_DEVATY_SLOUPEC
;
-- UNION vs UNION ALL - delaji to same, ale prikaz bez ALL kontroluje duplicitni radky (stejne hodnoty ve vsech sloupcich)
-- Ukázka s UNION ALL = Spojí tabulky pod sebe
SELECT *
FROM SCH_TEROR.COUNTRY_DIRTYDATA
UNION ALL
SELECT *
FROM SCH_TEROR.COUNTRY
;
-- Ukázka s UNION = Spojí tabulky pod sebe a navíc odstraní duplicity
SELECT *
FROM SCH_TEROR.COUNTRY_DIRTYDATA
UNION
SELECT *
FROM SCH_TEROR.COUNTRY
;
-- Stejně jako UNION (bez ALL) by fungnoval SELECT DISTINCT (také odstraňuje duplicitní řádky)
SELECT DISTINCT *
FROM
(SELECT *
FROM SCH_TEROR.COUNTRY_DIRTYDATA
UNION ALL
SELECT *
FROM SCH_TEROR.COUNTRY
);
-- Možné problémy s UNION, na které narazíte:
-- 1. Jiná struktura tabulek - jiný počet sloupců
SELECT
1 AS TAB1_PRVNI_SLOUPEC
, 1 AS TAB1_DRUHY_SLOUPEC
UNION ALL
SELECT
2 AS TAB2_PRVNI_SLOUPEC
;
-- Pokud je struktura druhe tabulky jina a nemame k dispozici vsechny sloupce, muzeme si je dotvorit, klidne jako NULL
SELECT
1 AS TAB1_PRVNI_SLOUPEC
, 1 AS TAB1_DRUHY_SLOUPEC
UNION ALL
SELECT
2 AS TAB2_PRVNI_SLOUPEC
, NULL AS TAB2_DRUHY_SLOUPEC
;
-- 2. Nekompatibilita datových typů
SELECT
    1 AS TAB1_PRVNI_SLOUPEC
    , 1 AS TAB1_DRUHY_SLOUPEC
UNION ALL
SELECT
    'ahoj' AS TAB2_PRVNI_SLOUPEC
    , 2 AS TAB2_DRUHY_SLOUPEC
;
-- Doporucujeme precastovat jednotlive sloupce (vsem dat datove typy) - obcas se stane, ze UNION nahodi spatny datovy typ
-- např. 1::VARCHAR AS TAB1_PRVNI_SLOUPEC
SELECT
    1::VARCHAR AS TAB1_PRVNI_SLOUPEC
    , 1::INTEGER AS TAB1_DRUHY_SLOUPEC
UNION ALL
SELECT
    'ahoj'::VARCHAR AS TAB2_PRVNI_SLOUPEC
    , 2::INTEGER AS TAB2_DRUHY_SLOUPEC
;
-- 3. Spojujeme pod sebe významově různé sloupce, UNION nám sice projde, ale ztrácíme informace
SELECT
    'červená' AS BARVA_LAKU_AUTA
    , 1000 AS PRIPLATEK_KC
UNION ALL
SELECT
    'žlutá' AS BARVA_CALOUNENI
    , 200 AS PRIPLATEK_EUR
;
-- Příklad na tabulce TEROR
---------------------------
-- Chceme vytvorit ciselnik weaptype z tabulky TEROR.
-- Cislo pro weaptype je obsazen ve trech sloupcich: WEAPTYPE1, WEAPTYPE2, WEAPTYPE3
-- Popis pro weaptype je obsazen ve trech sloupcich: WEAPTYPE1_TXT, WEAPTYPE2_TXT, WEAPTYPE3_TXT
SELECT
WEAPTYPE1
, WEAPTYPE1_TXT
, WEAPTYPE2
, WEAPTYPE2_TXT
, WEAPTYPE3
, WEAPTYPE3_TXT
FROM TEROR
LIMIT 100;
-- CISELNIK:
--> Potrebuju si vybrat sloupecky WEAPTYPE1 a WEAPTYPE1_TXT, pod ne prilepit sloupecky WEAPTYPE2 a WEAPTYPE2_TXT, nakonec pod ne WEAPTYPE3 a WEAPTYPE3_TXT
--> Pokud pouziju UNION (bez ALL), postara se mi o duplicity (chceme pouze seznam unikatnich weaptypes - ze vsech tri sloupecku)
SELECT
WEAPTYPE1 AS WEAPTYPE
, WEAPTYPE1_TXT AS WEAPTYPE_TXT
FROM TEROR
WHERE WEAPTYPE1 IS NOT NULL
UNION
SELECT
WEAPTYPE2
, WEAPTYPE2_TXT
FROM TEROR
WHERE WEAPTYPE2 IS NOT NULL
UNION
SELECT
WEAPTYPE3
, WEAPTYPE3_TXT
FROM TEROR
WHERE WEAPTYPE3 IS NOT NULL
ORDER BY WEAPTYPE
;
-- UKOL ----------------------------------------------------------
--> 1. Vytvořte z tabulky TEROR číselník pro ATTACKTYPE.
-- Díváme se na data
SELECT
ATTACKTYPE1
, ATTACKTYPE1_TXT
, ATTACKTYPE2
, ATTACKTYPE2_TXT
, ATTACKTYPE3
, ATTACKTYPE3_TXT
FROM TEROR
LIMIT 100;
-- Tvoříme číselník
SELECT
ATTACKTYPE1 AS ATTACKTYPE_ID
, ATTACKTYPE1_TXT AS ATTACKTYPE_TXT
FROM TEROR
WHERE ATTACKTYPE1 IS NOT NULL
UNION
SELECT
ATTACKTYPE2 AS ATTACKTYPE_ID
, ATTACKTYPE2_TXT AS ATTACKTYPE_TXT
FROM TEROR
WHERE ATTACKTYPE2 IS NOT NULL
UNION
SELECT
ATTACKTYPE3 AS ATTACKTYPE_ID
, ATTACKTYPE3_TXT AS ATTACKTYPE_TXT
FROM TEROR
WHERE ATTACKTYPE3 IS NOT NULL
ORDER BY ATTACKTYPE_ID -- volitelné a na konci -- týká se celého skriptu
;
-- AGREGACE:
--> chceme vedet, kolikrat se která zbran objevila v utocich
-- pouzijeme UNION ALL - bez promazani duplicit
-- spojime hodnoty pouze tam, kde neni NULL hodnota
-- vložíme do vnorene query a celé zagregujeme
SELECT
WEAPTYPE_TXT
, COUNT (*) AS KOLIKRAT
FROM
(SELECT
WEAPTYPE1 AS WEAPTYPE
, WEAPTYPE1_TXT AS WEAPTYPE_TXT
FROM TEROR
WHERE WEAPTYPE1 IS NOT NULL
UNION ALL
SELECT
WEAPTYPE2
, WEAPTYPE2_TXT
FROM TEROR
WHERE WEAPTYPE2 IS NOT NULL
UNION ALL
SELECT
WEAPTYPE3
, WEAPTYPE3_TXT
FROM TEROR
WHERE WEAPTYPE3 IS NOT NULL )
GROUP BY WEAPTYPE_TXT
;
------------------------------------------------------------------
---------------------------------------------------------
-- Rychlé opakování JOINů
---------------------------------------------------------
--Příklady na zubařském datasetu:
--1) Pro každé telefonní číslo chceme zjistit čas poslední návštěvy (zajímají nás sloupce telefon a MAX(datum)).
--2) Pro každé telefonní číslo chceme zjistit důvod poslední návštěvy (zajímají nás sloupce telefon a popis u nejnovějšího záznamu).

--1)
SELECT telefon, MAX(datum)
FROM pacienti
LEFT JOIN navstevy ON pacienti.id = navstevy.pacient_id
GROUP BY telefon
;
--2)
SELECT telefon, MAX(popis)
FROM pacienti
LEFT JOIN navstevy ON pacienti.id = navstevy.pacient_id
GROUP BY telefon
;
-- 2) Jenže tohle není nejnovější popis - Tohle je popis, který začíná nejvyšším písmenkem v abecedě.
-- Musíme na to jinak - Potřebujeme se podívat do řádku, kde je nejnovější datum, do sloupce popis. A tohle nám umožní WINDOW funkce.
SELECT DISTINCT telefon, LAST_VALUE(popis) OVER (PARTITION BY telefon ORDER BY datum)
FROM pacienti
LEFT JOIN navstevy ON pacienti.id = navstevy.pacient_id
;
---------------------------------------------------------
-- WINDOW FUNKCE
---------------------------------------------------------
-- Šikovné funkce.
-- Umí se dívat do jiných řádků tabulky.

-- Využijeme, když chceme provádět výpočty v rámci určitého okna, které je definované 0-n sloupci,
-- některé funkce vyžadují řazení.

-- Okno si můžeme představit jako výsledek nějakého SELECTu.



---- Tři typy funkcí: skalární x agregační x window
--------------------------------

-- SKALÁRNÍ - transformuje každý řádek zvlášť na ten samý řádek
-- Nemění strukturu tabulky

SELECT DATE_FROM_PARTS(IYEAR,IMONTH,IDAY) AS DATUM, *
FROM TEROR
;

-- AGREGAČNÍ - agreguje data - např. z několika řádků vratí jeden
-- Mění strukturu tabulky

SELECT IYEAR, COUNT (*) AS POCET_UTOKU
FROM TEROR
GROUP BY IYEAR
ORDER BY IYEAR
;

-- WINDOW
-- Nemění strukturu tabulky
-- Umí např. číslovat záznamy, sčítat záznamy, kumulativní součet, koukat se do předesleho řádku, ...


-- SYNTAXE: <function> ( [ <arguments> ] ) OVER ( [ PARTITION BY <expr1> ] [ ORDER BY <expr2> ] )

--> i když funkce nemá argumenty ani nevyužívá partition by/order by, píšeme vždy: funkce() OVER ()

-- COUNT(*) Agregační funkce
-- COUNT(*) OVER () Window funkce




---- Agregační funkce jako window funkce
----------------------------------------
-- všechny agregační funkce, co jsme se učily se dají napsat jako window fce
-- COUNT() OVER (), SUM() OVER (), MAX() OVER (), MIN() OVER (), AVG() OVER ()


-- UKOL ----------------------------------------------------------

--> 1. Spočítejte pomocí window funkce celkový součet zabitých obětí (SUM) a průměr zabitých obětí (AVG) za celý dataset (= dosaďte do každé řádky).
-- Vypište jako první dva nové sloupečky (výsledky window funkcí), následně NKILL (počet zabitých pro daný útok) a za ně všechny sloupečky z tabulky TEROR.
;


select
    sum(nkill) over () as celkovy_pocet_mrtvych,
    avg(nkill) over () as prumerny_pocet_zabitych,
    nkill,
    *
from teror;


SELECT
SUM (NKILL) OVER () AS CELKOVY_POCET_MRTVYCH_ZA_CELY_DATASET,
AVG (NKILL) OVER () AS PRUMERNY_POCET_MRTVYCH_ZA_CELY_DATASET,
NKILL,
*
FROM TEROR
;

-- Vyzkoušej si: Pro každý útok v tabulce TEROR vypiš sloupce EVENTID a NKILL. Následně přidej sloupec nazvaný MAXIMALNI_POCET_ZABITYCH. Využij window funkci, která ke každému řádku napíše nejvyšší počet mrtvých u jednotlivého útoku pro celý dataset.
-- Nápověda: použij MAX(NKILL) OVER ()
SELECT
    EVENTID
    , NKILL
    , MAX(NKILL) OVER () AS MAXIMALNI_POCET_ZABITYCH -- MOJE
FROM TEROR;

SELECT
      EVENTID
    , NKILL
    , MAX(NKILL) OVER() AS MAXIMALNI_POCET_ZABITYCH
   
FROM TEROR
;

-- Když si to chceme ověřit:
SELECT NKILL
FROM TEROR
ORDER BY NKILL DESC NULLS LAST
LIMIT 100
;



------------------------------------------------------------------
---- PARTITION BY
-----------------
-- definuje okno
SELECT DISTINCT IYEAR FROM TEROR;
-- okno definovane IYEAR -> 50 oken (1972, ..., 2020)
;

-- Počítáme útoky v každém roce:
-- 1. Přes agregační funkci:

select
    iyear
    , count (*)
from teror
group by iyear;

SELECT IYEAR, COUNT (*)
FROM TEROR
GROUP BY IYEAR; -- MOJE


SELECT
IYEAR,
COUNT (*)
FROM TEROR
GROUP BY IYEAR
;
-- 2. Přes WINDOW funkci:


select distinct
iyear,
count(*) over (partition by iyear) as pocet_utoku_za_dany_rok
from teror;


SELECT DISTINCT
IYEAR,
COUNT (*) OVER (PARTITION BY IYEAR) AS POCET_UTOKU_CELKEM_DANY_ROK
FROM TEROR
;


-- Okno definovane datem

SELECT
COUNT (*) OVER (PARTITION BY DATE_FROM_PARTS(IYEAR,IMONTH,IDAY)) AS POCET_UTOKU_CELKEM_DANY_DEN
FROM TEROR
;

-- okno definovane vice sloupecky: datum + zeme
-- seradme dle dimenzi pres ktere se divame oknem

select
    count(*) over (partition by date_from_parts(iyear, imonth, iday), country_txt) as pocet_utoku_za_dany_rok
    , *
from teror
order by date_from_parts(iyear, imonth, iday), country_txt;

SELECT
COUNT (*) OVER (PARTITION BY DATE_FROM_PARTS(IYEAR,IMONTH,IDAY), COUNTRY_TXT) AS POCET_UTOKU_V_DANE_ZEMI_DANY_DEN
, *
FROM TEROR
ORDER BY DATE_FROM_PARTS(IYEAR,IMONTH,IDAY), COUNTRY_TXT
;


------------------------------------------------------------------
---- ORDER BY
-------------
-- seřadí výsledek v okně
-- funkce se aplikuje postupne (narozdil od partition by ale neresetuje vypocet)
-- serazeni probiha pri vyhodnocovani window fce - neni to to stejne, jako ORDER BY ktery uz zname


-- opet pocet radku jako window fce, PARTITION BY IYEAR, ORDER BY EVENTID -- EVENTID je unikatni, takze vysledek bude vzdy s kazdym utokem zvyseny o 1

SELECT
COUNT (*) OVER (ORDER BY EVENTID) AS PORADI_UTOKU
, *
FROM TEROR
ORDER BY EVENTID
;

-- Co kdybychom řadili podle něčeho, co unikátní není? např. podle data IDATE

SELECT
COUNT (*) OVER (ORDER BY IDATE)
, *
FROM TEROR
ORDER BY IDATE
;

-- Co by se stalo, kdybychom namísto ORDER BY IDATE použili PARTITION BY IDATE?
SELECT
COUNT (*) OVER (PARTITION BY IDATE)
, *
FROM TEROR
ORDER BY IDATE
;

-- Podobny princip můžeme aplikovat i na zbylé funkce, napřiklad kumulativní součet NKILL:

SELECT
  SUM (NKILL) OVER (ORDER BY EVENTID) AS KUMULATIVNI_POCET_MRTVYCH_OD_PRVNIHO_UTOKU
, SUM (NKILL) OVER (PARTITION BY REGION_TXT ORDER BY EVENTID) AS KUMULATIVNI_POCET_MRTVYCH_V_REGIONU_OD_PRVNIHO_UTOKU
, SUM (NKILL) OVER (PARTITION BY REGION_TXT) AS CELKOVY_POCET_MRTVYCH_V_REGIONU
, SUM (NKILL) OVER (PARTITION BY REGION_TXT, IYEAR) AS POCET_MRTVYCH_V_REGIONU_V_DANEM_ROCE
, SUM (NKILL) OVER (PARTITION BY IYEAR) AS POCET_MRTVYCH_V_DANEM_ROCE
, SUM (NKILL) OVER (PARTITION BY REGION_TXT, WEAPTYPE1) AS POCET_MRTVYCH_V_REGIONU_DANYM_TYPEM_UTOKU
, SUM (NKILL) OVER (PARTITION BY REGION_TXT, EVENTID) AS POCET_MRTVYCH_V_DANEM_UTOKU -- EVENTID JE UNIKATNI
, REGION_TXT
, NKILL
, EVENTID

FROM TEROR
-- WHERE NKILL >= 1000
-- ORDER BY EVENTID
;


------------------------------------------------------------------
---- QUALIFY: FILTROVANI VYSLEDKU WINDOW FUNKCE
-----------------------------------------------

-- Chci se podivat na utoky pouze z let, kde bylo alespon 14 tisic utoku


SELECT
COUNT(*) OVER (PARTITION BY IYEAR) AS pocet_utoku_celkem_dany_rok
, *
FROM TEROR
--WHERE pocet_utoku_celkem_dany_rok >= 14000
--HAVING COUNT(*) OVER (PARTITION BY IYEAR) >= 14000
--HAVING pocet_utoku_celkem_dany_rok >= 14000
QUALIFY pocet_utoku_celkem_dany_rok >= 14000
ORDER BY IYEAR, EVENTID;

-- QUALIFY je nadstavba, neni to SQL standard, poradime si bez QUALIFY


SELECT *
FROM
(
SELECT
COUNT(*) OVER (PARTITION BY IYEAR) AS pocet_utoku_celkem_dany_rok
, *
FROM TEROR
ORDER BY IYEAR, EVENTID
)
WHERE pocet_utoku_celkem_dany_rok >= 14000
;

-- UKOL ----------------------------------------------------------

--> 1. Spočítejte kumulativní součet zabitých obětí (NKILL) pomocí window funkce SUM, nadefinujte okno pomocí IYEAR, okno uvnitř seřaďte pomocí IDATE. Pojmenujte jako POCET_OBETI_KUMULATIVNE.
-- Celkový výsledek seřaďte pomocí IYEAR a IDATE.
-- Vypište si pouze sloupečky POCET_OBETI_KUMULATIVNE, NKILL, EVENTID, IYEAR
-- Filtrujte výsledek na prvních 100 obětí kumulativně (POCET_OBETI_KUMULATIVNE bude menší nebo rovno 100) pro každý rok.


SELECT
SUM (NKILL) OVER (PARTITION BY IYEAR ORDER BY IDATE) AS POCET_OBETI_KUMULATIVNE,
NKILL,
EVENTID,
IYEAR

FROM TEROR
QUALIFY SUM (NKILL) OVER (PARTITION BY IYEAR ORDER BY IDATE) <= 100
ORDER BY IYEAR, IDATE
;

------------------------------------------------------------------
---- WINDOW FUNKCE & GROUP BY
-----------------------------

-- WINDOW funkce můžeme kombinovat s agregačními funkcemi (nejdříve se vyhodnotí GROUP BY, pak az WINDOW funkce)
-- POZOR - je treba dat agregaci jako argument window funkci, jinak vyhodi group by error

-- Spocitame si opet pocet utoku v kazdem roce, ale tentokrat pomoci GROUP BY, nasledne secteme agregovane pocty a vypocitame podil (%) utoku v danem roce na celkovem poctu

SELECT
IYEAR
, COUNT (*) AS POCET_UTOKU
, SUM(COUNT(*)) OVER () AS POCET_UTOKU_CELKEM
, COUNT (*) / SUM(COUNT(*)) OVER () AS PROCENTO_UTOKU_V_DANEM_ROCE

FROM TEROR
GROUP BY IYEAR
;

-- Filtrace:
-- ve vysledku chceme pouze ty roky, kde podil byl nad 5 %
-- pozor nemuzeme window funkci pouzit ani ve WHERE, ani v HAVING --> QUALIFY

SELECT
IYEAR
, COUNT (*) AS POCET_UTOKU
, SUM(COUNT(*)) OVER () AS POCET_UTOKU_CELKEM
, COUNT (*) / SUM(COUNT(*)) OVER () AS PROCENTO_UTOKU_V_DANEM_ROCE

FROM TEROR
GROUP BY IYEAR
QUALIFY PROCENTO_UTOKU_V_DANEM_ROCE >= 0.05
;


-- UKOLY ----------------------------------------------------------

--> 1. Spočítejte, kolik jednotlivé teroristické skupiny (GNAME) měly na svědomí obětí (NKILL) - pojmenujte sloupeček POCET_OBETI (pomocí GROUP BY). Odfiltrujte pryč skupinu 'Unknown'. Seřaďte podle počtu obětí (NULL hodnoty budou na konci).

--> 2. Do stejného příkazu spočítejte celkový počet (= za celý dataset) zabitých obětí (NKILL) pomocí WINDOW funkce. Pojmenujte jako POCET_OBETI_CELKEM. Přidejte také sloupec ukazující podíl zabitých (POCET_OBETI / POCET_OBETI_CELKEM) - pojmenujte jako PROCENTO_OBETI.

--> 3. Ve stejném příkazu filtrujte pouze organizace, které se na celkovém počtu obětí podílelo alespoň 7 procenty (PROCENTO_OBETI >= 0.07).

SELECT
  GNAME
, SUM(NKILL) AS POCET_OBETI
, SUM(SUM(NKILL)) OVER () AS POCET_OBETI_CELKEM
, POCET_OBETI/POCET_OBETI_CELKEM AS PROCENTO_OBETI
FROM TEROR
WHERE GNAME != 'Unknown'
GROUP BY GNAME
QUALIFY PROCENTO_OBETI >= 0.07
ORDER BY POCET_OBETI DESC NULLS LAST
;



------------------------------------------------------------------
-- DALSI WINDOW FUNKCE:
-----------------------

---- ROW_NUMBER()
-----------------
-- vyzaduje ORDER BY

-- NEW_ID --> vytvorime si nove ID v tabulce teror pomoci funkce ROW_NUMBER()

SELECT
ROW_NUMBER() OVER (ORDER BY EVENTID) AS NEW_ID
, *
FROM TEROR
;

-- pokud je nam jedno, podle ceho je to serazene, muzeme radit podle NULL
-- ROW_NUMBER() vzdy vrati unikatni cislo (i kdyz radime podle stejne hodnoty)

-- co kdyz pridame PARTITION BY IYEAR?
-- maximalni hodnota pro kazdy rok bude stejna jako pocet radku v group by

SELECT
ROW_NUMBER() OVER (PARTITION BY IYEAR ORDER BY EVENTID) AS NEW_ID
, *
FROM TEROR
;

---- RANK()
-----------
-- vyzaduje ORDER BY
-- poradi - napr. kdyz vyhodnocujeme nejakou soutez podle poctu ziskanych bodu apod.
-- narozdil od ROW_NUMBER() v pripade shody v hodnote, ktera je v ORDER BY priradi stejne cislo (stejny rank = stejne poradi)

-- Vybere seřazené organizace podle počtu obětí sestupně a přiřadí jim pořadí (rank)
-- kombinace group by a window fce

SELECT
GNAME
, SUM(NKILL)
, RANK () OVER (ORDER BY SUM(NKILL) DESC NULLS LAST) AS RANK_POCET_OBETI
FROM TEROR
GROUP BY GNAME
ORDER BY SUM(NKILL) DESC NULLS LAST
;


-- chceme poradi segmentovat podle roku --> pridame PARTITION BY
--> GROUP BY GNAME, IYEAR
--> filtrovat pouze prvni 3 kazdy rok

---------------------------------------------------------
-- UKOLY Z LEKCE 7
---------------------------------------------------------

--// A/ Vypiš tři největší útoky pro organizace s více než 500 obětmi. Vypiš sloupečky city, gname a nkill a rank. Výsledek seřaď podle gname a rank

-- pouze window funkce
----------------------




-- vnorena query
----------------
SELECT
  CITY AS MESTO
  , GNAME AS NAZEV_ORGANIZACE
  , NKILL AS POCET_MRTVYCH_OBETI
  , RANK() OVER (PARTITION BY gname ORDER BY nkill DESC) AS PORADI
FROM TEROR
WHERE nkill IS NOT NULL
QUALIFY SUM(NKILL) OVER (PARTITION BY GNAME) > 500 AND PORADI <=3
ORDER BY GNAME, PORADI;




--// B/ Vypiš 5 nejaktivnějších organizací (dle počtu útoků) podle regionu. Výsledek seraď podle regionu a ranku.
---------------------------------------------------------

-- ŘEŠENÍ:

-- A jako WINDOW funkce

SELECT
    gname,
    city,
    nkill,
    RANK() OVER (PARTITION BY gname ORDER BY nkill DESC) AS rank

FROM teror
 
WHERE nkill IS NOT NULL
QUALIFY SUM(nkill) OVER (PARTITION BY gname) > 500
    AND rank <= 3
ORDER BY gname, rank;

-- A jako vnořená query

SELECT city, gname, nkill, rank

FROM (
  SELECT *, RANK() OVER (PARTITION BY gname ORDER BY nkill DESC) AS rank
  FROM teror
  WHERE nkill IS NOT NULL
      AND gname IN (    SELECT gname as sk
                        FROM teror
                        GROUP BY gname
                        HAVING sum(nkill) > 500
                        ORDER BY sum(nkill)
                    )
     )
 
WHERE rank <= 3
ORDER BY gname, rank
;

-- B

 SELECT *
 FROM
    (    SELECT gname, region_txt, COUNT(*) as pocet_akci
         , RANK() OVER (PARTITION BY region_txt ORDER BY pocet_akci DESC) AS rank
         
         FROM teror
         WHERE nkill IS NOT NULL
         GROUP BY gname, region_txt
    )
 WHERE rank <= 5
 ORDER BY region_txt, rank
 ;

--https://learnsql.com/blog/mysql-window-functions-examples/