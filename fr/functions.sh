#!/bin/bash
# Here you can create functions which will be available from the commands file
# You can also use here user variables defined in your config file


jv_pg_ct_thermomix()  {
varchemthermomix_etape="$jv_dir/plugins_installed/jarvis-thermomix/recette_etape.txt";

varchemthermomix_sauv="$jv_dir/plugins_installed/jarvis-thermomix/recette_dujour.txt";

if test -e "$varchemthermomix_etape"; then
ETAPEMOMO=`cat $varchemthermomix_etape`;
else
echo "1" > $varchemthermomix_etape;
ETAPEMOMO="1"
fi


# ETAPEMOMO=$(( $ETAPEMOMO + 1 )); 

# say "je suis à  $ETAPEMOMO";
if [[ "$ETAPEMOMO" == "1" ]] ; then
say "Recherche de la recette Thermomix du jour.";
lignesay_temps="";
lignesay_portion="";
lignesay_difficulte="";
lignesay_type="";
lignesay_ingredient="";
lignesay_html="";
varchemthermomix="$jv_dir/plugins_installed/jarvis-thermomix/recette.txt";
wget -q https://www.espace-recettes.fr -O $varchemthermomix;


## Titre: ########################
exactlignealirethermomix=510;
lignesay=$(sed -n "$exactlignealirethermomix p" $varchemthermomix);
lignesay_titreRCTE=`echo "$lignesay" | cut -d">" -f2 | cut -d"<" -f1`;
# say "La recette proposé du jour est: $lignesay_titreRCTE";

## Lien internet: ########################
exactlignealirethermomix=510;
lignesay_html=`echo "$lignesay" | cut -d"/" -f2- | cut  -d'"' -f1`;
lignesay_html="https://www.espace-recettes.fr/$lignesay_html";
wget -q $lignesay_html -O $varchemthermomix;


## Temps: ########################
# <h5 class="media-heading">30min</h5> ligne N° 634  puis 626
lignesay_temps=`grep '<h5 class="media-heading">.*min' $varchemthermomix | cut -d">" -f2 | cut -d"<" -f1`;
if [[ "$lignesay_temps" != "" ]]; then 
jv_pg_ct_thermomix_corige "$lignesay_temps";
thermomix_corigeOk=`echo "$thermomix_corigeOk" | sed -e "s/1m/une m/g"`
lignesay_temps="elle se fait en $thermomix_corigeOk,";
# say "Fait en $lignesay_temps.";
fi


## Portions: ########################
lignesay_portion=`grep 'portion/s' $varchemthermomix | cut -d">" -f3 | cut -d"<" -f1`;
if [[ "$lignesay_portion" == "" ]] ; then
lignesay_portion=`grep 'litre/s' $varchemthermomix | cut -d">" -f3 | cut -d"<" -f1`;
fi
if [[ "$lignesay_portion" == "" ]] ; then
lignesay_portion=`grep 'personne/s' $varchemthermomix | cut -d">" -f3 | cut -d"<" -f1`;
fi
if [[ "$lignesay_portion" != "" ]]; then 
jv_pg_ct_thermomix_corige "$lignesay_portion";
lignesay_portion="pour $thermomix_corigeOk";
lignesay_portion=`echo "$lignesay_portion" | sed -e "s/1/une/g"`
# say "Pour $lignesay_portion."
fi

## Difficulté: ########################
# <h5 class="media-heading">Facile</h5> ligne 660 puis 652
# <div class="smallText">Preparation ligne d'avant
exactlignealirethermomix=660;
# lignesay=$(sed -n "$exactlignealirethermomix p" $varchemthermomix)
lignesay=`grep -n  '<div class="smallText">Preparation' $varchemthermomix | cut -d":" -f1 | paste -s | cut -f2`;
if [[ "$lignesay" -gt "1" ]]; then 
lignesay=$(( $lignesay - 1 ));
lignesay=$(sed -n "$lignesay p" $varchemthermomix);
lignesay_difficulte=`echo "$lignesay" | cut -d">" -f2 | cut -d"<" -f1`;
if [[ "$lignesay_difficulte" != "" ]]; then 
        lignesay_difficulte="est $lignesay_difficulte à faire,";
	# say "C'est une recette $lignesay_difficulte à faire."
	fi
fi


## Type R7: ########################
# exactlignealirethermomix=425
# lignesay=$(sed -n "$exactlignealirethermomix p" $varchemthermomix)
lignesay=`grep -n  '<a class="catText preventDefault" href="/categories/">recette</a>'  $varchemthermomix  | cut -d":" -f1 | paste -s | cut -f2`;
if [[ "$lignesay" -gt "1" ]]; then 
lignesay=$(( $lignesay - 1 ));
lignesay=$(sed -n "$lignesay p" $varchemthermomix);
lignesay_type=`echo "$lignesay" | cut -d">" -f2 | cut -d"<" -f1`;
jv_pg_ct_thermomix_corige "$lignesay_type";
lignesay_type="elle fait partie des $thermomix_corigeOk.";
# say "ça fait parti des $lignesay_type.";
fi

## ingrédients: ########################
lignesay_ingredient_qte=`sed -n '/<ul itemprop="ingredients/,/div class="text-center margin-top-10 shopping-list-button btn-block/p' $varchemthermomix | grep "<li>" | wc -l`;
lignesay_ingredient_etape=`sed -n '/<ul itemprop="ingredients/,/div class="text-center margin-top-10 shopping-list-button btn-block/p' $varchemthermomix | grep "<ul" | wc -l`;
lignesay_ingredient=`sed -n '/<ul itemprop="ingredients/,/div class="text-center margin-top-10 shopping-list-button btn-block/p' $varchemthermomix | paste -s`;
lignesay_ingredient=`echo $lignesay_ingredient | sed -e "s/<\/li> <li>//g" | sed -e "s/<li>//g" | sed -e "s/<\/li>//g" | sed -e "s/<ul>//g" | sed -e "s/<\/p>//g" | sed -e "s/<\/ul>//g" | sed -e "s/  /,/g" | sed -e 's/<ul itemprop="ingredients">//g' | sed -e 's/<\/li> <\/ul> <div class="text-center margin-top-10 shopping-list-button btn-block">//g' | sed -e 's/<p class="h5 padding-bottom-5 padding-top-5">//g' | sed -e 's/<div class="text-center margin-top-10 shopping-list-button btn-block">//g' | sed -e 's/,,/: /g'| cut -c2-`;
jv_pg_ct_thermomix_corige "$lignesay_ingredient";
if [[ "$lignesay_type" != "" ]]; then 
lignesay_ingredient="$thermomix_corigeOk";
# say "Ingrédient: $lignesay_ingredient";
fi 
if [[ "$lignesay_ingredient_etape" -gt "1" ]]; then 
lignesay_ingredient_etape="Elle se fait en $lignesay_ingredient_etape étapes.";
else
lignesay_ingredient_etape="Elle se fait en une seule étape.";
fi                  


# say "J'ai trouvé, elle se fait en $lignesay_temps pour $lignesay_portion est $lignesay_difficulte à faire, elle fait partie des $lignesay_type."
# local thermomix_say_ok=`echo "J'ai trouvé, $lignesay_temps $lignesay_portion $lignesay_difficulte $lignesay_type." | sed -e "s/\/s//g"`
thermomix_say_ok=`echo "J'ai trouvé, $lignesay_temps $lignesay_portion $lignesay_difficulte $lignesay_type. $lignesay_ingredient_etape."`;
echo "La recette proposé du jour $lignesay_temps $lignesay_portion $lignesay_difficulte $lignesay_type, son nom: $lignesay_titreRCTE:" > $varchemthermomix_sauv
echo "$lignesay_html" >> $varchemthermomix_sauv
echo "$lignesay_ingredient_qte" >> $varchemthermomix_sauv
echo "$lignesay_ingredient_etape" >> $varchemthermomix_sauv
echo "$lignesay_ingredient" >> $varchemthermomix_sauv

jv_pg_ct_thermomix_corige "$thermomix_say_ok";
say "$thermomix_corigeOk";

say "Son nom: $lignesay_titreRCTE";
	if jv_plugin_is_enabled "jarvis-FREE-sms"; then
	say "Est-ce que je vous envoie le lien par sms à $(jv_pg_ct_ilyanom) ou personne ?";
	echo "2" > $varchemthermomix_etape;
	return;
	else
	say "Voilà."
	echo "4" > $varchemthermomix_etape;
	GOTOSORTIMOMO="Fin";
	fi

echo "2" > $varchemthermomix_etape;
 
return;
fi

if [[ "$ETAPEMOMO" == "2" ]] ; then
order="$REPONSEMOMO";

 
	if [[ "$REPONSEMOMO" =~ "personn" ]]; then
	echo "4" > $varchemthermomix_etape;
	GOTOSORTIMOMO="Fin";
	say "Ok, la prochaine recette peut-être.";
	return; 
	else

	if jv_plugin_is_enabled "jarvis-FREE-sms"; then
	jv_pg_ct_verinoms;
	
		if [[ "$PNOM" == "" ]]; then
		say "Je ne reconnais pas le nom..."
		GOTOSORTIMOMO="Fin";
		echo "4" > $varchemthermomix_etape;
		return;
		fi
	else
	say "Voilà."
	echo "4" > $varchemthermomix_etape;
	GOTOSORTIMOMO="Fin";
	fi

if test -z "$PNOM"; then 
echo "4" > $varchemthermomix_etape;
GOTOSORTIMOMO="Fin";
return; 
fi
	if [[ "$order" =~ "$PNOM" ]]; then
	
		echo "$PNOM" >> $varchemthermomix_sauv 
		say "Je fais partir le lien internet à $PNOM."; 
		# thermomix_sms="Voici au prochain SMS la recette proposé du jour faite en $lignesay_temps pour $lignesay_portion $lignesay_difficulte à faire, elle fait parti $lignesay_type = $lignesay_titreRCTE.";
		thermomix_sms=`cat $varchemthermomix_sauv | sed -n 1p`;
		lignesay_html=`cat $varchemthermomix_sauv | sed -n 2p`; 
		lignesay_ingredient_qte=`cat $varchemthermomix_sauv | sed -n 3p`;
		lignesay_ingredient_etape=`cat $varchemthermomix_sauv | sed -n 4p`;
		commands="$(jv_get_commands)"
		jv_handle_order "MESSEXTERNE ; $PNOM ; $thermomix_sms";
		jv_handle_order "MESSEXTERNE ; $PNOM ; $lignesay_html"; 
		say "Souhaitez vous aussi que je vous envoie les $lignesay_ingredient_qte ingrédients par sms ?";
		say "$lignesay_ingredient_etape";
		echo "3" > $varchemthermomix_etape;
		return; 
		else
		say "Désolé je n'ai pas reconnu le nom... Annulation..."; 
		echo "4" > $varchemthermomix_etape;
		GOTOSORTIMOMO="Fin";
		fi

	fi
fi


if [[ "$ETAPEMOMO" == "3" ]] ; then
	if [[ "$REPONSEMOMO" =~ "oui" ]] || [[ "$REPONSEMOMO" =~ "ok" ]]; then
	say "Et voilà c'est fait...bonne cuisine !";
	lignesay_ingredient=`cat $varchemthermomix_sauv | sed -n 5p`;
	PNOM=`cat $varchemthermomix_sauv | sed -n 6p`;
	commands="$(jv_get_commands)";
	jv_handle_order "MESSEXTERNE ; $PNOM ; $lignesay_ingredient"; 
	echo "4" > $varchemthermomix_etape;
	GOTOSORTIMOMO="Fin";
	else	
	GOTOSORTIMOMO="Fin";
	echo "4" > $varchemthermomix_etape;
	say "d'accord, je ne l'envoie pas...";
	fi
fi

if [[ "$ETAPEMOMO" -ge "4" ]] ; then
jv_pg_ct_thermomixazero;
# echo "Je force à aller à GOTOfin";
GOTOSORTIMOMO="Fin";
return; 
fi
}


jv_pg_ct_thermomixazero() {
varchemthermomix_etape="$jv_dir/plugins_installed/jarvis-thermomix/recette_etape.txt";
ETAPEMOMO="0";
if [ -e "$varchemthermomix_etape" ]; then
sudo rm "$varchemthermomix_etape";
fi
}

jv_pg_ct_thermomix_corige() {
thermomix_corigeOk=`echo "$1" | sed -e "s/&amp;/et/g" | sed -e "s/min,/ minutes,/g" | sed -e "s/  //g" | sed -e "s/&#039;/'/g" | sed -e "s/\/s//g"`;
														 
if [[ `echo "$thermomix_corigeOk" | cut -c1` == " " ]]; then
thermomix_corigeOk=`echo "$thermomix_corigeOk" | cut -c2-`;
fi

return;
}
 