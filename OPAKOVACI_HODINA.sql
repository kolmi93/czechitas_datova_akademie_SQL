------------------------------------------------------------------------------------------------------------------
-- OPAKOVACÍ LEKCE SQL - CZECHITAS DATOVÁ AKADEMIE PRAHA PODZIM 2023
------------------------------------------------------------------------------------------------------------------
-- Cílem je si připomenout, co už všechno umíme.
-- Nad každým příkladem chvíli popřemýšlejte a pak si ho projedeme společně
--------------------------------
-- CREATE TABLE, CREATE OR REPLACE TABLE, INSERT INTO TABLE, DELETE FROM TABLE
--------------------------------
-- Přepni se do svého schématu buď myší nebo s použitím USE SCHEMA SCH_CZECHITA_PRIJMENIK;
-- Použít můžeš příkaz CREATE TABLE, ale (pokud je to tvůr záměr), raději vždy používej CREATE OR REPLACE TABLE
-- Vytvoř si tabulku NAVSTEVY_2022. Chceme, aby měla stejnou strukturu jako již existující tabulka NAVSTEVY.
-- 1. ROLE -- zadejte svou roli
USE ROLE ROLE_CZECHITA_KOLAROVAM;
-- 2. WAREHOUSE
USE WAREHOUSE COMPUTE_WH;
-- 3. DATABASE
USE DATABASE COURSES;
-- 4. SCHEMA -- zadejte sve schema
USE SCHEMA SCH_CZECHITA_KOLAROVAM;
;
CREATE OR REPLACE TABLE NAVSTEVY_2022( -- MOJE
    ID INT
    , DATUM DATE
    , POPIS VARCHAR
    , PACIENT_ID INTEGER
    , POJISTOVNA_ID INTEGER
);

CREATE OR REPLACE TABLE NAVSTEVY_2022 ( 
  ID INT,
  DATUM DATETIME,
  POPIS VARCHAR(2000),
  PACIENT_ID INT,
  POJISTOVNA_ID INT
);
-- VLOŽENÍ DAT: Zde jsou data pro manuální vložení řádků do tabulky NAVSTEVY_2022. Vlož je.
INSERT INTO NAVSTEVY_2022(ID, DATUM, POPIS, PACIENT_ID, POJISTOVNA_ID)
VALUES
    (1,'2022-03-14 16:20','Preventivní prohlídka, rozhodnuto o trhání 8A',1,1),
    (2,'2022-03-15 10:05', NULL,2,2),
    (3,'2022-03-15 11:00','Výběr barvy korunky',3,4),
    (4,'2022-03-15 17:00','Trhání 8A',1,1),
    (5,'2022-06-15 12:30','Instalace nové korunky',3,3),
    (6,'2022-08-16 12:45','Nastaly komplikace při trhání 8A, ošetření bolesti',1,2),
    (7,'1970-01-01 00:01','Testovací záznam',10,10),
    (8,'2022-12-31 17:30','Instalace nové korunky',2,2) -- MOJE
;

INSERT INTO NAVSTEVY_2022 (ID, DATUM, POPIS, PACIENT_ID, POJISTOVNA_ID)
  VALUES 
(1,'2022-03-14 16:20','Preventivní prohlídka, rozhodnuto o trhání 8A',1,1),
(2,'2022-03-15 10:05', NULL,2,2), -- pokud hodnotu nemáme, vložíme "prázdno"
(3,'2022-03-15 11:00','Výběr barvy korunky',3,4),
(4,'2022-03-15 17:00','Trhání 8A',1,1),
(5,'2022-06-15 12:30','Instalace nové korunky',3,3),
(6,'2022-08-16 12:45','Nastaly komplikace při trhání 8A, ošetření bolesti',1,2),
(7,'1970-01-01 00:01','Testovací záznam',10,10),
(8,'2022-12-31 17:30','Instalace nové korunky',2,2)
;
-- MAZÁNÍ DAT: Smaž řádek z tabulky NAVSTEVY_2022, který na první pohled vypadá jako chybný/testovací.

--SELECT * FROM NAVSTEVY_2022;
DELETE FROM NAVSTEVY_2022 WHERE ID=7; -- MOJE

--SELECT * FROM NAVSTEVY_2022;

