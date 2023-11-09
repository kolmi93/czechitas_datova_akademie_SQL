
---------------------------------------------------------                        
-- FUNKCE
---------------------------------------------------------
--- Ve světě databází jsou funkce programovatelné části kódu, které provádějí určité operace nebo výpočty nad daty v databázi.
--- Funkce jsou často používány pro transformaci dat, výpočty a zpracování dat
--- Funkce jako nadstavba (každá SQL flavor se může různit) -> dokumentace
------ Některé databázové systémy mohou nabízet rozšíření nebo vlastní funkce, které nejsou součástí standardního SQL a jsou specifické pro daný systém


---- jak zjistit datovy typ?
DESCRIBE TABLE TEROR;

-- Funkce skalární se zabývají konkrétním řádkem ne celou tabulkou, jako jsme se učili doposud.


---------------------------------------------------------                        
-- STRING FUNCTIONS
---------------------------------------------------------
-- ÚČEL: Manipulace s textem - čištění dat, získávání informací

/*
SPLIT
LENGTH, LEN
REPLACE
SUBSTRING
LEFT
RIGHT
LOWER, UPPER

*/
;

-- SPLIT
SELECT SPLIT('127.0.0.1', '.')
--       ,SPLIT_PART('127.0.0.1', '.',2)
; -- argumenty jsou rozděleny čárkama (jedná se o to, co je v závorce). SPLIT rozkouskuje rozdělit string a rozdělení probíhá všude, kde je tečka. Výsledek je v datovým typu ARAY. 

SELECT SPLIT('127.0.0.1', '.') [0]; -- Hranaté závorky nám říkají, se kterou částí ze splitu chci pracovat.

SELECT SPLIT_PART ('127.0.0.1', '.', 1); -- Dělá to samé, co řádek výš. POZOR! začíná se počítat od 1, ne od 0 jako na řádku výše!


SELECT DISTINCT
    city
    ,SPLIT(city, ' ')
    ,ARRAY_SIZE(SPLIT(city, ' ')) -- spočítá na kolik částí se vybraný text rozdělil
    ,ARRAY_SIZE(SPLIT(city,' '))-1 -- lze s tím počítat. V tomto případě od spočítaných částí odečte -1. 
    ,SPLIT(city, ' ')[ARRAY_SIZE(SPLIT(city,' '))-1]::STRING -- array_size počítá od 0. V případě, že napíšeme -1, koukáme na poslední část názvu.
FROM teror; -- vybere vsechny mesta a rozdeli je podle poctu slov 


-- UKOLY ----------------------------------------------------------

-- Vypiste vsechny utoky, ktere maji trislovne a vice slovne nazvy mest (city).

SELECT
    EVENTID
    , CITY
FROM TEROR
WHERE ARRAY_SIZE(SPLIT(CITY, ' ')) >= 3;
------------------------------------------------------------------


------------------------------------------------------------



-- LENGTH & REPLACE (jako LEN v pythonu)
SELECT LENGTH('12345'); -- textova hodnota
SELECT LEN('12345');

SELECT LENGTH(12345); -- ciselna hodnota (chybí uvozovky. Snowflake to umí, jiné databáze může mít prolém)
SELECT LEN(12345);

SELECT LENGTH('dobry den'); -- mezera je taky znak
//SELECT LEN('dobry den');
SELECT LEN('dobry den');

SELECT city
       ,REPLACE(city,' ','-') --(kde budeme nahrazovat, co budeme nahrazovat, čím budeme nahrazovat)
FROM teror;



-- SUBSTRING & LOWER & UPPER
SELECT city 
       ,SUBSTRING(city,1,1) AS prvni_pismeno -- vezme jen první písmeno
       ,SUBSTR(city,1,1) AS taky_prvni_pismeno -- to samé jako řádek výše
       ,SUBSTRING(city,1,1) || SUBSTRING(city,2) -- SVISLÍTKO NEBOLI ROUŘÍTKO! Spojujeme různé stringy. Prní část vezme jen prní písemeno (P), druhá za rourama vezme zbytek (RAHA)
       ,LOWER(prvni_pismeno) || SUBSTRING(UPPER(city),2)
