------------------------------------------------------------------------------------------------------------------
-- LEKCE 4: JOINY
------------------------------------------------------------------------------------------------------------------

--Začněme u relačních databází - data ukládáme v pevně definovaných tabulkách, mezi kterými máme definované relace (vzájemné vztahy)


--* Denormalizovaná tabulka - "Hodíme data na jednu hromadu, jak se nám to hodí" - Všechny sloupce v jedné tabulce
--Příklad: Zubař si vede knihu návštěv: 
--https://docs.google.com/spreadsheets/d/1fWR1b1KSsBHkgowxAO23UOtIkP_l4R7Ci-yk8RD494o/edit?usp=sharing

--* Normalizovaná tabulka/databáze - Data rozdělíme po entitách do více tabulek 
--  - Tabulka, ve které jsou všechny opakující se hodnoty vyjádřeny cizím klíčem a vazbou na tabulku s těmito hodnotami (číselník)

--+ Odstranění redundance (zbytečné opakování), snížení prostoru pro chyby (nekonzistentní data)
--+ Zvýšení flexibility databáze - efektivnější ukládání nových a změněných dat, rychlejší prohledávání a zpracování
--+ Ochrana dat (mohu řídit přístupy uživatelů k druhům dat)

--Důsledky: 
--- Trochu komplexnější dotazy
--- Obří tabulky – dopad na performance
--* Struktura databáze: tabulky faktové a dimenzionální (číselníky)

--Faktová tabulka - ude jsou uložena vlastní analyzovaná data - veličiny, které sledujeme; hodnoty, které jsou použity k analytickým výpočtům - agregacím, třídění apod. 
--- Většina paměťového místa v datovém skladu zabírají faktové tabulky, které obsahují detailní údaje ze všech zdrojů - tedy řádově více údajů než ostatní tabulky.
--- Častěji dochází ke změně/přidání dat.
--- Příklady: Jednotlivé prodeje u eshopu, hovory v call centru, jednotlivé účetní záznamy, zobrazení webové reklamy...
--Dimenze (číselník) jsou tabulky, které obsahují seznamy hodnot sloužících ke kategorizaci a třídění dat ve faktových tabulkách (atributy,
--prostřednictvím kterých se „díváme“ na data).
--- Změny probíhají méně často než ve faktové tabulce.
--- Příklady: Číselník zemí, firem, zákazníků, účtů, poboček...

--Úkol: Zubař si vede knihu návštěv, která je denormalizovaná. 
--Chceme knihu převést do tří normalizovaných tabulek. Jedna tabulka bude faktová (transakční) a dvě dimenzní.

--* Klíče identifikují záznamy a umožňují odkazovat na jiné záznamy 
--Primární klíč - jednoznačně určí konkrétní záznam
--Cizí klíč - Primární klíč z jiné tabulky
--Příklad ZUB 1: Zubař zjistil, že má covid. Potřebuje telefonní čísla všech pacientů kteří ho navštívili od 14. do 15. března 2023. Pacientům odešle informativní sms.
--- Denormalizovaná tabulka:

SELECT DISTINCT telefon
FROM kniha
WHERE datum_navstevy BETWEEN 2023-03-14 AND 2023-03-15

--- Více normalizovaných tabulek. 
--- K jejich spojení využijeme funkci JOIN. Tedy tabulky přielpíme jednu vedle druhé. Spojování pod sebe se budeme věnovat až v dalších hodinách.

--- Syntaxe:

--SELECT *
--FROM tabulka AS t1 -- (alias)
--JOIN tabulka2 AS t2  -- (napoj na tabulku další tabulku, která má název tabulka2 a dal jsem ji alias t2)
--ON t1.klic1 = t2.klic2 -- (napoj na sebe ty řádky, kde je klic1 stejna hodnota jako klic2)

SELECT *
FROM navstevy AS nas
JOIN pacienti AS pac ON nas.pacient_id = pac.id
;

