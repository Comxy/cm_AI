
/obj/item/weapon/gun/smg
	mouse_pointer = 'icons/effects/mouse_pointer/pistol_mouse.dmi'
	reload_sound = 'sound/weapons/handling/smg_reload.ogg'
	unload_sound = 'sound/weapons/handling/smg_unload.ogg'
	cocked_sound = 'sound/weapons/gun_cocked2.ogg'
	fire_sound = 'sound/weapons/gun_m39.ogg'

	force = 5
	w_class = SIZE_LARGE
	movement_onehanded_acc_penalty_mult = 4
	aim_slowdown = SLOWDOWN_ADS_QUICK
	wield_delay = WIELD_DELAY_VERY_FAST
	attachable_allowed = list(
		/obj/item/attachable/suppressor,
		/obj/item/attachable/reddot,
		/obj/item/attachable/reflex,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/magnetic_harness,
	)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AUTO_EJECT_CASINGS
	gun_category = GUN_CATEGORY_SMG
	start_automatic = TRUE

/obj/item/weapon/gun/smg/Initialize(mapload, spawn_empty)
	. = ..()
	if(current_mag && current_mag.current_rounds > 0)
		load_into_chamber()

/obj/item/weapon/gun/smg/unique_action(mob/user)
	cock(user)

/obj/item/weapon/gun/smg/set_gun_config_values()
	..()
	movement_onehanded_acc_penalty_mult = 4
	fa_max_scatter = SCATTER_AMOUNT_TIER_5

//-------------------------------------------------------
//M39 SMG

/obj/item/weapon/gun/smg/m39
	name = "\improper Viper 9 submachinegun"
	desc = "Made popular through their use by the United States Secret Service, the Armat Battlefield Systems Model-39 submachinegun, marketed as the 'Viper 9', is a common firearm utilized by private security firms. Chambered in 9x19mm."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/uscm.dmi'
	icon_state = "m39"
	item_state = "m39"
	fire_sound = "m4a3"
	flags_equip_slot = SLOT_BACK
	current_mag = /obj/item/ammo_magazine/smg/m39
	attachable_allowed = list(
		/obj/item/attachable/suppressor,
		/obj/item/attachable/reddot,
		/obj/item/attachable/reflex,
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/flashlight/grip,
		/obj/item/attachable/stock/smg,
		/obj/item/attachable/stock/smg/collapsible,
		/obj/item/attachable/compensator,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonet/upp,
		/obj/item/attachable/bayonet/co2,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/gyro,
		/obj/item/attachable/stock/smg/collapsible/brace,
	)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_AUTO_EJECT_CASINGS
	starting_attachment_types = list(/obj/item/attachable/stock/smg/collapsible)
	map_specific_decoration = FALSE

/obj/item/weapon/gun/smg/m39/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 20,"rail_x" = 14, "rail_y" = 22, "under_x" = 21, "under_y" = 16, "stock_x" = 24, "stock_y" = 15, , "side_rail_x" = 25, "side_rail_y" = 19)

/obj/item/weapon/gun/smg/m39/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_SMG)
	set_burst_delay(FIRE_DELAY_TIER_SMG)
	set_burst_amount(BURST_AMOUNT_TIER_3)
	accuracy_mult = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_7
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_5
	scatter = SCATTER_AMOUNT_TIER_4
	burst_scatter_mult = SCATTER_AMOUNT_TIER_8
	scatter_unwielded = SCATTER_AMOUNT_TIER_4
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil_unwielded = RECOIL_AMOUNT_TIER_5
	fa_max_scatter = SCATTER_AMOUNT_TIER_10 + 0.5

/obj/item/weapon/gun/smg/m39/forecon
	name = "\improper M39 submachinegun"
	desc = "Fielded in limited numbers by elements of United States Colonial Marine Force-Reconnaissance units, the M39 is often used as a high-capacity sidearm or backup weapon rather than an offensive weapon. This one is painted in a fresh coat of the newer Humbrol 76 camouflage and comes chambered in 9x19mm."
	icon = 'icons/obj/items/weapons/guns/guns_by_map/jungle/guns_obj.dmi'
	current_mag = /obj/item/ammo_magazine/smg/m39/extended
	item_icons = list(
		WEAR_L_HAND = 'icons/obj/items/weapons/guns/guns_by_map/jungle/guns_lefthand.dmi',
		WEAR_R_HAND = 'icons/obj/items/weapons/guns/guns_by_map/jungle/guns_righthand.dmi',
		WEAR_BACK = 'icons/obj/items/weapons/guns/guns_by_map/jungle/back.dmi',
		WEAR_J_STORE = 'icons/obj/items/weapons/guns/guns_by_map/jungle/suit_slot.dmi'
	)