FROM teror; -- vybere mesto a jeho prvni pismeno


-- LEFT
SELECT city 
       ,LEFT(city,1) AS prvni_pismeno -- začíná zleva, v tmto případě bere jen 1.písmeno (,1)
FROM teror; -- vybere mesto a jeho prvni pismeno

-- RIGHT & UPPER
;
SELECT city, 
       UPPER(RIGHT(city,3)) AS posledni_tri_pismena -- začíná zprava a funkce upper mi napíše písmena velkým
       , RIGHT(UPPER(city),3) AS posledni_tri_pismena_znovu
FROM teror; -- vybere mesto a jeho posledni tri pismena v UPPERCASE

-- BONUS: CHARINDEX & POSITION

SELECT -- vrátí na kterém místě je písmenko "o"
    country_txt
    ,CHARINDEX('o',country_txt)
    ,POSITION('o',country_txt)
    ,POSITION('o' IN country_txt)
FROM teror;



---------------------------------------------------------                        
-- MATH FUNCTIONS
---------------------------------------------------------
/*
HAVERSINE
ROUND
FLOOR
CEIL
*/

SELECT 
     latitude     --zeměpisná šířka
    ,longitude    --zeměpisná délka
FROM teror;

-- HAVERSINE - počítá vzdálenost v kilometrech
----HAVERSINE( lat1, lon1, lat2, lon2 )
SELECT 
     gname --název teroristicke skupiny
    ,city 
    ,iyear
    ,nkill
//    ,latitude 
//    ,longitude
    ,HAVERSINE(50.0833472, 14.4252625, latitude, longitude) AS vzdalenost_od_czechitas -- v km (czechitas, czechitas, útok, útok)
FROM teror 
---WHERE vzdalenost_od_czechitas < 100 -- novy sloupec muzeme pouzit v podmince. Aby vzdálenost útoku byla do 100 km od czechitas.
ORDER BY nkill DESC;









-- co jednotlive funkce delaji?
SELECT 
     ROUND(1.5) -- zaokrouhluje matematicky
    ,CEIL(1.5) -- zaokrouhlení nahoru
    ,FLOOR(1.5) -- zaokrouhlí dolů
    ,TRUNC(1.5); --TRUNCATE ořízne desetinná čísla
       
    ,ROUND(1.1)
    ,CEIL(1.1) 
    ,FLOOR(1.1)
    ,TRUNC(1.1)
;
SELECT -- záporná čísla
     ROUND(-1.5) -- zaokrouhlí nahoru -2
    ,CEIL(-1.5) -- zaokrouhlí nahoru na -1
    ,FLOOR(-1.5) -- zaokrouhlí na -2
    ,TRUNC(-1.5) -- osekne desetinná čísla
       
    ,ROUND(-1.1)
    ,CEIL(-1.1) 
    ,FLOOR(-1.1)
    ,TRUNC(-1.1)
;



-- UKOLY ----------------------------------------------------------

-- Zaokrouhlete cislo 1574.14676767676 na dve desetinna mista (pokud si nevite rady -> dokumentace). Použijte funkce ROUND, CEIL, FLOOR, TRUNC.

SELECT
    ROUND (1574.1467676767, 2)
    , CEIL (1574.1467676767, 2)
    , FLOOR (1574.1467676767, 2)
    , TRUNC (1574.1467676767, 2);


------------------------------------------------------------------



-- Další funkce, o kterých je dobré vědět, že existují:
-- ABS() absolutní hodnoty
-- POWER(), SQRT() mocniny, odmocniny
-- LOG() logaritmiscké funkce
-- RAND() náhodné číslo
-- SIN(), COS(), TAN(), 

-- Pokud vás víc zajímají -> dokumentace ;-)

---------------------------------------------------------                        
-- DATE FUNCTION
---------------------------------------------------------
--  Manipulace s daty a časem
/*
TO_DATE
DATE_FROM_PARTS
DATEADD
DATEDIFF
EXTRACT
*/


-- Co je snowflake datum? YYYY-MM-DD

/*

1. '2021-23-06' - nevezme

2. '2020/03/05' - nevezme

3. '2018-05-03'- Snowflake přijme

4. '1.3.2019' - nevezme


SELECT CAST('' AS DATE);
SELECT ''::DATE;

*/


