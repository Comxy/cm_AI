/*
Shotguns always start with an ammo buffer and they work by alternating ammo and ammo_buffer1
in order to fire off projectiles. This is only done to enable burst fire for the shotgun.
Consequently, the shotgun should never fire more than three projectiles on burst as that
can cause issues with ammo types getting mixed up during the burst.
*/

/obj/item/weapon/gun/shotgun
	w_class = SIZE_LARGE
	mouse_pointer = 'icons/effects/mouse_pointer/shotgun_mouse.dmi'

	accuracy_mult = 1.15
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_INTERNAL_MAG|GUN_AUTO_EJECT_CASINGS
	gun_category = GUN_CATEGORY_SHOTGUN
	aim_slowdown = SLOWDOWN_ADS_SHOTGUN
	wield_delay = WIELD_DELAY_NORMAL //Shotguns are as hard to pull up as a rifle. They're quite bulky afterall
	has_empty_icon = FALSE
	has_open_icon = FALSE
	fire_delay_group = list(FIRE_DELAY_GROUP_SHOTGUN)

	fire_sound = 'sound/weapons/gun_shotgun.ogg'
	reload_sound = "shell_load"
	cocked_sound = 'sound/weapons/gun_shotgun_reload.ogg'
	var/break_sound = 'sound/weapons/handling/gun_mou_open.ogg'
	var/seal_sound = 'sound/weapons/handling/gun_mou_close.ogg'

	map_specific_decoration = FALSE
	var/gauge = "12g"

/obj/item/weapon/gun/shotgun/Initialize(mapload, spawn_empty)
	. = ..()
	if(current_mag)
		replace_tube(current_mag.current_rounds) //Populate the chamber.

/obj/item/weapon/gun/shotgun/get_examine_text(mob/user)
	. = ..()
	if(flags_gun_features & GUN_AMMO_COUNTER && user)
		var/chambered = in_chamber ? TRUE : FALSE
		. += "It has [current_mag.current_rounds][chambered ? "+1" : ""] / [current_mag.max_rounds] rounds remaining."

/obj/item/weapon/gun/shotgun/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_5)
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_3
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_10
	scatter = SCATTER_AMOUNT_TIER_6
	burst_scatter_mult = SCATTER_AMOUNT_TIER_6
	scatter_unwielded = SCATTER_AMOUNT_TIER_2
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil = RECOIL_AMOUNT_TIER_4
	recoil_unwielded = RECOIL_AMOUNT_TIER_2

/obj/item/weapon/gun/shotgun/proc/replace_tube(number_to_replace)
	if(!current_mag)
		return
	current_mag.chamber_contents = list()
	current_mag.chamber_contents.len = current_mag.max_rounds
	var/i
	for(i = 1 to current_mag.max_rounds) //We want to make sure to populate the tube.
		current_mag.chamber_contents[i] = i > number_to_replace ? "empty" : current_mag.default_ammo
	current_mag.chamber_position = current_mag.current_rounds //The position is always in the beginning [1]. It can move from there.

/obj/item/weapon/gun/shotgun/proc/add_to_tube(mob/user,selection) //Shells are added forward.
	if(!current_mag)
		return
	current_mag.chamber_position++ //We move the position up when loading ammo. New rounds are always fired next, in order loaded.
	current_mag.chamber_contents[current_mag.chamber_position] = selection //Just moves up one, unless the mag is full.
	if(current_mag.current_rounds == 1 && !in_chamber) //The previous proc in the reload() cycle adds ammo, so the best workaround here,
		update_icon() //This is not needed for now. Maybe we'll have loaded sprites at some point, but I doubt it. Also doesn't play well with double barrel.
		ready_in_chamber()
		cock_gun(user)
	if(user)
		playsound(user, reload_sound, 25, TRUE)
		if(flags_gun_features & GUN_AMMO_COUNTER)
			var/chambered = in_chamber ? TRUE : FALSE
			to_chat(user, SPAN_DANGER("[current_mag.current_rounds][chambered ? "+1" : ""] / [current_mag.max_rounds] ROUNDS REMAINING"))
	return TRUE

/obj/item/weapon/gun/shotgun/proc/empty_chamber(mob/user)
	if(!current_mag)
		return
	if(current_mag.current_rounds <= 0)
		if(in_chamber)
			in_chamber = null
			var/obj/item/ammo_magazine/handful/new_handful = retrieve_shell(ammo.type)
			playsound(user, reload_sound, 25, TRUE)
			new_handful.forceMove(get_turf(src))
			if(flags_gun_features & GUN_AMMO_COUNTER && user)
				var/chambered = in_chamber ? TRUE : FALSE //useless, but for consistency
				to_chat(user, SPAN_DANGER("[current_mag.current_rounds][chambered ? "+1" : ""] / [current_mag.max_rounds] ROUNDS REMAINING"))
		else
			if(user)
				to_chat(user, SPAN_WARNING("[src] is already empty."))
		return

	unload_shell(user)
	if(!current_mag.current_rounds && !in_chamber) update_icon()

/obj/item/weapon/gun/shotgun/proc/unload_shell(mob/user)
	if(isnull(current_mag) || !length(current_mag.chamber_contents))
		return
	var/obj/item/ammo_magazine/handful/new_handful = retrieve_shell(current_mag.chamber_contents[current_mag.chamber_position])

	if(user)
		user.put_in_hands(new_handful)
		playsound(user, reload_sound, 25, 1)
	else new_handful.forceMove(get_turf(src))

	current_mag.current_rounds--
	current_mag.chamber_contents[current_mag.chamber_position] = "empty"
	current_mag.chamber_position--
	return 1

		//While there is a much smaller way to do this,
		//this is the most resource efficient way to do it.
/obj/item/weapon/gun/shotgun/proc/retrieve_shell(selection)
	var/datum/ammo/A = GLOB.ammo_list[selection]
	var/obj/item/ammo_magazine/handful/new_handful = new A.handful_type()
	new_handful.generate_handful(selection, gauge, 5, 1, /obj/item/weapon/gun/shotgun)
	return new_handful

/obj/item/weapon/gun/shotgun/proc/check_chamber_position()
	return 1


/obj/item/weapon/gun/shotgun/reload(mob/user, obj/item/ammo_magazine/magazine)
	if(flags_gun_features & GUN_BURST_FIRING)
		return

	if(!magazine || !istype(magazine,/obj/item/ammo_magazine/handful)) //Can only reload with handfuls.
		to_chat(user, SPAN_WARNING("You can't use that to reload!"))
		return

	if(!check_chamber_position()) //For the double barrel.
		to_chat(user, SPAN_WARNING("[src] has to be open!"))
		return

	//From here we know they are using shotgun type ammo and reloading via handful.
	//Makes some of this a lot easier to determine.

	var/mag_caliber = magazine.default_ammo //Handfuls can get deleted, so we need to keep this on hand for later.
	if(current_mag.transfer_ammo(magazine,user,1))
		add_to_tube(user,mag_caliber) //This will check the other conditions.

/obj/item/weapon/gun/shotgun/unload(mob/user)
	if(flags_gun_features & GUN_BURST_FIRING)
		return
	empty_chamber(user)

/obj/item/weapon/gun/shotgun/proc/ready_shotgun_tube()
	if(isnull(current_mag) || !length(current_mag.chamber_contents))
		return
	if(current_mag.current_rounds > 0)
		ammo = GLOB.ammo_list[current_mag.chamber_contents[current_mag.chamber_position]]
		in_chamber = create_bullet(ammo, initial(name))
		current_mag.current_rounds--
		current_mag.chamber_contents[current_mag.chamber_position] = "empty"
		current_mag.chamber_position--
		return in_chamber

/obj/item/weapon/gun/shotgun/ready_in_chamber()
	return ready_shotgun_tube()

/obj/item/weapon/gun/shotgun/reload_into_chamber(mob/user)
	if(!active_attachable)
		in_chamber = null

		//Time to move the tube position.
		ready_in_chamber() //We're going to try and reload. If we don't get anything, icon change.
		if(!current_mag.current_rounds && !in_chamber) //No rounds, nothing chambered.
			update_icon()

	return 1


//-------------------------------------------------------
//GENERIC MERC SHOTGUN //Not really based on anything.

