Cvičení Bilan
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
b = bil.new(type = 'd')
bil.set.values(b, vstup[UPOV_ID == 1])
bil.pet(b)
res = bil.optimize(b)
```

DO PROTOKOLU Z CV. 1
====================

> Kalibrace modelu Bilan

> Graf srážek, graf teploty

> Graf pozorovaného a modelovaného odtoku

    ## NULL

![](README_files/figure-markdown_github/unnamed-chunk-9-1.png)

    ## NULL

> Graf `ET` a `ETa`

> Graf `SS` a `SC`

> Graf `SW` a `AWV2`

    ## NULL

![](README_files/figure-markdown_github/unnamed-chunk-10-1.png)

    ## NULL

------------------------------------------------------------------------

Cvičení 2
=========

1.  Porovnejte pozorovaný a modelovaný odtok pomocí několika způsobů:

    1.  graficky - graf distribučních funkcí/m-denních vod, korelační graf, QQ plot
    2.  pomocí ukazatelů shody (RMSE, MSE, NSE, KGE, apod. - využijte balík `hydroGOF`)
    3.  vyhodnoťe chybu (relativní/absolutní) v základních charakteristikých polohy, variability a m-denních vodách
    4.  vytvořte funkci pro vyčíslení rozdílů mezi pozorovaným a modelovaným odtokem

2.  Vytvořte funkci, která bude sumarizovat vybrané výše uvedené body pomocí vhodně navrženého layoutu

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

Cvičení 3
=========

Nakalibrujte model Bilan pomocí charakteristik (modifikace `"critvars"`)

    a) experimentujte se zahrnutými mírami polohy, variability, m-denními vodami apod.
    b) porovnejte se standardní kalibrací
    c) pomocí jakých charakteristik lze nakalibrovat model Bilan co nejblíže pozorované/modelované řadě?

Různá nastavení kalibrace
-------------------------

### Standardní kalibrace pomocí diferenciální evoluce

``` r
library(KZ2018)
library(bilan)

data("vstup")

b = bil.new(type = 'd')  # vytvor novy model
bil.set.values(b, input_vars = vstup[UPOV_ID == 1 & year(DTM) %in% c(2005:2006)]) # vloz do modelu data
bil.pet(b) # spocti potencialni evapotranspiraci

bil.set.optim(b, method = 'DE', init_GS = 0.1) # nasta optimalizacni metodu na difirencialni evoluci (DE) a nastav pocatecni zasobu podzemni vody na 0 
res = bil.optimize(b) # optimalizuj

porovnej(res, plot = TRUE) # porovnej R a RM
```

![](README_files/figure-markdown_github/unnamed-chunk-13-1.png)

    ##      ME    RMSE PBIAS %     NSE     KGE 
    ##   -0.04    0.63   -5.60    0.78    0.85

### Kalibrace na průměr

``` r
b1 = bil.new(type = 'd', modif = 'critvars')
bil.set.values(b1, input_vars = vstup[UPOV_ID == 1 & year(DTM) %in% c(2001:2002)])
bil.pet(b1)
bil.set.optim(b1, method = 'DE', init_GS = 0.1)

bil.set.critvars(b1, obs_vars = c('R'), mod_vars = c('RM'), crit = c("mean"), weights = c(1) ) # nastav kalibraci na kriteria 

res1 = bil.optimize(b1)
porovnej(res1)
```

![](README_files/figure-markdown_github/unnamed-chunk-14-1.png)

    ##      ME    RMSE PBIAS %     NSE     KGE 
    ##    0.00    0.32    0.00   -1.12    0.14

`bil.set.critvars` nastavuje parametry optimalizace pomocí charakteristik průtoku

-   `obs_vars` - název proměnné, která je pozorovaná - zpravidla pozorovaný odtok `R`
-   `obs_vars` - název proměnné, která je simulovaná - zpravidla simulovaný odtok `RM`
-   `crit` - pomocí jaké charakteristiky se kalibruje (možno `mean`, `sd`, `range` nebo `custom`)
-   `weights`- v případě zadání více kritérií specifikuje váhy, které se mají kritériím přiřadit

### Kalibrace na průměr a směrodatnou odchylku

``` r
b1 = bil.new(type = 'd', modif = 'critvars')
bil.set.values(b1, input_vars = vstup[UPOV_ID == 1 & year(DTM) %in% c(2001:2002)])
bil.pet(b1)

bil.set.optim(b1, method = "DE", init_GS = 0.1)
bil.set.critvars(b1, obs_vars = c('R', 'R'), mod_vars = c('RM', 'RM'), crit = c("mean", 'sd'), weights = c(1, 1) )

res1 = bil.optimize(b1)
porovnej(res1)
```

![](README_files/figure-markdown_github/unnamed-chunk-15-1.png)

    ##      ME    RMSE PBIAS %     NSE     KGE 
    ##    0.00    0.38    0.00   -0.04    0.48

### Kalibrace na m-denní vody

``` r
obs_mdr = mdr(res)$mR