/obj/item/weapon/gun/smg/m39/training
	current_mag = /obj/item/ammo_magazine/smg/m39/rubber

/obj/item/weapon/gun/smg/m39/solidstock
	starting_attachment_types = list(/obj/item/attachable/stock/smg)

/obj/item/weapon/gun/smg/m39/tactical
	starting_attachment_types = list(/obj/item/attachable/stock/smg/collapsible,/obj/item/attachable/reflex,/obj/item/attachable/verticalgrip,/obj/item/attachable/suppressor)

/obj/item/weapon/gun/smg/m39/tactical/ap
	starting_attachment_types = list(/obj/item/attachable/stock/smg/collapsible,/obj/item/attachable/reflex,/obj/item/attachable/verticalgrip)
	current_mag = /obj/item/ammo_magazine/smg/m39/ap

//-------------------------------------------------------

/obj/item/weapon/gun/smg/m39/elite
	name = "\improper M39B/2 submachinegun"
	desc = "A modified version M-39 submachinegun, re-engineered for better weight, handling and accuracy. Given only to elite units."
	icon_state = "m39b2"
	item_state = "m39b2"
	current_mag = /obj/item/ammo_magazine/smg/m39/ap
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_WY_RESTRICTED|GUN_AUTO_EJECT_CASINGS
	map_specific_decoration = FALSE
	starting_attachment_types = list(/obj/item/attachable/stock/smg/collapsible)

	random_spawn_chance = 100
	random_spawn_rail = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/reflex,
		/obj/item/attachable/magnetic_harness,
	)
	random_spawn_under = list(
		/obj/item/attachable/angledgrip,
		/obj/item/attachable/flashlight/grip,
	)
	random_spawn_siderail = list(
		/obj/item/attachable/lasersight,
		/obj/item/attachable/flashlight,
	)
	random_spawn_muzzle = list(
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/extended_barrel,
	)



/obj/item/weapon/gun/smg/m39/elite/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_SMG)
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_7
	accuracy_mult_unwielded = BASE_ACCURACY_MULT
	scatter = SCATTER_AMOUNT_TIER_9
	burst_scatter_mult = SCATTER_AMOUNT_TIER_10
	scatter_unwielded = SCATTER_AMOUNT_TIER_6
	damage_mult =  BASE_BULLET_DAMAGE_MULT + BULLET_DAMAGE_MULT_TIER_7

/obj/item/weapon/gun/smg/m39/elite/pve //duplex round
	name = "\improper M39B/3 submachinegun"
	desc = "An experimental M-39 capable of firing squash-head duplex rounds. A bit bulkier and more unwieldy than the average M39, with a thicker reciever and slower projectile. Still produced in small quantities."
	desc_lore = "The Company recieved a rather unexpected windfall of revenue from the VP78. Squash-head small-arms rounds were rather popular among their clientelle. Initial testing with rifle-caliber HESH rounds presented a few problems. The least of which was that the required additional powder drove the chamber pressure up to dangerous levels, causing premature detonations and inaccurate fire. <BR> <BR> Thanks to Armat's overengineering, the M39 was rated for pressures well beyond that of even +P ammunition. It was simple for Weyland Yutani to iterate upon the problem by taking a step back. How do you fix rifle rounds being too pressurized? Make it a pistol round. How do you remedy its firepower? Make it a duplex."
	current_mag = /obj/item/ammo_magazine/smg/m39/pve
	random_spawn_chance = 0
	fire_sound = 'sound/weapons/gun_m39.ogg'

/obj/item/weapon/gun/smg/m39/elite/whiteout//attachies + heap mag for whiteout.
	starting_attachment_types = list(/obj/item/attachable/stock/smg, /obj/item/attachable/suppressor, /obj/item/attachable/angledgrip, /obj/item/attachable/magnetic_harness)
	current_mag = /obj/item/ammo_magazine/smg/m39/heap

//-------------------------------------------------------
//M5, a classic SMG used in a lot of action movies.