/obj/item/weapon/gun/shotgun/merc
	name = "custom built shotgun"
	desc = "A cobbled-together pile of scrap and alien wood. Point end towards things you want to die. Has a burst fire feature, as if it needed it."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/colony.dmi'
	icon_state = "cshotgun"
	item_state = "cshotgun"

	fire_sound = 'sound/weapons/gun_shotgun_automatic.ogg'
	current_mag = /obj/item/ammo_magazine/internal/shotgun/merc
	attachable_allowed = list(
		/obj/item/attachable/compensator,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_INTERNAL_MAG

/obj/item/weapon/gun/shotgun/merc/Initialize(mapload, spawn_empty)
	. = ..()
	if(current_mag && current_mag.current_rounds > 0)
		load_into_chamber()


/obj/item/weapon/gun/shotgun/merc/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 31, "muzzle_y" = 19,"rail_x" = 10, "rail_y" = 21, "under_x" = 17, "under_y" = 14, "stock_x" = 17, "stock_y" = 14)


/obj/item/weapon/gun/shotgun/merc/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_6*2)
	set_burst_amount(BURST_AMOUNT_TIER_2)
	set_burst_delay(FIRE_DELAY_TIER_11)
	accuracy_mult = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_4
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_10
	scatter = SCATTER_AMOUNT_TIER_6
	burst_scatter_mult = SCATTER_AMOUNT_TIER_4
	scatter_unwielded = SCATTER_AMOUNT_TIER_2
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil = RECOIL_AMOUNT_TIER_4
	recoil_unwielded = RECOIL_AMOUNT_TIER_2

/obj/item/weapon/gun/shotgun/merc/get_examine_text(mob/user)
	. = ..()
	if(in_chamber) . += "It has a chambered round."

/obj/item/weapon/gun/shotgun/merc/damaged
	name = "damaged custom built shotgun"
	desc = "A cobbled-together pile of scrap and alien wood. Point end towards things you want to die. Has a burst fire feature, as if it needed it. Well, it had one, this one's barrel has apparently exploded outwards like an overripe grape. Guess that's what happens when you DIY a shotgun."
	icon_state = "cshotgun_bad"

/obj/item/weapon/gun/shotgun/merc/damaged/set_gun_config_values()
	..()
	set_fire_delay(1.5 SECONDS)
	set_burst_amount(BURST_AMOUNT_TIER_1)
	accuracy_mult = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_6
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_10
	scatter = SCATTER_AMOUNT_TIER_5
	burst_scatter_mult = SCATTER_AMOUNT_TIER_3
	scatter_unwielded = SCATTER_AMOUNT_TIER_1
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil = RECOIL_AMOUNT_TIER_3
	recoil_unwielded = RECOIL_AMOUNT_TIER_1

//-------------------------------------------------------
//TACTICAL SHOTGUN

/obj/item/weapon/gun/shotgun/combat
	name = "\improper M120 tactical shotgun"
	desc = "A successor to the Benelli M4 Super 90, the M120 tactical shotgun is in service with the USCM due its easy maneuverability in close quarters, 12 gauge chambering, high firerate and integrated U1 underslung grenade launcher. While not part of the standard doctrine, they are common none the less. The internal tube magazine stores 6 shells and the U1 grenade launcher stores three grenades."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/uscm.dmi'
	icon_state = "mk221"
	item_state = "mk221"

	fire_sound = "gun_shotgun_tactical"

	flags_equip_slot = SLOT_BACK
	current_mag = /obj/item/ammo_magazine/internal/shotgun/combat
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonet/upp,
		/obj/item/attachable/bayonet/co2,
		/obj/item/attachable/reddot,
		/obj/item/attachable/reflex,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/compensator,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/stock/tactical,
		/obj/item/attachable/sling,
	)

/obj/item/weapon/gun/shotgun/combat/Initialize(mapload, spawn_empty)
	. = ..()
	if(current_mag && current_mag.current_rounds > 0)
		load_into_chamber()

/obj/item/weapon/gun/shotgun/combat/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 19,"rail_x" = 11, "rail_y" = 21, "under_x" = 22, "under_y" = 14, "stock_x" = 11, "stock_y" = 13, "side_rail_x" = 23, "side_rail_y" = 17)

/obj/item/weapon/gun/shotgun/combat/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_9)
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_3
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_10
	scatter = SCATTER_AMOUNT_TIER_6
	burst_scatter_mult = SCATTER_AMOUNT_TIER_6
	scatter_unwielded = SCATTER_AMOUNT_TIER_2
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil = RECOIL_AMOUNT_TIER_4
	recoil_unwielded = RECOIL_AMOUNT_TIER_2
	starting_attachment_types = list(/obj/item/attachable/attached_gun/grenade/mk1/m120, /obj/item/attachable/stock/tactical)

/obj/item/weapon/gun/shotgun/combat/get_examine_text(mob/user)
	. = ..()
	if(in_chamber) . += "It has a chambered round."

/obj/item/weapon/gun/shotgun/combat/unloaded
	current_mag = /obj/item/ammo_magazine/internal/shotgun/combat/unloaded

/obj/item/weapon/gun/shotgun/combat/slug
	current_mag = /obj/item/ammo_magazine/internal/shotgun/combat/slug

/obj/item/weapon/gun/shotgun/combat/riot
	current_mag = /obj/item/ammo_magazine/internal/shotgun/combat/riot

//SOF MK210, an earlier developmental variant of the MK211 tactical used by USCM SOF.
/obj/item/weapon/gun/shotgun/combat/marsoc
	name = "\improper XM38 tactical shotgun"
	desc = "An ARMAT design adopted for testing by the Marine Raiders due to it's compact size, high firerate and integrated magnetic harness system. You might think the size would leave its magazine tube wanting, but through engineering magic, the XM38 is capable of holding six shells with its internal tube magazine."
	icon_state = "mk210"
	item_state = "mk210"

	current_mag = /obj/item/ammo_magazine/internal/shotgun/marsoc

	flags_equip_slot = SLOT_WAIST|SLOT_BACK
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_INTERNAL_MAG|GUN_AUTO_EJECT_CASINGS
	auto_retrieval_slot = WEAR_J_STORE
	start_automatic = TRUE

/obj/item/weapon/gun/shotgun/combat/marsoc/Initialize(mapload, spawn_empty)
	. = ..()
	if(current_mag && current_mag.current_rounds > 0)
		load_into_chamber()

/obj/item/weapon/gun/shotgun/combat/marsoc/retrieve_to_slot(mob/living/carbon/human/user, retrieval_slot)
	if(retrieval_slot == WEAR_J_STORE) //If we are using a magharness...
		if(..(user, WEAR_WAIST)) //...first try to put it onto the waist.
			return TRUE
	return ..()

/*obj/item/weapon/gun/shotgun/combat/marsoc/handle_starting_attachment()
	return */ //we keep the UGL

/obj/item/weapon/gun/shotgun/combat/marsoc/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 19,"rail_x" = 10, "rail_y" = 21, "under_x" = 14, "under_y" = 16, "stock_x" = 14, "stock_y" = 16, "side_rail_x" = 25, "side_rail_y" = 18)

/obj/item/weapon/gun/shotgun/combat/marsoc/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_6)
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_3
	accuracy_mult_unwielded = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_3
	scatter = SCATTER_AMOUNT_TIER_6
	burst_scatter_mult = SCATTER_AMOUNT_TIER_6
	scatter_unwielded = SCATTER_AMOUNT_TIER_2
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil = RECOIL_AMOUNT_TIER_4
	recoil_unwielded = RECOIL_AMOUNT_TIER_2

//-------------------------------------------------------
//TYPE 23. SEMI-AUTO UPP SHOTGUN, BASED ON KS-23

