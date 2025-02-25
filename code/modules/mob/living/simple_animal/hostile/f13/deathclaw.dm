/mob/living/simple_animal/hostile/deathclaw
	name = "deathclaw"
	desc = "A massive, reptilian creature with powerful muscles, razor-sharp claws, and aggression to match."
	icon = 'icons/fallout/mobs/monsters/deathclaw.dmi'
	icon_state = "deathclaw"
	icon_living = "deathclaw"
	icon_dead = "deathclaw_dead"
	icon_gib = "deathclaw_gib"
	gender = MALE
	a_intent = INTENT_HARM //So we can not move past them.
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	robust_searching = 1
	speak = list("ROAR!","Rawr!","GRRAAGH!","Growl!")
	speak_emote = list("growls", "roars")
	emote_hear = list("grumbles.","grawls.")
	emote_taunt = list("stares ferociously", "stomps")
	speak_chance = 10
	taunt_chance = 25
	speed = -1
	see_in_dark = 8
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/deathclaw = 4,
							/obj/item/stack/sheet/animalhide/f13/deathclaw = 2,
							/obj/item/stack/sheet/bone/claw = 1)
	response_help_simple  = "pets"
	response_disarm_simple = "gently pushes aside"
	response_harm_simple   = "hits"
	maxHealth = 800
	health = 800
	obj_damage = 300
	environment_smash = 2 //wall-busts
	armour_penetration = 0.7
	melee_damage_lower = 60
	melee_damage_upper = 70
	attack_verb_simple = "claws"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	faction = list("deathclaw")
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 5
	gold_core_spawnable = HOSTILE_SPAWN
	var/charging = FALSE
	wound_bonus = 0 //This might be a TERRIBLE idea
	bare_wound_bonus = 0 //is already 0 from simple_animal.dm but putting it here for ease of adjustment
	sharpness = SHARP_EDGED

	emote_taunt_sound = list('sound/f13npc/deathclaw/taunt.ogg')
	aggrosound = list('sound/f13npc/deathclaw/aggro1.ogg', 'sound/f13npc/deathclaw/aggro2.ogg', )
	idlesound = list('sound/f13npc/deathclaw/idle.ogg',)
	death_sound = 'sound/f13npc/deathclaw/death.ogg'

/mob/living/simple_animal/hostile/deathclaw/playable
	emote_taunt_sound = null
	emote_taunt = null
	aggrosound = null
	idlesound = null
	see_in_dark = 8
	environment_smash = 2 //can smash walls
	wander = 0

/mob/living/simple_animal/hostile/deathclaw/mother
	name = "mother deathclaw"
	desc = "A massive, reptilian creature with powerful muscles, razor-sharp claws, and aggression to match. This one is an angry mother."
	gender = FEMALE
	maxHealth = 1000
	health = 1000
	stat_attack = UNCONSCIOUS
	melee_damage_lower = 70
	melee_damage_upper = 75
	armour_penetration = 0.75
	color = rgb(95,104,94)
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/deathclaw = 6,
		/obj/item/reagent_containers/food/snacks/f13/egg/deathclaw = 1,
		/obj/item/stack/sheet/animalhide/f13/deathclaw = 3,
		/obj/item/stack/sheet/bone/claw = 1)

/mob/living/simple_animal/hostile/deathclaw/legendary
	name = "legendary deathclaw"
	desc = "A massive, reptilian creature with powerful muscles, razor-sharp claws, and aggression to match. This one is a legendary enemy."
	maxHealth = 1400
	health = 1400
	color = "#FFFF00"
	stat_attack = UNCONSCIOUS
	melee_damage_lower = 80
	melee_damage_upper = 80
	armour_penetration = 0.9

/mob/living/simple_animal/hostile/deathclaw/legendary/death(gibbed)
	var/turf/T = get_turf(src)
	if(prob(60))
		new /obj/item/melee/unarmed/deathclawgauntlet(T)
	. = ..()

/mob/living/simple_animal/hostile/deathclaw/bullet_act(obj/item/projectile/Proj)
	if(!Proj)
		return
	if(prob(10))
		visible_message(SPAN_DANGER("\The [src] growls, enraged!"))
		sleep(3)
		Charge()
	if(prob(85) || Proj.damage > 30) //prob(x) = chance for proj to actually do something, adjust depending on how OP you want deathclaws to be
		return ..()
	else
		visible_message(SPAN_DANGER("\The [Proj] bounces off \the [src]'s thick hide!"))
		return 0

/mob/living/simple_animal/hostile/deathclaw/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!charging)
		..()

/mob/living/simple_animal/hostile/deathclaw/AttackingTarget()
	if(!charging)
		return ..()

/mob/living/simple_animal/hostile/deathclaw/Goto(target, delay, minimum_distance)
	if(!charging)
		..()

/mob/living/simple_animal/hostile/deathclaw/Move()
	if(charging)
		new /obj/effect/temp_visual/decoy/fading(loc,src)
		DestroySurroundings()
	. = ..()
	if(charging)
		DestroySurroundings()

/mob/living/simple_animal/hostile/deathclaw/proc/Charge()
	var/turf/T = get_turf(target)
	if(!T || T == loc)
		return
	charging = TRUE
	visible_message(SPAN_DANGER("[src] charges!"))
	DestroySurroundings()
	walk(src, 0)
	setDir(get_dir(src, T))
	var/obj/effect/temp_visual/decoy/D = new /obj/effect/temp_visual/decoy(loc,src)
	animate(D, alpha = 0, color = "#FF0000", transform = matrix()*2, time = 1)
	sleep(3)
	throw_at(T, get_dist(src, T), 1, src, 0, callback = CALLBACK(src, .proc/charge_end))

/mob/living/simple_animal/hostile/deathclaw/proc/charge_end(list/effects_to_destroy)
	charging = FALSE
	if(target)
		Goto(target, move_to_delay, minimum_distance)

/mob/living/simple_animal/hostile/deathclaw/Bump(atom/A)
	if(charging)
		if(isturf(A) || isobj(A) && A.density)
			A.ex_act(EXPLODE_HEAVY)
		DestroySurroundings()
	..()

/mob/living/simple_animal/hostile/deathclaw/throw_impact(atom/A)
	if(!charging)
		return ..()

	else if(isliving(A))
		var/mob/living/L = A
		L.visible_message(SPAN_DANGER("[src] slams into [L]!"), "<span class='userdanger'>[src] slams into you!</span>")
		L.apply_damage(melee_damage_lower/2, BRUTE)
		playsound(get_turf(L), 'sound/effects/meteorimpact.ogg', 100, 1)
		shake_camera(L, 4, 3)
		shake_camera(src, 2, 3)
		var/throwtarget = get_edge_target_turf(src, get_dir(src, get_step_away(L, src)))
		L.throw_at(throwtarget, 3)


	charging = FALSE
	charging = FALSE

//Power Armor Deathclaw the tankest and the scariest deathclaw in the West. One mistake will end you. May the choice be with you.
/mob/living/simple_animal/hostile/deathclaw/power_armor
	name = "power armored deathclaw"
	desc = "A massive, reptilian creature with powerful muscles, razor-sharp claws, and aggression to match. Someone had managed to put power armor on him."
	icon_state = "combatclaw"
	icon_living = "combatclaw"
	icon_dead = "combatclaw_dead"
	maxHealth = 2500
	health = 2500
	stat_attack = UNCONSCIOUS
	melee_damage_lower = 90
	melee_damage_upper = 90
	armour_penetration = 0.7
