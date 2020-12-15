********************************************************************************
*                 DATATHON - Danone: Equipe 6 NutriSquad                       *
********************************************************************************

* Base filtrada para idosos (acima de 60 anos) com dados de consumo alimentar

* n inicial = 5.299 idosos de ambos os sexos



*------------------------------------------------------------------------------*
* 1º passo: Exclusão de relato implausível de energia

* Cut-offs: * Mulheres - Abaixo de 500 Kcal e acima de 3.500 Kcal
            * Homens - Abaixo de 800 Kcal e acima de 4000 Kcal
			
* ReferÊncia: 
  * Banna JC, McCrory MA,Fialkowski MK and Boushey C (2017) Examining 
  * Plausibility of Self-Reported Energy Intake Data: Considerations for 
  * Method Selection. Front. Nutr. 4:45. 


drop if energia_kcal > 4000 & sexo == 1
*(651 observations deleted)

drop if energia_kcal > 3500 & sexo == 2
*(1,054 observations deleted)

drop if energia_kcal < 800 & sexo == 1
*(34 observations deleted)

drop if energia_kcal < 500 & sexo == 2
*(7 observations deleted)

* n = 3.553 (Amostra corrigida para relato implausível da ingestão de energia)


*------------------------------------------------------------------------------*
*2º passo: Calcular consumo diário de energia e proteínas por quilo de peso

gen kcalkg = energia_kcal/peso

gen ptnkg = ptn/peso


*------------------------------------------------------------------------------*
*3º passo: Categorizar o consumo de energia e proteínas por adequação

* Faixa de adequação de energia: 30-35 kcal/kg/dia
* Faixa de adequação de proteína: 1,0-1,5 g/kg/dia, podendo chegar a 2g/kg
      * Cut-off utilizado: Entre 1-2g de proteína por quilo

* ReferÊncia: 
  * Diretriz BRASPEN de terapia nutricional no envelhecimento. 
  * BRASPEN J 2019; 34 (Supl 3):2-58


gen kcalkg = energia_kcal/peso
gen ptnkg = ptn/peso

gen kcal_cat = kcalkg
recode kcal_cat min/29.999 = 0 30/35 = 1 35.001/max = 2
label define kcal 0 "Inadequado" 1 "Adequado" 2 "Acima"
label val kcal_cat kcal


gen ptn_cat = ptnkg
recode ptn_cat min/0.999999 = 0 1.00000/2.0000 = 1  2.00001/max = 2 
label define ptncat 0 "Inadequado" 1 "Adequado" 2 "Acima"
label val ptn_cat ptncat



*------------------------------------------------------------------------------*
*4º passo: Gerando a variável de localidade geográfica por UF

* Convertendo o número identificador para o tipo 'string'
tostring ident, gen (ufnovo) usedisplayformat

* Extraindo os dois primeiros dígitos da variável (indicadores do código da UF)
gen str estado = substr(ufnovo,1,2)

* Transformando a variável 'string' em numéria para categorização por estado
destring estado, gen (uf_novo)


*------------------------------------------------------------------------------*
*5º passo: Calculando o valor da suplementação 

* Suplemente escolhido: Nutridrink Protein
    * Fornece 300 kcal e 20g de proteínas por embalagem de 200 mL
	* Sugestão de consumo: 1-2 embalagens por dia
	

	
*              *                    *                     *                    *
* Considerando 1 embalagem (200 mL)
*              *                    *                     *                    *

gen energia_suple = energia_kcal + 300

gen ptn_supl = ptn + 20



* Recalculando a ingestão por quilo de peso por dia

gen kcalkg_suple = energia_suple/peso

gen ptnkgsuple = ptn_supl/peso 


* Recalculando a prevalência de inadequação após suplementação

gen kcalsupl_cat = kcalkg_suple 
recode kcalsupl_cat min/29.999 = 0 30/35 = 1 35.001/max = 2
label val kcalsupl_cat kcal


gen ptnsuple_cat = ptnkgsupl 
recode ptnsuple_cat min/0.999999 = 0 1.00000/2.0000 = 1  2.00001/max = 2
label val ptnsuple_cat ptncat


*              *                    *                     *                    *
* Considerando 2 embalagens (400 mL)
*              *                    *                     *                    *


gen energia_suple2 = energia_kcal + 600

gen ptn_supl2 = ptn + 40



* Recalculando a ingestão por quilo de peso por dia

gen kcalkg_suple2 = energia_suple2/peso

gen ptnkgsuple2 = ptn_supl2/peso 


* Recalculando a prevalência de inadequação após suplementação

gen kcalsupl2_cat = kcalkg_suple2
recode kcalsupl2_cat min/29.999 = 0 30/35 = 1 35.00001/max = 2
label val kcalsupl2_cat kcal


gen ptnsuple2_cat = ptnkgsuple2
recode ptnsuple2_cat min/0.999999 = 0 1.00000/2.0000 = 1  2.00001/max = 2
label val ptnsuple2_cat ptncat


*------------------------------------------------------------------------------*
*6º passo: Determinação do estado nutricional dos idosos

* IMC calculado como a razão entre peso e altura ao quadrado
* IMC categorizado de acordo com a OPAS para idosos

    * Abaixo de 23 kg/m2 = Baixo peso (Desnutrição)
	* Entre 23 - 28 kg/m2 = Eutrofia ou peso adequado
	* Entre 28 - 30 kg/m2 = Pré-obesidade
	* Maior ou igual a 30 kg/m2 = Obesidade
	

gen alt_m = altura/100

* NANISMO
* Homens com altura menor que 1,40m e mulheres com altura menor que 1,35m foram exluídos
	
drop if alt_m <1.40 & sexo == 1
*(38 observations deleted)

drop if alt_m <1.35 & sexo == 2
*(13 observations deleted)


gen imc = peso/(alt_m*alt_m)

gen est_nut = imc
recode est_nut min/23=1 23.01/28=2 28.01/30=3 30.01/max=4
label define est_nut 1"Baixo Peso" 2"Eutrofia" 3"Pré-obesidade" 4"Obesidade"
label val est_nut est_nut

*------------------------------------------------------------------------------*
*7º passo: Montando as estatísticas dos mapas de geolocalização

sort regiao

* Visualização da estatística descritiva por região, filtrado para inadequação
* Verificando o perfil por região para o consumo de proteínas e energia

by regiao:sum inadeq_ptn
by regiao:sum inadequptn_supl1
by regiao:sum inadeq_kcal
by regiao:sum inadequptn_supl1
by regiao:sum inadkcal_supl1
by regiao:sum inadeqptn_suple2
by regiao:sum inadeqkcal_suple2


*------------------------------------------------------------------------------*
*8º passo: Investigar o perfil dos individuos em inadequação


* Situação com bases nos dados da POF dos indivíduos com consumo inadequado

* Sexo 
tab sexo ptn_cat, col chi

* Estado nutricional
tab est_nut ptn_cat , col chi

*Idade
sort ptn_cat
by ptn_cat: sum idade

* Raça
tab raca ptn_cat , col chi

* Escolaridade
tab anos_estudo ptn_cat , col chi

* Tipo de domicílio


*------------------------------------------------------------------------------*
* Fim da preparação da base individual de suplementação

* FIM
*------------------------------------------------------------------------------*