/obj/item/weapon/gun/shotgun/type23
	name = "\improper KS-29/4 combat shotgun"
	desc = "A contemporary semi-automatic design based off of the KS-23, a Soviet-era pump-action riot shotgun chambered in 6 gauge shells. Updated for the UPP's Naval Infantry as a boarding gun, it was downgraded to 8 gauge chambering in order to make it more controllable without much loss to overall firepower and allow for easier storage of large quantities of shells on the individual user. Its internal tube magazine can store 4 shells."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/upp.dmi'
	icon_state = "type23_tactical"
	item_state = "type23_tactical"
	fire_sound = 'sound/weapons/gun_type23.ogg'
	current_mag = /obj/item/ammo_magazine/internal/shotgun/type23
	attachable_allowed = list(
		/obj/item/attachable/reddot, // Rail
		/obj/item/attachable/reddot/upp,
		/obj/item/attachable/reflex,
		/obj/item/attachable/reflex/upp,
		/obj/item/attachable/scope/upp,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/bayonet, // Muzzle
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/bayonet/upp,
		/obj/item/attachable/verticalgrip, // Underbarrel
		/obj/item/attachable/verticalgrip/upp,
		/obj/item/attachable/flashlight/grip,
		/obj/item/attachable/flashlight/grip/upp,
		/obj/item/attachable/attached_gun/flamer,
		/obj/item/attachable/attached_gun/flamer/advanced,
		/obj/item/attachable/attached_gun/extinguisher,
		/obj/item/attachable/burstfire_assembly,
		/obj/item/attachable/stock/type23, // Stock
		/obj/item/attachable/flashlight, // Side Rail
		)
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_INTERNAL_MAG|GUN_AUTO_EJECT_CASINGS
	flags_equip_slot = SLOT_BACK
	gauge = "8g"
	starting_attachment_types = list(/obj/item/attachable/stock/type23)

/obj/item/weapon/gun/shotgun/type23/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 19,"rail_x" = 13, "rail_y" = 21, "under_x" = 24, "under_y" = 15, "stock_x" = -1, "stock_y" = 17, "side_rail_x" = 25, "side_rail_y" = 18)

/obj/item/weapon/gun/shotgun/type23/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_8)
	accuracy_mult = BASE_ACCURACY_MULT
	accuracy_mult_unwielded = BASE_ACCURACY_MULT
	scatter = SCATTER_AMOUNT_TIER_4
	scatter_unwielded = SCATTER_AMOUNT_TIER_1
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil = RECOIL_AMOUNT_TIER_1
	recoil_unwielded = RECOIL_AMOUNT_TIER_1

/obj/item/weapon/gun/shotgun/type23/unloaded
	current_mag = /obj/item/ammo_magazine/internal/shotgun/type23/unloaded

/obj/item/weapon/gun/shotgun/type23/unloaded/stored
	current_mag = /obj/item/ammo_magazine/internal/shotgun/type23/unloaded
	starting_attachment_types = null

/obj/item/weapon/gun/shotgun/type23/slug
	current_mag = /obj/item/ammo_magazine/internal/shotgun/type23/slug

/obj/item/weapon/gun/shotgun/type23/riot
	current_mag = /obj/item/ammo_magazine/internal/shotgun/type23/riot

/obj/item/weapon/gun/shotgun/pump/type23
	name = "\improper KS-29 riot shotgun"
	desc = "A contemporary pump-action design based off of the KS-23, a Soviet-era riot shotgun chambered in 6 gauge shells. Like its Naval Infantry sibling, it is downgraded to 8 gauge chambering in order to make it more controllable without much loss to overall firepower and allow for easier storage of large quantities of shells on the individual user. Its internal tube magazine can store 4 shells."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/upp.dmi'
	icon_state = "type23_wood"
	item_state = "type23_wood"
	fire_sound = 'sound/weapons/gun_type23.ogg'
	current_mag = /obj/item/ammo_magazine/internal/shotgun/type23
	attachable_allowed = list(/obj/item/attachable/stock/type23/wood)
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_INTERNAL_MAG
	flags_equip_slot = SLOT_BACK
	gauge = "8g"
	starting_attachment_types = list(/obj/item/attachable/stock/type23/wood)

/obj/item/weapon/gun/shotgun/pump/type23/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 19,"rail_x" = 13, "rail_y" = 21, "under_x" = 24, "under_y" = 15, "stock_x" = 16, "stock_y" = 15, "side_rail_x" = 25, "side_rail_y" = 18)

/obj/item/weapon/gun/shotgun/pump/type23/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_8)
	accuracy_mult = BASE_ACCURACY_MULT
	accuracy_mult_unwielded = BASE_ACCURACY_MULT
	scatter = SCATTER_AMOUNT_TIER_4
	scatter_unwielded = SCATTER_AMOUNT_TIER_1
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil = RECOIL_AMOUNT_TIER_1
	recoil_unwielded = RECOIL_AMOUNT_TIER_1

/obj/item/weapon/gun/shotgun/pump/type23/unloaded
	current_mag = /obj/item/ammo_magazine/internal/shotgun/type23/unloaded

/obj/item/weapon/gun/shotgun/pump/type23/slug
	current_mag = /obj/item/ammo_magazine/internal/shotgun/type23/slug

/obj/item/weapon/gun/shotgun/pump/type23/riot
	current_mag = /obj/item/ammo_magazine/internal/shotgun/type23/riot

//-------------------------------------------------------
//DOUBLE SHOTTY

/obj/item/weapon/gun/shotgun/double
	name = "\improper Spearhead Rival 78"
	desc = "A double barrel shotgun produced by Spearhead. Archaic, sturdy, affordable. Only holds two 12g shells at a time."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/colony.dmi'
	icon_state = "dshotgun"
	item_state = "dshotgun"

	current_mag = /obj/item/ammo_magazine/internal/shotgun/double
	fire_sound = 'sound/weapons/gun_shotgun_heavy.ogg'
	break_sound = 'sound/weapons/handling/gun_mou_open.ogg'
	seal_sound = 'sound/weapons/handling/gun_mou_close.ogg'//replace w/ uniques
	cocked_sound = null //We don't want this.
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonet/upp,
		/obj/item/attachable/reddot,
		/obj/item/attachable/reflex,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/stock/double,
	)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_INTERNAL_MAG
	burst_delay = 0 //So doubleshotty can doubleshot
	has_open_icon = TRUE
	civilian_usable_override = TRUE // Come on. It's THE survivor shotgun.
	additional_fire_group_delay = 1.5 SECONDS

/obj/item/weapon/gun/shotgun/double/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 19,"rail_x" = 11, "rail_y" = 20, "under_x" = 15, "under_y" = 14, "stock_x" = 13, "stock_y" = 14, "side_rail_x" = 23, "side_rail_y" = 17)

/obj/item/weapon/gun/shotgun/double/set_gun_config_values()
	..()
	set_burst_amount(BURST_AMOUNT_TIER_2)
	set_fire_delay(FIRE_DELAY_TIER_11)
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_3
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_10
	scatter = SCATTER_AMOUNT_TIER_6
	burst_scatter_mult = SCATTER_AMOUNT_TIER_10
	scatter_unwielded = SCATTER_AMOUNT_TIER_2
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil = RECOIL_AMOUNT_TIER_4
	recoil_unwielded = RECOIL_AMOUNT_TIER_2

/obj/item/weapon/gun/shotgun/double/get_examine_text(mob/user)
	. = ..()
	if(!current_mag)
		return
	if(current_mag.chamber_closed) . += "It's closed."
	else . += "It's open with [current_mag.current_rounds] shell\s loaded."

/obj/item/weapon/gun/shotgun/double/unique_action(mob/user)
	if(flags_item & WIELDED)
		unwield(user)
	open_chamber(user)

/obj/item/weapon/gun/shotgun/double/check_chamber_position()
	if(!current_mag)
		return
	if(current_mag.chamber_closed)
		return
	return 1

/obj/item/weapon/gun/shotgun/double/add_to_tube(mob/user,selection) //Load it on the go, nothing chambered.
	if(!current_mag)
		return
	current_mag.chamber_position++
	current_mag.chamber_contents[current_mag.chamber_position] = selection
	playsound(user, reload_sound, 25, 1)
	return 1

/obj/item/weapon/gun/shotgun/double/able_to_fire(mob/user)
	. = ..()
	if(. && istype(user))
		if(!current_mag)
			return
		if(!current_mag.chamber_closed)
			to_chat(user, SPAN_DANGER("Close the chamber!"))
			return 0

/obj/item/weapon/gun/shotgun/double/empty_chamber(mob/user)
	if(!current_mag)
		return
	if(current_mag.chamber_closed)
		open_chamber(user)
	else
		..()

/obj/item/weapon/gun/shotgun/double/load_into_chamber()
	//Trimming down the unnecessary stuff.
	//This doesn't chamber, creates a bullet on the go.

	if(!current_mag)
		return
	if(current_mag.current_rounds > 0)
		ammo = GLOB.ammo_list[current_mag.chamber_contents[current_mag.chamber_position]]
		in_chamber = create_bullet(ammo, initial(name))
		current_mag.current_rounds--
		return in_chamber
	//We can't make a projectile without a mag or active attachable.