SELECT DISTINCT TELEFON -- moje
FROM NAVSTEVY
JOIN PACIENTI ON NAVSTEVY.PACIENT_ID = PACIENTI.ID -- v případě, že se vybrané sloupce jmenují v obou tabulkách stejně, je třeba k tomu přidat i název tabulky -> př. pacienti.id či návštěvy.id
WHERE DATUM BETWEEN '2023-03-14' AND '2024-03-16'; -- pokud je v tabulce datum i čas, ale není nastvavena na timestamp, stačí vyselektovat datum a i tak to ten údaj najde


SELECT DISTINCT pac.telefon
FROM navstevy AS nas
JOIN pacienti AS pac ON nas.pacient_id = pac.id
WHERE nas.datum BETWEEN '2023-03-14' AND '2023-03-16'
;

--Příklad ZUB 2: U každého pacienta (jmeno_prijmeni) chceme zjistit, kdy byl naposledy na návštěvě (datum_navstevy).
--- Denormalizovaná tabulka:

SELECT JMENO, MAX (DATUM)
FROM PACIENTI
JOIN NAVSTEVY ON PACIENTI.ID=NAVSTEVY.PACIENT_ID
GROUP BY JMENO -- GROUP BY vezme maximální hodnotu daného výběru
;

SELECT DISTINCT jmeno_prijmeni, MAX(datum_navstevy)
FROM kniha
GROUP BY jmeno_prijmeni


--- Více normalizovaných tabulek. K jejich spojení využijeme funkci JOIN.

SELECT DISTINCT pac.jmeno, MAX(nas.datum)
FROM pacienti AS pac
JOIN navstevy AS nas ON pac.id = nas.pacient_id
GROUP BY pac.jmeno
;




--Příklad ZUB 3: Chceme zkonstruovat původní denormalizovanou tabulku ze třech nových tabulek:
;
SELECT *
FROM NAVSTEVY
JOIN PACIENTI ON NAVSTEVY.PACIENT_ID=PACIENTI.ID
JOIN POJISTOVNY ON NAVSTEVY.POJISTOVNA_ID = POJISTOVNY.ID;

SELECT nas.*, pac.*, poj.*
FROM navstevy AS nas
JOIN pacienti AS pac ON nas.pacient_id = pac.id
JOIN pojistovny AS poj ON nas.pojistovna_id = poj.id

---------------------------------------------------------
-- Typy JOINů a JOIN BINGO
---------------------------------------------------------

--Typy JOINů:

--- (INNER) JOIN  --> pouze prunik obou tabulek, cili pouze to, co se objevuje jak v prvni tabulce tak tabulce druhe --> nebudou NULL hodnoty
--- LEFT JOIN     --> DEFAULTNĚ JOIN - k prvni tabulce pripoji pouze ta data, ktera nasla v druhe tabulce --> muze se stat, ze radek z prvni tabulky bude mit pak NULL hodnoty ve sloupeccich druhe tabulky
--- RIGHT JOIN    --> k druhe tabulce pripoji pouze ta data, ktera nasla v prvni tabulce --> muze se stat, ze radek z druhe tabulky bude mit pak NULL hodnoty ve sloupeccich prvni tabulky
--- FULL JOIN     --> kde prvni tabulka nemuze najit spojitost s tabulkou druhou, budou nullove hodnoty a obracene - tam, kde druha tabulka nemuze najit spolecne hodnoty v tabulce prvni, budou NULL



--Vennovy diagramy:
--https://cdn.educba.com/academy/wp-content/uploads/2019/10/Types-of-Joins-in-SQl.png.webp

--Když nemám rád Vennovy diagramy:
--https://towardsdatascience.com/can-we-stop-with-the-sql-joins-venn-diagrams-insanity-16791d9250c3

--JOIN BINGO:
--https://docs.google.com/spreadsheets/d/1OUBGiKhhtgJ5mjsJX15ttej8eu9bEIFsnCJ07otLyU4/edit?usp=sharing

