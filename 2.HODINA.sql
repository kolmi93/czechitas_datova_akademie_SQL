-----------------------------------------------------------------------------------------
 LEKCE 2: Datové typy a jejich převody, Podmínky a základní operátory, Agregační funkce
-----------------------------------------------------------------------------------------




------------------------------------------------
DATOVÉ TYPY
------------------------------------------------
- datové typy specifikují, jaký druh dat se ukládá a jaké funkce lze vyvolat. Každé pole v databázi má přiřazený datový typ.
- odkaz na rozcestník datových typů ve Snowflaku: https://docs.snowflake.com/en/sql-reference/intro-summary-data-types.html

--> VARCHAR - řetězec libovolných znaků o různé délce
    - tento datový typ zachází se vším jako s textem, ale může obsahovat i číslice a speciální znaky
    - VARCHAR (defaultní a zároveň maximální velikost 16 777 216 bytů), STRING, TEXT, CHAR, CHARACTER, BINARY, VARBINARY
    - jejich spojením byste je pouze připojili za sebe, což byste očekávali od textu, nespojujte je plusem, ale znaky || nebo funkcí CONCAT
    - 'a' || 'b' --> 'ab'
    - '1' || '2' --> '12'
    - '1' || 'b' --> '1b'
    - odkaz na datový typ string v dokumentaci Snowflaku: https://docs.snowflake.com/en/sql-reference/data-types-text.html#data-types-for-text-strings
    - přehled funkcí pro tento datový typ v dokumentaci Snowflaku: https://docs.snowflake.com/en/sql-reference/functions-string.html

--> NUMBER - celá nebo desetinná čísla (desetinná čísla mají ve Snowflaku desetinnou TEČKU)
    - zafixované desetinné místo (Fixed-point numbers): NUMBER, DECIMAL, NUMERIC, INT, INTEGER, BIGINT, SMALLINT, TINYINT, BYTEINT
    - pohyblivé desetinné místo (Floating-point numbers): FLOAT, FLOAT4, FLOAT8, DOUBLE, DOUBLE PRECISION, REAL
    - Snowflake podporuje pro float také hodnoty 'NaN' (Not a Number), 'inf' (infinity/nekonečno), '-inf' (negative infinity/mínus nekonečno)
    - 1 + 2 --> 3
    - 1.1 + 2.2 --> 3.3
    - odkaz na datový typ numeric v dokumentaci Snowflaku: https://docs.snowflake.com/en/sql-reference/data-types-numeric.html

--> BOOLEAN - logický datový typ, nabývá jen dvou hodnot: True, nebo False
    - hodí se pro binární charakteristiky nebo status
    - přihlásil se někdo k útoku? - Ano/True, Ne/False
    - na boolean můžeme převést textové a numerické hodnoty použitím funkce CAST nebo TO_BOOLEAN
      - převod ze stringu na TRUE: 'true', 't', 'yes', 'y', 'on', '1'
      - převod ze stringu na FALSE: 'false', 'f', 'no', 'n', 'off', '0'
      - převod je case-insensitive (nerozlišuje malá a velká písmena), jakékoli jiné hodnoty stringu nebudou převedeny
      --------------------------------------------------------------------
      - převod čísla na FALSE: 0 (nula)
      - převod čísla na TRUE: jakákoli jiná nenulová číselná hodnota bude převedena na TRUE

--> DATE - hodnota datum(+čas)
    - tento datový typ obsahuje o datum a/nebo čas, což umožňuje používat kalkulace, které jsou relevatní k datumu/času
    - DATE, DATETIME, TIME, TIMESTAMP, TIMESTAMP_LTZ, TIMESTAMP_NTZ, TIMESTAMP_TZ
    - např. kolik dní uběhlo od útoku?
    - odkaz na datový typ DATE v dokumentaci Snowflaku: https://docs.snowflake.com/en/sql-reference/data-types-datetime.html
    - přehled funkcí pro tento datový typ v dokumentaci Snowflaku: https://docs.snowflake.com/en/sql-reference/functions-date-time.html

