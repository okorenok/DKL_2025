clear 

import excel "/Users/okorenok/Library/CloudStorage/GoogleDrive-okorenok@vcu.edu/.shortcut-targets-by-id/1vOqkSb5CBZCZsEqddGjAdtTL_JGCmCg6/Public Signals and Information Aggregation/data/dataAllsubj.xlsx", sheet("all") firstrow

forvalues i = 1(1)3 { 
	replace Period = Period+7 if (Period==`i')&(treatment==2)
	}


// treatment dummies
gen base = (session1==1)|(session1==2)|(session1==3)|(session1==4)|(session1==5)
gen pubF = (session1==6)|(session1==7)|(session1==8)|(session1==9)|(session1==10)
gen pubA = (session1==11)|(session1==12)|(session1==13)|(session1==14)|(session1==15)|(session1==16)

// subject numbers
gen Subject1 = Subject if (session1==1)

forvalues i = 2(1)16 { 
	replace Subject1 = Subject+12*(`i'-1) if (session1==`i')
	}

//------------------------------------------------------------------------------ 
// Table 4
//------------------------------------------------------------------------------ 
tsset Subject1 Period

// all signals
gen sigAll = sigA+sigF
xtreg sigAll pubF pubA Period if (Period>0)&(session1~=15), cluster(session1)
test _b[pubF]=_b[pubA]

// A signal
xtreg sigA pubF pubA Period if (Period>0)&(session1~=15), cluster(session1)
test _b[pubF]=_b[pubA]

// F signal
xtreg sigF pubF pubA Period if (Period>0)&(session1~=15), cluster(session1)
test _b[pubF]=_b[pubA]




//------------------------------------------------------------------------------ 
// New dataset 
//------------------------------------------------------------------------------ 
//------------------------------------------------------------------------------ 
clear

//import excel "/Users/okorenok/Library/CloudStorage/GoogleDrive-okorenok@vcu.edu/.shortcut-targets-by-id/1vOqkSb5CBZCZsEqddGjAdtTL_JGCmCg6/Public Signals and Information Aggregation/analysis/fcst.xlsx", sheet("Sheet1") firstrow

import excel "/Users/dddavis/Library/CloudStorage/GoogleDrive-dddavis@vcu.edu/My Drive/Papers/Public Signals and Information Aggregation/analysis/fcst.xlsx", sheet("Sheet1") firstrow 

// treatment dummies
gen base = (session1==1)|(session1==2)|(session1==3)|(session1==4)|(session1==5)
gen pubF = (session1==6)|(session1==7)|(session1==8)|(session1==9)|(session1==10)
gen pubA = (session1==11)|(session1==12)|(session1==13)|(session1==14)|(session1==16)
gen correct = 1 if base==1
replace correct = 1 if (base~=1)&(A==pSig)

gen pfa_state = abs(pfa-value)
gen ap60_pfa = abs(ap60-pfa)

gen ppi_state = abs(medB-value)
gen ap60_ppi = abs(ap60-medB)


// Generate decision maker knowledge
// for al treatment A and F are reversed, pSig is 70% accurate about A 
gen sig1 = A if pubF~=1
replace sig1 = 1 if (Period==3)&(pubF~=1)
replace sig1 = F if pubF==1
replace sig1 = 1 if (Period==3)&(pubF==1)
replace sig1 = 1 if (session1==1)&(Period==10) // to fix basline session 1

gen sig2 = A if pubF==1
replace sig2 = 1 if (Period==5)&(pubF==1)
replace sig2 = 1 if (Period==7)&(pubF==1)
replace sig2 = 0 if (Period==9)&(pubF==1)
replace sig2 = F if pubF~=1
replace sig2 = 1 if (Period==5)&(pubF~=1)
replace sig2 = 1 if (Period==7)&(pubF~=1)
replace sig2 = 0 if (Period==9)&(pubF~=1)
replace sig2 = 1 if (session1==1)&(Period==9) // to fix basline session 1

gen sig1a = 90 if (sig1==1)
replace sig1a = 10 if (sig1==0)
gen sig2a = 70 if (sig2==1)
replace sig2a = 30 if (sig2==0)

gen mgrinfo =abs(F*100-sig2a)
replace mgrinfo =abs(A*100-sig2a) if pubF==1
gen mktinfo = abs(F*100-(ap60-sig1a))
replace mktinfo = abs(A*100-(ap60-sig1a)) if pubF==1
gen flearn =mgrinfo - mktinfo // a measure of how much closer to sig1-ap60 is to F than the manager's own signal about F. A negative number indicates more learned from mkt
tsset session1 Period