DELETE FROM NAVSTEVY_2022
WHERE id = 7
;
-- Spusť tyto dva skripty, ať máme stejná data (přidává časový údaj do sloupce datum)
CREATE OR REPLACE TABLE NAVSTEVY ( 
  ID INT,
  DATUM DATETIME,
  POPIS VARCHAR(2000),
  PACIENT_ID INT,
  POJISTOVNA_ID INT
)
;
INSERT INTO NAVSTEVY (ID, DATUM, POPIS, PACIENT_ID, POJISTOVNA_ID)
  VALUES 
(1,'2023-03-14 16:20','PreventivnÍ prohlídka, rozhodnuto o trhání 8A',1,1),
(2,'2023-03-15 10:05','Ošetření vypadlé plomby',2,2),
(3,'2023-03-15 11:00','Výběr barvy korunky',3,3),
(4,'2023-03-15 12:00','Trhání 8A',1,1),
(5,'2023-03-15 12:30','Instalace nové korunky',3,3),
(6,'2023-03-16 12:45','Nastaly komplikace při trhání 8A, ošetření bolesti',1,2)
;
--------------------------------
-- UNION ALL, UNION, TVORBA ID
--------------------------------
-- UNION ALL spojí tabulky pod sebe, UNION navíc smaže z výsledku duplicitní řádky (stejně jako SELECT DISTINCT)
-- Spoj pod sebe tabulky NAVSTEVY a NAVSTEVY_2022 a vytvoř tak tabulku NAVSTEVY_KOMPLET
-- Sloupec id z tabulek přejmenuj na id_puvodni
-- Vytvoř nový sloupec id, který bude obsahovat primární unikátní klíč pro nově vzniklou tabulku ve formátu např. '2022_1' (rok podtržítko id z původních tabulek)
   -- Jako rok pro tabulku NAVSTEVY_2022 použij 2022. Tabulka NAVSTEVY obsahuje pouze události z roku 2023.
CREATE OR REPLACE TABLE NAVSTEVY_KOMPLET AS
SELECT 
    ID AS ID_PUVODNI
    , '2022'||'_'||ID AS ID
    , DATUM
    , POPIS
    , PACIENT_ID
    , POJISTOVNA_ID
FROM NAVSTEVY
UNION ALL
SELECT
    ID AS ID_PUVODNI
    , '2023'||'_'||ID AS ID
    , DATUM
    , POPIS
    , PACIENT_ID
    , POJISTOVNA_ID
FROM NAVSTEVY_2022; -- MOJE
   
CREATE OR REPLACE TABLE NAVSTEVY_KOMPLET AS
SELECT
      '2023'||'_'||id AS id
    , id AS id_puvodni
    , datum
    , popis
    , pacient_id
    , pojistovna_id
FROM NAVSTEVY
UNION ALL 
SELECT
      '2022'||'_'||id AS id
    , id AS id_puvodni
    , datum
    , popis
    , pacient_id
    , pojistovna_id
FROM NAVSTEVY_2022
;

--------------------------------
-- ALTER TABLE, UPDATE TABLE
--------------------------------
-- Můžeme přejmenovat sloupec, přidat a odebrat sloupec, měnit hodnoty atd.
-- Přidej do tabulky NAVSTEVY_KOMPLET nový sloupec "zpracovanoL, který bude mít defaultní hodnotu 1 a datový typ INTEGER.
-- Proveď kontrolu.
ALTER TABLE NAVSTEVY_KOMPLET ADD zpracovanoL INTEGER DEFAULT 1;
SELECT * FROM NAVSTEVY_KOMPLET; -- MOJE

ALTER TABLE NAVSTEVY_KOMPLET ADD zpracovano INTEGER DEFAULT 1;
DESC TABLE NAVSTEVY_KOMPLET; -- Pro kontrolu sloupce a jeho datového typu

-- Změň hodnotu ve sloupci zpracovano na 0 pro záznamy, kde pojistovna_id = 3 (Zdravotní pojišťovna datových analitiků)
UPDATE NAVSTEVY_KOMPLET SET zpracovanoL = 0 WHERE POJISTOVNA_ID = 3; -- MOJE

UPDATE NAVSTEVY_KOMPLET SET zpracovano = 0
WHERE pojistovna_id = 3;
SELECT * FROM NAVSTEVY_KOMPLET
ORDER BY pojistovna_id; -- pro kontrolu

