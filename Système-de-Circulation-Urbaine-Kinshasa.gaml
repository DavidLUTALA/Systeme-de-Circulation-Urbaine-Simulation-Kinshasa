
model Systeme_de_circulation_Kinshasa

/* Insert your model definition here */


global {
//	declaration des variables globales
	shape_file route_shape_file <- shape_file("../includes/route.shp");
	shape_file maison_shape_file <- shape_file("../includes/batiment.shp");
	shape_file Bat_shape_file <- shape_file("../includes/Bat.shp");
	shape_file arret_shape_file <- shape_file("../includes/station.shp");
	shape_file terminus_shape_file <- shape_file("../includes/terminus_a.shp");
	shape_file ward_shape_file <- shape_file("../includes/ward.shp");
	shape_file line_1_shape_file <- shape_file("../includes/line_1.shp");
	image_file icon <- image_file("../includes/personnes.png");
	image_file bus_transco <- image_file("../includes/bus .png");
	image_file moto <- image_file("../includes/moto.png");
	
	image_file car <- image_file("../includes/car.png");
	
	
	 // Déclaration des graphes qui seront utilisés pour modéliser les réseaux de transport.

	graph road_network;
	graph road_line_1_aller;
	graph road_line_1_retour;
	graph road_line_1;
	
	 // Points initiaux pour les bus dans les différents itinéraires.
	 
	point point_bus_1_aller <- {460, 1300};
	point point_bus_1_retour <- {1540, 500};//  1540, 500
	point point_3_bus_1 <- {500, 1500}; //600 et 1350  500, 1500
	
	// Enveloppe de la zone couverte par les routes, utilisée pour définir les limites géographiques.
   
	geometry shape <- envelope(route_shape_file);

	init {
		// Création des routes à partir des fichiers de forme spécifiés.
		create road from: route_shape_file;
		create bati from: Bat_shape_file;
		
		
		//creation des agents
		
		      
     
		create terminus from: terminus_shape_file {
			
			 // Création des terminus avec des noms spécifiés, utilisés comme points de départ et d'arrivée des bus.
			 
			list<terminus> the_terminus <- list(terminus);
			if (the_terminus != []) {
				the_terminus[0].terminus_name <- "A";
				the_terminus[1].terminus_name <- "B";
			}

		}
		
// Création des communes et attribution des noms aux différents communes de Kinshasa.
		create ward from: ward_shape_file {
			list<ward> the_wards <- list(ward);
			if (the_wards != []) {
				the_wards[0].nom_commune <- "Ngaliema";
				the_wards[1].nom_commune <- "Gombe";
				the_wards[2].nom_commune <- "Lingwala";
				the_wards[3].nom_commune <- "Barumbu";
			}

		}
		// Initialisation de la ligne de bus et ajustement de leur position.

		create line_1 from: line_1_shape_file {
			location <- {location.x - 10, location.y + 10};
		}
		
		
 // Création des arrêts de bus et ajustement de leur position géographique.
		create arret from: arret_shape_file {
			list<arret> the_bus_stop <- list(arret);
			//			Ajustement des agents sur la carte Qgis
			the_bus_stop[16].location <- {1040, 240};
			the_bus_stop[12].location <- {965, 1560};
			the_bus_stop[14].location <- {1542, 1420};
			the_bus_stop[1].location <- {664, 826};
			the_bus_stop[2].location <- {1168, 971};
			 // Association des arrêts de bus aux quartiers environnants.
			list<ward> the_wards <- list(ward) where ((each distance_to self <= 5));
			if (the_wards != []) {
				address <- the_wards[0].nom_commune;
			}
   			// Association des arrêts de bus aux lignes de bus correspondantes.
			list<line_1> the_line_1 <- list(line_1) where ((each distance_to self <= 50));
			if (the_line_1 != []) {
				line_bus <- "line_1";
			} 

			list<arret> the_stop <- list(arret);
		}
			// Création des bus, attribution d'un terminus et définition de la ligne de bus.
		create bus number: 1 {
			list<terminus> the_terminus <- list(terminus);
			if (the_terminus != []) {
							the_terminus[0].terminus_name <- "A";
							the_terminus[1].terminus_name <- "B";
				location <- the_terminus[0].location;
			}
			//Distribution de la probabilite 
			line <- rnd_choice(["line_1"::1]);
			

		}
			
		// Création des bus, attribution d'un terminus et définition de la ligne de bus.
		
		create vehicules number: 1 {
			list<terminus> the_terminus <- list(terminus);
			if (the_terminus != []) {
							the_terminus[0].terminus_name <- "A";
							the_terminus[1].terminus_name <- "B";
				location <- the_terminus[0].location;
			}
			//Distribution de la probabilite 
			line <- rnd_choice(["line_1"::1]);
			

		}
		
		
		create motos number: 1 {
			list<terminus> the_terminus <- list(terminus);
			if (the_terminus != []) {
							the_terminus[0].terminus_name <- "A";
							the_terminus[1].terminus_name <- "B";
				location <- the_terminus[1].location;
			}
			//Distribution de la probabilite 
			line <- rnd_choice(["line_1"::1]);
			

		}
// Création des résidences et association aux communes correspondantes.
		create residence from: maison_shape_file {
			list<ward> the_wards <- list(ward) where ((each distance_to self <= 5));
			if (the_wards != []) {
				address <- the_wards[0].nom_commune;
			}
		}
		
		// Création de 50 personnes et placement aléatoire dans les résidences.

		create personne number: 100 {
			location <- any_location_in(one_of(residence));
		}
		
		// Construction du graphe de la route pour les simulations de circulation.
		road_network <- as_edge_graph(road);
		road_line_1 <- as_edge_graph(line_1);
		
		 // Sélection et transformation des segments spécifiques de la ligne 1 en graphes pour représenter les directions aller et retour.
     
		list<line_1> the_lines_1 <- list(line_1);
		road_line_1_aller <- as_edge_graph(the_lines_1[1]);
		road_line_1_retour <- as_edge_graph(the_lines_1[2]);
	} 
}
// Définition de l'espèce 'road' pour représenter les routes dans la simulation.
species road {
    // Définit la couleur des routes comme grise.
    rgb couleur <- #grey;

    // Aspect visuel par défaut pour dessiner les routes.
    aspect basic {
        // Dessine la forme de l'agent route avec la couleur définie.
        draw shape color: couleur width: 2;
    }
}