--JOIN BINGO vyplněné:
--https://docs.google.com/spreadsheets/d/1VcuAykkHSMTxr4eme69_7a3mLYFLP5hIWPldKQ0q42A/edit?usp=sharing

---------------------------------------------------------
-- Základní JOIN
---------------------------------------------------------

-- Nove tabulky k prozkoumání: TEROR2, COUNTRY, WEAPTYPE

-- K záznamům z tabulky TEROR2 chceme přilepit jméno dané země.
-- Vybereme vsechny sloupce z obou tabulek:
;
SELECT NAME, EVENTID
FROM TEROR2
LEFT JOIN COUNTRY ON TEROR2.COUNTRY = COUNTRY.ID;

SELECT NAME, EVENTID
FROM TEROR2
LEFT JOIN COUNTRY_DIRTYDATA ON TEROR2.COUNTRY = COUNTRY_DIRTYDATA.ID;


SELECT *
FROM teror2
LEFT JOIN country
ON teror2.country = country.id;

-- sloupce jen z jedne tabulky + vyber z druhe, přidáme alias


SELECT t2.*, c.name AS country_name
FROM teror2 AS t2
LEFT JOIN country AS c
ON t2.country=c.id;

-- vyber jednotlivych sloupcu z více tabulek


SELECT c.name, c2.name, t2.nkill, t2.nkillter, t2.gname
FROM teror2 AS t2
LEFT JOIN country AS c ON t2.country = c.id
LEFT JOIN country AS c2 ON t2.country = c2.id;


-- Úkol: K tabulce TEROR2 přidejte název regionu, ve kterém se daný útok stal.
-- Nápověda: Název regionu je ve sloupci NAME v tabulce REGION. V tabulce REGION je primární klíč ID, který je v relaci se sloupcem REGION v tabulce TEROR2. 

SELECT *
FROM TEROR2
LEFT JOIN REGION
ON TEROR2.REGION = REGION.ID;


SELECT reg.name AS nazev_regionu, ter.*
FROM teror2 AS ter
LEFT JOIN region AS reg ON ter.region = reg.id



-- Když data nejsou uhlazená:

SELECT *
FROM COUNTRY_DIRTYDATA
ORDER BY ID;


-- Jaké jsou jiné způsoby ověření unikátnosti dat?

SELECT NAME, COUNT(*)
FROM COUNTRY_DIRTYDATA
GROUP BY 1
ORDER BY 2 DESC

SELECT c.*
FROM teror2 as t2
LEFT JOIN COUNTRY_DIRTYDATA as c
ON t2.country=c.id;

---------------------------------------------------------
-- Základní JOIN (pozor na sloupce)
-- Takto se to nedělá!!!
---------------------------------------------------------

SELECT c.name, t2.*
FROM teror2 as t2
LEFT JOIN country as c
ON t2.attacktype1 = c.id; -- take ciselnik, ale spatne prirazene hodnoty



---------------------------------------------------------
-- Základní JOIN (jde to i pres stringy)
---------------------------------------------------------

SELECT c.name, t.country_txt
FROM teror AS t
LEFT JOIN country AS c
ON t.country_txt = c.name;


-- pouziti funkci v on clause
SELECT c.name, t.country_txt
FROM teror AS t
LEFT JOIN country AS c
ON LOWER(t.country_txt) = LOWER(c.name) -- ZÁZNAMY JSOU CASE SENSITIVE 
;

-- UKOLY ----------------------------------------------------------

-- 1. napiste join, ktery napoji ciselnik weaptype na sloupce weaptype1, weaptype2 a weaptype3
-- vypiste nejdrive sloupecky s nazvy zbrani z ciselniku, z teroru vsechny sloupecky

SELECT W1.NAME AS ZBRAN1
    , W2.NAME AS ZBRAN2
    , W3.NAME AS ZBRAN3
    , TEROR2.*