/obj/item/weapon/gun/shotgun/double/delete_bullet(obj/projectile/projectile_to_fire, refund = 0)
	qdel(projectile_to_fire)
	if(!current_mag)
		return
	if(refund) current_mag.current_rounds++
	return TRUE

/obj/item/weapon/gun/shotgun/double/reload_into_chamber(mob/user)
	if(!current_mag)
		return
	in_chamber = null
	current_mag.chamber_contents[current_mag.chamber_position] = "empty"
	current_mag.chamber_position--
	return 1

/obj/item/weapon/gun/shotgun/double/proc/open_chamber(mob/user, override)
	if(!current_mag)
		return
	current_mag.chamber_closed = !current_mag.chamber_closed
	update_icon()

	if (current_mag.chamber_closed)
		playsound(user, break_sound, 25, 1)
		eject_casing()
	else
		playsound(user, seal_sound, 25, 1)


/obj/item/weapon/gun/shotgun/double/with_stock/handle_starting_attachment()
	. = ..()
	var/obj/item/attachable/stock/double/S = new(src)
	S.hidden = FALSE
	S.flags_attach_features &= ~ATTACH_REMOVABLE
	S.Attach(src)
	update_attachable(S.slot)

/obj/item/weapon/gun/shotgun/double/upp
	name = "\improper MP-122 'Olympiets' hunting shotgun"
	desc = "A double barrel over-under shotgun produced by BaikalMech Factory. Mostly issued to colonists for protection against hostile fauna or hunting. Has a single scope mounting point right behind the barrel."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/upp.dmi'
	icon_state = "olympiets"
	item_state = "olympiets"
	flags_equip_slot = SLOT_BACK
	fire_sound = 'sound/weapons/gun_olympia.ogg'
	attachable_allowed = list(
		/obj/item/attachable/stock/olympiets,
		/obj/item/attachable/olympiets_barrel,
		/obj/item/attachable/scope/mini/hunting/upp,
	)

/obj/item/weapon/gun/shotgun/double/upp/handle_starting_attachment()
	. = ..()
	var/obj/item/attachable/stock/olympiets/stock = new(src)
	stock.flags_attach_features &= ~ATTACH_REMOVABLE
	stock.Attach(src)
	update_attachable(stock.slot)

	var/obj/item/attachable/olympiets_barrel/barrel = new(src)
	barrel.flags_attach_features &= ~ATTACH_REMOVABLE
	barrel.Attach(src)
	update_attachable(barrel.slot)

/obj/item/weapon/gun/shotgun/double/upp/set_gun_config_values()
	..()
	set_burst_amount(BURST_AMOUNT_TIER_2)
	set_fire_delay(FIRE_DELAY_TIER_11)
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_6
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_10
	scatter = SCATTER_AMOUNT_TIER_8
	burst_scatter_mult = SCATTER_AMOUNT_TIER_10
	scatter_unwielded = SCATTER_AMOUNT_TIER_2
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil = RECOIL_AMOUNT_TIER_4
	recoil_unwielded = RECOIL_AMOUNT_TIER_2

/obj/item/weapon/gun/shotgun/double/upp/open_chamber(mob/user, override)
	..()
	var/obj/item/attachable/olympiets_barrel/barrel = attachments["special"]
	if(!barrel)
		return
	if(current_mag.chamber_closed)
		attachable_offset["special_x"] = 35
		attachable_offset["special_y"] = 17
		barrel.attach_icon = "olympiets_barrel"
	else
		attachable_offset["special_x"] = 33
		attachable_offset["special_y"] = 7
		barrel.attach_icon = "olympiets_barrel_o"
	update_icon()

/obj/item/weapon/gun/shotgun/double/upp/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 19,"rail_x" = 9, "rail_y" = 22, "under_x" = 15, "under_y" = 14, "stock_x" = 16, "stock_y" = 15, "side_rail_x" = 23, "side_rail_y" = 17, "special_x" = 35, "special_y" = 17)

/obj/item/weapon/gun/shotgun/double/damaged
	name = "semi-sawn-off Spearhead Rival 78"
	desc = "A double barrel shotgun produced by Spearhead. Archaic, sturdy, affordable. For some reason it seems that someone tried to saw through the barrel and gave up halfway through. This probably isn't going to be the greatest gun for combat.."
	icon_state = "dshotgun_bad"

/obj/item/weapon/gun/shotgun/double/damaged/set_gun_config_values()
	..()
	set_burst_amount(BURST_AMOUNT_TIER_1)
	set_fire_delay(0.9 SECONDS)
	accuracy_mult = BASE_ACCURACY_MULT
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_10
	scatter = SCATTER_AMOUNT_TIER_7
	scatter_unwielded = SCATTER_AMOUNT_TIER_1
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil = RECOIL_AMOUNT_TIER_3
	recoil_unwielded = RECOIL_AMOUNT_TIER_1

/obj/item/weapon/gun/shotgun/double/sawn
	name = "\improper sawn-off Spearhead Rival 78"
	desc = "A double barrel shotgun produced by Spearhead. Archaic, sturdy, affordable. It has been artificially shortened to reduce range but increase damage and spread."
	icon_state = "sshotgun"
	item_state = "sshotgun"
	flags_equip_slot = SLOT_WAIST
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_INTERNAL_MAG

/obj/item/weapon/gun/shotgun/double/sawn/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 28, "muzzle_y" = 19, "rail_x" = 11, "rail_y" = 20, "under_x" = 15, "under_y" = 14,  "stock_x" = 18, "stock_y" = 16, "side_rail_x" = 19, "side_rail_y" = 16)

/obj/item/weapon/gun/shotgun/double/sawn/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_11)
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_3 - HIT_ACCURACY_MULT_TIER_5
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_10
	scatter = SCATTER_AMOUNT_TIER_6
	burst_scatter_mult = SCATTER_AMOUNT_TIER_10
	scatter_unwielded = SCATTER_AMOUNT_TIER_2
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil = RECOIL_AMOUNT_TIER_3
	recoil_unwielded = RECOIL_AMOUNT_TIER_1

// COULDN'T THINK OF ANOTHER WAY SORRY!!!! SOMEONE ADD A GUN COMPONENT!!

/obj/item/weapon/gun/shotgun/double/cane
	name = "fancy cane"
	desc = "An ebony cane with a fancy, seemingly-golden tip. Feels hollow to the touch."
	icon = 'icons/obj/items/weapons/weapons.dmi'
	icon_state = "fancy_cane"
	item_state = "fancy_cane"
	pickup_sound = null
	drop_sound = null
	item_icons = list(
		WEAR_L_HAND = 'icons/mob/humans/onmob/items_lefthand_0.dmi',
		WEAR_R_HAND = 'icons/mob/humans/onmob/items_righthand_0.dmi'
		)
	caliber = ".44"
	gauge = ".44" // misery
	force = 15 // hollow. also too hollow to support one's weight like normal canes
	attack_speed = 1.5 SECONDS
	current_mag = /obj/item/ammo_magazine/internal/shotgun/double/cane
	fire_sound = null
	fire_sounds = list('sound/weapons/gun_silenced_oldshot1.ogg', 'sound/weapons/gun_silenced_oldshot2.ogg') // Uses the old sounds because they're more 'James Bond'-y
	break_sound = 'sound/weapons/handling/pkd_open_chamber.ogg'
	seal_sound = 'sound/weapons/handling/pkd_close_chamber.ogg'
	attachable_allowed = list()

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_INTERNAL_MAG|GUN_TRIGGER_SAFETY|GUN_ONE_HAND_WIELDED|GUN_ANTIQUE|GUN_NO_DESCRIPTION|GUN_UNUSUAL_DESIGN
	flags_item = NO_FLAGS

	inherent_traits = list(TRAIT_GUN_SILENCED)

/obj/item/weapon/gun/shotgun/double/cane/Initialize(mapload, spawn_empty)
	. = ..()
	AddElement(/datum/element/traitbound/gun_silenced)