species bati {
    // Définit la couleur des routes comme grise.
    rgb couleur <- #green;

    // Aspect visuel par défaut pour dessiner les routes.
    aspect basic {
        // Dessine la forme de l'agent route avec la couleur définie.
        draw shape color: couleur;
    }
}





// Définition de l'espèce 'terminus' pour représenter les terminus des bus.
species terminus {
    // Définir la couleur des terminus.
    rgb couleur <- #green;
    // Variable pour stocker le nom du terminus.
    string terminus_name;

    // Aspect visuel par défaut pour dessiner les terminus.
    aspect default {
        // Dessine la forme de l'agent terminus avec la couleur définie.
        draw shape color: couleur;
    }
}

// Définition de l'espèce 'arret' pour représenter les arrêts de bus.
species arret {
    // Définit la couleur des arrêts de bus comme rouge.
    rgb couleur <- #red;
    // Variable pour stocker l'adresse de l'arrêt de bus.
    string address;
    // Variable pour stocker la ligne de bus desservant cet arrêt.
    string line_bus;

    // Aspect visuel par défaut pour dessiner les arrêts de bus.
    aspect default {
        // Dessine un cercle de rayon 15 avec la couleur définie pour représenter l'arrêt.
        draw circle(15) color: couleur;
    }
}



// Définition de l'espèce 'residence' pour représenter les résidences dans la simulation.
species residence {
    // Définit la couleur des résidences comme grise.
    rgb couleur <- #green;
    // Variable pour stocker l'adresse de la résidence.
    string address;

    // Aspect visuel par défaut pour dessiner les résidences.
    aspect default {
        // Dessine la forme de l'agent résidence avec la couleur définie.
        draw shape color: couleur;
    }
}

// Définition de l'espèce 'ward' pour représenter les quartiers dans la simulation.
species ward {
    // Définit la couleur des quartiers comme gris ardoise foncé.
    rgb couleur <- #darkslategrey;
    // Variable pour stocker le nom du district du quartier.
    string nom_commune;

    // Aspect visuel par défaut pour dessiner les quartiers.
    aspect default {
        // Dessine la forme de l'agent quartier avec la couleur définie.
        draw shape color: couleur;
    }
}

// Définition de l'espèce 'line_1' pour représenter la première ligne de bus.
species line_1 {
    // Définit la couleur de la ligne 1 comme rouge.
    rgb couleur <- #grey;
    // Variable pour stocker le nom du district associé à cette ligne.
    string nom_commune;

    // Aspect visuel par défaut pour dessiner la ligne 1.
    aspect default {
        // Dessine la forme de l'agent ligne 1 avec la couleur définie.
        draw shape color: couleur width: 2;
    }
}

