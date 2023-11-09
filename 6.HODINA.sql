------------------------------------------------------------------------------------------------------------------
-- LEKCE 6: OPAKOVANI JOINU, VNORENY SELECT, CTE
-----------------------------------------------------------------------------------------------------------------
​
Pojďme se ještě na první část vrátit k JOINům.
​
LEFT JOIN
RIGHT JOIN
INNER JOIN
FULL JOIN
;
​
SELECT *
FROM PACIENTI;
​
​
;
CREATE OR REPLACE TEMPORARY TABLE PACIENTI_2 ( 
  ID INT,
  JMENO VARCHAR(1000),
  DATUM_NAROZENI DATE,
  TELEFON INT,
  ADRESA VARCHAR(2000)
);
​
INSERT INTO PACIENTI_2 (ID, JMENO, DATUM_NAROZENI, TELEFON, ADRESA)
  VALUES 
(1,'František Vomáčka','1990-03-12',666777888,'K Říčce 7, 12345 Plzeň'),
(2,'Linda Lízátková','1967-10-12',777345678,'Svatoplukova 21, 12111 Praha - Nové Město'),
(3,'Magdaléna Hodná','1968-12-12',737983920,'Václavské náměstí 1, 100000 Praha'),
(4,'Jan Krátký','1970-03-03',777123456,'Londýnská 5, 10001 Praha'),
(5,'Emanuela Smutná','1981-04-23',606123456,'Italská 5, 10002 Praha')
;
​
CREATE OR REPLACE TEMPORARY TABLE PACIENTI_3 ( 
  ID INT,
  JMENO VARCHAR(1000),
  DATUM_NAROZENI DATE,
  TELEFON INT,
  ADRESA VARCHAR(2000)
);
​
INSERT INTO PACIENTI_3 (ID, JMENO, DATUM_NAROZENI, TELEFON, ADRESA)
  VALUES 
--(1,'František Vomáčka','1990-03-12',666777888,'K Říčce 7, 12345 Plzeň'),
(2,'Linda Lízátková','1967-10-12',777345678,'Svatoplukova 21, 12111 Praha - Nové Město'),
(3,'Magdaléna Hodná','1968-12-12',737983920,'Václavské náměstí 1, 100000 Praha'),
(4,'Jan Krátký','1970-03-03',777123456,'Londýnská 5, 10001 Praha'),
(5,'Emanuela Smutná','1981-04-23',606123456,'Italská 5, 10002 Praha')
;
​
​
-- JAK MA PORADI DULEZITOST?
select *
from pacienti
left join pacienti_2 on pacienti.id = pacienti_2.id
 -- vsechny radky z PACIENTI a vlastne vsechny radkyy z PACIENTI 2