/obj/item/weapon/gun/smg/mp5
	name = "\improper MP5 submachinegun"
	desc = "Knockoff of an antique UPP submachine gun, made somewhere in the former German state. Chambered for 9x19mm cased ammunition."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/colony.dmi'
	icon_state = "mp5"
	item_state = "mp5"

	fire_sound = 'sound/weapons/smg_light.ogg'
	current_mag = /obj/item/ammo_magazine/smg/mp5
	attachable_allowed = list(
		/obj/item/attachable/suppressor, // Barrel
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonet/upp,
		/obj/item/attachable/bayonet/co2,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/compensator,
		/obj/item/attachable/reddot, // Rail
		/obj/item/attachable/reflex,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/gyro, // Under
		/obj/item/attachable/bipod,
		/obj/item/attachable/burstfire_assembly,
		/obj/item/attachable/attached_gun/grenade/m203,
		/obj/item/attachable/lasersight, // Side Rail
		/obj/item/attachable/flashlight,
		)

	flags_gun_features = GUN_CAN_POINTBLANK|GUN_ANTIQUE|GUN_AUTO_EJECT_CASINGS



/obj/item/weapon/gun/smg/mp5/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 30, "muzzle_y" = 17,"rail_x" = 12, "rail_y" = 19, "under_x" = 23, "under_y" = 15, "stock_x" = 28, "stock_y" = 17, "side_rail_x" = 27, "side_rail_y" = 17)

/obj/item/weapon/gun/smg/mp5/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_11)
	set_burst_delay(FIRE_DELAY_TIER_SMG)
	set_burst_amount(BURST_AMOUNT_TIER_3)

	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_4
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_4
	scatter = SCATTER_AMOUNT_TIER_8
	burst_scatter_mult = SCATTER_AMOUNT_TIER_8
	scatter_unwielded = SCATTER_AMOUNT_TIER_5
	damage_mult = BASE_BULLET_DAMAGE_MULT + BULLET_DAMAGE_MULT_TIER_4
	recoil_unwielded = RECOIL_AMOUNT_TIER_5

/obj/item/weapon/gun/smg/mp5/Initialize(mapload, spawn_empty)
	. = ..()
	if(prob(10))
		var/obj/item/attachable/attached_gun/grenade/m203/UGL = new(src)
		UGL.Attach(src)
		update_attachable(UGL.slot)

//-------------------------------------------------------
//MP27, based on the MP27, based on the M7.

/obj/item/weapon/gun/smg/mp27
	name = "\improper MP27 submachinegun"
	desc = "Once a respectable weapon, now after the design files were leaked in '67 the cheaply made copies are everywhere. Lightweight and fast firing, but the poor construction of almost every copy severely hampers accuracy."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/colony.dmi'
	icon_state = "mp7"
	item_state = "mp7"
	fire_sound = 'sound/weapons/smg_light.ogg'
	current_mag = /obj/item/ammo_magazine/smg/mp27
	attachable_allowed = list(
		/obj/item/attachable/suppressor, // Barrel
		/obj/item/attachable/bayonet,
		/obj/item/attachable/bayonet/upp,
		/obj/item/attachable/bayonet/co2,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/compensator,
		/obj/item/attachable/reddot, // Rail
		/obj/item/attachable/reflex,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/gyro, // Under
		/obj/item/attachable/bipod,
		/obj/item/attachable/burstfire_assembly,
		/obj/item/attachable/lasersight, // Side Rail
		/obj/item/attachable/flashlight,
		)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AUTO_EJECT_CASINGS
	aim_slowdown = SLOWDOWN_ADS_NONE


/obj/item/weapon/gun/smg/mp27/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 19,"rail_x" = 12, "rail_y" = 20, "under_x" = 23, "under_y" = 16, "stock_x" = 28, "stock_y" = 17, "side_rail_x" = 26, "side_rail_y" = 17)

/obj/item/weapon/gun/smg/mp27/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_SMG)
	set_burst_delay(FIRE_DELAY_TIER_SMG)
	set_burst_amount(BURST_AMOUNT_TIER_2)
	accuracy_mult = BASE_ACCURACY_MULT
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_2
	scatter = SCATTER_AMOUNT_TIER_4 + (SCATTER_AMOUNT_TIER_10 * 0.5)
	burst_scatter_mult = SCATTER_AMOUNT_TIER_8 + (SCATTER_AMOUNT_TIER_10 * 0.5)
	scatter_unwielded = SCATTER_AMOUNT_TIER_4 + SCATTER_AMOUNT_TIER_10
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil_unwielded = RECOIL_AMOUNT_TIER_5

//-------------------------------------------------------
//PPSH //Based on the PPSh-41.

#define PPSH_UNJAM_CHANCE 25

/obj/item/weapon/gun/smg/ppsh
	name = "\improper PPSh-17b submachinegun"
	desc = "An unauthorized copy of a replica of a prototype submachinegun developed in a third world shit hole somewhere."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/upp.dmi'
	icon_state = "ppsh17b"
	item_state = "ppsh17b"

	fire_sound = 'sound/weapons/smg_heavy.ogg'
	current_mag = /obj/item/ammo_magazine/smg/ppsh
	flags_gun_features = GUN_CAN_POINTBLANK|GUN_ANTIQUE|GUN_AUTO_EJECT_CASINGS
	starting_attachment_types = list(/obj/item/attachable/stock/ppsh)
	var/jammed = FALSE