FROM TEROR2
LEFT JOIN WEAPTYPE2 AS W1 ON TEROR2.WEAPTYPE1 = W1.ID
LEFT JOIN WEAPTYPE2 AS W2 ON TEROR2.WEAPTYPE2 = W2.ID
LEFT JOIN WEAPTYPE2 AS W3 ON TEROR2.WEAPTYPE3 = W3.ID;





SELECT W1.NAME AS WEAPTYPE1_TXT, W2.NAME AS WEAPTYPE2_TXT, W3.NAME AS WEAPTYPE3_TXT, T2.*
FROM TEROR2 AS T2
LEFT JOIN WEAPTYPE AS W1
ON T2.WEAPTYPE1=W1.ID
LEFT JOIN WEAPTYPE AS W2
ON T2.WEAPTYPE2=W2.ID
LEFT JOIN WEAPTYPE AS W3
ON T2.WEAPTYPE3=W3.ID;

--- 2. Vyberte pouze utoky, kde byly pouzity tri ruzne typy zbrani
--- 2-A. POMOCI INNER JOIN

SELECT W1.NAME AS WEAPTYPE1_TXT
    , W2.NAME AS WEAPTYPE2_TXT
    , W3.NAME AS WEAPTYPE3_TXT
    , TEROR2.*
FROM TEROR2
INNER JOIN WEAPTYPE2 AS W1 ON TEROR2.WEAPTYPE1 = W1.ID -- u tabulky weaptype2 musíme napsat aliasy, protože pracujeme sice v teroru2 se 3 sloupci, ale ve weaptype pouze s jedním sloupcem, proto je třeba ho různě pojmenovat. Snowflake by jinak nevěděl, co má přechroustat.
INNER JOIN WEAPTYPE2 AS W2 ON TEROR2.WEAPTYPE2 = W2.ID
INNER JOIN WEAPTYPE2 AS W3 ON TEROR2.WEAPTYPE3 = W3.ID;


SELECT W1.NAME AS WEAPTYPE1_TXT, W2.NAME AS WEAPTYPE2_TXT, W3.NAME AS WEAPTYPE3_TXT, T2.*
FROM TEROR2 AS T2
INNER JOIN WEAPTYPE AS W1
ON T2.WEAPTYPE1=W1.ID
INNER JOIN WEAPTYPE AS W2
ON T2.WEAPTYPE2=W2.ID
INNER JOIN WEAPTYPE AS W3
ON T2.WEAPTYPE3=W3.ID;


--- 2-B. POMOCI LEFT JOIN & WHERE
SELECT W1.NAME AS WEAPTYPE1_TXT, W2.NAME AS WEAPTYPE2_TXT, W3.NAME AS WEAPTYPE3_TXT, T2.*
FROM TEROR2 AS T2
LEFT JOIN WEAPTYPE AS W1
ON T2.WEAPTYPE1=W1.ID
LEFT JOIN WEAPTYPE AS W2
ON T2.WEAPTYPE2=W2.ID
LEFT JOIN WEAPTYPE AS W3
ON T2.WEAPTYPE3=W3.ID
WHERE WEAPTYPE1 IS NOT NULL AND WEAPTYPE2 IS NOT NULL AND W3.NAME IS NOT NULL;

---------------------------------------------------------
-- JOIN a WHERE - dalsi priklad
---------------------------------------------------------

-- Úkol: Napojit číselnik country na tabulku teror2, chceme vidět jméno země, datum a číslo útoku.
-- Filtrujeme pouze zemi 'Czech Republic' a roky 2017-2018

SELECT COUNTRY.NAME AS ZEME, TEROR2.IDATE AS DATUM, TEROR2.EVENTID AS ID_UTOKU -- moje
FROM TEROR2
LEFT JOIN COUNTRY ON TEROR2.COUNTRY = COUNTRY.ID
WHERE COUNTRY.NAME='Czech Republic' AND TEROR2.IYEAR BETWEEN 2017 AND 2018; -- 1. spojíme 2 tabulky dohromady, 2.filtrujeme pomocí WHERE

