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

### pozn. Práce s `data.table`

``` r
require(KZ2018)
```

    ## Loading required package: KZ2018

    ## Loading required package: data.table

``` r
data(vstup)
```

1.  Filtorvání

``` r
vstup[UPOV_ID == 1]
```

1.  volba sloupců

``` r
vstup[, Q]
vstup[, Q*100]
```

1.  Tvorba nových proměnných

``` r
vstup[, R:=1000*(Q*60*60*24)/(A*1000000)]
```

1.  skupinové charakteristiky

``` r
vstup[, sum(R)]
vstup[, sum(R), by = .(UPOV_ID, year(DTM), month(DTM))]
```

### Práce s modelem Bilan

1.  vytvořte nový model, nahrajte data, nakalibrujte, výsledky uložte

2.  vytvořte funkci pro výpočet m-denních vod

3.  nakalibrujte model pomocí m-denních vod a výsledky porovnejte

``` r
require(bilan)
```

    ## Loading required package: bilan

    ## Loading required package: Rcpp

``` r
b = bil.new(type = 'd')
bil.set.values(b, vstup[UPOV_ID == 1])
```

    ## Warning in evalq((function (..., call. = TRUE, immediate. = FALSE, noBreaks. = FALSE, : Unknown variable 'UPOV_ID'. Omitted.

    ## Warning in evalq((function (..., call. = TRUE, immediate. = FALSE, noBreaks. = FALSE, : Unknown variable 'ETr'. Omitted.

    ## Warning in evalq((function (..., call. = TRUE, immediate. = FALSE, noBreaks. = FALSE, : Unknown variable 'ETa'. Omitted.

    ## Warning in evalq((function (..., call. = TRUE, immediate. = FALSE, noBreaks. = FALSE, : Unknown variable 'SC'. Omitted.

    ## Warning in evalq((function (..., call. = TRUE, immediate. = FALSE, noBreaks. = FALSE, : Unknown variable 'AWV2'. Omitted.

    ## Warning in evalq((function (..., call. = TRUE, immediate. = FALSE, noBreaks. = FALSE, : Unknown variable 'DBCN'. Omitted.

    ## Warning in evalq((function (..., call. = TRUE, immediate. = FALSE, noBreaks. = FALSE, : Unknown variable 'Q'. Omitted.

    ## Warning in evalq((function (..., call. = TRUE, immediate. = FALSE, noBreaks. = FALSE, : Unknown variable 'A'. Omitted.

``` r
bil.pet(b)
res = bil.optimize(b)
```

DO PROTOKOLU Z CV. 1
====================

> Kalibrace modelu Bilan

> Graf srážek, graf teploty

> Graf pozorovaného a modelovaného odtoku

``` r
res[, plot(DTM, RM, type = "l")]
```

    ## NULL

``` r
res[, lines(DTM, R, col = "red")]
```

![](README_files/figure-markdown_github/unnamed-chunk-8-1.png)

    ## NULL

> Graf `ET` a `ETa`

> Graf `SS` a `SC`

> Graf `SW` a `AWV2`

``` r
res[, plot(DTM, SW, type = "l")]
```

    ## NULL

``` r
vstup[UPOV_ID==1, lines(DTM, AWV2, col = "red")]
```

![](README_files/figure-markdown_github/unnamed-chunk-9-1.png)

    ## NULL