/obj/item/weapon/gun/smg/ppsh/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 17,"rail_x" = 15, "rail_y" = 19, "under_x" = 26, "under_y" = 15, "stock_x" = 18, "stock_y" = 15, "side_rail_x" = 18, "side_rail_y" = 16)

/obj/item/weapon/gun/smg/ppsh/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_SMG)
	set_burst_delay(FIRE_DELAY_TIER_SMG)
	set_burst_amount(BURST_AMOUNT_TIER_3)
	accuracy_mult = BASE_ACCURACY_MULT
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_5
	scatter = SCATTER_AMOUNT_TIER_4
	burst_scatter_mult = SCATTER_AMOUNT_TIER_4
	scatter_unwielded = SCATTER_AMOUNT_TIER_4
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil_unwielded = RECOIL_AMOUNT_TIER_5
	fa_max_scatter = SCATTER_AMOUNT_TIER_9
	fa_scatter_peak = 1 // Seems a bit funny, but it works pretty well in the end

/obj/item/weapon/gun/smg/ppsh/with_drum_mag
	current_mag = /obj/item/ammo_magazine/smg/ppsh/extended

// Special feature! The PPSH can jam with the drum magazine, and will also receive handling debuffs when using one.

/obj/item/weapon/gun/smg/ppsh/Fire(atom/target, mob/living/user, params, reflex = 0, dual_wield)
	var/obj/item/ammo_magazine/smg/ppsh/ppsh_mag =  current_mag
	if(jammed)
		if(world.time % 3)
			playsound(src, 'sound/weapons/handling/gun_jam_click.ogg', 35, TRUE)
			to_chat(user, SPAN_WARNING("Your gun is jammed! Mash Unique-Action to unjam it!"))
			balloon_alert(user, "*jammed*")
		return NONE
	else if(prob(ppsh_mag?.jam_chance))
		jammed = TRUE
		playsound(src, 'sound/weapons/handling/gun_jam_initial_click.ogg', 50, FALSE)
		user.visible_message(SPAN_DANGER("[src] makes a noticeable clicking noise!"), SPAN_HIGHDANGER("\The [src] suddenly jams and refuses to fire! Mash Unique-Action to unjam it."))
		balloon_alert(user, "*jammed*")
		return NONE
	else
		return ..()

/obj/item/weapon/gun/smg/ppsh/unique_action(mob/user)
	if(jammed)
		if(prob(PPSH_UNJAM_CHANCE))
			to_chat(user, SPAN_GREEN("You successfully unjam \the [src]!"))
			playsound(src, 'sound/weapons/handling/gun_jam_rack_success.ogg', 50, FALSE)
			jammed = FALSE
			cock_cooldown += 1 SECONDS //so they dont accidentally cock a bullet away
			balloon_alert(user, "*unjammed!*")
		else
			to_chat(user, SPAN_NOTICE("You start wildly racking the bolt back and forth attempting to unjam \the [src]!"))
			playsound(src, "gun_jam_rack", 50, FALSE)
			balloon_alert(user, "*rack*")
		return
	. = ..()

/obj/item/weapon/gun/smg/ppsh/unload(mob/user, reload_override, drop_override, loc_override)
	. = ..()
	aim_slowdown = SLOWDOWN_ADS_QUICK
	wield_delay = WIELD_DELAY_VERY_FAST

/obj/item/weapon/gun/smg/ppsh/reload(mob/user, obj/item/ammo_magazine/magazine)
	var/obj/item/ammo_magazine/smg/ppsh/ppsh_mag = magazine

	if( (ppsh_mag.bonus_mag_aim_slowdown || ppsh_mag.bonus_mag_wield_delay) && user)
		to_chat(user, SPAN_WARNING("\The [src] feels noticeably bulkier with \the [magazine]. It's probably going to have a lot worse handling than usual."))

	aim_slowdown = SLOWDOWN_ADS_QUICK + ppsh_mag.bonus_mag_aim_slowdown
	wield_delay = WIELD_DELAY_VERY_FAST + ppsh_mag.bonus_mag_wield_delay
	update_icon()
	. = ..()

/obj/item/weapon/gun/smg/ppsh/update_icon()
	..()
	var/obj/item/ammo_magazine/smg/ppsh/ppsh_mag = current_mag
	if(ppsh_mag && ppsh_mag.new_item_state)
		item_state = ppsh_mag.new_item_state
		ppsh_mag.update_icon()