--------------------------------
-- WHERE A PODMÍNKY
--------------------------------
-- Vyber všechny sloupce z tabulky NAVSTEVY_KOMPLET.
-- Vyber pouze řádky, které:
 -- Datum je v roce 2022 a pojistovna_id je 3 NEBO datum je v roce 2023 a pojistovna_id je 1 nebo 2
 -- a zároveň kde popis návštěvy obsahuje řetězec '%orun%' nebo '%plom%' (ignoruj velikost písmen)
 -- a zároveň kde zpracovano = 1
 
-- Pokud nevíš, jak napsat některou funkci, vyjledej Googlem například "snowflake year" a nakoukni do dokumentace.

SELECT * FROM NAVSTEVY_KOMPLET
WHERE 1=1
    AND ((YEAR(datum) = 2022 AND POJISTOVNA_ID = 3) OR (YEAR(datum) = 2023 AND POJISTOVNA_ID IN (1,2)))
    AND (POPIS ILIKE'%orun%' OR POPIS ILIKE '%plom%') 
    AND zpracovanoL = 1; -- MOJE (POZOR NA ZÁVORKY!)

SELECT *
FROM NAVSTEVY_KOMPLET
WHERE 1=1
    AND ((YEAR(datum) = 2022 AND pojistovna_id = 2) OR (YEAR(datum) = 2023 AND pojistovna_id IN (2, 2)))
    AND (popis ILIKE '%orun%' OR popis ILIKE '%plom%')
    AND zpracovanoL = 1
;
--------------------------------
-- ZÁKLADNÍ (SKALÁRNÍ) FUNKCE, ORDER BY, LIMIT
--------------------------------
-- Vytvoř SELECT, kterým vybereš sloupce id a popis z tabulky NAVSTEVY_KOMPLET.
-- Přidej sloupec, kde vynásobíš 25 s 4. Pojmenuj ho "nasobek" (včetně uvozovek).
-- Vyber sloupec pojistovna_id, přecastuj ho na VARCHAR(255)
-- Z popis zobraz pouze první slovo
-- Ve sloupci popis nahraď mezery podtržítky
-- K datu přidej vždy dva dny
-- Každému složitějšímu sloupci přidej komentář, ať v budoucnu víš, co dělá
-- Zobraz pouze prvních 10 záznamů, seřazeno dle sloupce datum od nejnovějších
SELECT ID
    , POPIS
    , 24*5 AS "NASOBEK" -- JEDODUCHÉ NÁSOBENÍ ČÍSEL
    , POJISTOVNA_ID :: VARCHAR(255) -- PŘECASTOVÁNÍ
    , SPLIT (POPIS, ' ')[0] -- VYPÍŠE JEN PRVNÍ SLOVO
    , REPLACE (POPIS,' ', '_') -- VYMĚNÍ MEZERY ZA PODTRŽÍTKY
    , DATEADD (DAY,2,DATUM) -- PŘIDÁNÍ 2 DNŮ K DATUMU
FROM NAVSTEVY_KOMPLET
ORDER BY DATUM DESC
LIMIT 10; -- MOJE

SELECT
      id
    , popis
    , 25*4 AS "nasobek" -- prosté násobení dvou fixních čísel
    , pojistovna_id::VARCHAR(255) -- přecastování na text, jiný možný zápis: CAST(pojistovna_id AS VARCHAR(255))
    , SPLIT_PART(popis, ' ', 1) -- zobrazí první slovo popisu (resp. část textu před první mezerou)
    , REPLACE(popis, ' ', '_') -- nahrazuje mezery podtrřítky
    , DATEADD(day, 2, datum) -- přidává dva dny k datumu
FROM NAVSTEVY_KOMPLET
ORDER BY datum DESC
LIMIT 10
;
--------------------------------
-- CASE WHEN, IFNULL
--------------------------------
-- Z tabulky NAVSTEVY_KOMPLET vyber sloupce id a datum.
-- Pokud ve sloupci popis je hodnota NULL, nahraď ji textem 'Není známo'
-- Přidej sloupec pojistovna_txt, kde:
  -- Pokud je pojistovna_id = 1 vypiš 'Odborová zdravotní pojišťovna'
  -- Pokud je pojistovna_id = 2 vypiš 'Všeobecná zdravotní pojišťovna'
  -- Pokud je pojistovna_id = 3 vypiš 'Zdravotní pojišťovna datových analitiků'
  -- Jinak vypiš 'Jiná'