--> NULL - znamená chybějící hodnotu v poli
    - tento datový typ je vhodný pro zobrazení absence dat
    - prázdná buňka a NULL jsou rozdílné, vizuálně prázdná buňka může obsahovat prázdný string '' nebo whitespace 
        (mezera, nezlomitelná mezera, tabulátor, konec stránky, ...), což může být obtížné detekovat
    - agregační funkce zpravidla NULL ignorují (např. COUNT, SUM), pro detaily zkontrolujte dokumentaci vámi vybrané funkce
    - chování NULL ve Snowflaku shrnuto příspěvkem na Snowflake community: https://community.snowflake.com/s/article/NULL-handling-in-Snowflake
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DALŠÍ DATOVÉ TYPY

--> GEOSPATIAL - Snowflake nabízí podporu pro prostorová data jako jsou body, linie a plochy na Zemi (points, lines, and polygons)
    - odkaz na Snowflake dokumentaci o tomto datovém typu: https://docs.snowflake.com/en/sql-reference/data-types-geospatial.html

--> SEMI-STRUCTURED DATA TYPES - Snowflake podporuje semi-strukturované datové typy
    - VARIANT, OBJECT, ARRAY
    - použití například při importu dat ze souboru JSON, XML
    - odkaz na Snowflake dokumentaci o těchto datových typech: https://docs.snowflake.com/en/sql-reference/data-types-semistructured.html
*/

---------------------------------------------------------
-- CAST - PŘETYPOVÁNÍ DATOVÉHO TYPU
---------------------------------------------------------

SELECT
    *
FROM TEROR
LIMIT 100;


-- popise tabulku - datove typy
DESC TABLE TEROR; -- sloupec type


;SHOW COLUMNS IN TABLE TEROR; -- sloupec data_type





-- Přetypování datového typu, použijeme funkci CAST

-- SYNTAXE, dvě možné, dělají to samé:
-- CAST (který_sloupec AS cílový_datový_typ)
-- který_sloupec::cílový_datový_typ


SELECT
    CAST(IDATE AS VARCHAR),
    IDATE::VARCHAR
FROM TEROR




-- Přetypování datového typu - číslo

SELECT 1 as Cislo;

SELECT '1' as Text;  

SELECT CAST('1' AS INT);

SELECT CAST('tohle neni cislo' AS INT);


-- Jiný zápis pomocí dvou dvojteček (::)

SELECT '1'::INT;

SELECT 'tohle neni cislo'::INT;


-- Chceme desetinné číslo

SELECT '1'::FLOAT;
SELECT '1'::NUMBER(20,10);


-- Přetypování datového typu -  textovy řetězec

SELECT 1::VARCHAR ; -- STRING


-- Přetypování datového typu - datum

SELECT '2021-03-13'::DATE; -- YYYY-MM-DD defaultně

SELECT '13.3.2021'::DATE; -- neumí převést na datum

SELECT '13/3/2021'::DATE; -- neumí převést na datum

SELECT '3/13/2021'::DATE; -- tento druh zápisu pochopí MM-DD-YYYY


-- Cvičení: Z tabulky TEROR vyberte sloupec COUNTRY a přetypujte ho na textový řetězec.
-- Následně vyberte sloupec IDATE a přetypujte ho na textový řetězec.


SELECT 
    COUNTRY::VARCHAR
    , IDATE::VARCHAR
FROM TEROR
;

SELECT
    CAST(COUNTRY AS VARCHAR)
    , CAST(IDATE AS VARCHAR)
FROM TEROR


SELECT COUNTRY::VARCHAR, IDATE::VARCHAR
FROM TEROR
;


---------------------------------------------------------
-- PODMÍNKY: Zakladní operátory
---------------------------------------------------------


a = b
a is equal to b.


a <> b -- nerovná se - používat UNIVERZÁLNÍ
a != b -- může se použít, ale upřednostnit první variantu
a is not equal to b.
-- Oba operátory fungují stejně, <> je univerzálnější

a > b
a is greater than b.