#undef PPSH_UNJAM_CHANCE

//-------------------------------------------------------
//Type-19,

/obj/item/weapon/gun/smg/pps43
	name = "\improper Type-19 Submachinegun" //placeholder
	desc = "An outdated, but reliable and powerful, submachinegun originating in the Union of Progressive Peoples, it is still in limited service in the UPP but is most often used by paramilitary groups or corporate security forces. It is usually used with a 35 round stick magazine, or a 71 round drum."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/upp.dmi'
	icon_state = "insasu"
	item_state = "insasu"

	fire_sound = 'sound/weapons/smg_heavy.ogg'
	current_mag = /obj/item/ammo_magazine/smg/pps43
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_AUTO_EJECT_CASINGS
	attachable_allowed = list(
		/obj/item/attachable/suppressor,
		/obj/item/attachable/reddot,
		/obj/item/attachable/reflex,
		/obj/item/attachable/flashlight/grip,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/magnetic_harness,
	)

/obj/item/weapon/gun/smg/pps43/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 20,"rail_x" = 20, "rail_y" = 24, "under_x" = 25, "under_y" = 17, "stock_x" = 26, "stock_y" = 15, "side_rail_x" = 23, "side_rail_y" = 19)

/obj/item/weapon/gun/smg/pps43/set_gun_config_values()
	..()
	fire_delay = FIRE_DELAY_TIER_SMG
	burst_delay = FIRE_DELAY_TIER_SMG
	burst_amount = BURST_AMOUNT_TIER_3
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_3
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_5
	scatter = SCATTER_AMOUNT_TIER_6
	burst_scatter_mult = SCATTER_AMOUNT_TIER_4
	scatter_unwielded = SCATTER_AMOUNT_TIER_4
	damage_mult = BASE_BULLET_DAMAGE_MULT + BULLET_DAMAGE_MULT_TIER_4
	recoil_unwielded = RECOIL_AMOUNT_TIER_5

/obj/item/weapon/gun/smg/pps43/extended_mag
	current_mag = /obj/item/ammo_magazine/smg/pps43/extended
//-------------------------------------------------------
//Type 64

/obj/item/weapon/gun/smg/bizon
	name = "\improper Type 64 Submachinegun"
	desc = "The standard submachinegun of the UPP, sporting an unusual 64 round helical magazine, it has a high fire-rate, but is unusually accurate. This one has a faux-wood grip, denoting it as civilian use or as an export model."
	desc_lore = "The Type 64 finds its way into the hands of more than just UPP soldiers, it has an active life with rebel groups, corporate security forces, mercenaries, less well-armed militaries, and just about everything or everyone in between."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/upp.dmi'
	icon_state = "type64"
	item_state = "type64"

	fire_sound = 'sound/weapons/smg_heavy.ogg'
	current_mag = /obj/item/ammo_magazine/smg/bizon
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_AUTO_EJECT_CASINGS
	wield_delay = WIELD_DELAY_MIN
	aim_slowdown = SLOWDOWN_ADS_QUICK_MINUS

/obj/item/weapon/gun/smg/bizon/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 20,"rail_x" = 18, "rail_y" = 23, "under_x" = 26, "under_y" = 15, "stock_x" = 26, "stock_y" = 15, "side_rail_x" = 27, "side_rail_y" = 18)

/obj/item/weapon/gun/smg/bizon/set_gun_config_values()
	..()
	fire_delay = FIRE_DELAY_TIER_SMG
	burst_delay = FIRE_DELAY_TIER_SMG
	burst_amount = BURST_AMOUNT_TIER_4
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_5
	accuracy_mult_unwielded = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_3
	scatter = SCATTER_AMOUNT_TIER_9
	burst_scatter_mult = SCATTER_AMOUNT_TIER_8
	scatter_unwielded = SCATTER_AMOUNT_TIER_4
	damage_mult = BASE_BULLET_DAMAGE_MULT + BULLET_DAMAGE_MULT_TIER_3
	recoil_unwielded = RECOIL_AMOUNT_TIER_5

/obj/item/weapon/gun/smg/bizon/upp
	name = "\improper Type 64 Submachinegun"
	desc = "The standard submachinegun of the UPP, sporting an unusual 64 round helical magazine, it has a high fire-rate, but is unusually accurate. This one has a black polymer grip, denoting it as in-use by the UPP military."
	desc_lore = "The Type 64 finds its way into the hands of more than just UPP soldiers, it has an active life with rebel groups, corporate security forces, mercenaries, less well-armed militaries, and just about everything or everyone in between."
	icon_state = "type64_u"
	item_state = "type64"