-- Co s tim, kdyz to snowflake nepozna?
-- https://docs.snowflake.com/en/sql-reference/functions-conversion#date-and-time-formats-in-conversion-functions



-- TO_DATE - pomáhá převézt string na datum. Řekneme Snowflake, kde je která část a čím jsou oddělené. Správný formát je YYYY-MM-DD.

SELECT TO_DATE('2021-23-06','YYYY-DD-MM');

-- UKOLY ----------------------------------------------------------

-- Jak bude vypadat funkce pro dalsi data?

SELECT TO_DATE ('2020/03/06', 'YYYY/DD/MM');


SELECT TO_DATE ('1.3.2019', 'DD.MM.YYYY');

------------------------------------------------------------------

-- DATE_FROM_PARTS
SELECT
    DATE_FROM_PARTS(iyear, imonth, iday)
    ,idate
--  ,*
FROM teror 
LIMIT 100; -- skládá z částí datum, vstup musí být číslo!



-- DATEADD - dlouží např. k připomenutí výročí
SELECT DATE_FROM_PARTS(iyear, imonth, iday) AS datum
      ,DATEADD(year,2, datum) as budoucnost -- přidá 2 roky k datumu -> (k čemu chceme přidat, kolik, datum)       
      ,DATEADD(year,-2, datum) as minulost -- odebere 2 roky z data -> (z čeho odečítám, kolik, datum)
      ,DATEADD(month,-2, datum) -- odebere 2 měsíce -> ( z čeho odečítá, kolik, datum)
FROM teror
-- WHERE datum > DATEADD(year, -4, '2020-03-12') -- ukáže jen ty řádky, které je o 4 roky méně než současné datum
-- WHERE DATEADD(year, 2, datum) = DATE_FROM_PARTS(2016, 1, 1) -- přidáme 2 roky k datumu z date_from_parts se rovná datu 2016-1-1.
WHERE DATEADD(year, 2, datum) = '2016-01-01' -- to samé, co řádek nadtím
;
-- https://docs.snowflake.com/en/sql-reference/functions-date-time.html#label-supported-date-time-parts

SELECT CURRENT_DATE(); -- vypíše aktuální datum
SELECT CURRENT_DATE; -- to samé, co řádek nahoře. Snowflake umí i bez závorek

SELECT CURRENT_TIMESTAMP(); -- vypíše aktuání timestamp. číslo na konci nám říká časové pásmo. -0700 by mělo být LA.


-- DATEDIFF - dělá rozdíl mezi datumy

SELECT DATEDIFF(month,'1993-06-14',CURRENT_DATE()); --(v čem budeme hledat rozdíl, vybrané datum, současné datum)


SELECT 
    DATE_FROM_PARTS(iyear, imonth, iday) AS datum
--  ,DATE_FROM_PARTS(2015,1,1)
    ,DATEDIFF(year,datum, DATE_FROM_PARTS(2015,1,1)) -- (rozdíl v letech, datum v tabulce, od date_from_parts)
FROM teror
WHERE DATEDIFF(year,datum, DATE_FROM_PARTS(2015,1,1)) = -2 -- (rozdíl v letech, od data v tabulce, od 1.1.2015), kdy rozdíl mezi daty jsou 2 roky
;



-- EXTRACT & DATE_PART
SELECT 
     idate AS datum 
    ,EXTRACT(YEAR FROM datum) AS rok --MONTH,DAY,WEEK,HOUR,QUARTER,MINUTE,SECOND (vytěží nám z datumu nějaký konkrétní údaj, zde rok)
    ,YEAR(datum)
    ,MONTH(datum)
    ,DAY(datum)
    ,DATE_PART(year,datum) -- vybere rok z datumu. Lze měnit na jiné jednotky (day, month)
FROM teror;

-- Další zajímavé funkce s datumy:

-- LAST_DAY(): Vrátí poslední den v měsíci pro zadané datum.
-- DATE_TRUNC(): Zkrátí datum na určitý časový úsek, například den, měsíc nebo rok.

-- UKOLY KODIM.CZ ----------------------------------------------------------