a >= b
a is greater than or equal to b.

a < b
a is less than b.

a <= b
a is less than or equal to b.


-- Příklady TEXT

;
SELECT CITY, IYEAR, NKILL
FROM TEROR 
WHERE CITY = 'Prague'; --vybrat město, rok a počet zabitých, kdy město JE Praha


;
SELECT CITY, IYEAR, NKILL
FROM TEROR 
WHERE CITY <> 'Prague'; --vybrat město, rok a počet zabitých, kdy město NENÍ Praha

;
SELECT CITY, IYEAR, NKILL
FROM TEROR
WHERE CITY IS NULL
;

SELECT 'Podmínka splněna, součet sedí.'
WHERE 209256+24+426=209706
;-- podmínka, která má dvě strany.

SELECT 'Podmínka splněna, součet sedí.'
WHERE 9209256+24+426=209706
;-- v případě, že podmínka není splněna, objeví se "Query produced no results"

-- Příklady čísla

SELECT CITY, IYEAR, NKILL
FROM TEROR 
WHERE NKILL = 0;

SELECT CITY, IYEAR, NKILL
FROM TEROR 
WHERE NKILL < 1;

SELECT CITY, IYEAR, NKILL
FROM TEROR 
WHERE NKILL >= 50;


-- Testujeme podmínky za pomoci jednoduchého SELECTu

SELECT 'Podmínka platí'
WHERE 1=1
;

-- Otestujte, jestli '2' = 2
SELECT 'Podmínka platí'
WHERE '2'=2
;

-- Otestujte, jestli 1 + 4 - 2 / 2 je menší než 2 * 2
SELECT 'Podmínka platí'
WHERE ((1+4-2)/2) < (2*2) 
;

-- Otestujte, jestli 5 je menší nebo rovno 10
SELECT 'Podmínka platí'
WHERE 5<=10
;

-- Otestujte, jestli 500 (přecastováno na text) není rovno 10 (přecastováno na text)
SELECT 'Podmínka platí'
WHERE 500::VARCHAR <> 10::VARCHAR
;


-- UKOLY
// A Úkol 2.1  // Vyber z tabulky útoky, kde zemřel alespoň jeden TERORista (NKILLter).      
;
SELECT *
FROM TEROR
WHERE NKILLTER >=1
;

// B Úkol 2.2 // Zobraz jen sloupečky GNAME, COUNTRY_TXT, NKILL a všechny řádky (seřazené podle počtu mrtvých sestupně), na kterých je víc než 340 mrtvých (počet mrtvých je ve sloupci NKILL), sloupečky přejmenuj na ORGANIZACE, ZEME, POCET_MRTVYCH.
;
SELECT 
    GNAME AS ORGANIZACE
    , COUNTRY_TXT AS ZEME
    , NKILL AS POCET_MRTVYCH
FROM TEROR
WHERE NKILL>340
ORDER BY NKILL DESC 
; -- do části WHERE a ORDER BY  je možné po přejmenování používat přejmenované názvy a ne NKILL

--A
SELECT *
FROM TEROR
WHERE NKILLTER > 0
;

--B
SELECT
    GNAME AS ORGANIZACE
  , COUNTRY_TXT AS ZEME
  , NKILL AS POCET_MRTVYCH
FROM TEROR
WHERE NKILL > 340
ORDER BY POCET_MRTVYCH DESC
;

---------------------------------------------------------
-- Porovnáváme více hodnot - čísla a textové řetězce
;
IYEAR = 2018
YEAR IN (2016, 2017, 2018)
;

IYEAR <> 2018
IYEAR NOT IN (2016, 2017, 2018)
;

 IYEAR IN (2016, 2017, 2018)
 CITY IN ('Prague', 'Brno', 'Bratislava')
 ;

-- Úkol: Vyberte sloupce IYEAR a EVENTID z tabulky TEROR pro záznamy, které se staly v letech 1990, 1998 a 1999.


SELECT IYEAR, EVENTID
FROM TEROR
WHERE IYEAR IN (1990,1998,1999)
;