//-------------------------------------------------------
//GENERIC UZI //Based on the uzi submachinegun, of course.

/obj/item/weapon/gun/smg/mac15
	name = "\improper MAC-15 submachinegun"
	desc = "A cheap, reliable design and manufacture make this ubiquitous submachinegun useful despite the age." //Includes proprietary 'full-auto' mode, banned in several Geneva Suggestions rim-wide.
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/colony.dmi'
	icon_state = "mac15"
	item_state = "mac15"

	fire_sound = 'sound/weapons/gun_mac15.ogg'
	current_mag = /obj/item/ammo_magazine/smg/mac15
	flags_gun_features = GUN_ANTIQUE|GUN_CAN_POINTBLANK|GUN_ONE_HAND_WIELDED|GUN_AUTO_EJECT_CASINGS //|GUN_HAS_FULL_AUTO|GUN_FULL_AUTO_ON|GUN_FULL_AUTO_ONLY commented out until better fullauto code

	attachable_allowed = list(
		/obj/item/attachable/suppressor, // Barrel
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/compensator,
		/obj/item/attachable/reddot, // Rail
		/obj/item/attachable/reflex,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/lasersight, // Under
		/obj/item/attachable/burstfire_assembly,
		)
	wield_delay = WIELD_DELAY_NONE
	aim_slowdown = SLOWDOWN_ADS_NONE

/obj/item/weapon/gun/smg/mac15/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 29, "muzzle_y" = 21,"rail_x" = 13, "rail_y" = 24, "under_x" = 19, "under_y" = 18, "stock_x" = 22, "stock_y" = 16, "side_rail_x" = 22, "side_rail_y" = 20)

/obj/item/weapon/gun/smg/mac15/set_gun_config_values()
	..()

	fa_scatter_peak = FULL_AUTO_SCATTER_PEAK_TIER_7
	fa_max_scatter = SCATTER_AMOUNT_TIER_3
	set_fire_delay(FIRE_DELAY_TIER_12)
	accuracy_mult = BASE_ACCURACY_MULT
	scatter = SCATTER_AMOUNT_TIER_5
	burst_scatter_mult = SCATTER_AMOUNT_TIER_8
	damage_mult = BASE_BULLET_DAMAGE_MULT - BULLET_DAMAGE_MULT_TIER_2

/obj/item/weapon/gun/smg/mac15/extended
	current_mag = /obj/item/ammo_magazine/smg/mac15/extended

//-------------------------------------------------------
// DAS REAL UZI

#define UZI_UNJAM_CHANCE 25

/obj/item/weapon/gun/smg/uzi
	name = "\improper UZI"
	desc = "Antique firearm, now almost two centuries old. 9mm, fully automatic. Pull the trigger and hold on tight."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/colony.dmi'
	icon_state = "uzi"
	item_state = "uzi"
	flags_equip_slot = SLOT_WAIST
	fire_sound = 'sound/weapons/gun_uzi.ogg'
	current_mag = /obj/item/ammo_magazine/smg/uzi
	flags_gun_features = GUN_ANTIQUE|GUN_CAN_POINTBLANK|GUN_ONE_HAND_WIELDED|GUN_AUTO_EJECT_CASINGS //|GUN_HAS_FULL_AUTO|GUN_FULL_AUTO_ON|GUN_FULL_AUTO_ONLY commented out until better fullauto code

	attachable_allowed = list(
		/obj/item/attachable/suppressor, // Barrel
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
		/obj/item/attachable/compensator,
		/obj/item/attachable/reddot, // Rail
		/obj/item/attachable/reflex,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/scope/mini,
		/obj/item/attachable/lasersight, // Under
		/obj/item/attachable/burstfire_assembly,
		)
	wield_delay = WIELD_DELAY_MIN
	aim_slowdown = SLOWDOWN_ADS_QUICK
	var/jammed = FALSE

/obj/item/weapon/gun/smg/uzi/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 28, "muzzle_y" = 20,"rail_x" = 12, "rail_y" = 22, "under_x" = 22, "under_y" = 16, "stock_x" = 22, "stock_y" = 16, "side_rail_x" = 23, "side_rail_y" = 18)

