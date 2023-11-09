--- ÚKOL Č. 1: Vypište vývoj po dnech (použijte pole IDAY, IMONTH, IYEAR a funkci DATE_FROM_PARTS) v roce 2015 v zemích Iraq, Nigeria a Syria. Tabulka by měla obsahovat stát, počet útoků (EVENTID), počet zabitých obětí (rozdíl NKILL a NKILLTER), počet zabitých teroristů a počet zraněných na daný den a danou zemi. Výsledek omezte pouze na dny, kdy bylo v dané zemi provedeno alespoň 10 útoků a počet obětí byl nejméně 8 (rozdíl NKILL a NKILLTER). Sloupečky rozumně přejmenujte (alias – AS), aby bylo poznat, jaká informace se v daném sloupečku nachází. Výsledek seřaďte podle země abecedně (A-Z) a zároveň vzestupně dle datumu.
--- Pozn. správnost výpočtu si ověř třeba na počtech ze Sýrie.
SELECT
    DATE_FROM_PARTS(IYEAR, IMONTH, IDAY) AS DATUM
    , COUNTRY_TXT AS ZEME
    , COUNT(EVENTID) AS POCET_UTOKU   
    , SUM(NKILL)- SUM(NKILLTER) AS POCET_ZABITYCH_OBETI
    , SUM(NKILLTER) AS POCET_ZABITYCH_TERORISTU
    , SUM(NWOUND) AS POCET_ZRANENYCH
FROM TEROR
WHERE IYEAR = 2015
    AND ZEME IN ('Iraq','Nigeria','Syria')
GROUP BY ZEME, DATUM
HAVING POCET_UTOKU >= 10 
    AND POCET_ZABITYCH_OBETI >= 8
ORDER BY ZEME ASC, DATUM ASC;

--- ÚKOL Č. 2: Vypočítejte vzdálenost útoků od Prahy (latitude = 50.0755, longitude = 14.4378) a tuto hodnotu kategorizujte a spočítejte počet útoků (EVENTID) a počet obětí (rozdíl NKILL a NKILLTER). 
--- Kategorie: '0-99 km', '100-499 km', '500-999 km', '1000+ km', 'exact location unknown'. Berte v úvahu pouze roky 2014 a 2015. Seřaďte sestupně dle počtu útoků. Při kategorizaci dejte pozor, abyste skutečně pokryly všechny vzdálenosti a nestalo se vám, že na přelomu kategorií vám bude chybět jeden kilometr (nebo 1 metr 😊), např. hodnota 499,5 má spadat do kategorie '100-499 km' - je nežádoucí, aby spadla do 'exact location unknown'.
SELECT
    CASE
        WHEN HAVERSINE(50.0833472, 14.4252625, LATITUDE, LONGITUDE) >= 1000  THEN '1000+ km'
        WHEN HAVERSINE(50.0833472, 14.4252625, LATITUDE, LONGITUDE) >= 500 THEN '500-999 km'
        WHEN HAVERSINE(50.0833472, 14.4252625, LATITUDE, LONGITUDE) >= 100 THEN '100-499 km'
        WHEN HAVERSINE(50.0833472, 14.4252625, LATITUDE, LONGITUDE) >= 0 THEN '0-99 km'
        ELSE 'exact location unknown'
    END AS VZDALENOST_OD_PRAHY
    , COUNT(EVENTID) AS POCET_UTOKU    
    , SUM(NKILL)- SUM(NKILLTER) AS POCET_ZABITYCH_OBETI
FROM TEROR
WHERE IYEAR BETWEEN 2014 AND 2015
GROUP BY VZDALENOST_OD_PRAHY
ORDER BY POCET_UTOKU DESC
;

--- ÚKOL Č. 3: Zobrazte 15 útoků s největším počtem mrtvých (NKILL) ze zemí Iraq, Afghanistan, Pakistan, Nigeria. Z výsledku odfiltrujte targtype1_txt ‘Private Citizens & Property’, pro gname ‘Taliban’ tato výjimka neplatí (u této skupiny vypište i útoky s targtype1_txt ‘Private Citizens & Property’). Vypište pouze sloupečky eventid, iyear, country_txt, city, attacktype1_txt, targtype1_txt, gname, weaptype1_txt, nkill. Vyřešte bez použití UNION.
--- odfiltruj znamená nechat to projet přes WHERE
SELECT
    EVENTID AS UDALOST
    , IYEAR AS ROK
    , COUNTRY_TXT AS ZEME
    , CITY AS MESTO
    , ATTACKTYPE1_TXT AS DRUH_UTOKU
    , TARGTYPE1_TXT AS CIL_UTOKU
    , GNAME AS NAZEV_ORGANIZACE
    , WEAPTYPE1_TXT AS DRUH_ZBRANE
    , NKILL AS POCET_MRTVYCH
FROM TEROR
WHERE ZEME IN ('Iraq', 'Afghanistan', 'Pakistan', 'Nigeria') AND (TARGTYPE1_TXT <> 'Private Citizens & Property' OR NAZEV_ORGANIZACE = 'Taliban')
ORDER BY NKILL DESC NULLS LAST
LIMIT 15;