/obj/item/weapon/gun/shotgun/double/cane/set_gun_config_values()
	..()
	set_burst_amount(BURST_AMOUNT_TIER_1)
	set_fire_delay(FIRE_DELAY_TIER_7)
	accuracy_mult_unwielded = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_10
	scatter_unwielded = SCATTER_AMOUNT_TIER_7
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil = RECOIL_AMOUNT_TIER_2
	recoil_unwielded = RECOIL_AMOUNT_TIER_3

/obj/item/weapon/gun/shotgun/double/cane/gun_safety_handle(mob/user)
	if(flags_gun_features & GUN_TRIGGER_SAFETY)
		to_chat(user, SPAN_NOTICE("You turn [src] back into its normal cane stance."))
		playsound(user, 'sound/weapons/handling/nsg23_unload.ogg', 25, 1)
	else
		to_chat(user, SPAN_DANGER("You unlock the safety and change [src] into its gun stance!"))
		playsound(user, 'sound/weapons/handling/smg_reload.ogg', 25, 1)

	if(current_mag.chamber_closed == FALSE) // close the chamber
		open_chamber(user, TRUE)

	update_desc()
	update_icon()

	playsound(user, 'sound/weapons/handling/safety_toggle.ogg', 25, 1)

/obj/item/weapon/gun/shotgun/double/cane/proc/update_desc()
	if(flags_gun_features & GUN_TRIGGER_SAFETY)
		name = initial(name)
		desc = initial(desc)
	else
		name = "cane revolver"
		desc = initial(desc) + " Apparently, because it's a large revolver. Who'da thunk it?"

/obj/item/weapon/gun/shotgun/double/cane/open_chamber(mob/user, override)
	if(flags_gun_features & GUN_TRIGGER_SAFETY && !override)
		to_chat(user, SPAN_WARNING("Not with the safety on!"))
		return
	return ..()

/obj/item/weapon/gun/shotgun/double/cane/update_icon()
	if(flags_gun_features & GUN_TRIGGER_SAFETY)
		icon_state = initial(icon_state)

	else if(current_mag.chamber_closed == FALSE)
		icon_state = initial(icon_state) + "_gun_open"
	else
		icon_state = initial(icon_state) + "_gun"

//M-OU53 SHOTGUN | Marine mid-range slug/flechette only coach gun (except its an over-under). Support weapon for slug stuns / flechette DOTS (when implemented). Buckshot in this thing is just stupidly strong, hence the denial.

/obj/item/weapon/gun/shotgun/double/mou53
	name = "\improper MOU53 break action shotgun"
	desc = "A limited production Kerchner MOU53 triple break action classic. Respectable damage output at medium ranges, while the ARMAT M37 is the king of CQC, the Kerchner MOU53 is what hits the broadside of that barn. This specific model cannot safely fire buckshot shells."
	icon_state = "mou"
	item_state = "mou"
	var/max_rounds = 3
	var/current_rounds = 0
	fire_sound = 'sound/weapons/gun_mou53.ogg'
	reload_sound = 'sound/weapons/handling/gun_mou_reload.ogg'//unique shell insert
	flags_equip_slot = SLOT_BACK
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_INTERNAL_MAG
	current_mag = /obj/item/ammo_magazine/internal/shotgun/double/mou53 //Take care, she comes loaded!
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonet/upp,
		/obj/item/attachable/bayonet/co2,
		/obj/item/attachable/reddot,
		/obj/item/attachable/reflex,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/flashlight/grip,
		/obj/item/attachable/gyro,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/stock/mou53,
	)
	civilian_usable_override = FALSE

/obj/item/weapon/gun/shotgun/double/mou53/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 11, "rail_y" = 21, "under_x" = 17, "under_y" = 15, "stock_x" = 10, "stock_y" = 9, "side_rail_x" = 20, "side_rail_y" = 17) //Weird stock values, make sure any new stock matches the old sprite placement in the .dmi


/obj/item/weapon/gun/shotgun/double/mou53/set_gun_config_values()
	..()
	set_burst_amount(BURST_AMOUNT_TIER_1)
	set_fire_delay(FIRE_DELAY_TIER_11)
	accuracy_mult = BASE_ACCURACY_MULT
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_10
	scatter = SCATTER_AMOUNT_TIER_10
	scatter_unwielded = SCATTER_AMOUNT_TIER_2
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil = RECOIL_AMOUNT_TIER_3
	recoil_unwielded = RECOIL_AMOUNT_TIER_2

/obj/item/weapon/gun/shotgun/double/mou53/reload(mob/user, obj/item/ammo_magazine/magazine)
	if(ispath(magazine.default_ammo, /datum/ammo/bullet/shotgun/buckshot)) // No buckshot in this gun
		to_chat(user, SPAN_WARNING("\the [src] cannot safely fire this type of shell!"))
		return
	..()




//TWO BORE - Van Bandolier's ginormous elephant gun.
/datum/action/item_action/specialist/twobore_brace
	ability_primacy = SPEC_PRIMARY_ACTION_1

/datum/action/item_action/specialist/twobore_brace/New(mob/living/user, obj/item/holder)
	..()
	name = "Brace for Recoil"
	action_icon_state = "twobore_brace"
	button.name = name
	button.overlays.Cut()
	button.overlays += image('icons/mob/hud/actions.dmi', button, action_icon_state)

/datum/action/item_action/specialist/twobore_brace/can_use_action()
	var/mob/living/carbon/human/H = owner
	if(H.is_mob_incapacitated() || H.get_active_hand() != holder_item)
		return
	if(H.action_busy)
		to_chat(H, SPAN_WARNING("You're already doing something!"))
		return
	return TRUE

/datum/action/item_action/specialist/twobore_brace/action_cooldown_check()
	var/obj/item/weapon/gun/shotgun/double/twobore/G = holder_item
	if(G.braced)
		return TRUE

/datum/action/item_action/specialist/twobore_brace/action_activate()
	. = ..()
	var/obj/item/weapon/gun/shotgun/double/twobore/G = holder_item
	if(G.braced)
		return
	var/mob/living/carbon/human/H = owner
	if(!do_after(H, 0.5 SECONDS, INTERRUPT_ALL, BUSY_ICON_HOSTILE)) //Takes a moment to brace to fire.
		to_chat(H, SPAN_WARNING("You were interrupted!"))
		return
	H.visible_message(SPAN_WARNING("[H] braces himself to fire the [initial(G.name)]."),\
			SPAN_WARNING("You brace yourself to fire the [initial(G.name)]."))
	G.brace(H)
	update_button_icon()

/obj/item/weapon/gun/shotgun/double/twobore
	name = "two-bore rifle"
	desc = "An enormously heavy double-barreled rifle with a bore big enough to fire the Moon. If you want an intact trophy, don't aim for the head. \nThe recoil is apocalyptic: if you aren't highly experienced with it and braced using a Specialist Activation, you won't get a second shot."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/event.dmi'
	icon_state = "twobore"
	item_state = "twobore"
	unacidable = TRUE
	indestructible = TRUE
	force = 20 //Big heavy elephant gun.
	current_mag = /obj/item/ammo_magazine/internal/shotgun/double/twobore
	gauge = "2 bore"
	fire_sound = 'sound/weapons/gun_mateba.ogg'
	break_sound = 'sound/weapons/handling/gun_mou_open.ogg'
	seal_sound = 'sound/weapons/handling/gun_mou_close.ogg'//replace w/ uniques
	cocked_sound = null //We don't want this.
	attachable_allowed = list()
	delay_style = WEAPON_DELAY_NO_FIRE //This is a heavy, bulky weapon, and tricky to snapshot with.
	flags_equip_slot = SLOT_BACK
	actions_types = list(/datum/action/item_action/specialist/twobore_brace)
	starting_attachment_types = list(/obj/item/attachable/stock/twobore)
	aim_slowdown = SLOWDOWN_ADS_LMG //Quite slow, but VB has light-armor slowdown and doesn't feel pain.
	civilian_usable_override = FALSE
	var/braced = FALSE
	var/fired_shots = 0 //How many shots were fired since it was last closed, for casing ejection purposes.
	var/image/fired_casing

/obj/item/weapon/gun/shotgun/double/twobore/Initialize(mapload, spawn_empty)
	. = ..()
	fired_casing = image('icons/obj/items/weapons/projectiles.dmi', "casing_twobore", ABOVE_BLOOD_LAYER)
	fired_casing.appearance_flags = PIXEL_SCALE