/obj/item/weapon/gun/smg/uzi/set_gun_config_values()
	..()

	fa_scatter_peak = FULL_AUTO_SCATTER_PEAK_TIER_5
	fa_max_scatter = SCATTER_AMOUNT_TIER_5
	set_fire_delay(FIRE_DELAY_TIER_11)
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_2
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_2
	scatter = SCATTER_AMOUNT_TIER_6
	scatter_unwielded = SCATTER_AMOUNT_TIER_3
	damage_mult = BASE_BULLET_DAMAGE_MULT + BULLET_DAMAGE_MULT_TIER_2
	recoil_unwielded = RECOIL_AMOUNT_TIER_5

// The UZI can also jam, though it's less likely.

/obj/item/weapon/gun/smg/uzi/Fire(atom/target, mob/living/user, params, reflex = 0, dual_wield)
	var/obj/item/ammo_magazine/smg/uzi/uzi_mag = current_mag
	if(jammed)
		if(world.time % 3)
			playsound(src, 'sound/weapons/handling/gun_jam_click.ogg', 35, TRUE)
			to_chat(user, SPAN_WARNING("Your gun is jammed! Mash Unique-Action to unjam it!"))
			balloon_alert(user, "*jammed*")
		return NONE
	else if(prob(uzi_mag.jam_chance))
		jammed = TRUE
		playsound(src, 'sound/weapons/handling/gun_jam_initial_click.ogg', 35, TRUE)
		user.visible_message(SPAN_DANGER("[src] makes a noticeable clicking noise!"), SPAN_HIGHDANGER("\The [src] suddenly jams and refuses to fire! Mash Unique-Action to unjam it."))
		balloon_alert(user, "*jammed*")
		return NONE
	else
		return ..()

/obj/item/weapon/gun/smg/uzi/unique_action(mob/user)
	if(jammed)
		if(prob(UZI_UNJAM_CHANCE))
			to_chat(user, SPAN_GREEN("You successfully unjam \the [src]!"))
			playsound(src, 'sound/weapons/handling/gun_jam_rack_success.ogg', 35, TRUE)
			jammed = FALSE
			cock_cooldown += 1 SECONDS //so they dont accidentally cock a bullet away
			balloon_alert(user, "*unjammed!*")
		else
			to_chat(user, SPAN_NOTICE("You start wildly racking the bolt back and forth attempting to unjam \the [src]!"))
			playsound(src, "gun_jam_rack", 50, FALSE)
			balloon_alert(user, "*rack*")
		return
	. = ..()

#undef UZI_UNJAM_CHANCE

//-------------------------------------------------------
//FP9000 //Based on the FN P90

/obj/item/weapon/gun/smg/fp9000
	name = "\improper FN FP9000 Submachinegun"
	desc = "An old design, but one that's stood the test of time. A leaked and unencrypted 3D-printing pattern alongside an extremely robust and reasonably cheap to manufacture frame have ensured this weapon be a mainstay of rim colonies and private security firms for over a century."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/colony.dmi'
	icon_state = "fp9000"
	item_state = "fp9000"

	fire_sound = 'sound/weapons/gun_p90.ogg'
	current_mag = /obj/item/ammo_magazine/smg/fp9000

	attachable_allowed = list(
		/obj/item/attachable/compensator,
		/obj/item/attachable/lasersight,
		/obj/item/attachable/extended_barrel,
		/obj/item/attachable/heavy_barrel,
	)
	random_spawn_chance = 65
	random_spawn_siderail = list(
		/obj/item/attachable/lasersight,
	)
	random_spawn_muzzle = list(
		/obj/item/attachable/compensator,
		/obj/item/attachable/extended_barrel,
	)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AUTO_EJECT_CASINGS

/obj/item/weapon/gun/smg/fp9000/handle_starting_attachment()
	..()
	var/obj/item/attachable/scope/mini/S = new(src)
	S.icon_state = "miniscope_fp9000"
	S.attach_icon = "miniscope_fp9000_a" // Custom
	S.flags_attach_features &= ~ATTACH_REMOVABLE
	S.Attach(src)
	update_attachable(S.slot)

/obj/item/weapon/gun/smg/fp9000/set_gun_attachment_offsets()
	attachable_offset = list("muzzle_x" = 33, "muzzle_y" = 18,"rail_x" = 20, "rail_y" = 21, "under_x" = 26, "under_y" = 16, "stock_x" = 22, "stock_y" = 16, "side_rail_x" = 25, "side_rail_y" = 17)

/obj/item/weapon/gun/smg/fp9000/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_SMG)
	set_burst_delay(FIRE_DELAY_TIER_SMG)
	set_burst_amount(BURST_AMOUNT_TIER_3)
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_5
	accuracy_mult_unwielded = BASE_ACCURACY_MULT - HIT_ACCURACY_MULT_TIER_5
	scatter = SCATTER_AMOUNT_TIER_6
	burst_scatter_mult = SCATTER_AMOUNT_TIER_4
	scatter_unwielded = SCATTER_AMOUNT_TIER_4
	damage_mult = BASE_BULLET_DAMAGE_MULT + BULLET_DAMAGE_MULT_TIER_1
	recoil_unwielded = RECOIL_AMOUNT_TIER_5