SELECT IYEAR, EVENTID
FROM TEROR
WHERE IYEAR IN (1990, 1998, 1999)


---------------------------------------------------------
-- AND, OR a závorky
---------------------------------------------------------
;
SELECT 'Podmínka platí'
WHERE 1=5 AND 2=2
;

SELECT 'Podmínka platí'
WHERE 1=5 OR 2=2
;

-- Doplň podmínku: Obojí je pravda: 5 je menší nebo rovno 6 a 3*10 je 30.
SELECT 'Podmínka platí'
WHERE 5<=6 AND 3*10=30; -- moje

SELECT 'Podmínka platí'
WHERE 5 <= 6 AND 3*10 = 30
;

-- Doplň podmínku: Buď platí, že  5 je menší než 4 nebo platí, že je 5 větší než 5. (Nebo platí obojí.)
SELECT 'Podmínka platí'
WHERE 5<4 OR 5>5; -- moje

SELECT 'Podmínka platí'
WHERE 5<4 OR 5>5
;

-- Úkol: Vyber z tabulky TEROR útoky v Německu (Germany), kde zemřel alespoň jeden TERORista (NKILLter).  

SELECT *
FROM TEROR
WHERE COUNTRY_TXT = 'Germany' AND NKILLTER >= 1;-- moje

SELECT *
FROM TEROR
WHERE  NKILLTER > 0
       AND COUNTRY_TXT = 'Germany'
;

-- Pojďme se podívat na závorky:

SELECT COUNTRY_TXT, CITY
FROM TEROR
WHERE COUNTRY_TXT = 'India' AND (CITY='Delina' OR CITY='Bara'); -- zěmě je Indie a jedná se o města v Indii Delina nebo Bara

SELECT COUNTRY_TXT, CITY
FROM TEROR
WHERE COUNTRY_TXT = 'India' AND CITY='Prague' OR CITY='Bara'; -- v Indii není žádná Praha a vypíšou se Báry z celého světa

SELECT COUNTRY_TXT, CITY   
FROM TEROR 
WHERE COUNTRY_TXT = 'India' AND CITY='Bara' OR CITY='Delina'; -- ukáže Baru z Indie anebo Delinu z celého světa

SELECT COUNTRY_TXT, CITY
FROM TEROR
WHERE COUNTRY_TXT = 'India' AND (CITY='Delina' OR CITY='Bara');



---------------------------------------------------------
-- AGREGAČNÍ FUNKCE
---------------------------------------------------------

---------------------------------------------------------                        
-- COUNT() - počet
---------------------------------------------------------                        

SELECT 
    COUNT(*) -- as pocet
FROM TEROR;

SELECT 
    COUNT(EVENTID)
FROM TEROR;

SELECT COUNT (CITY)
FROM TEROR;

-- COUNT(DISTINCT x)

SELECT 
    COUNT(DISTINCT COUNTRY_TXT)
FROM TEROR; -- ve sloupci city je 204 záznamů

---------------------------------------------------------                        
-- SUM() - součet
---------------------------------------------------------

SELECT 
    SUM(NKILL) AS pocet_mrtvych
FROM TEROR; --sečte všechna čísla ve sloupi pocet_mrtvych

---------------------------------------------------------                        
-- AVG() - průměr
---------------------------------------------------------  

SELECT 
    AVG(NKILL) AS prumerny_pocet_mrtvych 
FROM TEROR; -- spočítá průměrný počet zabitých v Teroru (nezahrnuje Nully)

---------------------------------------------------------                        
-- MAX() - maximální hodnota
---------------------------------------------------------                         

-- vrati jedno cislo
SELECT 
    MAX(NKILL) AS max_pocet_mrtvych
FROM TEROR; -- najde v NKill nejvyšší hodnotu


-- chci vrátit cely řadek záznamů -- stejný vysledek jinou cestou
SELECT 
    NKILL AS max_pocet_mrtvych
    , *
FROM TEROR 
WHERE NKILL IS NOT NULL 
ORDER BY NKILL DESC 
LIMIT 1; 