err_mdr = function(x){
  m = c(30, 60, 90, 180, 270, 300, 330, 360, 365)
  pcp = m/365.25
  p = 1-pcp
  qx = quantile(x, p)  
  return(mean(abs(obs_mdr - qx)))
}

bil.set.optim(b1, method = "DE", init_GS = 0.1)
bil.set.critvars(b1, obs_vars = c('R'), mod_vars = c('RM'), crit = c('custom'), weights = c(1), funs = c(err_mdr), obs_values = 0)

res1 = bil.optimize(b1)
porovnej(res1)
```

![](README_files/figure-markdown_github/unnamed-chunk-16-1.png)

    ##      ME    RMSE PBIAS %     NSE     KGE 
    ##   -0.28    1.80  -38.20    0.08   -0.10

nastavení `crit = "custom"` umožňuje specifikovat jakoukoliv funkci - zde funkci, která počítá průměr rozdílů mezi pozorovanými a simulovanými m-denními vodami. Parametr `obs_values` je zde nastaven na `0` - jelikož cílem optimalizace je, aby průměrný rozíl byl co nejblíže nule. Je evidentní, že je nezbytné přidat nějakou další charakteristiku odtoku.

### Kalibrace pomocí m-denních vod a dalších charakteristik

``` r
err_mdr = function(x){
  m = c(30, 60, 90, 180, 270, 300, 330, 360, 365)
  pcp = m/365.25
  p = 1-pcp
  qx = quantile(x, p)  
  return(mean(abs(qx/obs_mdr-1)))
}

bil.set.critvars(b1, obs_vars = c('R', 'R', "R"), mod_vars = c('RM', 'RM', "RM"), crit = c('custom', 'custom', "range"), weights = c(5,1, 1), funs = c(err_mdr, IQR, NA), obs_values = c(0, IQR(res1$RM), NA) )

bil.set.optim(b1, method = 'DE', init_GS = 0.1)
res1 = bil.optimize(b1)
porovnej(res1)
```

![](README_files/figure-markdown_github/unnamed-chunk-17-1.png)

    ##      ME    RMSE PBIAS %     NSE     KGE 
    ##   -0.12    0.64  -21.00    0.21    0.27

``` r
err_mdr(res1$RM)
```

    ## [1] 0.1768139

``` r
IQR(res1$R)
```

    ## [1] 0.4164517

``` r
IQR(res1$RM)
```

    ## [1] 0.451454

Parametrická nejistota
----------------------

Při opakované kalibraci můžeme dospět k různým výsledkům. Abychom tuto skutečnost postihli, kalibrujeme víckrát.

### Pro standardní kalibraci

``` r
.i = 10


b = bil.new(type = 'd')
bil.set.values(b, input_vars = vstup[UPOV_ID == 1 & year(DTM) %in% c(2001:2002)])
bil.pet(b)

bil.set.optim(b, method = 'DE', init_GS = 1)

C1 = list()
for (i in 1:.i){
  res = bil.optimize(b)
  C1[[length(C1) + 1]] = data.table(t(porovnej(res, plot = FALSE)  ))
}

C1 = rbindlist(C1)
```

### Pro kalibraci na průměr a směrodatnou odchylku

``` r
b1 = bil.new(type = 'd', modif = 'critvars')
bil.set.values(b1, input_vars = vstup[UPOV_ID == 1 & year(DTM) %in% c(2001:2002)])
bil.pet(b1)
bil.set.optim(b1, method = 'DE')

bil.set.critvars(b1, obs_vars = c('R', 'R'), mod_vars = c('RM', 'RM'), crit = c("mean", 'sd'), weights = c(1, 1) )

C4 = list()
for (i in 1:.i){
  res1 = bil.optimize(b1)
  C4[[length(C4) + 1]] = data.table(t(porovnej(res1, plot = FALSE)  ))
}

C4 = rbindlist(C4)
```

### Vyhodnocení

Můžeme sledovat rozdělení různých ukazatelů chyb pro různá nastavení.

``` r
C = rbind(
  data.table(ID = 'C1', C1),
  data.table(ID = 'C4', C4)
)

boxplot(ME ~ ID, data = C)
```

![](README_files/figure-markdown_github/unnamed-chunk-20-1.png)

``` r
boxplot(RMSE ~ ID, data = C)
```

![](README_files/figure-markdown_github/unnamed-chunk-20-2.png)

> Dodělat

Část "Parametrická nejistota" rozšiřte o kalibraci na

-   průměr
-   sd
-   m-denni vody
-   vlastní "nejlepší" nastavení

Cvičení 4
=========

Vyhodnoťte různé kalibrace, dokumentujte pomocí R markdown. Výsledný html soubor nahrajte do odevzdávárny na moodle. Dokument bude obsahovat i stručné texty.