/obj/item/weapon/gun/smg/fp9000/pmc
	name = "\improper FN FP9000/2 Submachinegun"
	desc = "Despite the rather ancient design, the FN FP9K sees frequent use in PMC teams due to its extreme reliability and versatility, allowing it to excel in any situation, especially due to the fact that they use the patented, official version of the gun, which has received several upgrades and tuning to its design over time."
	icon_state = "fp9000_pmc"
	item_state = "fp9000_pmc"
	random_spawn_chance = 100
	random_spawn_rail = list(
		/obj/item/attachable/reddot,
		/obj/item/attachable/reflex,
		/obj/item/attachable/magnetic_harness,
	)
	random_spawn_siderail = list(
		/obj/item/attachable/lasersight,
		/obj/item/attachable/flashlight,
	)

/obj/item/weapon/gun/smg/fp9000/pmc/set_gun_config_values()
	..()
	damage_mult = BASE_BULLET_DAMAGE_MULT + BULLET_DAMAGE_MULT_TIER_4
	scatter = SCATTER_AMOUNT_TIER_9
	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_7

//-------------------------------------------------------

/obj/item/weapon/gun/smg/nailgun
	name = "nailgun"
	desc = "A carpentry tool, used to drive nails into tough surfaces. Of course, if there isn't anything there, that's just a very sharp nail launching at high velocity..."
	icon = 'icons/obj/items/weapons/guns/guns_by_faction/colony.dmi'
	icon_state = "nailgun"
	item_state = "nailgun"
	current_mag = /obj/item/ammo_magazine/smg/nailgun

	reload_sound = 'sound/weapons/handling/smg_reload.ogg'
	unload_sound = 'sound/weapons/handling/smg_unload.ogg'
	cocked_sound = 'sound/weapons/gun_cocked2.ogg'

	fire_sound = 'sound/weapons/nailgun_fire.ogg'
	force = 5
	w_class = SIZE_MEDIUM
	movement_onehanded_acc_penalty_mult = 4
	aim_slowdown = SLOWDOWN_ADS_QUICK
	wield_delay = WIELD_DELAY_VERY_FAST
	attachable_allowed = list()

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK
	gun_category = GUN_CATEGORY_SMG
	civilian_usable_override = TRUE
	start_automatic = FALSE
	var/nailing_speed = 2 SECONDS //Time to apply a sheet for patching. Also haha name. Try to keep sync with soundbyte duration
	var/repair_sound = 'sound/weapons/nailgun_repair_long.ogg'
	var/material_per_repair = 1

/obj/item/weapon/gun/smg/nailgun/set_gun_config_values()
	..()
	set_fire_delay(FIRE_DELAY_TIER_11)

	accuracy_mult = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_5
	accuracy_mult_unwielded = BASE_ACCURACY_MULT + HIT_ACCURACY_MULT_TIER_4
	scatter = SCATTER_AMOUNT_TIER_7
	scatter_unwielded = SCATTER_AMOUNT_TIER_5
	damage_mult = BASE_BULLET_DAMAGE_MULT
	recoil_unwielded = RECOIL_AMOUNT_TIER_5

/obj/item/weapon/gun/smg/nailgun/unique_action(mob/user)
	return //Yeah no.

/obj/item/weapon/gun/smg/nailgun/unload_chamber(mob/user)
	return //Can't remove nails from mags or gun.

/obj/item/weapon/gun/smg/nailgun/compact
	name = "compact nailgun"
	desc = "A carpentry tool, used to drive nails into tough surfaces. Cannot fire nails offensively due to a lack of a gas seal around the nail, meaning it cannot build up the pressure to fire."
	icon_state = "cnailgun"
	item_state = "nailgun"
	w_class = SIZE_SMALL
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_NO_DESCRIPTION

/obj/item/weapon/gun/smg/nailgun/compact/able_to_fire(mob/living/user)
	. = ..()
	return FALSE

/obj/item/weapon/gun/smg/nailgun/compact/tactical
	name = "tactical compact nailgun"
	desc = "A carpentry tool, used to drive nails into tough surfaces. This one is military grade, it's olive drab and tacticool. Cannot fire nails as a projectile."
	icon_state = "tnailgun"
	item_state = "tnailgun"
	w_class = SIZE_SMALL
	material_per_repair = 2