SELECT COUNTRY.NAME AS ZEME, TEROR2.IDATE AS DATUM, TEROR2.EVENTID AS ID_UTOKU -- moje
FROM TEROR2
INNER JOIN COUNTRY ON TEROR2.COUNTRY = COUNTRY.ID AND COUNTRY.NAME='Czech Republic' AND TEROR2.IYEAR BETWEEN 2017 AND 2018; --1. spojíme INNER 2 tabulky a dáme zároveň 2 podmínky s AND

SELECT T2.COUNTRY, C.NAME AS COUNTRY_NAME, t2.IDATE, t2.EVENTID
FROM teror2 AS t2

LEFT JOIN country AS c
ON t2.country = c.id

WHERE c.name = 'Czech Republic'
  AND t2.iyear IN (2017, 2018)
;

-- Můžeme dát podmínku pro zemi přímo do podmínek JOINu?
SELECT T2.COUNTRY, C.NAME AS COUNTRY_NAME, t2.IDATE, t2.EVENTID
FROM teror2 AS t2

INNER JOIN country AS c ON t2.country = c.id AND c.name = 'Czech Republic'

WHERE t2.iyear IN (2017, 2018)
;

---------------------------------------------------------
-- JOIN a GROUP BY
---------------------------------------------------------

-- Q: chceme zjistit, pro jake typy zbrani (weaptype1) bylo provedeno vice nez 1000 utoku

SELECT NAME, COUNT (*)
FROM TEROR2
LEFT JOIN WEAPTYPE2 ON TEROR2.WEAPTYPE1 = WEAPTYPE2.ID
GROUP BY WEAPTYPE2.NAME
HAVING COUNT (*)>1000;

SELECT W1.NAME, COUNT(*)
FROM TEROR2 AS T2
LEFT JOIN WEAPTYPE AS W1
ON T2.WEAPTYPE1=W1.ID

GROUP BY W1.NAME
HAVING COUNT(*) > 1000;

-------------------------------------------------------------------------
-- CROSS JOIN
-------------------------------------------------------------------------
-- kartezsky soucin
-- vrati kombinace vsech radku z obou tabulek bez shody mezi jakymikoli sloupci

SELECT count(*)
FROM teror2;

SELECT count(*)
FROM weaptype;

SELECT *
FROM teror2 AS t
CROSS JOIN weaptype AS a
;

SELECT 12 * 56353; 

-- pozor na CROSS JOIN velkých tabulek
SELECT *
FROM teror2 AS t1
CROSS JOIN teror2 AS t2
;


-- pozor na nechtěný CROSS JOIN
SELECT *
FROM teror2 AS t
JOIN weaptype AS a
--ON 1=1
;


------------------------------------------------------------------------------------------------------------------
-- UKOLY Z LEKCE 4
------------------------------------------------------------------------------------------------------------------

//A / Vypiš idate, gname, nkill, nwound z tabulky teror2 (!) a přes sloupeček country připoj zemi z tabulky country

SELECT 
    COUNTRY.NAME
    , IDATE
    , GNAME
    , NKILL
    , NWOUND
FROM TEROR2
LEFT JOIN COUNTRY ON TEROR2.COUNTRY = COUNTRY.ID;







SELECT t2.idate, t2.gname, t2.nkill, t2.nwound, c.name as country_name
 FROM teror2 AS t2
 LEFT JOIN country AS c 
 ON t2.country = c.id;
 

//B / Vypiš IDATE, gname, nkill, nwound z tabulky teror2 (!) a
//přes sloupecek country pripoj zemi z tabulky country
//přes sloupecek weaptype1 připoj nazev zbrane z tabulky weaptype
//přes sloupecek weaptype2 připoj nazev zbrane z tabulky weaptype
;
SELECT
    IDATE
    , GNAME
    , NKILL
    , NWOUND
    , COUNTRY.NAME
    , W1.NAME
    , W2.NAME