;
​
select *
from pacienti_2
left join pacienti on pacienti.id = pacienti_2.id
-- v tomto pripade se vlastne vytvor INNER JOIN i kdyz nechtene a to kvuli poradi tabulek
;
​
select *
from pacienti_2
inner join pacienti on pacienti.id = pacienti_2.id
-- stejny vysledek
;
​
PROTO JE FAJN SI UDELAT NEKDY I FULL OUTER JOIN;
​
select *
from pacienti
full outer join pacienti_3 on pacienti.id = pacienti_3.id
where pacienti.id is null or  pacienti_3.id is null
​
;
​
​
​
Příklady na zubařském datasetu.
​
1) Pro každou návštěvu chceme zjistit zdravotní pojišťovnu (zajímají nás sloupce datum a kod).;
;
select nav."datum", poj."kod"
from "navstevy" as nav
​
2) Pro každou adresu pacienta chceme zjistit datum každé návštěvy (zajímají nás sloupce adresa a datum).;
​
​
3) Pro každé telefonní číslo chceme zjistit datum poslední návštěvy (zajímají nás sloupce telefon a MAX(datum)).;
​
​
4) Pro každého pacienta chceme zjistit nejvyšší počet návštěv za den u pacienta s tímto číslem (zajímají nás sloupce pacient a datum).;
​
​
----------------------------------------------------------------------------------------------------
​
​
​
​
--; řešení
--1) 
SELECT datum, kod
FROM navstevy
LEFT JOIN pojistovny ON navstevy.pojistovna_id = pojistovny.id
;
​
--2)
SELECT adresa, datum
FROM pacienti
LEFT JOIN navstevy ON pacienti.id = navstevy.pacient_id
;
-- Co by se stalo, kdyby nějaký pacient v tabulce pacienti neměl žádný záznam v tabulce navstevy?
​
--3)
SELECT telefon, MAX(datum)
FROM pacienti
LEFT JOIN navstevy ON pacienti.id = navstevy.pacient_id
GROUP BY telefon
;
​
--4) Pro každého pacienta chceme zjistit nejvyšší počet návštěv za den u pacienta s tímto číslem (zajímají nás sloupce pacient a datum).;
​
-- To je blbý, tohle zatím neumíme... :-(
-- Musíme na to jinak a brzy to budeme umět! :-)
-- Musíme si data nejdříve předchroustat a pak až je zpracujeme.
​
-- Předchroustání dat:
-- Nejdřiv si zobrazíme všechny navstevy
;
​
​
​
-- 1. Vytvoření dočasné tabulky
;
CREATE OR REPLACE TABLE temp_celkovy_pocet_navstev_za_den AS
SELECT cast(datum as date) as den, COUNT(*) AS pocet_navstev_za_den 
FROM navstevy 
GROUP BY cast(datum as date)
;
​
SELECT navstevy.*, cast(datum as date) as den, pocet_navstev_za_den 
FROM navstevy
LEFT JOIN temp_celkovy_pocet_navstev_za_den ON cast(navstevy.datum as date)  = temp_celkovy_pocet_navstev_za_den.den
​
;
​
-- 2. CTE
​
WITH cte_celkovy_pocet_navstev_za_den AS
       (SELECT cast(datum as date) as den, COUNT(*) AS pocet_navstev_za_den 
        FROM navstevy 
        GROUP BY cast(datum as date) 
       )
​
SELECT navstevy.*, pocet_navstev_za_den
FROM navstevy
LEFT JOIN cte_celkovy_pocet_navstev_za_den ON cast(navstevy.datum as date)  = cte_celkovy_pocet_navstev_za_den.den
;
​
-- 3. SubSELECT (vnořený SELECT)
​
SELECT navstevy.*, pocet_navstev_za_den
FROM navstevy
LEFT JOIN 
       (SELECT cast(datum as date) as den, COUNT(*) AS pocet_navstev_za_den 
        FROM navstevy 
        GROUP BY cast(datum as date) 
        ) ON cast(navstevy.datum as date)  = den
​
;
​
​
​
​
​
---------------------------------------------------------                        
-- VNORENY SELECT / SUBSELECT / SUBQUERY
---------------------------------------------------------  
https://docs.snowflake.com/en/user-guide/querying-subqueries.html
​
Vnořený SELECT, subSELECT, subquery, nested SELECT
​
K čemu se využívá:
- Jako výpočet určité DYNAMICKÉ hodnoty
- Jako vytvoření „virtuální“ tabulky
​
Kde všude ho můžeme použít
SELECT – k vypočtení hodnoty ve sloupečku
FROM – k vytvoření „virtuální“ tabulky
JOIN – k vytvoření „virtuální“ tabulky
WHERE – k vypočtení hodnoty (=) nebo hodnot (in) pro splnění podmínky
​
​
​
​
-- SYNTAX SELECT
SELECT sloupecek, agg_funkce(jiny_sloupecek)
FROM tabulka
WHERE podminka
GROUP BY sloupecek
HAVING dalsi_podminka;
​
SELECT gname, SUM(NKILL)
FROM teror
WHERE region_txt ILIKE '%asia%'
GROUP BY gname
HAVING gname like 'A%';
​
​
SELECT *
FROM 
   (SELECT gname, SUM(NKILL)
    FROM teror
    WHERE region_txt ILIKE'%asia%'
    GROUP BY gname
    HAVING gname like 'A%') AS  sum_nkill_v_asii_pro_org_na_A;