// Définition de l'espèce 'bus' qui possède la capacité de se déplacer.
species bus skills: [moving] {
	// Définit l'état du bus (en station, en transit, etc.)
	string state <- "station";
    // Vitesse du bus, définie aléatoirement entre 1.0 et 4.0.
    float speed <- rnd(4.0, 4.0, 3.0);
    // Définit si le bus peut se déplacer ou non. //de type booleen
    bool peut_marcher <- true;
    // Nombre de personnes à l'intérieur du bus.
    int nb_personne_inside <- 0;
    // Définit la couleur du bus
    rgb couleur;
    // Définit la ligne de bus
    string line;
    // Cible du bus pour l'itinéraire
    point target <- nil;
    
    
    // Action pour contrôler les billets
    action control_tickets {
        list<personne> passengers <- list(personne) where each.state_to_get_in = "dans le bus";
        int without_ticket <- length(passengers where !each.has_ticket);
        if (without_ticket > 0) {
            write "Contrôle de billets : " + without_ticket + " passagers sans billet";
            // Logique pour pénaliser les passagers sans billet (ex. les faire descendre du bus)
        }
    }
    
    
    // Comportement deplacer pour l'agent bus.
    reflex move_behavior {
    	if (line = "line_1") {
    		if (state = "station") {
    			target <- {460, 1300};
    		}

    		if (self distance_to target <= 10 and state = "station") {
    			state <- "transit_1";
    		}

    		if (state = "transit_1") {
    			target <- {1540, 500};
    			if (self distance_to target <= 10) {
    				state <- "transit_2";
    			}

    		}

    		if (state = "transit_2") {
    			target <- {860, 1650};
    			if (self distance_to target <= 10) {
    				state <- "station";
    			}

    		}

    		if (peut_marcher) {
    			do goto target: target on: road_line_1 speed: speed;
    		}

    	}

    	// Action pour les personnes entrant dans le bus.
    	list<personne> the_personne <- list(personne) where ((each.state_to_get_in = "dans le bus") and (each distance_to self <= 20));
    	if (the_personne != []) {
    		nb_personne_inside <- length(the_personne);
    	}
    	
    	
    	

    }

    // Aspect visuel du bus, montrant le nombre de personnes à l'intérieur et sa forme.
    aspect basic {
    	draw image_file(bus_transco) size: (150) rotate: heading + 180 color: couleur;
    	if (nb_personne_inside >= 10) {
    		draw "MAX" color: #black;
    		
    	}

    } }





species vehicules skills: [moving] {
	// Définit l'état du bus (en station, en transit, etc.)
	string state <- "station";
    // Vitesse du bus, définie aléatoirement entre 1.0 et 4.0.
    float speed <- rnd(9.0, 9.0, 8.0);
    // Définit si le bus peut se déplacer ou non. //de type booleen
    bool peut_marcher <- true;
    // Nombre de personnes à l'intérieur du bus.
    int nb_personne_inside <- 0;
    // Définit la couleur du bus
    rgb couleur;
    // Définit la ligne de bus
    string line;
    // Cible du bus pour l'itinéraire
    point target <- nil;
    
    
    // Comportement deplacer pour l'agent bus.
    reflex move_behavior {
    	if (line = "line_1") {
    		if (state = "station") {
    			target <- {460, 1300};
    		}

    		if (self distance_to target <= 10 and state = "station") {
    			state <- "transit_1";
    		}

    		if (state = "transit_1") {
    			target <- {1540, 500};
    			if (self distance_to target <= 10) {
    				state <- "transit_2";
    			}

    		}

    		if (state = "transit_2") {
    			target <- {860, 1650};
    			if (self distance_to target <= 10) {
    				state <- "station";
    			}

    		}

    		if (peut_marcher) {
    			do goto target: target on: road_line_1 speed: speed;
    		}

    	}

    	// Action pour les personnes entrant dans le bus.
    	list<personne> the_people <- list(personne) where ((each.state_to_get_in = "dans le bus") and (each distance_to self <= 20));
    	if (the_people != []) {
    		nb_personne_inside <- length(the_people);
    	}

    }

    // Aspect visuel du bus, montrant le nombre de personnes à l'intérieur et sa forme.
    aspect basic {
    	draw image_file(car) size: (150) rotate: heading + 180 color: couleur;
    	if (nb_personne_inside >= 4) {
    		draw "MAX" color: #black;
    		write "Ce taxi est plein, ne peut plus ajouter des passagers";
    		
    		
    	}

    } }
    
    
    
    
    
    species motos skills: [moving] {
	// Définit l'état du bus (en station, en transit, etc.)
	string state <- "station";
    // Vitesse du bus, définie aléatoirement entre 1.0 et 4.0.
    float speed <- rnd(7.0, 7.0, 6.0);
    // Définit si le bus peut se déplacer ou non. //de type booleen
    bool peut_marcher <- true;
    // Nombre de personnes à l'intérieur du bus.
    int nb_personne_inside <- 0;
    // Définit la couleur du bus
    rgb couleur;
    // Définit la ligne de bus
    string line;
    // Cible du bus pour l'itinéraire
    point target <- nil;
    
    
    // Comportement deplacer pour l'agent bus.
    reflex move_behavior {
    	if (line = "line_1") {
    		if (state = "station") {
    			target <- {460, 1300};
    		}

    		if (self distance_to target <= 10 and state = "station") {
    			state <- "transit_1";
    		}

    		if (state = "transit_1") {
    			target <- {1540, 500};
    			if (self distance_to target <= 10) {
    				state <- "transit_2";
    			}

    		}

    		if (state = "transit_2") {
    			target <- {860, 1650};
    			if (self distance_to target <= 10) {
    				state <- "station";
    			}

    		}

    		if (peut_marcher) {
    			do goto target: target on: road_line_1 speed: speed;
    		}

    	}

    	// Action pour les personnes entrant dans le bus.
    	list<personne> the_people <- list(personne) where ((each.state_to_get_in = "dans le bus") and (each distance_to self <= 20));
    	if (the_people != []) {
    		nb_personne_inside <- length(the_people);
    	}

    }

    // Aspect visuel du bus, montrant le nombre de personnes à l'intérieur et sa forme.
    aspect basic {
    	draw image_file(moto) size: (150) rotate: heading + 360 color: couleur;
    	if (nb_personne_inside >= 2) {
    		draw "MAX" color: #black;
    	}

    } }
    	