/obj/item/weapon/gun/shotgun/double/twobore/set_gun_config_values()
	..()
	set_burst_amount(BURST_AMOUNT_TIER_1)
	set_fire_delay(2 SECONDS )//Less than the stun time, but you still have to brace to fire safely.
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_5
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_10
	scatter = SCATTER_AMOUNT_TIER_8
	scatter_unwielded = SCATTER_AMOUNT_TIER_2
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil = RECOIL_OFF //This is done manually.
	recoil_unwielded = RECOIL_OFF

/obj/item/weapon/gun/shotgun/double/twobore/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 21,"rail_x" = 15, "rail_y" = 22, "under_x" = 21, "under_y" = 16, "stock_x" = 0, "stock_y" = 16)

/obj/item/weapon/gun/shotgun/double/twobore/proc/brace(mob/living/carbon/human/user)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(unbrace), user)
	RegisterSignal(src, COMSIG_ITEM_DROPPED, PROC_REF(unbrace), user)
	RegisterSignal(src, COMSIG_ITEM_EQUIPPED, PROC_REF(unbrace), user)
	braced = TRUE

///Returns TRUE if the gun was braced.
/obj/item/weapon/gun/shotgun/double/twobore/proc/unbrace(mob/living/carbon/human/user)
	SIGNAL_HANDLER
	if(braced)
		to_chat(user, SPAN_NOTICE("You relax your stance."))
		braced = FALSE
		UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
		UnregisterSignal(src, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))
		for(var/X in actions)
			var/datum/action/A = X
			A.update_button_icon()
		return TRUE

/obj/item/weapon/gun/shotgun/double/twobore/item_action_slot_check(mob/user, slot)
	if(HAS_TRAIT(user, TRAIT_TWOBORE_TRAINING)) //Only the hunter himself knows how to use this weapon properly.
		return TRUE

/obj/item/weapon/gun/shotgun/double/twobore/open_chamber(mob/user)
	..()
	if(!fired_shots) //No empty shells. Means it wasn't fired or is being closed.
		return

	var/turf/floor = get_turf(src)
	if(fired_shots == 1)
		to_chat(user, SPAN_NOTICE("An empty shell falls to [floor] as you open the [initial(name)]."))
	else
		to_chat(user, SPAN_NOTICE("Two empty shells fall to [floor] as you open the [initial(name)]."))

	playsound(user, "gun_casing_shotgun", 25, TRUE)

	for(var/I in 1 to fired_shots)
		fired_casing.transform = matrix(rand(0,359), MATRIX_ROTATE)*matrix(rand(-14,14), rand(-14,14), MATRIX_TRANSLATE)
		floor.overlays += fired_casing
	fired_shots = 0

/obj/item/weapon/gun/shotgun/double/twobore/Fire(atom/target, mob/living/carbon/human/user, params, reflex = 0, dual_wield) //Using this instead of apply_bullet_effects() as RPG does so I get more granular angles than just user direction.
	var/prefire_rounds = current_mag.current_rounds //How many rounds do we have before we fire?
	. = ..()
	if(current_mag.current_rounds == prefire_rounds) //We didn't fire a shot.
		return NONE
	var/target_angle = Get_Compass_Dir(user, target) //More precise than get_dir().
	fired_shots++
	twobore_recoil(user, target_angle)

/obj/item/weapon/gun/shotgun/double/twobore/attack(mob/living/M, mob/living/user, def_zone)
	var/target_angle
	if(M != user && get_turf(M) != get_turf(user))
		target_angle = get_dir(user, M)

	var/prefire_rounds = current_mag.current_rounds //How many rounds do we have before we fire?
	..()
	if(current_mag.current_rounds == prefire_rounds) //We didn't fire a shot.
		return
	fired_shots++
	twobore_recoil(user, target_angle)

/obj/item/weapon/gun/shotgun/double/twobore/proc/twobore_recoil(mob/living/carbon/human/user, target_angle)
	var/turf/start_turf = get_turf(user)
	//Muzzle smoke. Black powder is messy.
	var/obj/effect/particle_effect/smoke/newsmoke = new(get_step(start_turf, target_angle), 1, src, user)
	newsmoke.time_to_live = 3

	var/suicide //Target is or is on the same tile as the shooter. Means the gun goes one way and the shooter stays.
	var/behind_angle
	if(target_angle)
		behind_angle = REVERSE_DIR(target_angle)
	else
		suicide = TRUE
		behind_angle = pick(CARDINAL_ALL_DIRS) //Random angle

	if(flags_item & WIELDED)
		if(braced && !suicide) //Recoil and brief stun but nothing more. Gun is huge and you can't brace properly when shooting at extreme (same tile) close range.
			user.visible_message(SPAN_WARNING("[user] rocks back under the heavy recoil of the [initial(name)]."),\
				SPAN_DANGER("The [initial(name)] kicks like an elephant!"))
			unbrace(user)
			user.apply_effect(1, STUN) //Van Bandolier is a human/hero and stuns last half as long for him.
			shake_camera(user, RECOIL_AMOUNT_TIER_2 * 0.5, RECOIL_AMOUNT_TIER_2)
			return
	else //You *do not* fire this one-handed.
		var/obj/limb/shoulder
		if(user.hand) //They're using their left hand.
			shoulder = user.get_limb("l_arm")
			user.apply_damage(15, BRUTE, "l_arm")
		else
			shoulder = user.get_limb("r_arm")
			user.apply_damage(15, BRUTE, "r_arm")
		shoulder.fracture(100)
		if(!(shoulder.status & LIMB_SPLINTED_INDESTRUCTIBLE) && (shoulder.status & LIMB_SPLINTED)) //If they have it splinted, the splint won't hold.
			shoulder.status &= ~LIMB_SPLINTED
			playsound(get_turf(loc), 'sound/items/splintbreaks.ogg', 20)
			to_chat(user, SPAN_DANGER("The splint on your [shoulder.display_name] comes apart under the recoil!"))
			user.pain.apply_pain(PAIN_BONE_BREAK_SPLINTED)
			user.update_med_icon()

	//Ruh roh.
	user.visible_message(SPAN_WARNING("[user] is thrown to the ground by the recoiling [initial(name)]!"),\
		SPAN_HIGHDANGER("The world breaks in half!"))
	shake_camera(user, RECOIL_AMOUNT_TIER_1 * 0.5, RECOIL_AMOUNT_TIER_1)

	var/turf/behind_turf = get_step(user, behind_angle)
	if(suicide || !behind_turf) //in case of map edge or w/e. If firing at something on the same tile, we don't throw the gun as far away.
		behind_turf = start_turf

	//Assemble a list of target turfs in a rough cone behind us.
	var/list/throw_turfs = list(
		get_step(behind_turf, behind_angle),
		get_step(behind_turf, turn(behind_angle, 45)),
		get_step(behind_turf, turn(behind_angle, -45))
		)

	//Sift through the turfs to remove ones that don't exist, and move ones that we can't throw the whole way into to a last-resort list.
	var/list/bad_turfs = list()
	add_temp_pass_flags(PASS_OVER_THROW_ITEM) //We'll be using the gun to test objects to see if it can pass over, so we set throw flags on.
	for(var/turf/T in throw_turfs)
		if(!T) //Off edge of map.
			throw_turfs.Remove(T)
			continue
		var/list/turf/path = get_line(get_step_towards(src, T), T) //Same path throw code will calculate from.
		if(!length(path))
			throw_turfs.Remove(T)
			continue
		var/prev_turf = start_turf
		for(var/turf/P in path)
			if(P.density || LinkBlocked(src, prev_turf, P))
				throw_turfs.Remove(T)
				bad_turfs.Add(T)
				break
			prev_turf = P
	remove_temp_pass_flags(PASS_OVER_THROW_ITEM)

	//Pick a turf to throw into.
	var/throw_turf
	var/throw_strength = 1
	if(length(throw_turfs)) //If there's any ideal throwpaths, pick one.
		throw_turf = pick(throw_turfs)
		throw_strength = suicide ? 1 : 2
	else if(length(bad_turfs)) //Otherwise, pick from blocked paths.
		throw_turf = pick(bad_turfs)
	else //If there's nowhere to put it, throw it to the same place we're putting the shooter.
		throw_turf = behind_turf

	user.drop_inv_item_on_ground(src)
	throw_atom(throw_turf, throw_strength, SPEED_AVERAGE, src, TRUE)

	user.apply_effect(2, WEAKEN)
	user.apply_effect(3, DAZE)
	if(!suicide && !step(user, behind_angle))
		user.animation_attack_on(behind_turf)
		playsound(user.loc, "punch", 25, TRUE)
		var/blocker = LinkBlocked(user, start_turf, behind_turf) //returns any objects blocking the user from moving back.
		if(blocker)
			user.visible_message(SPAN_DANGER("[user] slams into [blocker]!"),\
				SPAN_DANGER("The [initial(name)]'s recoil hammers you against [blocker]!"))
		else
			user.visible_message(SPAN_DANGER("[user] slams into an obstacle!"),\
				SPAN_DANGER("The [initial(name)]'s recoil hammers you against an obstacle!"))
		user.apply_damage(5, BRUTE)


