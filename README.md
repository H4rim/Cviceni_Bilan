KZ2018
================

Celkové zadání
==============

> Pro vybraný útvar povrchových vod (UPOV) modelujte hydrologickou bilanci pomocí charakteristik odtoku (m-denní vody), posuďte vliv užívání vod na jejich odhad a modelujte dopad klimatické změny na charakteristiky odtoku (m-denní vody a ukazatele sucha).

Cvičení 1
=========

1.  nainstalujte balík `KZ2018` z <https://github.com/hanel/KZ2018>

``` r
devtools::install_github("hanel/KZ2018")
```

(je potřeba mít nainstalovaný balík `devtools`)

1.  stáhněte a nainstalujte model Bilan z <https://github.com/hanel/KZ2018/tree/master/bilan>

(pro windows je soubor s příponou zip)

1.  vytvořte nový model, nahrajte data, nakalibrujte, výsledky uložte

2.  vytvořte funkci pro výpočet m-denních vod

3.  nakalibrujte model pomocí m-denních vod a výsledky porovnejte
