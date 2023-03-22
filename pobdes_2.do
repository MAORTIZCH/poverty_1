****************
****QALLARIY****
****************

*Medición de la pobreza y desigualdad 2: Distribución de ingresos y gastos

*Autor: Miguel Angel Ortiz Chávez (maortiz@pucp.edu.pe)
*grupoqallariy.com

*Preparando la base de datos
global base "D:\Proyectos\2022 Blog Qallariy\Publicados\Manuales\02 Pobreza y desigualdad_Distribucipon de ingresos\Base"

	global origin "$base\original"
	global trabajado "$base\trabajado"

*arreglar nombre de la variable año
forvalues i=10/21 {
	use "$origin\sumaria-20`i'", clear
	rename a*o aÑo
	save "$origin\sumaria-20`i'", replace
}

clear all

*Conviertiendo a valores reales (Asegurarse de cambiar las direcciones de las bases)
do "$origin\01.ConstrVarGastoIngreso2010-2021.do"
save "$trabajado\real_sumaria1021", replace

*Descriptivos y distribución
use "$trabajado\real_sumaria1021", clear

svyset [pweight = factornd07], psu(conglome)strata(estrato)

svy: mean ipcr_0, over(aniorec)
sum ipcr_0 if aniorec==2016 [fw=factornd07], detail
sum ipcr_0 if aniorec==2021 [fw=factornd07], detail

histogram ipcr_0 if aniorec==2021 [fw=factornd07], percent ytitle(Porcentaje) xtitle(Ingreso real per-cápita) title(Ingreso real per-cápita mensual)

histogram ipcr_0 if aniorec==2021 & ipcr_0<4900 [fw=factornd07], percent ytitle(Porcentaje) xtitle(Ingreso real per-cápita) title(Ingreso real per-cápita mensual)

twoway (kdensity ipcr_0 [aw=factornd07] if aniorec==2011) (kdensity ipcr_0 [aw=factornd07] if aniorec==2016) (kdensity ipcr_0 [aw=factornd07] if aniorec==2021) if ipcr_0<3000, ytitle(Densidad) xtitle(Ingreso real per-cápita mensual) title("Distribución del ingreso") legend(label(1 "2011") label(2 "2016") label(3 "2021") region(lstyle(none)))

*Quintiles de ingresos
xtile quintil2021=ipcr_0 if ipcr_0!=. & aniorec==2021 [aw=factornd07], nq(5)
table quintil2021 if aniorec==2021 [aw=factornd07], c(mean ipcr_0) row col
svy: mean ipcr_0 if aniorec==2021, over(quintil2021)
sumdist ipcr_0 if aniorec==2021 [aw=factornd07], ng(5)

xtile quintil2016=ipcr_0 if ipcr_0!=. & aniorec==2016 [aw=factornd07], nq(5)
table quintil2016 if aniorec==2016 [aw=factornd07], c(mean ipcr_0) row col
svy: mean ipcr_0 if aniorec==2016, over(quintil2016)
sumdist ipcr_0 if aniorec==2016 [aw=factornd07], ng(5)

*logaritmos
gen ling=ln(ipcr_0)

twoway (kdensity ling [aw=factornd07] if aniorec==2011) (kdensity ling [aw=factornd07] if aniorec==2016) (kdensity ling [aw=factornd07] if aniorec==2021), ytitle(Densidad) xtitle(Ingreso real per-cápita mensual) title("Distribución del ingreso en logaritmos") legend(label(1 "2011") label(2 "2016") label(3 "2021") region(lstyle(none)))

graph box ling [aw=factornd07] if aniorec==2021, over(quintil2021) 

gen quintil=quintil2021
replace quintil=quintil2016 if quintil==.
graph box ling [aw=factornd07], over(aniorec) over(quintil)