//-------------------------------------------------------
//PUMP SHOTGUN
//Shotguns in this category will need to be pumped each shot.

/obj/item/weapon/gun/shotgun/pump
	name = "Ithaca 37 pump-action shotgun"
	desc = "A customized Ithaca 37 hunting shotgun. Its wooden stock has been replaced with a bakelite pistol grip, and its barrel and magazine tube have been cut down to half their lengths for easier handling in close quarters at the cost of magazine size, only fitting four shells and one chambered."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/uscm.dmi'
	icon_state = "m37"
	item_state = "m37"
	current_mag = /obj/item/ammo_magazine/internal/shotgun
	flags_equip_slot = SLOT_BACK
	fire_sound = 'sound/weapons/gun_shotgun.ogg'
	var/pump_sound = "shotgunpump"
	var/pump_delay //Higher means longer delay.
	var/recent_pump //world.time to see when they last pumped it.
	var/pumped = FALSE //Used to see if the shotgun has already been pumped.
	var/message //To not spam the above.
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonet/upp,
		/obj/item/attachable/bayonet/co2,
		/obj/item/attachable/reddot,
		/obj/item/attachable/reflex,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/flashlight/grip,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/flashlight/grip,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/compensator,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/attached_gun/extinguisher,
		/obj/item/attachable/attached_gun/flamer,
		/obj/item/attachable/attached_gun/flamer/advanced,
		/obj/item/attachable/stock/shotgun,
		/obj/item/attachable/sling,
	)

/obj/item/weapon/gun/shotgun/pump/Initialize(mapload, spawn_empty)
	. = ..()
	pump_delay = FIRE_DELAY_TIER_8
	additional_fire_group_delay += pump_delay


/obj/item/weapon/gun/shotgun/pump/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 19,"rail_x" = 12, "rail_y" = 20, "under_x" = 20, "under_y" = 14, "stock_x" = 20, "stock_y" = 14, "side_rail_x" = 25, "side_rail_y" = 18)


/obj/item/weapon/gun/shotgun/pump/set_gun_config_values()
	..()
	set_burst_amount(BURST_AMOUNT_TIER_1)
	set_fire_delay(FIRE_DELAY_TIER_7)
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_3
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_10
	scatter = SCATTER_AMOUNT_TIER_6
	burst_scatter_mult = SCATTER_AMOUNT_TIER_6
	scatter_unwielded = SCATTER_AMOUNT_TIER_2
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil = RECOIL_AMOUNT_TIER_4
	recoil_unwielded = RECOIL_AMOUNT_TIER_2
	//wield_delay = WIELD_DELAY_MIN

/obj/item/weapon/gun/shotgun/pump/unique_action(mob/user)
	pump_shotgun(user)

/obj/item/weapon/gun/shotgun/pump/ready_in_chamber() //If there wasn't a shell loaded through pump, this returns null.
	return

//Same as double barrel. We don't want to do anything else here.
/obj/item/weapon/gun/shotgun/pump/add_to_tube(mob/user, selection) //Load it on the go, nothing chambered.
	if(!current_mag)
		return
	current_mag.chamber_position++
	current_mag.chamber_contents[current_mag.chamber_position] = selection
	playsound(user, reload_sound, 25, 1)
	return 1
	/*
	Moves the ready_in_chamber to it's own proc.
	If the Fire() cycle doesn't find a chambered round with no active attachable, it will return null.
	Which is what we want, since the gun shouldn't fire unless something was chambered.
	*/

//More or less chambers the round instead of load_into_chamber().
/obj/item/weapon/gun/shotgun/pump/proc/pump_shotgun(mob/user) //We can't fire bursts with pumps.
	if(world.time < (recent_pump + pump_delay) )
		return //Don't spam it.
	if(pumped)
		if (world.time > (message + pump_delay))
			to_chat(usr, SPAN_WARNING("<i>[src] already has a shell in the chamber!<i>"))
			message = world.time
		return
	if(in_chamber) //eject the chambered round
		in_chamber = null
		var/obj/item/ammo_magazine/handful/new_handful = retrieve_shell(ammo.type)
		new_handful.forceMove(get_turf(src))

	ready_shotgun_tube()

	playsound(user, pump_sound, 10, 1)
	eject_casing()
	recent_pump = world.time
	if (in_chamber)
		pumped = TRUE


/obj/item/weapon/gun/shotgun/pump/reload_into_chamber(mob/user)
	if(!current_mag)
		return
	if(!active_attachable)
		pumped = FALSE //It was fired, so let's unlock the pump.
		in_chamber = null
		//Time to move the tube position.
		if(!current_mag.current_rounds && !in_chamber)
			update_icon()//No rounds, nothing chambered.

	return 1

/obj/item/weapon/gun/shotgun/pump/unload(mob/user) //We can't pump it to get rid of the shells, so we'll make it work via the unloading mechanism.
	if(pumped)
		to_chat(user, SPAN_WARNING("You release the locking mechanism on [src]."))
		pumped = FALSE
	return ..()

/obj/item/weapon/gun/shotgun/pump
	current_mag = /obj/item/ammo_magazine/internal/shotgun

/obj/item/weapon/gun/shotgun/pump/unloaded
	current_mag = /obj/item/ammo_magazine/internal/shotgun/unloaded

//-------------------------------------------------------

/obj/item/weapon/gun/shotgun/pump/dual_tube
	name = "generic dual-tube pump shotgun"
	desc = "A twenty-round pump action shotgun with dual internal tube magazines. You can switch the active internal magazine by toggling the shotgun tube."
	current_mag = /obj/item/ammo_magazine/internal/shotgun
	var/obj/item/ammo_magazine/internal/shotgun/primary_tube
	var/obj/item/ammo_magazine/internal/shotgun/secondary_tube

/obj/item/weapon/gun/shotgun/pump/dual_tube/Initialize(mapload, spawn_empty)
	. = ..()
	primary_tube = current_mag
	secondary_tube = new current_mag.type(src, spawn_empty ? TRUE : FALSE)
	current_mag = secondary_tube
	replace_tube(current_mag.current_rounds)

/obj/item/weapon/gun/shotgun/pump/dual_tube/Destroy()
	QDEL_NULL(primary_tube)
	QDEL_NULL(secondary_tube)
	. = ..()

/obj/item/weapon/gun/shotgun/pump/dual_tube/proc/swap_tube(mob/user)
	if(!ishuman(user) || user.is_mob_incapacitated())
		return FALSE
	var/obj/item/weapon/gun/shotgun/pump/dual_tube/shotgun = user.get_active_hand()
	if(shotgun != src)
		to_chat(user, SPAN_WARNING("You must be holding \the [src] in your active hand to switch the active internal magazine!")) // currently this warning can't show up, but this is incase you get an action button or similar for it instead of current implementation
		return
	if(!current_mag)
		return
	if(current_mag == primary_tube)
		current_mag = secondary_tube
	else
		current_mag = primary_tube
	to_chat(user, SPAN_NOTICE("[icon2html(src, user)] You switch \the [src]'s active magazine to the [(current_mag == primary_tube) ? "<b>first</b>" : "<b>second</b>"] magazine."))
	playsound(src, 'sound/machines/switch.ogg', 15, TRUE)
	return TRUE

/obj/item/weapon/gun/shotgun/pump/dual_tube/verb/toggle_tube()
	set category = "Weapons"
	set name = "Toggle Shotgun Tube"
	set desc = "Toggles which shotgun tube your gun loads from."
	set src = usr.contents

	var/obj/item/weapon/gun/shotgun/pump/dual_tube/shotgun = get_active_firearm(usr)
	if(shotgun == src)
		swap_tube(usr)