// Définition de l'espèce 'people', représentant les individus dans la simulation.
species personne skills: [moving] {
    // Couleur assignée à chaque personne, ici fixée à jaune.
    rgb couleur <- #yellow;
    // Adresse de résidence actuelle de la personne.
    string living_address;
    // Adresse de travail visitée.
    string visiting_address;
    // Temps restant pour dormir, initialisé aléatoirement entre 50 et 100 unités de temps.
    int time_rest <- rnd(50, 100, 2);
    // Temps passé au travail, initialisé aléatoirement entre 40 et 70 unités de temps.
    int time_work <- rnd(40, 70, 2);
    // État initial de la personne, ici "dormant".
    string state <- "sleeping";
    // Cible actuelle de la personne dans le monde de la simulation.
    point his_target;
    // Arrêt de bus le plus proche du lieu de travail.
    arret the_nearest_bus_stop_working;
    // Indicateur si la personne peut marcher.
    bool peut_marcher <- true;
    // Vitesse de déplacement de la personne.
    float vitesse <- 2.0;
    // État pour embarquer dans le bus.
    string state_to_get_in;
    // Ligne de bus que la personne compte prendre.
    string line_bus;
    // Ligne de bus que la personne compte prendre.
    string line_vehicule;
    string line_moto;
    // Lieu de travail comme type de résidence.
    residence place_working;
    // Indicateur si la personne est déjà montée dans le bus.
    bool deja_entrer <- false;
    int prix_de_base<-1500;
    
     // Propriétés pour la billetterie
    bool has_ticket <- false;
    float ticket_price <- 1000.0;
    
    // Action pour acheter un billet
    action buy_ticket {
        has_ticket <- true;
        // Débit du coût du billet du budget de l'usager (à implémenter si vous avez un budget)
    }

    // Action pour valider un billet
    action validate_ticket {
        if (!has_ticket) {
            // Logique pour pénaliser ou interdire l'accès
        }
    }

    // Comportement pour gérer le sommeil des individus.
    reflex sleeping when: state = "sleeping" {
        time_rest <- time_rest - 1;
        if (time_rest = 0) {
            state <- "go working";  // Change l'état pour aller travailler.
        }
    }
    
  

    // Comportement pour démarrer le trajet vers le travail.
    reflex working when: state = "go working" {
        // Sélectionne aléatoirement un lieu de travail qui n'est pas l'adresse de résidence.
        list<residence> the_residence <- list(residence) where ((each.address != living_address));
        int j <- length(the_residence);
        place_working <- the_residence[rnd(j - 1)];
        // Trouve l'arrêt de bus le plus proche du lieu de travail.
        list<arret> the_bus_stop <- list(arret) where ((each.address = place_working.address));
        the_nearest_bus_stop_working <- first(the_bus_stop sort_by (place_working.location distance_to each));
        // Trouve le point d'embarquement le plus proche pour monter dans le bus.
        list<arret> the_pick_up_point <- list(arret) where ((each.line_bus = the_nearest_bus_stop_working.line_bus));
        arret the_nearest_pickup_point <- first(the_pick_up_point sort_by (self distance_to each));
        his_target <- the_nearest_pickup_point.location;
        line_bus <- the_nearest_pickup_point.line_bus;
        state <- "go take the bus";
    }
    


    // Comportement pour monter dans le bus.
    reflex get_in_on_the_bus {
        if (state = "go take the bus") {
            int stop_point <- rnd(10, 15, 1);
            if (self distance_to his_target <= stop_point) {
                peut_marcher <- false;
                state_to_get_in <- "arret bus";
            }
            list<bus> the_bus <- list(bus) where ((each distance_to self <= 20) and each.line = line_bus);
            if (the_bus != []) {
                his_target <- the_bus[0].location;
                vitesse <- 3.3;
                peut_marcher <- true;
                line_bus <- the_bus[0].line;
                state_to_get_in <- "dans le bus";
                if (!has_ticket) {
                    do buy_ticket;
                    write "Billet acheté : " + ticket_price + " Franc Congolais";
                }
                do validate_ticket;
                write "Embarquement des passagers dans le bus";  
            }
        }
        if (state_to_get_in = "dans le bus") {
            if (self distance_to the_nearest_bus_stop_working <= 5) {
                his_target <- place_working.location;
            }
        }
    }
    
    
    // Comportement pour monter dans le vehicule.
    reflex get_in_on_the_vehicules {
        if (state = "go take the bus") {
            int stop_point <- rnd(10, 15, 1);
            if (self distance_to his_target <= stop_point) {
                peut_marcher <- false;
                state_to_get_in <- "arret vehicules";
            }
            // Trouve le bus correspondant à la ligne et monte dedans.
            list<vehicules> the_vehicules <- list(vehicules) where ((each distance_to self <= 20) and each.line = line_bus);
            if (the_vehicules != []) {
                his_target <- the_vehicules[0].location;
                vitesse <- 3.3;
                peut_marcher <- true;
                line_bus <- the_vehicules[0].line;
                state_to_get_in <- "dans le vehicules";
                write "Embarquement des passagers dans le vehicule";  
                     float prix <- 1500.0;
                    write "================>>A payer  "+prix+" " +"Franc Congolais";
                
 		}

            }
            // Détermine si la personne est arrivée à destination.
            if (state_to_get_in = "dans le vehicules") {
                if (self distance_to the_nearest_bus_stop_working <= 50) {
                    his_target <- place_working.location;
            }
        }
    }
    
    
    
    
    
    // Comportement pour monter dans le vehicule.
    reflex get_in_on_the_motos {
        if (state = "go take the moto") {
            int stop_point <- rnd(10, 15, 1);
            if (self distance_to his_target <= stop_point) {
                peut_marcher <- false;
                state_to_get_in <- "arret motos";
            }
            // Trouve le bus correspondant à la ligne et monte dedans.
            list<motos> the_motos <- list(motos) where ((each distance_to self <= 20) and each.line = line_bus);
            if (the_motos != []) {
                his_target <- the_motos[0].location;
                vitesse <- 3.3;
                peut_marcher <- true;
                line_bus <- the_motos[0].line;
                state_to_get_in <- "dans le motos";
                write "Embarquement des passagers sur la moto";  
                     float prix <- 2000.0;
                    write "================>>A payer  "+prix+" " +"Franc Congolais";
                
 		}

            }
            // Détermine si la personne est arrivée à destination.
            if (state_to_get_in = "dans la moto") {
                if (self distance_to the_nearest_bus_stop_working <= 50) {
                    his_target <- place_working.location;
                    write "================>>A destination";
            }
        }
    }
    
    
    
    
    

    // Comportement de déplacement, exécuté si la personne peut marcher.
    reflex move_behavior when: peut_marcher = true {
        do goto target: his_target speed: vitesse;
    }

    // Aspect visuel par défaut des personnes, représentées par une pyramide et une sphère.

    
    aspect basic {
    draw image_file(icon) size:50;
}   
}



// Expérience de simulation pour visualiser la ville en 3D.
experiment Systeme_de_circulation_Kinshasa type: gui  {
    output {
        display map type: 3d {
            species road aspect: basic;
            species residence;
            species bus aspect: basic;
            species line_1;
            species personne aspect: basic;
            species arret;
            species vehicules aspect: basic;
            species motos aspect: basic;
            species bati aspect: basic;
        }
        
        
       
    }
}