SELECT
    ID
    , DATUM
    , CASE
        WHEN pojistovna_id = 1 THEN 'Odborová zdravotní pojišťovna'
        WHEN pojistovna_id = 2 THEN 'Všeobecná zdravotní pojišťovna'
        WHEN pojistovna_id = 3 THEN 'Zdravotní pojišťovna datových analitiků'
        ELSE 'Jiná'
    END AS POJISTOVNA_TXT
FROM NAVSTEVY_KOMPLET; -- MOJE
  
SELECT 
      id
    , datum
    , IFNULL(popis, 'Není známo')
    , CASE 
        WHEN pojistovna_id = 1 THEN 'Odborová zdravotní pojišťovna'
        WHEN pojistovna_id = 2 THEN 'Všeobecná zdravotní pojišťovna'
        WHEN pojistovna_id = 3 THEN 'Zdravotní pojišťovna datových analitiků'
        ELSE 'Jiná'
      END AS pojistovna_txt
FROM NAVSTEVY_KOMPLET
;

--------------------------------
-- COUNT, COUNT DISTINCT
--------------------------------
-- Spočítej, kolik záznamů je v tabulce NAVSTEVY_KOMPLET
-- Spočítej, v kolika různých dnech byla nějaká návštěva
-- Spočítej, kolik různých pojišťoven je v tabulce
-- Spočítej, u kolika záznamů je vyplněný popis (není NULL)
SELECT
    COUNT (*)
    , COUNT (DISTINCT DATUM)
    , COUNT (DISTINCT POJISTOVNA_ID)
    , (SELECT COUNT (POPIS) FROM NAVSTEVY_KOMPLET WHERE POPIS IS NOT NULL)
FROM NAVSTEVY_KOMPLET; -- MOJE

SELECT
      COUNT (*) -- kolik záznamů je v tabulce
    , COUNT (DISTINCT datum) -- v kolika různých dnech byla nějaká návštěva
    , COUNT (DISTINCT pojistovna_id) -- kolik různých pojišťoven je v tabulce
    , COUNT (popis) -- u kolika záznamů je vyplněný popis
FROM NAVSTEVY_KOMPLET
;
--------------------------------
-- AGREGČNÍ FUNKCE: GROUP BY, SUM, MAX
--------------------------------
-- Agreguj data v tabulce NAVSTEVY_KOMPLET na úrovni dní - GROUP BY DATE(datum)
-- Vypiš sloupec s datumem = DATE(datum)
-- Spočítej počet návštěv v daný den
-- Pro každý den vypiš čas nejpozdější návštěvy
-- Sečti pacient_id v daný den (nedává to smysl, jen ukázka sčítání)
-- Celé tohle udělej pouze se záznamy, které jsou zpracované (ZPRACOVANO = 1)
SELECT
    DATE(DATUM) AS DATUM
    , COUNT (*) AS POCET_NAVSTEV_ZA_DEN
    , MAX(TIME(DATUM)) AS NEJPOZDEJSI_CAS_NAVSTEVY 
    , SUM (PACIENT_ID) AS SOUCET_PACIENTU_V_DANY_DEN
FROM NAVSTEVY_KOMPLET
WHERE ZPRACOVANOL = 1
GROUP BY DATE(DATUM);

SELECT
      DATE(datum)
    , COUNT(*) -- počet návštěv v daný den
    , MAX(TIME(datum)) -- nejpozdější čas návštěvy v den
    , SUM(pacient_id) -- součet hodnot v pacient_id v daný den