---------------------------------------------------------                        
-- MIN() - minimální hodnota
---------------------------------------------------------                         
                          
SELECT 
    MIN(NKILL) AS min_pocet_mrtvych
FROM TEROR
WHERE COUNTRY_TXT = 'Germany';-- najde v NKill nejvyšší hodnotu


-- Cvičení: Napiš dotaz, který vrátí z Tabulky TEROR:
  -- Počet různých měst ve sloupci CITY
  -- Minimální (nejmenší) datum ve sloupci IDATE
  -- Maximální počet mrtvých teroristů na jeden útok ve sloupci NKILLTER
  -- Průměrný počet zraněných na útok ze sloupce NWOUND
  -- Celkový počet zabitých osob v tabulce - sloupec NKILL
;
SELECT
    COUNT (DISTINCT CITY) -- COUNT (DISTINCT) vybere název města jen jednou, tzn. pokud tam bude Praha 10x, vezme ji v potaz jen jednou. Pokud bych chtěla sečíst kolikrát se tam Praha objevuje celkově, použije se jen COUNT
    , MIN (IDATE) AS MIN_DATUM_UTOKU
    , MAX (NKILLTER) AS MAX_POCET_ZABITYCH_TERORISTU
    , AVG (NWOUND) AS PRUMERNY_POCET_ZRANENYCH
    , COUNT (NKILL) AS CELKOY_POCET_ZABITYCH
FROM TEROR; -- moje

SELECT
      COUNT(DISTINCT CITY)
    , MIN(IDATE)
    , MAX(NKILLTER)
    , AVG(NWOUND)
    , SUM(NKILL)
FROM TEROR
;

---------------------------------------------------------                        
-- GROUP BY - vytváření skupin
---------------------------------------------------------                         
SELECT DISTINCT COUNTRY_TXT
FROM TEROR; -- moje

-- Seznam všech zemí
SELECT DISTINCT COUNTRY_TXT
FROM TEROR
;

-- Všechny záznamy rozskupinkovány dle zemí
SELECT COUNTRY_TXT
FROM TEROR
GROUP BY COUNTRY_TXT; --na tom to není vidět, ale vše je rozskupinkováno podle zemí

SELECT COUNTRY_TXT
FROM TEROR
GROUP BY COUNTRY_TXT
;

-- Kolik je záznamů v každé skupině?
SELECT COUNTRY_TXT, COUNT (*)
FROM TEROR
GROUP BY COUNTRY_TXT; --kolik je v jednotlivých zemích záznamů

SELECT COUNTRY_TXT, COUNT(*)
FROM TEROR
GROUP BY COUNTRY_TXT
;

-- Cvičení: Vypiš všechny regiony (REGION_TXT) a spočítej, kolik bylo v každém regionu útoků.
SELECT 
    REGION_TXT AS REGION
    ,COUNT (*) AS POCET
FROM TEROR
GROUP BY REGION_TXT; -- moje

SELECT REGION_TXT, COUNT(*)
FROM TEROR
GROUP BY REGION_TXT
;

SELECT
    COUNTRY_TXT AS ZEME -- vypíše zemi jako první sloupec
    , COUNT(DISTINCT CITY) AS POCET_RUZNYCH_MEST -- Počet různých měst ve sloupci CITY
    , MIN(IDATE) AS NEJMENSI_DATUM -- Minimální (nejmenší) datum ve sloupci IDATE
    , MAX(NKILLTER) AS MAX_MRTVYCH_TERORISTU_NA_UTOK -- Maximální počet mrtvých teroristů na jeden útok ve sloupci NKILLTER
    , AVG(NWOUND) AS PRUMER_POCET_ZRANENYCH -- Průměrný počet zraněných na útok ze sloupce NWOUND
    , SUM(NKILL) AS CELKEM_MRTVI -- Celkový počet zabitých osob v tabulce - sloupec NKILL
FROM TEROR
GROUP BY COUNTRY_TXT; -- rozdělí tabulku podle zemí;