//SHOTGUN FROM ISOLATION

/obj/item/weapon/gun/shotgun/pump/dual_tube/cmb
	name = "\improper HG 37-12 pump shotgun"
	desc = "An eight-round pump action shotgun with four-round capacity dual internal tube magazines allowing for quick reloading and highly accurate fire. Standard issue shotgun of the Colonial Marshals Bureau. By toggling the shotgun tube, you can swap between the internal magazines."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/colony.dmi'
	icon_state = "hg3712"
	item_state = "hg3712"
	fire_sound = 'sound/weapons/gun_shotgun_small.ogg'
	current_mag = /obj/item/ammo_magazine/internal/shotgun/cmb
	attachable_allowed = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/reflex,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/compensator,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/attached_gun/extinguisher,
		/obj/item/attachable/attached_gun/flamer,
		/obj/item/attachable/attached_gun/flamer/advanced,
	)
	starting_attachment_types = list(/obj/item/attachable/stock/hg3712)
	civilian_usable_override = TRUE // Come on. It's THE, er, other, survivor shotgun.


/obj/item/weapon/gun/shotgun/pump/dual_tube/cmb/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 31, "muzzle_y" = 17,"rail_x" = 8, "rail_y" = 21, "under_x" = 22, "under_y" = 15, "stock_x" = 24, "stock_y" = 10, "side_rail_x" = 27, "side_rail_y" = 17)


/obj/item/weapon/gun/shotgun/pump/dual_tube/cmb/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_7)
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_3
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_10
	scatter = SCATTER_AMOUNT_TIER_6
	burst_scatter_mult = SCATTER_AMOUNT_TIER_6
	scatter_unwielded = SCATTER_AMOUNT_TIER_2
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil = RECOIL_AMOUNT_TIER_4
	recoil_unwielded = RECOIL_AMOUNT_TIER_2

/obj/item/weapon/gun/shotgun/pump/dual_tube/cmb/slug
	current_mag = /obj/item/ammo_magazine/internal/shotgun/cmb/slug

/obj/item/weapon/gun/shotgun/pump/dual_tube/cmb/m3717
	name = "\improper M37-17 pump shotgun"
	desc = "A military version of the iconic HG 37-12, this design can fit one extra shell in each of its dual-tube internal magazines, and fires shells with increased velocity, resulting in more damage. Issued to select USCM vessels and stations in the outer veil. A button on the side toggles the internal tubes."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/uscm.dmi'
	icon_state = "m3717"
	item_state = "m3717"
	current_mag = /obj/item/ammo_magazine/internal/shotgun/cmb/m3717
	starting_attachment_types = list(/obj/item/attachable/stock/hg3712/m3717)

//-------------------------------------------------------


//-------------------------------------------------------
//XM51, Breaching Scattergun, PVE Edition: civilian magfed shotgun

/obj/item/weapon/gun/rifle/xm51
	name = "\improper M1771 shotgun"
	desc = "Full designation: Model 1771 Cobra Max Tactical. Magazine-fed, pump-action shotgun designed by ARMAT Battlefield Systems meant for civilian and law-enforcement use. Failed its short USCM trials due to unreliability and was ridiculed heavily for having a 'tryhard' name."
	icon_state = "xm51"
	item_state = "xm51"
	mouse_pointer = 'icons/effects/mouse_pointer/shotgun_mouse.dmi'

	fire_sound = 'sound/weapons/gun_shotgun_xm51.ogg'
	reload_sound = 'sound/weapons/handling/l42_reload.ogg'
	unload_sound = 'sound/weapons/handling/l42_unload.ogg'

	current_mag = /obj/item/ammo_magazine/rifle/xm51
	attachable_allowed = list(
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonet/upp,
		/obj/item/attachable/bayonet/co2,
		/obj/item/attachable/reddot,
		/obj/item/attachable/reflex,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/gyro,
		/obj/item/attachable/flashlight/grip,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/stock/xm51,
		/obj/item/attachable/stock/xm51/military,
	)
	flags_equip_slot = SLOT_BACK
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER
	gun_category = GUN_CATEGORY_SHOTGUN
	aim_slowdown = SLOWDOWN_ADS_SHOTGUN
	map_specific_decoration = FALSE

	var/pump_delay //How long we have to wait before we can pump the shotgun again.
	var/pump_sound = "shotgunpump"
	var/message_delay = 1 SECONDS //To stop message spam when trying to pump the gun constantly.
	var/burst_count = 0 //To detect when the burst fire is near its end.
	COOLDOWN_DECLARE(allow_message)
	COOLDOWN_DECLARE(allow_pump)

/obj/item/weapon/gun/rifle/xm51/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 34, "muzzle_y" = 18, "rail_x" = 12, "rail_y" = 20, "under_x" = 24, "under_y" = 13, "stock_x" = 15, "stock_y" = 16)

/obj/item/weapon/gun/rifle/xm51/set_gun_config_values()
	..()
	set_burst_amount(BURST_AMOUNT_TIER_1)
	set_fire_delay(FIRE_DELAY_TIER_7)
	accuracy_mult = BASE_ACCURACY_MULT + 2*HIT_ACCURACY_MULT_TIER_8
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_8
	recoil = RECOIL_AMOUNT_TIER_4
	recoil_unwielded = RECOIL_AMOUNT_TIER_2
	scatter = SCATTER_AMOUNT_TIER_6

/obj/item/weapon/gun/rifle/xm51/Initialize(mapload, spawn_empty)
	. = ..()
	pump_delay = FIRE_DELAY_TIER_8
	additional_fire_group_delay += pump_delay
	remove_firemode(GUN_FIREMODE_BURSTFIRE)

/obj/item/weapon/gun/rifle/xm51/unique_action(mob/user)
	if(!COOLDOWN_FINISHED(src, allow_pump))
		return
	if(in_chamber)
		if(COOLDOWN_FINISHED(src, allow_message))
			to_chat(usr, SPAN_WARNING("<i>[src] already has a shell in the chamber!<i>"))
			COOLDOWN_START(src, allow_message, message_delay)
		return

	playsound(user, pump_sound, 10, 1)
	COOLDOWN_START(src, allow_pump, pump_delay)
	ready_in_chamber()
	burst_count = 0 //Reset the count for burst mode.

/obj/item/weapon/gun/rifle/xm51/load_into_chamber(mob/user)
	return in_chamber

/obj/item/weapon/gun/rifle/xm51/reload_into_chamber(mob/user) //Don't chamber bullets after firing.
	if(!current_mag)
		update_icon()
		return

	in_chamber = null
	if(current_mag.current_rounds <= 0 && flags_gun_features & GUN_AUTO_EJECTOR)
		if (user.client?.prefs && (user.client?.prefs?.toggle_prefs & TOGGLE_AUTO_EJECT_MAGAZINE_OFF))
			update_icon()
	return 1

/obj/item/weapon/gun/rifle/xm51/replace_magazine(mob/user, obj/item/ammo_magazine/magazine) //Don't chamber a round when reloading.
	user.drop_inv_item_to_loc(magazine, src) //Click!
	current_mag = magazine
	replace_ammo(user,magazine)
	user.visible_message(SPAN_NOTICE("[user] loads [magazine] into [src]!"),
		SPAN_NOTICE("You load [magazine] into [src]!"), null, 3, CHAT_TYPE_COMBAT_ACTION)
	if(reload_sound)
		playsound(user, reload_sound, 25, 1, 5)

/obj/item/weapon/gun/rifle/xm51/cock_gun(mob/user)
	return

/obj/item/weapon/gun/rifle/xm51/cock(mob/user) //Stops the "You cock the gun." message where nothing happens.
	return

/obj/item/weapon/gun/rifle/xm51/withstock
	starting_attachment_types = list(/obj/item/attachable/stock/xm51)

/obj/item/weapon/gun/rifle/xm51/military
	name = "\improper XM51 shotgun"
	desc = "Magazine-fed, pump-action shotgun designed by ARMAT Battlefield Systems, also known as M1771 Cobra Max Tactical. This one is painted with a fresh coat of Humbrol 170."
	icon_state = "xm51_military"
	item_state = "xm51_military"

/obj/item/weapon/gun/rifle/xm51/military/withstock
	starting_attachment_types = list(/obj/item/attachable/stock/xm51/military)