FROM NAVSTEVY_KOMPLET
WHERE ZPRACOVANOL = 1
GROUP BY DATE(datum) -- Pokud by zde bylo pouze datum, nejednalo by se o agregaci, protože každý návštěva v tabulce má svůj unikátní čas
;
--------------------------------
-- JOINY
--------------------------------
-- JOIN bingo: https://docs.google.com/spreadsheets/d/1VcuAykkHSMTxr4eme69_7a3mLYFLP5hIWPldKQ0q42A/
-- Chceme vedle sebe spojit tabulku NAVSTEVY_KOMPLET a POJISTOVNY (pojistovna_id = id) a vybrat všechny sloupce.
-- Zajímá nás každá návštěva, chceme ji obohatit o další informace
 --> Použijeme tedy LEFT JOIN, kde tabulka návštěv bude vlevo
 -- Pokud nemáš ve svém schématu tabulku POJISTOVNY, vezmi si ji odsud: COURSES.SCH_CZECHITA.POJISTOVNY
 SELECT *
 FROM NAVSTEVY_KOMPLET AS nav
 LEFT JOIN POJISTOVNY AS poj ON nav.pojistovna_id = poj.id
 ;
-- JOIN + agregace
-- Zajímá nás jmeno pojišťovny z tabulky POJISTOVNY obohacené o následující pole:
  -- Celkový počet návštěv pro pojišťovnu
  -- Datum první a datum poslední návštěvy nějakého pacienta pojišťovny
  -- Celkový počet pacientů, kteří uskutečnili návštěvu na danou pojišťovnu
;
SELECT
    POJ.JMENO
    , COUNT(NAV.ID) AS CELKOVY_POCET_NAVSTEV_PRO_POJISTOVNU
    , MIN(NAV.DATUM) AS PRVNI_DATUM_NAVSTEVY
    , MAX(NAV.DATUM) AS POSLEDNI_DATUM_NAVSTEVY
    , COUNT(DISTINCT NAV.PACIENT_ID)
FROM POJISTOVNY AS POJ
LEFT JOIN NAVSTEVY_KOMPLET AS NAV
ON POJ.ID = NAV.POJISTOVNA_ID
GROUP BY POJ.JMENO;
  
SELECT
      poj.jmeno
    , COUNT(nav.id) -- počet návštěv pro pojišťovnu
    , MAX(nav.datum) -- poslední návštěva
    , MIN(nav.datum) -- první návštěva
    , COUNT(DISTINCT pacient_id) -- počet pacientů
FROM POJISTOVNY poj
LEFT JOIN NAVSTEVY_KOMPLET nav ON poj.id = nav.pojistovna_id
GROUP BY poj.jmeno
;
--------------------------------
-- VNOŘENÝ SELECT
--------------------------------
-- Pro každého pacienta chceme přidat informaci, kolikrát nás pacient navštívil
-- Chceme tedy vypsat celou tabulku pacienti a pridat sloupec KOLIKRAT
-- Nejdříve si připravíme tabulku s počtem návštěv na pacienta
-- Následně ji spojíme s tabulkou PACITENTI (dáme ji do vnořeného selectu)
-- Přípravná tabulka alias předchroustání
SELECT pacient_id, COUNT(*) AS kolikrat
FROM NAVSTEVY_KOMPLET
GROUP BY pacient_id
;
-- Sem ji pak vkládáme:
SELECT PACIENTI.*, kolikrat
FROM PACIENTI
LEFT JOIN (     SELECT pacient_id, COUNT(*) AS kolikrat
                FROM NAVSTEVY_KOMPLET
                GROUP BY pacient_id
          ) ON id = pacient_id
;
--------------------------------
-- WINDOW FUNKCE
--------------------------------
-- Chceme docílit toho stejného jako v minulém připadě, bez použití agregace a vnořené query
-- Dále chceme ke každému pacientovi přidat informaci (sloupec):
   -- posledni_navsteva: Kdy byl pacient na návštěvě naposledy
   -- kolik_pojistoven: Kolik různých zdravotních pojišťoven pacient využil
   -- posledni_popis: Popis u poslední návštěvy pacienta
   
SELECT DISTINCT 
      PACIENTI.*
    , COUNT(*) OVER (PARTITION BY pacient_id) AS kolikrat
    , MAX(datum) OVER (PARTITION BY pacient_id) AS posledni_navsteva
    , COUNT(DISTINCT pojistovna_id) OVER (PARTITION BY pacient_id) AS kolik_pojistoven
    , LAST_VALUE(popis) OVER (PARTITION BY pacient_id ORDER BY datum) AS posledni_popis
    
FROM PACIENTI
LEFT JOIN NAVSTEVY_KOMPLET ON PACIENTI.id = pacient_id
;