// 2.5 // Z IYEAR, IMONTH a IDAY vytvořte sloupeček datum a vypište tohle datum a pak datum o tři měsíce později a klidně i o tři dny a tři měsíce.                        
;
SELECT
    DATE_FROM_PARTS (IYEAR, IMONTH, IDAY) AS SLOZENE_DATUM
    , DATEADD (MONTH, 3, SLOZENE_DATUM) AS POSUNUTE_MES_SLOZENE_DATUM
    , DATEADD (DAY, 3, POSUNUTE_MES_SLOZENE_DATUM) AS POSUNUTE_MES_A_DNY_SLOZENE_DATUM
FROM
    TEROR;

 -------------------------------------------------------------------------------

---------------------------------------------------------
-- LIKE, ILIKE - používá se při vyhledávání mezi textovými řetězci string a neznáme úplné znění stringu

-- LIKE bere písmenka uplně přesně tak, jak jsme to napsali. V SQLlite neni case sensitive.
---------------------------------------------------------
/*
% - 0 az N znaku
_ - jeden znak
*/

-- hledame Bombing/Explosion
;
SELECT DISTINCT attacktype1_txt
FROM teror 
-- WHERE attacktype1_txt LIKE 'bomb%' -- nenajde nic, je to case sensitive
-- WHERE attacktype1_txt LIKE 'Bomb%' -- najde Bombing/Explosion, case sensitive - název začíná velkým písmenem
-- WHERE attacktype1_txt ILIKE 'bomb%' -- najde Bombing/Explosion, není case sensitive
-- WHERE LOWER(attacktype1_txt) LIKE 'bomb%' -- najde Bombing/Explosion, díky LOWER
-- WHERE attacktype1_txt LIKE '_omb%' -- najde Bombing/Explosion
;


SELECT DISTINCT region_txt
FROM teror 
WHERE region_txt ILIKE '%america%'; -- vybere unikatni nazvy regionu, ktere obsahuji america (kdekoliv a v jakekoliv velikosti)

SELECT DISTINCT gname
FROM teror 
WHERE gname ILIKE 'a%'; -- vybere unikatni nazvy organizaci, ktere zacinaji na 'a' a vypíše je jen jednou díky DISTINCT


SELECT DISTINCT gname 
FROM teror 
WHERE gname ILIKE '_a%'; -- vybere unikatni nazvy organizaci, ktere maji v nazvu druhe pismeno a


SELECT city 
FROM teror 
WHERE city like '% % %'; -- vybere vsechny mesta, ktera maji vice jak 2 slova


-- UKOLY KODIM.CZ ----------------------------------------------------------

// 2.4 // Vypiš všechny organizace, které na jakémkoliv místě v názvu obsahují výraz „anti“ a výraz „extremists“

SELECT
    GNAME
FROM
    TEROR
WHERE GNAME LIKE '%anti%' OR GNAME LIKE '%extremists'
ORDER BY GNAME ASC;

---------------------------------------------------------     
-- IN, NOT IN
---------------------------------------------------------                     

-- IN, NOT IN
;
SELECT *
FROM teror
WHERE country_txt <> 'India' AND country_txt <> 'Somalia';

SELECT *
FROM teror
-- WHERE country_txt NOT IN ('India','Somalia')
-- WHERE country_txt IN ('India','Somalia') -- jaka je alternativa?
WHERE country_txt = 'India' OR country_txt = 'Somalia'
;

---------------------------------------------------------                        
-- BETWEEN
---------------------------------------------------------    

-- cisla

SELECT * 
FROM teror
WHERE nkillter >= 40 AND nkillter <= 60;


SELECT
    NKILLTER, *
FROM teror
WHERE nkillter BETWEEN 40 AND 60; -- vcetne


SELECT DISTINCT iyear
FROM teror 
WHERE iyear BETWEEN 2014 AND 2016; -- vybere unikatni roky mezi roky 2014 a 2016 (vcetne krajnich hodnot)


-- pismena
SELECT DISTINCT city, 
       SUBSTRING(city,1,1) AS prvni_pismeno 
FROM teror 
WHERE prvni_pismeno BETWEEN 'A' AND 'C'; -- vybere mesta, ktera zacinaji na A, B nebo C

-- funguje i na datum