SELECT ATTACKTYPE1_TXT AS DRUH_UTOKU, COUNTRY_TXT AS ZEME, COUNT (*) AS POCET
FROM TEROR
GROUP BY ATTACKTYPE1_TXT, COUNTRY_TXT; -- vezme všechny typy útoků a země a počet.Jsou zde kombinace, které mají více jak jeden útok

SELECT *
FROM TEROR
WHERE ATTACKTYPE1_TXT = 'Hostage Taking (Barricade Incident)' AND COUNTRY_TXT = 'Burkina Faso'
GROUP BY ATTACKTYPE1_TXT, COUNTRY_TXT; -- NEFUNGUJE, NEVÍM PROČ  

SELECT COUNTRY_TXT, COUNT (*)
FROM TEROR; -- nefunguje, protože chybí GROUP BY - není co agregovat

-- Počet zabitych dle GNAME (TERORisticke organizace)

SELECT GNAME, -- skupina
       SUM(NKILL) -- agregace
FROM TEROR
GROUP BY GNAME;

-- podle GNAME a COUNTRY_TXT

SELECT GNAME, -- skupina
       COUNTRY_TXT, -- skupina 
       SUM(NKILL), -- agregace
       COUNT(NKILL) -- agregace
FROM TEROR
GROUP BY GNAME, COUNTRY_TXT;


-- UKOLY KODIM.CZ ----------------------------------------------------------

// A // Zjisti počet obětí a raněných po letech a měsících 
;
SELECT 
    IYEAR AS ROK
    , IMONTH AS MESIC
    , COUNT (NWOUND) AS POCET_ZRANENYCH
    , COUNT (NKILL) AS POCET_ZABITYCH
FROM TEROR
GROUP BY IYEAR, IMONTH;

// B // Zjisti počet obětí a raněných v západní Evropě po letech a měsících

SELECT 
    IYEAR AS ROK
    , IMONTH AS MESIC
    , COUNT (NWOUND) AS POCET_ZRANENYCH
    , COUNT (NKILL) AS POCET_ZABITYCH
FROM TEROR
WHERE REGION_TXT = 'Western Europe'
GROUP BY IYEAR, IMONTH;

// C // Zjisti počet útoků po zemích. Seřaď je podle počtu útoků sestupně
;
SELECT 
    COUNTRY_TXT AS ZEME
    , COUNT (*) AS POCET_UTOKU
FROM TEROR
GROUP BY ZEME
ORDER BY  POCET_UTOKU DESC;

// D // Zjisti počet útoků po zemích a letech, seřaď je podle počtu útoků sestupně

SELECT 
    COUNTRY_TXT AS ZEME
    , IYEAR AS ROK
    , COUNT (*) AS POCET_UTOKU   
FROM TEROR
GROUP BY ZEME, ROK
ORDER BY  POCET_UTOKU DESC;

// E // Kolik která organizace spáchala útoků zápalnými zbraněmi (weaptype1_txt = 'Incendiary'), 
    --  kolik při nich celkem zabila obětí, kolik zemřelo TERORistů a kolik lidí bylo zraněno (NKILL, NKILLter, nwound)

;
SELECT
    GNAME AS ORGANIZACE
    , SUM (NKILL) AS POCET_OBETI
    , SUM (NKILLTER) AS POCET_ZABITYCH_TERORISTU
    , COUNT (NWOUND) AS POCET_ZRANENYCH
FROM TEROR
WHERE weaptype1_txt = 'Incendiary'
GROUP BY GNAME;



--A
SELECT IYEAR -- vybíráme rok události
    , IMONTH -- vybíráme měsíc události
    , SUM(NKILL) AS KILLED -- sčítáme počet mrtvých (NKILL) a odečítáme z toho počet mrtvých teroristů (NKILLTER), celkový součet označujeme jako "KILLED" viz dokumentace datasetu... NKILL obsahuje i mrtve teroristy, tezko rict, jestli mrtvi teroristi obeti
    , SUM(NWOUND) AS WOUNDED -- sčítáme počet zraněných a celkový součet označujeme jako "WOUNDED"