// RDM forecasting models
// Estimate model for baseline
logit F sig1 sig2 ap60 if (Period>0)&(base), vce(cluster session1)
predict f_b
gen F_Fs = abs(F - f_b) if (Period>0)&(base)
 

// Estimate model for f_a
logit F sig1 sig2 pSig ap60 if (Period>0)&(pubA), vce(cluster session1)
// Generate f_a estimate
predict f_a
replace F_Fs = abs(F - f_a) if (Period>0)&(pubA)

// Estimate model for f_f
logit  A sig1 sig2 pSig ap60 if (Period>0)&(pubF), vce(cluster session1)
// Generate f_f estimate
predict f_f
replace F_Fs = abs(A - f_f) if (Period>0)&(pubF)

// Classifications
gen cl_50 = ~(F_Fs<.50)
gen cl_40 = ~(F_Fs<.40)
gen cl_30 = ~(F_Fs<.30)
gen cl_20 = ~(F_Fs<.20)
gen cl_10 = ~(F_Fs<.10)



//------------------------------------------------------------------------------ 
// Table 5
//------------------------------------------------------------------------------ 

// |P^FA - V| 
xtreg pfa_state pubF pubA Period if (Period>0)&(session1~=15), cluster(session1)
test _b[pubF]=_b[pubA]

// |P^FA - V| for correct signals
xtreg pfa_state pubF pubA Period if (Period>0)&(session1~=15)&(correct==1), cluster(session1)
test _b[pubF]=_b[pubA]


// |P_60 - P^FA| 
xtreg ap60_pfa pubF pubA Period if (Period>0)&(session1~=15), cluster(session1)
test _b[pubF]=_b[pubA]

// |P_60 - P^FA| 
xtreg ap60_pfa pubF pubA Period if (Period>0)&(session1~=15)&(correct==1), cluster(session1)
test _b[pubF]=_b[pubA]


//------------------------------------------------------------------------------ 
// Table 6
//------------------------------------------------------------------------------

// |F-F'| - |F-(p60-A')|
xtreg flearn pubF pubA Period if (Period>0)&(session1~=15), cluster(session1)
test _b[pubF]=_b[pubA]

// |F-F*| 
xtreg F_Fs pubF pubA Period if (Period>0)&(session1~=15), cluster(session1)
test _b[pubF]=_b[pubA]


//------------------------------------------------------------------------------ 
// Table 7 
//------------------------------------------------------------------------------

// Classifications
// .50
xtreg cl_50 pubF pubA if (Period>0)&(session1~=15), cluster(session1)

display _b[_cons] // classification baseline
display _b[_cons]+_b[pubF] // classification pubF
display _b[_cons]+_b[pubA] // classification pubA
test _b[pubF]=_b[pubA]

// .40
xtreg cl_40 pubF pubA if (Period>0)&(session1~=15), cluster(session1)

display _b[_cons] // classification baseline
display _b[_cons]+_b[pubF] // classification pubF
display _b[_cons]+_b[pubA] // classification pubA
test _b[pubF]=_b[pubA]

// .30
xtreg cl_30 pubF pubA if (Period>0)&(session1~=15), cluster(session1)

display _b[_cons] // classification baseline
display _b[_cons]+_b[pubF] // classification pubF
display _b[_cons]+_b[pubA] // classification pubA
test _b[pubF]=_b[pubA]

// .20
xtreg cl_20 pubF pubA if (Period>0)&(session1~=15), cluster(session1)

display _b[_cons] // classification baseline
display _b[_cons]+_b[pubF] // classification pubF
display _b[_cons]+_b[pubA] // classification pubA
test _b[pubF]=_b[pubA]

// .10
xtreg cl_10 pubF pubA if (Period>0)&(session1~=15), cluster(session1)

display _b[_cons] // classification baseline
display _b[_cons]+_b[pubF] // classification pubF
display _b[_cons]+_b[pubA] // classification pubA
test _b[pubF]=_b[pubA]


//------------------------------------------------------------------------------ 
// Table 8 
//------------------------------------------------------------------------------
// |P^PI - V| 
xtreg ppi_state pubF pubA Period if (Period>0)&(session1~=15), cluster(session1)
test _b[pubF]=_b[pubA]

// |P^PI - V| for correct signals
xtreg ppi_state pubF pubA Period if (Period>0)&(session1~=15)&(correct==1), cluster(session1)
test _b[pubF]=_b[pubA]


// |P_60 - P^PI| 
xtreg ap60_ppi pubF pubA Period if (Period>0)&(session1~=15), cluster(session1)
test _b[pubF]=_b[pubA]

// |P_60 - P^PI| 
xtreg ap60_ppi pubF pubA Period if (Period>0)&(session1~=15)&(correct==1), cluster(session1)
test _b[pubF]=_b[pubA]