SELECT *
FROM teror
WHERE DATE_FROM_PARTS(iyear, imonth, iday) BETWEEN '2017-11-01' AND '2017-12-01';

------------------------------------------------
-- IS NULL, IS NOT NULL
------------------------------------------------
SELECT weaptype1_txt,
       nkillter 
FROM teror 
WHERE nkillter IS NOT NULL -- všechny zabité teroristy, kdy hodnota není NULL
ORDER BY nkillter DESC;

SELECT weaptype1_txt,
       nkillter 
FROM teror 
WHERE nkillter IS NULL -- všechny zabité teroristy, kdy hodnota je NULL
ORDER BY nkillter DESC;

-- pozor, nekdy null hodnoty nejsou definovane, naucte se rozeznavat NULL hodnotu


-- UKOLY KODIM.CZ ----------------------------------------------------------

// 2.3 // Zobraz sloupečky IYEAR, IMONTH, IDAY, GNAME, CITY, ATTACKTYPE1_TXT, TARGTYPE1_TXT, WEAPTYPE1_TXT, WEAPDETAIL, NKILL, NWOUND a vyber jen útoky, 
//které se staly v Czech Republic v letech 2015, 2016 a 2017. 
-- Všechna data seřaď chronologicky sestupně

SELECT
    IYEAR AS YEAR
    , IMONTH AS MESIC
    , IDAY AS DEN
    , GNAME AS ORGANIZACE
    , CITY AS MESTO
    , ATTACKTYPE1_TXT AS TYP_UTOKU
    , TARGTYPE1_TXT AS CIL_UTOKU
    , WEAPTYPE1_TXT AS DRUH_ZBRANE
    , WEAPDETAIL AS DEATIL_ZBRANE
    , NKILL AS POCET_ZABITYCH
    , NWOUND AS POCET_ZRANENYCH
FROM TEROR
WHERE COUNTRY_TXT = 'Czech Republic' AND IYEAR BETWEEN 2015 AND 2017
ORDER BY IYEAR ASC;

-------------------------------------------------------------------------------


---------------------------------------------------------                        
-- IFNULL
---------------------------------------------------------       

-- IFNULL - vrací nám hodnotu v případě, že ve sloupečku je záznam, který je NULL
SELECT -- př. využití - připravujeme data pro aplikaci, která nezná NULL a my tam musíme dát nějaké číslo
    nkill
    ,IFNULL(nkill, -99) AS nkill -- místo NULL hodnoty to napíše -99
    ,IFNULL(nkill, 0) AS nkill -- místo NULL hodnoty napíše 0
FROM teror;

SELECT AVG(nkill)
    ,AVG(IFNULL(nkill,-99))
    ,AVG(IFNULL(nkill,0)) -- hodnoty 0 a -99 mi rozhodí průměr, proto přichází řešení viz. kód pod
FROM teror;

SELECT AVG(nkill)
    ,AVG(IFNULL(nkill,-99))
    ,AVG(IFNULL(nkill,0))
FROM teror
WHERE nkill IS NOT NULL -- odfiltrování NULL hodnot -> nerozhodí mi to průměr
//WHERE nkill IS NULL
;

---------------------------------------------------------   
-- CASE WHEN
---------------------------------------------------------   
-- Umožňuje provádět různé akce nebo vrátit různé hodnoty na základě splnění určitých podmínek.
-- Vyttvoří nový sloupeček

SELECT nkill,
       CASE -- přijde okamžik,kdy přijdou podmínky. Pokud podmínky budou splněny, něco se stane.
        WHEN NKILL IS NULL THEN 0 --v okamžiku když NKILL je NULL, ukaž 0
        ELSE NKILL -- jinak ukaž NULL
        END AS nkill_upraveno -- nový sloupec ukaž jako NKILL_UPRAVENO
       ,IFNULL(nkill,0) AS nkill_upraveno2 -- dělá uplně to samé jako to nahoře
FROM TEROR;


SELECT nkill,
       CASE
         WHEN nkill IS NULL THEN 'unknown'
         WHEN nkill > 100 THEN 'over 100 killed'
         WHEN nkill > 0 THEN '1-100 killed'
         WHEN nkill = 0 THEN 'none killed'
         ELSE '00-ERROR' -- v případě, že jsem nepodchytila všechny možnosti.
       END AS upraveny_nkill