​
    
-- Vybere jen některé sloupce jako subSELECT
SELECT * 
FROM (SELECT gname
            ,idate 
      FROM teror2 
      WHERE country = 54) AS subSELECT
;
​
     
-- Úkol pro ukázku: Vyberte sloupec GNAME z tabulky, ve které jsou tři organizace (GNAME) s nejvyšším množstvím zabitých lidí (MAX(NKILL)) z tabulky TEROR.
;
select gname
from
    (select gname,max(nkill)
    from teror
    group by gname
    order by max(nkill) desc nulls last
    limit 3
    );
​
SELECT GNAME
FROM 
     (SELECT GNAME, MAX(NKILL) 
      FROM TEROR 
      GROUP BY GNAME
      ORDER BY MAX(NKILL) DESC NULLS LAST
      LIMIT 3
     );
​
     
-- Zobrazení všech teroristických událostí, které spáchala teroristická organizace s nejvetším počtem obětí v jednom útoku
;
select eventid, gname nkill
from teror
where gname in (select gname
                from teror
                order by nkill desc nulls last
                limit 1
                );

​
SELECT 
    gname
    ,eventid
    ,nkill
FROM teror
WHERE gname = 'Islamic State of Iraq and the Levant (ISIL)'; --> HARD-CODED hodnota --> jak na dynamickou hodnotu?
​
​
SELECT 
    gname
    ,eventid
    ,nkill
FROM teror
WHERE gname IN (SELECT  gname -- tento SELECT nam vrati jednu hodnotu = 1 sloupec, 1 radek
               FROM teror 
               ORDER BY nkill DESC NULLS LAST
               LIMIT 1
               );
               
​
​
-- Co kdyby existovala shoda a my bychom chtěli obě organizace? (Např. dvě nebo více organizací se stejnou hodnotou MAX(NKILL))
SELECT DISTINCT gname
FROM teror
WHERE nkill = (SELECT  MAX(nkill)
               FROM teror);
​
​
-- Zkusme vnořit vnořený select
 -- = přesně 1 jedna hodnota
 -- IN použijeme pro porovnání s jednou či více hodnotami
SELECT 
      gname
    , eventid
    , nkill 
FROM teror
WHERE gname IN (SELECT DISTINCT gname  -- potencialne muze vratit i vice skupin, stale ale jen v 1 sloupci
                FROM teror
                WHERE nkill = (SELECT MAX(nkill) 
                               FROM teror)
                )
; 
-- pro ukázku můžeme MAX nahradit za MIN a najít si všechny organizace, které měly útok s 0 mrtvými
                               
​
​
-- Zajímá nás počet mrtvých v letech 2017 a 2016 které má na svědomí Islámský Stát. Chceme vidět název organizace a ve sloupcích počet mrtvých pro oba roky a meziroční změnu.
-- Pojďme si problém rozebrat na jednotlivé kroky:
​
​
-- Výsledný skript:
SELECT 
      pm17.gname
    , pm17.pocetmrtv2017
    , pm16.pocetmrtv2016     
    , pm17.pocetmrtv2017 - pm16.pocetmrtv2016 AS mezirocne
​
FROM (SELECT   gname
              ,SUM(nkill) AS pocetmrtv2017
      FROM teror
      WHERE iyear=2017 
            AND gname ILIKE'%islamic state%' 
      GROUP BY GNAME
      ORDER BY pocetmrtv2017 DESC) AS pm17
​
LEFT JOIN (SELECT gname
                 ,SUM(nkill) AS pocetmrtv2016
           FROM teror
           WHERE iyear=2016 
                 AND gname ILIKE'%islamic state%'
           GROUP BY 1
          ORDER BY pocetmrtv2016 DESC) AS pm16