FROM TEROR2
LEFT JOIN COUNTRY ON TEROR2.COUNTRY=COUNTRY.ID
LEFT JOIN WEAPTYPE2 AS W1 ON TEROR2.WEAPTYPE1=W1.ID
LEFT JOIN WEAPTYPE2 AS W2 ON TEROR2.WEAPTYPE2=W2.ID; -- MOJE


SELECT t2.idate, t2.gname, t2.nkill, t2.nwound, c.name as country_name, wt1.name as weapon_type1, wt2.name as weapon_type2
 FROM teror2 AS t2
 LEFT JOIN country as c ON t2.country = c.id
 LEFT JOIN weaptype as wt1 ON t2.weaptype1 = wt1.id
 LEFT JOIN weaptype as wt2 ON t2.weaptype2 = wt2.id;
 

//C / Vypis eventdate, gname, nkill, nwound z tabulky teror2 (!) a
//pres sloupecek country připoj zemi z tabulky country
//pres sloupecek weaptype1 připoj nazev zbrane z tabulky weaptype
//pres sloupecek weaptype2 připoj nazev zbrane z tabulky weaptype
//vypis jen utoky jejichz sekundarni zbran byla zapalna ('Incendiary')


SELECT
    IDATE
    , GNAME
    , NKILL
    , NWOUND
FROM TEROR2
LEFT



SELECT t2.idate, t2.gname, t2.nkill, t2.nwound, c.name as country_name, wt1.name as weapon_type1, wt2.name as weapon_type2
 FROM teror2 AS t2
 LEFT JOIN country as c ON t2.country = c.id
 LEFT JOIN weaptype as wt1 ON t2.weaptype1 = wt1.id
 LEFT JOIN weaptype as wt2 ON t2.weaptype2 = wt2.id
 WHERE wt2.name = 'Incendiary';

//D / Z tabulky teror2 vypis pocet utoku, pocty mrtvych a ranenych v roce 2020 -- podle pouzitych zbrani (WEAPTYPE1)

SELECT
    
FROM TEROR





















SELECT wt1.name as weapon_type1, count(*) as attacks, sum(t2.nkill) as nkill_sum, sum(t2.nwound) as nwound_sum 
FROM teror2 as t2
 LEFT JOIN country as c ON t2.country = c.id
 LEFT JOIN weaptype as wt1 ON t2.weaptype1 = wt1.id
 WHERE date_part(year, idate) = 2020
 GROUP BY wt1.name
 ORDER BY COUNT(*) DESC;

 
//E / Zjistí počty útoků z tabulky teror2 po letech a kontinentech. Tj. napoj sloupecek region z tabulky teror2 na tabulku region a vytvoř sloupeček kontinent z nazvu regionu a podle něj a podle roku tabulku "zgrupuj" (zagreguj).


SELECT
FROM TEROR2
WHERE
GROUP BY
ORDER BY KONTINENT, ROK;





SELECT CASE --vyber ze seznamu hodnot bude pri miliardach radek rychlejsi... Proc asi?
        -- pres region misto region_txt by to mozna bylo jeste rychlejsi...
         WHEN reg.name in ('Western Europe', 'Eastern Europe') THEN 'Europe'
         WHEN reg.name in ('Middle East & North Africa', 'Sub-Saharan Africa') THEN 'Africa'
         WHEN reg.name in ('East Asia', 'Southeast Asia', 'South Asia', 'Central Asia') THEN 'Asia'
         WHEN reg.name in ('North America', 'Central America & Caribbean', 'South America') THEN 'America'
         WHEN reg.name  = 'Australasia & Oceania' THEN 'Australia'
         ELSE reg.name
       END AS kontinent, 
       year(idate) as rok,
       count(*) utoku_celkem 
 FROM teror2 as t2
 LEFT JOIN region as reg
 ON t2.region=reg.id
 GROUP BY kontinent,rok  --potrebujeme tabulku zgrupovat po kontinentech a letech
 ;