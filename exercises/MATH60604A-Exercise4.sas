/* Exercise 4.1 */

data profsalary;
set statmod.profsalary;
if(salary > 105000) then salbi=1; else salbi=0;
run;

proc logistic data=profsalary;
model salbi(ref="0") = degree sex yr yd / plrl;
run;

proc logistic data=profsalary;
class rank(ref="1");
model salbi(ref="0") = degree sex yr yd rank / plrl;
run;

/* Exercise 4.2 */

proc genmod data=statmod.awards;
class prog(ref="1");
model nawards = prog math / dist=poisson link=log;
run;

proc genmod data=statmod.awards;
class prog(ref="1");
model nawards = prog math / dist=negbin link=log;
run;

data pval;
pval=(1-cdf('chisq', 1.6938, 1))/2;
run;
proc print data=pval;
run;

/* Exercise 4.3 */
data ceb;
set statmod.ceb;
lognwom = log(nwom);
mceb = nceb/nwom;
run;

proc sgplot data=ceb;
scatter x=nwom y=nceb;
yaxis type=log label="number of children ever born (log)";
xaxis type=log label="number of women (log)";
run;

proc sgplot data=ceb;
scatter x=mceb y=var;
xaxis label="mean of the number of children ever born";
yaxis label="variance of the number of children ever born";
run;


proc genmod data=ceb plots=(resdev leverage);
class res(ref="1") dur(ref="1") educ(ref="1");
model nceb = res dur educ / 
	offset=lognwom dist=poisson link=log type3 lrci;
run;

proc genmod data=ceb plots=(resdev(xbeta) leverage cooksd);
class res(ref="1") dur(ref="1") educ(ref="1");
model nceb = res dur educ lognwom / 
	dist=poisson link=log type3 lrci;
output out=residceb stdresdev=devres;
run;

proc univariate data=residceb noprint;
qqplot devres;
run;

proc genmod data=ceb;
class res(ref="1") dur(ref="1") educ(ref="1");
model nceb = res dur educ dur*educ / 
	offset=lognwom dist=poisson link=log type3;
run;

/* Exercise 4.4 */
data cancer;
set statmod.cancer;
total = no + yes;
run;

proc genmod data=cancer;
class age malignant;
model yes/total = age malignant age*malignant /
 dist=binomial link=logit type3;
run;

proc genmod data=cancer;
class age malignant;
model yes/total = malignant age / 
 dist=binomial link=logit type3;
run;

proc genmod data=cancer;
class age malignant;
model yes/total = malignant / 
 dist=binomial link=logit type1;
run;

/* Exercise 4.5 */

data smoking;
set statmod.smoking;
logpop = log(pop);
run;

proc genmod data=smoking;
class smoke age;
model dead/pop = smoke age / 
dist=binomial link=logit type3;
output out=predbin pred=predb;
run;

proc genmod data=smoking;
class smoke age;
model dead = smoke age /
 type3 offset=logpop dist=poisson link=log;
output out=predpois pred=predp;
run;

data predsmoker;
set predpois(keep=predp pop);
set predbin(keep=predb);
predd = predp/pop-predb;
run;

proc sgplot data=predsmoker;
scatter x=predb y = predd;
xaxis label="Predicted death rate (binomial model)";
yaxis label="Difference in predicted probability for Poisson versus binomial model";
run;