FROM teror
ORDER BY upraveny_nkill
; 


SELECT DISTINCT region_txt
FROM teror;

SELECT region_txt,
       CASE
         WHEN region_txt ILIKE '%america%' THEN 'Amerika' -- pokud v textu bude Amerika, napsat Amerika
         WHEN region_txt ILIKE '%africa%' THEN 'Afrika' -- to samé, co výše
         WHEN region_txt ILIKE '%asia%' THEN 'Asie' -- to samé, co výše
         ELSE region_txt
       END AS continent -- pokud nedopíšeme END, do názvu sloupce se vypíše celá funkce
FROM teror; -- vytvorime sloupec kontinent podle regionu


-- UKOLY SELEKTUJU.CZ ----------------------------------------------------------

                        
// 2.6 // Vypiš všechny druhy útoků ATTACKTYPE1_TXT

SELECT
    ATTACKTYPE1_TXT
FROM TEROR
ORDER BY ATTACKTYPE1_TXT ASC; -- vypíše všechny druhy útoků

SELECT
    ATTACKTYPE1_TXT
FROM TEROR
GROUP BY ATTACKTYPE1_TXT
ORDER BY ATTACKTYPE1_TXT ASC; -- vypíše všechny druhy útoků pouze jednou

                        
// 2.7 // Vypiš všechny útoky v Německu v roce 2015, vypiš sloupečky IYEAR, IMONTH, IDAY, COUNTRY_TXT, REGION_TXT, PROVSTATE, CITY, NKILL, NKILLTER, NWOUND. Ve sloupečku COUNTRY_TXT bude všude hodnota ‘Německo’

SELECT
    ATTACKTYPE1_TXT AS DRUH_UTOKU
    , DATE_FROM_PARTS (IYEAR, IMONTH, IDAY) AS DATUM
    , ADDNOTES AS POZNAMKY
    , COUNTRY_TXT AS ZEME  
    , REGION_TXT AS REGION
    , PROVSTATE
    , CITY AS MESTO
    , NKILL AS POCET_ZABITYCH
    , NKILLTER AS POCET_ZABITYCH_TERORISTU
    , NWOUND AS POCET_ZRANENYCH
FROM TEROR
WHERE COUNTRY_TXT = 'Germany' AND IYEAR = '2015'
ORDER BY DATUM;
    

// 2.8 // Kolik událostí se stalo ve třetím a čtvrtém měsíci a počet mrtvých teroristů není NULL?
;
SELECT 
    DATE_FROM_PARTS (IYEAR, IMONTH, IDAY) AS DATUM
    , NKILLTER AS POCET_ZABITYCH_TERORISTU    
    , *
FROM TEROR
WHERE (IMONTH = '03' OR IMONTH = '04') AND NKILLTER IS NOT NULL
ORDER BY DATUM;
                    
// 2.9 // Vypiš první 3 města seřazena abecedně kde bylo zabito 30 až 100 teroristů nebo zabito 500 až 1000 lidí. Vypiš i sloupečky nkillter a nkill.;
;
SELECT
    CITY AS MESTO
    , NKILLTER AS POCET_MRTVYCH_TERORISTU
    , NKILL AS POCET_MRTVYCH
FROM TEROR
WHERE NKILLTER BETWEEN 30 AND 100
ORDER BY CITY ASC
LIMIT 3;

