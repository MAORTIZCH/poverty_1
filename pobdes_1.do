****************
****QALLARIY****
****************

*Medición de la pobreza y desigualdad 1: Indicadores FGT

*Autor: Miguel Angel Ortiz Chávez (maortiz@pucp.edu.pe)
*grupoqallariy.com

*Preparando la base de datos

global base ""

	global origin "$base\original"
	global trabajado "$base\trabajado"
	
use "$origin\enaho01-2021-200.dta", clear
merge m:1 conglome vivienda hogar using "$origin\sumaria-2021.dta"
keep conglome vivienda hogar ubigeo ing* gas* linpe dominio estrato mieperho linea pobreza factor07 p209 p208a p207 p206 p205 p204 p203

drop if p204!=1
recode pobreza(1/2=1 "pobre") (3=2 "no pobre"), gen(pobre)	
g gpcm=gashog2d/(12*mieperho)

svyset conglome [pw=factor07] , strata(estrato)	|| vivienda	
svy: tab pobre, cv percent col format(%2,1f) missing

*Indicadores FGT
tab pobre [iw=factor07]
table pobreza, c(sum gpcm mean gpcm) format(%13.0g) row

sepov gpcm [w= factor07 ], povline(linea) psu(conglome) strata(estrato)
apoverty gpcm [w= factor07], varpl(linea) all

*Manualmente
gen p_xz=((linea-gpcm)/linea)

forvalues i=0/2 {
*gen p_xz_`i'=p_xz^`i'
*replace p_xz_`i'=0 if linea<gpcm
svy: mean p_xz_`i'
}