​
ON pm17.gname = pm16.gname;
​
​
--------------------------------------------------------
--------------------------------------------------------
​
-- Příklad: Vyber region (REGION_TXT), zemi (COUNTRY_TXT), počet zabitých v zemi (NKILL). Seřaď podle region_txt, country_txt.
​
​
​
-- Přidej sloupeček celkoveho poctu zabitých v regionu.
​
​
​
-- Řešení: Vyber region (REGION_TXT), zemi (COUNTRY_TXT), počet zabitých v zemi (NKILL):
​
SELECT region_txt
       , country_txt
       , SUM(nkill) AS zabitych_zeme
      
FROM teror
GROUP BY region_txt, country_txt
ORDER BY region_txt, country_txt
;
​
-- Přidej sloupeček celkoveho poctu zabitých v regionu:
​
SELECT teror.region_txt
       , country_txt
       , SUM(nkill) AS zabitych_zeme
       , navic_region.zabitych_region    
FROM teror
LEFT JOIN
          (SELECT region_txt, SUM(nkill) AS zabitych_region
          FROM teror
          GROUP BY region_txt) AS navic_region
    ON teror.region_txt   =  navic_region.region_txt
GROUP BY teror.region_txt, country_txt, navic_region.zabitych_region
ORDER BY teror.region_txt, country_txt
;
​
-- Můžeme to udělat i "složitěji", kdy si připravíme dvě hotové tabulky, které spojíme:
​
SELECT  puvodni_tabulka.*
      , navic_region.zabitych_region
FROM 
      (SELECT region_txt
             , country_txt
             , SUM(nkill) AS zabitych_zeme     
      FROM teror
      GROUP BY region_txt, country_txt
       ) AS puvodni_tabulka
​
LEFT JOIN
          (SELECT region_txt, SUM(nkill) AS zabitych_region
          FROM teror
          GROUP BY region_txt) AS navic_region
    ON puvodni_tabulka.region_txt   =  navic_region.region_txt
​
ORDER BY puvodni_tabulka.region_txt, country_txt
;
​
-- SUBSELECT V SELECT
​
-- Vypočítej následující sloupčeky:
      --počet všech útoků, kde byla použita Fake Weapons
      --počet zabitých, kde byla použita Fake Weapons
      --počet všech útoků, kde NEbyla použita Fake Weapons
      --počet zabitých, kde NEbyla použita Fake Weapons

      
SELECT 
      (SELECT count(nkill) FROM teror WHERE weaptype1_txt = 'Fake Weapons') AS attaks_fake_weapons   
    , (SELECT SUM(nkill) FROM teror WHERE weaptype1_txt = 'Fake Weapons') AS nkill_fake_weapons
    , (SELECT count(nkill) FROM teror WHERE weaptype1_txt != 'Fake Weapons') AS attacks_without_fake_weapons
    , (SELECT SUM(nkill) FROM teror WHERE weaptype1_txt != 'Fake Weapons') AS nkill_without_fake_weapons
;​

-- Vyhledej sloupečky Eventid, City, idate pro nejnovějších 10 útoků podle idate. Navíc vytvoř nový sloupeček, který vypočítá datum prvního útoku v daném městě.
​
-- Vnořený SELECT v části SELECT:
​
SELECT 
       eventid
     , city
     , idate
     , (SELECT min(idate) FROM teror2 AS sub_SELECT_table WHERE sub_SELECT_table.city = main_table.city ) AS first_attack
FROM teror2 AS main_table
ORDER BY idate desc
LIMIT 10
;​
-- Vnořený SELECT v části FROM:

SELECT   eventid
     , main_table.city
     , idate
     , prvni_utok
     
FROM teror2 AS main_table​
LEFT JOIN
 (SELECT city, min(idate)  AS prvni_utok
  FROM teror2
  GROUP BY 1
 ) AS sub_SELECT_table

ON main_table.city = sub_SELECT_table.city​
ORDER BY idate DESC
LIMIT 10;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- COMBO PRO ODVÁŽNÉ !!!! SUB-SELECT ve všech částech selektu
-- Celkový počet mrtvých v Evropě, Asii, celko...