FROM TEROR -- vybíráme data z tabulky TEROR
GROUP BY IYEAR, IMONTH -- seskupujeme podle roku a měsíce
ORDER BY IYEAR, IMONTH; -- řadíme výsledky vzestupně podle roku a měsíce

--B
SELECT IYEAR
    , IMONTH
    , SUM(NKILL) AS KILLED
    , SUM(NWOUND) AS WOUNDED
FROM TEROR
WHERE REGION_TXT = 'Western Europe'
GROUP BY IYEAR, IMONTH
ORDER BY IYEAR, IMONTH;

--C
-- Vrací počet útoků pro každou zemi z tabulky TEROR
SELECT COUNTRY_TXT,
    COUNT(*)
FROM TEROR
GROUP BY 1
ORDER BY COUNT(*) DESC;

--D
SELECT COUNTRY_TXT,
    IYEAR,
    COUNT(*)
FROM TEROR
GROUP BY COUNTRY_TXT,
    IYEAR
ORDER BY COUNT(*) DESC;

--E
SELECT GNAME,
    COUNT(EVENTID),
    -- celkový počet útoků
    SUM(NKILL),
    -- součet všech mrtvých
    SUM(NKILLTER),
    -- součet mrtvých teroristů
    SUM(NWOUND) -- počet raněných
FROM TEROR -- Výběr útoků s použitím zápalných zbraní (weaptype1_txt = 'Incendiary')
WHERE WEAPTYPE1_TXT = 'Incendiary' -- Seskupení výsledků podle názvu organizace
GROUP BY GNAME;

------------------------------------------------------------------------------
---------------------------------------------------------                        
-- HAVING - možnost zapsat podmínky ke skupinám (GROUP BY)
---------------------------------------------------------                         

-- SQL query pořadí:

SELECT
FROM
WHERE
GROUP BY
HAVING -- filtr na skupiny - chci pouze města, kde bylo pouze 10 útoků nebo kde je více než 100 mrtvích
ORDER BY
LIMIT


--- pocet mrtvych podle TERORisticke organizace kde je pocet obeti vetsi nez nula
;
SELECT 
      GNAME
    , SUM(NKILL) AS pocet_mrtvych 
FROM TEROR 
GROUP BY GNAME 
HAVING SUM(NKILL) > 0 
ORDER BY pocet_mrtvych DESC; 

--- pocet mrtvych podle TERORisticke organizace kde je pocet obeti a pocet mrtvych TERORistu vetsi nez nula
SELECT 
    GNAME
    , SUM(NKILL) AS pocet_mrtvych
    , SUM(NKILLter) AS pocet_mrtvych_TERORistu 
FROM TEROR 
GROUP BY GNAME 
HAVING SUM(NKILL) > 0 
   AND SUM(NKILLter) >= 1 
ORDER BY SUM(NKILL) DESC; 

-- UKOL KODIM.CZ ----------------------------------------------------------

// F // Stejné jako E, jen ve výsledném výpisu chceme jen organizace, které zápalnými útoky zabily 10 a více lidí.

-------------------------------------------------------------------------------

SELECT
    GNAME AS ORGANIZACE
    , SUM (NKILL) AS POCET_OBETI
    , SUM (NKILLTER) AS POCET_ZABITYCH_TERORISTU
    , COUNT (NWOUND) AS POCET_ZRANENYCH
FROM TEROR
WHERE weaptype1_txt = 'Incendiary'
GROUP BY GNAME
HAVING SUM(NKILL) >=10
ORDER BY SUM(NKILL) DESC;

--F
SELECT GNAME,
    COUNT(EVENTID) AS UTOKU,
    SUM(NKILL) AS MRTVI,
    SUM(NKILLTER) AS MRTVYCH_TERORISTU,
    SUM(NWOUND) AS RANENYCH
FROM TEROR
WHERE WEAPTYPE1_TXT = 'Incendiary'
GROUP BY GNAME
HAVING SUM(NKILL) > 10;

 