// 2.10 // Vypiš všechny útoky z roku 2014, ke kterým se přihlásil Islámský stát ('Islamic State of Iraq and the Levant (ISIL)').
/*
Vypiš sloupečky IYEAR, IMONTH, IDAY, GNAME, COUNTRY_TXT, REGION_TXT, PROVSTATE, CITY, NKILL, NKILLTER, NWOUND 
a na konec přidej sloupeček EventImpact, který bude obsahovat:

'Massacre' pro útoky s víc než 1000 obětí
'Bloodbath' pro útoky s 501 - 1000 obětmi
'Carnage' pro ůtoky s 251 - 500 obětmi
'Blodshed' pro útoky se 100 - 250 obětmi
'Slaugter' pro útoky s 1 - 100 obětmi
a ‘N/A’ pro všechny ostatní útoky.
*/
;
SELECT
    IYEAR AS ROK
    , IMONTH AS MESIC
    , IDAY AS DEN
    , GNAME AS ORGANIZACE
    , COUNTRY_TXT AS ZEME
    , REGION_TXT AS REGION
    , PROVSTATE
    , CITY AS MESTO
    , NKILL AS POCET_ZABITYCH
    , NKILLTER AS POCET_ZABITYCH_TERORISTU
    , NWOUND AS POCET_ZRANENYCH
    ,CASE -- case způsobí přidání nového žádku s poznámkami
        WHEN NKILL > 1000 THEN 'Massacre'
        WHEN NKILL > 500 THEN 'Bloodbath'
        WHEN NKILL > 250 THEN 'Carnage'
        WHEN NKILL > 100 THEN 'Blodshed'
        WHEN NKILL > 0 THEN 'Slaughter'
        ELSE 'N/A'
    END AS EVENT_IMPACT
FROM TEROR
WHERE ORGANIZACE = 'Islamic State of Iraq and the Levant (ISIL)' AND IYEAR = 2014
ORDER BY NKILL ASC;

                        
// 2.11 // Vypiš všechny útoky, které se staly v Německu, Rakousku, Švýcarsku, Francii a Itálii, s alespoň jednou mrtvou osobou. 
/*U Německa, Rakouska, Švýcarska nahraď region_txt za ‘DACH’, u zbytku nech původní region. Vypiš sloupečky IYEAR, IMONTH, IDAY, COUNTRY_TXT, REGION_TXT, PROVSTATE, CITY, NKILL, NKILLTER, NWOUND. Výstup seřaď podle počtu raněných sestupně.*/;

SELECT
     IYEAR AS ROK
    , IMONTH AS MESIC
    , IDAY AS DEN
    , CITY AS MESTO
    , REGION_TXT AS REGION
    , COUNTRY_TXT AS ZEME
    , PROVSTATE
    , NKILL AS POCET_ZABITYCH
    , NKILLTER AS POCET_ZABITYCH_TERORISTU
    , NWOUND AS POCET_ZRANENYCH
    , CASE
        WHEN COUNTRY_TXT IN ('Germany', 'Austria', 'Switzerland') THEN 'DACH'
        ELSE REGION_TXT
    END AS REGION_TXT
FROM TEROR
WHERE COUNTRY_TXT IN ('Germany', 'Austria', 'Switzerland', 'France', 'Italy') AND NKILL > 0
ORDER BY NWOUND DESC;

                        
--- 2.12 // Vypiš COUNTRY_TXT, CITY, NWOUND a 
--- přidej sloupeček vzdalenost_od_albertova obsahující vzdálenost místa útoku z pražské části Albertov v km 
--- a sloupeček kategorie obsahující ‘Blízko’ pro útoky bližší 2000 km a ‘Daleko’ pro ostatní. 
--- Vypiš jen útoky s víc než stovkou raněných a seřad je podle vzdálenosti od Albertova.
SELECT 
   COUNTRY_TXT
  ,CITY
  ,NWOUND
  ,HAVERSINE(50.0688111, 14.4243694, LATITUDE, LONGITUDE) VZDALENOST_OD_ALBERTOVA
  ,CASE
      WHEN HAVERSINE(50.0688111, 14.4243694, LATITUDE, LONGITUDE) < 2000 THEN 'Blízko'
      ELSE 'Daleko'
  END AS KATEGORIE
FROM TEROR
WHERE NWOUND > 100
ORDER BY VZDALENOST_OD_ALBERTOVA;
-------------------------------------------------------------------------------
ÚKOL Z LEKCE 3
-------------------------------------------------------------------------------

// 3.7 // Vypište celkový počet útoků podle druhu zbraně weaptype1_txt, počet mrtvých, mrtvých teroristů, průměrný počet mrtvých, průměrný počet mrtvých teroristů, kolik mrtvých obětí připadá na jednoho mrtvého teroristu a kolik zraněných...

*/
3_lekce.txt
Zobrazuje se 3_lekce.txt.