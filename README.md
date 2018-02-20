KZ2018
================

Celkové zadání
==============

> Pro vybraný útvar povrchových vod (UPOV) modelujte hydrologickou bilanci pomocí charakteristik odtoku (m-denní vody), posuďte vliv užívání vod na jejich odhad a modelujte dopad klimatické změny na charakteristiky odtoku (m-denní vody a ukazatele sucha).

Cvičení 1
=========

**1)** nainstalujte balík `KZ2018` z <https://github.com/hanel/KZ2018>

``` r
devtools::install_github("hanel/KZ2018")
```

(je potřeba mít nainstalovaný balík `devtools`)

**2)** stáhněte a nainstalujte model Bilan z <https://github.com/hanel/KZ2018/tree/master/bilan> (pro windows je soubor s příponou zip)

### pozn. Práce s `data.table`

``` r
require(KZ2018)
```

    ## Loading required package: KZ2018

    ## Loading required package: data.table

``` r
data(vstup)
```

*a)* Filtorvání

``` r
vstup[UPOV_ID == 1]
```

*b)* volba sloupců

``` r
vstup[, Q]
vstup[, Q*100]
```

*c)* Tvorba nových proměnných

``` r
vstup[, R:=1000*(Q*60*60*24)/(A*1000000)]
```

*d)* skupinové charakteristiky

``` r
vstup[, sum(R)]
vstup[, sum(R), by = .(UPOV_ID, year(DTM), month(DTM))]
```

### Práce s modelem Bilan

*3)* vytvořte nový model, nahrajte data, nakalibrujte, výsledky uložte

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

    ## NULL

![](README_files/figure-markdown_github/unnamed-chunk-8-1.png)

    ## NULL

> Graf `ET` a `ETa`

> Graf `SS` a `SC`

> Graf `SW` a `AWV2`

    ## NULL

![](README_files/figure-markdown_github/unnamed-chunk-9-1.png)

    ## NULL

------------------------------------------------------------------------

Cvičení 2
=========

1.  Porovnejte pozorovaný a modelovaný odtok pomocí několika způsobů:

    1.  graficky - graf distribučních funkcí/m-denních vod, korelační graf, QQ plot
    2.  pomocí ukazatelů shody (RMSE, MSE, NSE, KGE, apod. - využijte balík `hydroGOF`)
    3.  vyhodnoťe chybu (relativní/absolutní) v základních charakteristikých polohy, variability a m-denních vodách
    4.  vytvořte funkci pro vyčíslení mezi pozorovaným a modelovaným odtokem

2.  Vytvořte funkci, která bude sumarizovat vybrané výše uvedené body pomocí vhodně navrženého layoutu

3.  Nakalibrujte model Bilan pomocí charakteristik (modifikace `"critvars"`)

    1.  experimentujte se zahrnutými mírami polohy, variability, m-denními vodami apod.
    2.  porovnejte se standardní kalibrací
    3.  pomocí jakých charakteristik lze nakalibrovat model Bilan co nejblíže pozorované/modelované řadě?

------------------------------------------------------------------------

-   nakalibrujeme Bilan standardním způsobem

``` r
require(KZ2018)
data(vstup)
vstup[, R:=1000*(Q*60*60*24)/(A*1000000)]
require(bilan)
b = bil.new(type = 'd')
bil.set.values(b, vstup[UPOV_ID == 1])
bil.pet(b)
res = bil.optimize(b)
```

-   grafické porovnání

-   porovnání pomocí `hydroGOF`

``` r
require(hydroGOF)
```

|    ME|   MAE|   MSE|  RMSE|  NRMSE %|  PBIAS %|   RSR|  rSD|   NSE|  mNSE|  rNSE|     d|    md|    rd|     cp|     r|    R2|   bR2|   KGE|    VE|
|-----:|-----:|-----:|-----:|--------:|--------:|-----:|----:|-----:|-----:|-----:|-----:|-----:|-----:|------:|-----:|-----:|-----:|-----:|-----:|
|  0.06|  0.25|  0.21|  0.46|       81|     14.9|  0.81|  1.2|  0.34|  0.12|  0.35|  0.85|  0.65|  0.85|  -2.74|  0.75|  0.56|  0.54|  0.65|  0.39|

``` r
## res[, gof(RM, R)]
```
