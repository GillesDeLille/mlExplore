require(ranger)
mdl <- ranger(as.formula(paste(target,'~ .')), data=data)
# //
# TO DO
# "ranger" un maximum de résultats sous la même forme que pour la sortie de skl (avez-vous apprécié le jeu de mot ?)
# //
