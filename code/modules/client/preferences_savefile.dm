#define SAVEFILE_VERSION_MIN 8
#define SAVEFILE_VERSION_MAX 28

//handles converting savefiles to new formats
//MAKE SURE YOU KEEP THIS UP TO DATE!
//If the sanity checks are capable of handling any issues. Only increase SAVEFILE_VERSION_MAX,
//this will mean that savefile_version will still be over SAVEFILE_VERSION_MIN, meaning
//this savefile update doesn't run everytime we load from the savefile.
//This is mainly for format changes, such as the bitflags in toggles changing order or something.
//if a file can't be updated, return 0 to delete it and start again
//if a file was updated, return 1
/datum/preferences/proc/savefile_update(savefile/S)
	if(!isnum(savefile_version) || savefile_version < SAVEFILE_VERSION_MIN) //lazily delete everything + additional files so they can be saved in the new format
		for(var/ckey in GLOB.preferences_datums)
			var/datum/preferences/D = GLOB.preferences_datums[ckey]
			if(D == src)
				var/delpath = "data/player_saves/[copytext(ckey,1,2)]/[ckey]/"
				if(delpath && fexists(delpath))
					fdel(delpath)
				break
		return 0

	if(savefile_version < 12) //we've split toggles into toggles_sound and toggles_chat
		S["toggles_sound"] << TOGGLES_SOUND_DEFAULT
		S["toggles_chat"] << TOGGLES_CHAT_DEFAULT

	if(savefile_version < 13)
		var/sound_toggles
		S["toggles_sound"] >> sound_toggles
		sound_toggles |= SOUND_INTERNET
		S["toggles_sound"] << sound_toggles

	if(savefile_version < 14) //toggle unnest flashing on by default
		var/flash_toggles
		S["toggles_flashing"] >> flash_toggles
		flash_toggles |= FLASH_UNNEST
		S["toggles_flashing"] << flash_toggles

	if(savefile_version < 15) //toggles on membership publicity by default because forgot to six months ago
		var/pref_toggles
		S["toggle_prefs"] >> pref_toggles
		pref_toggles |= TOGGLE_MEMBER_PUBLIC
		S["toggle_prefs"] << pref_toggles

	if(savefile_version < 16) //toggle unpool flashing on by default
		var/flash_toggles_two
		S["toggles_flashing"] >> flash_toggles_two
		flash_toggles_two |= FLASH_POOLSPAWN
		S["toggles_flashing"] << flash_toggles_two

	if(savefile_version < 17) //toggle middle click swap hands on by default
		var/pref_middle_click_swap
		S["toggle_prefs"] >> pref_middle_click_swap
		pref_middle_click_swap |= TOGGLE_MIDDLE_MOUSE_SWAP_HANDS
		S["toggle_prefs"] << pref_middle_click_swap

	if(savefile_version < 17) //remove omniglots
		var/list/language_traits = list()
		S["traits"] >> language_traits
		if(LAZYLEN(language_traits) > 1)
			language_traits = null
		S["traits"] << language_traits

	if(savefile_version < 18) // adds ambient occlusion by default
		var/pref_toggles
		S["toggle_prefs"] >> pref_toggles
		pref_toggles |= TOGGLE_AMBIENT_OCCLUSION
		S["toggle_prefs"] << pref_toggles

	if(savefile_version < 19) // toggles vending to hand by default
		var/pref_toggle_vend_item_tohand
		S["toggle_prefs"] >> pref_toggle_vend_item_tohand
		pref_toggle_vend_item_tohand |= TOGGLE_VEND_ITEM_TO_HAND
		S["toggle_prefs"] << pref_toggle_vend_item_tohand

	if(savefile_version < 20) // adds midi and atmospheric sounds on by default
		var/sound_toggles
		S["toggles_sound"] >> sound_toggles
		sound_toggles |= (SOUND_ADMIN_MEME|SOUND_ADMIN_ATMOSPHERIC)
		S["toggles_sound"] << sound_toggles

	if(savefile_version < 21)
		var/pref_toggles
		S["toggle_prefs"] >> pref_toggles
		if(pref_toggles & TOGGLE_ALTERNATING_DUAL_WIELD)
			dual_wield_pref = DUAL_WIELD_SWAP
		else
			dual_wield_pref = DUAL_WIELD_FIRE
		S["dual_wield_pref"] << dual_wield_pref

	if(savefile_version < 22)
		var/temp_ooccolor
		S["ooccolor"] >> temp_ooccolor
		if(temp_ooccolor == "#b82e00")
			temp_ooccolor = "#1c52f5"
		S["ooccolor"] << temp_ooccolor

	/// Skipping 23 due to a woopsy with job resets
	if(savefile_version < 24)
		for(var/i in 1 to 10)
			S.cd = "/character[i]"
			var/overwrite_job_preference_list
			S["job_preference_list"] >> overwrite_job_preference_list

			for(var/j in overwrite_job_preference_list)
				overwrite_job_preference_list[j] = 0

			S["job_preference_list"] << overwrite_job_preference_list

		S.cd = "/"

	if(savefile_version < 25)
		var/ethnicity
		var/skin_color = "pale2"
		S["ethnicity"] >> ethnicity
		switch(ethnicity)
			if("anglo")
				skin_color = "pale2"
			if("western")
				skin_color = "tan2"
			if("germanic")
				skin_color = "pale2"
			if("scandinavian")
				skin_color = "pale3"
			if("baltic")
				skin_color = "pale3"
			if("sinoorient")
				skin_color = "pale1"
			if("southorient")
				skin_color = "tan1"
			if("indian")
				skin_color = "tan3"
			if("sino")
				skin_color = "tan1"
			if("mesoamerican")
				skin_color = "tan3"
			if("northamerican")
				skin_color = "tan3"
			if("southamerican")
				skin_color = "tan2"
			if("circumpolar")
				skin_color = "tan1"
			if("northafrican")
				skin_color = "tan3"
			if("centralafrican")
				skin_color = "dark1"
			if("costalafrican")
				skin_color = "dark3"
			if("persian")
				skin_color = "tan3"
			if("levant")
				skin_color = "tan3"
			if("australasian")
				skin_color = "dark2"
			if("polynesian")
				skin_color = "tan3"
		S["skin_color"] << skin_color

	if(savefile_version < 26) // adds fax machine sounds on by default & renemes nanotrasen to wy
		var/sound_toggles
		S["toggles_sound"] >> sound_toggles
		sound_toggles |= (SOUND_FAX_MACHINE)
		S["toggles_sound"] << sound_toggles
		var/relation
		S["nanotrasen_relation"] >> relation
		S["weyland_yutani_relation"] << relation

	if(savefile_version < 27)
		var/old_pref_armor
		S["preferred_armor"] >> old_pref_armor
		if(!(old_pref_armor in GLOB.armor_style_list))
			preferred_armor = "Random"
		S["preferred_armor"] << preferred_armor

	if(savefile_version < 28)
		// Removes TOGGLE_MIDDLE_MOUSE_CLICK (1<<2) and replaces it with a new pref
		var/toggle_prefs = 0
		S["toggle_prefs"] >> toggle_prefs
		if(toggle_prefs & (1<<2))
			S["xeno_ability_click_mode"] << XENO_ABILITY_CLICK_MIDDLE
		else
			S["xeno_ability_click_mode"] << XENO_ABILITY_CLICK_SHIFT

	savefile_version = SAVEFILE_VERSION_MAX
	return 1

/datum/preferences/proc/load_path(ckey,filename="preferences.sav")
	if(!ckey) return
	path = "[CONFIG_GET(string/playersave_path)]/[copytext(ckey,1,2)]/[ckey]/[filename]"
	savefile_version = SAVEFILE_VERSION_MAX

/proc/sanitize_keybindings(value)
	var/list/base_bindings = sanitize_islist(value, list())
	if(!length(base_bindings))
		base_bindings = deep_copy_list(GLOB.hotkey_keybinding_list_by_key)
	for(var/key in base_bindings)
		base_bindings[key] = base_bindings[key] & GLOB.keybindings_by_name
		if(!length(base_bindings[key]))
			base_bindings -= key
	return base_bindings

/datum/preferences/proc/load_preferences()
	if(!path)
		return FALSE

	if(!fexists(path))
		return FALSE

	var/savefile/S = new /savefile(path)
	if(!S)
		return FALSE

	if(!S.Lock())
		to_chat(owner, SPAN_BOLDWARNING("Failed to load your preferences file. It may be in use by another process. Please try again."))

		var/options = tgui_alert(owner, "Failed to load your preferences file. It may be in use by another process. Please try again.", "Failed to Load", list("Retry", "Disconnect"), timeout = FALSE)
		if(options != "Retry")
			qdel(owner, force = TRUE)
			return FALSE

		load_preferences()
		return FALSE

	S.cd = "/"

	S["version"] >> savefile_version
	//Conversion
	if(!savefile_version || !isnum(savefile_version) || savefile_version != SAVEFILE_VERSION_MAX)
		if(!savefile_update(S))  //handles updates
			savefile_version = SAVEFILE_VERSION_MAX
			save_preferences()
			save_character()
			return 0

	//general preferences
	S["ooccolor"] >> ooccolor
	S["lastchangelog"] >> lastchangelog
	S["be_special"] >> be_special
	S["default_slot"] >> default_slot
	S["toggles_chat"] >> toggles_chat
	S["chat_display_preferences"] >> chat_display_preferences
	S["toggles_ghost"] >> toggles_ghost
	S["toggles_langchat"] >> toggles_langchat
	S["toggles_sound"] >> toggles_sound
	S["toggle_prefs"] >> toggle_prefs
	S["xeno_ability_click_mode"] >> xeno_ability_click_mode
	S["dual_wield_pref"] >> dual_wield_pref
	S["toggles_flashing"] >> toggles_flashing
	S["toggles_ert"] >> toggles_ert
	S["toggles_admin"] >> toggles_admin
	S["UI_style"] >> UI_style
	S["tgui_say"] >> tgui_say
	S["UI_style_color"] >> UI_style_color
	S["UI_style_alpha"] >> UI_style_alpha
	S["item_animation_pref_level"] >> item_animation_pref_level
	S["pain_overlay_pref_level"] >> pain_overlay_pref_level
	S["flash_overlay_pref"] >> flash_overlay_pref
	S["crit_overlay_pref"] >> crit_overlay_pref
	S["stylesheet"] >> stylesheet
	S["window_skin"] >> window_skin
	S["fps"] >> fps
	S["ghost_vision_pref"] >> ghost_vision_pref
	S["ghost_orbit"] >> ghost_orbit
	S["auto_observe"] >> auto_observe

	S["human_name_ban"] >> human_name_ban

	S["xeno_prefix"] >> xeno_prefix
	S["xeno_postfix"] >> xeno_postfix
	S["xeno_name_ban"] >> xeno_name_ban
	S["playtime_perks"] >> playtime_perks
	S["xeno_vision_level_pref"] >> xeno_vision_level_pref
	S["view_controller"] >> View_MC
	S["observer_huds"] >> observer_huds
	S["pref_special_job_options"] >> pref_special_job_options
	S["pref_job_slots"] >> pref_job_slots

	S["synth_name"] >> synthetic_name
	S["synth_type"] >> synthetic_type
	S["pred_name"] >> predator_name
	S["pred_gender"] >> predator_gender
	S["pred_age"] >> predator_age
	S["pred_use_legacy"] >> predator_use_legacy
	S["pred_trans_type"] >> predator_translator_type
	S["pred_mask_type"] >> predator_mask_type
	S["pred_armor_type"] >> predator_armor_type
	S["pred_boot_type"] >> predator_boot_type
	S["pred_mask_mat"] >> predator_mask_material
	S["pred_armor_mat"] >> predator_armor_material
	S["pred_greave_mat"] >> predator_greave_material
	S["pred_caster_mat"] >> predator_caster_material
	S["pred_cape_type"] >> predator_cape_type
	S["pred_cape_color"] >> predator_cape_color
	S["pred_h_style"] >> predator_h_style
	S["pred_skin_color"] >> predator_skin_color
	S["pred_flavor_text"] >> predator_flavor_text

	S["commander_status"] >> commander_status
	S["co_sidearm"] >> commander_sidearm
	S["co_affiliation"] >> affiliation
	S["yautja_status"] >> yautja_status
	S["synth_status"] >> synth_status

	S["lang_chat_disabled"] >> lang_chat_disabled
	S["show_permission_errors"] >> show_permission_errors
	S["hear_vox"] >> hear_vox
	S["hide_statusbar"] >> hide_statusbar
	S["no_radials_preference"] >> no_radials_preference
	S["no_radial_labels_preference"] >> no_radial_labels_preference
	S["hotkeys"] >> hotkeys

	S["custom_cursors"] >> custom_cursors
	S["autofit_viewport"] >> auto_fit_viewport
	S["adaptive_zoom"] >> adaptive_zoom
	S["tooltips"] >> tooltips
	S["key_bindings"] >> key_bindings

	S["tgui_lock"] >> tgui_lock
	S["tgui_fancy"] >> tgui_fancy
	S["window_scale"] >> window_scale

	var/list/remembered_key_bindings
	S["remembered_key_bindings"] >> remembered_key_bindings

	//Sanitize
	ooccolor = sanitize_hexcolor(ooccolor, CONFIG_GET(string/ooc_color_normal))
	lastchangelog = sanitize_text(lastchangelog, initial(lastchangelog))
	UI_style = sanitize_inlist(UI_style, list("white", "dark", "midnight", "orange", "old"), initial(UI_style))
	tgui_say = sanitize_integer(tgui_say, FALSE, TRUE, TRUE)
	be_special = sanitize_integer(be_special, 0, SHORT_REAL_LIMIT, initial(be_special))
	default_slot = sanitize_integer(default_slot, 1, MAX_SAVE_SLOTS, initial(default_slot))
	toggles_chat = sanitize_integer(toggles_chat, 0, SHORT_REAL_LIMIT, initial(toggles_chat))
	chat_display_preferences = sanitize_integer(chat_display_preferences, 0, SHORT_REAL_LIMIT, initial(chat_display_preferences))
	toggles_ghost = sanitize_integer(toggles_ghost, 0, SHORT_REAL_LIMIT, initial(toggles_ghost))
	toggles_langchat = sanitize_integer(toggles_langchat, 0, SHORT_REAL_LIMIT, initial(toggles_langchat))
	toggles_sound = sanitize_integer(toggles_sound, 0, SHORT_REAL_LIMIT, initial(toggles_sound))
	toggle_prefs = sanitize_integer(toggle_prefs, 0, SHORT_REAL_LIMIT, initial(toggle_prefs))
	xeno_ability_click_mode = sanitize_integer(xeno_ability_click_mode, 1, XENO_ABILITY_CLICK_MAX, initial(xeno_ability_click_mode))
	dual_wield_pref = sanitize_integer(dual_wield_pref, 0, 2, initial(dual_wield_pref))
	toggles_flashing= sanitize_integer(toggles_flashing, 0, SHORT_REAL_LIMIT, initial(toggles_flashing))
	toggles_ert = sanitize_integer(toggles_ert, 0, SHORT_REAL_LIMIT, initial(toggles_ert))
	toggles_admin = sanitize_integer(toggles_admin, 0, SHORT_REAL_LIMIT, initial(toggles_admin))
	UI_style_color = sanitize_hexcolor(UI_style_color, initial(UI_style_color))
	UI_style_alpha = sanitize_integer(UI_style_alpha, 0, 255, initial(UI_style_alpha))
	item_animation_pref_level = sanitize_integer(item_animation_pref_level, SHOW_ITEM_ANIMATIONS_NONE, SHOW_ITEM_ANIMATIONS_ALL, SHOW_ITEM_ANIMATIONS_ALL)
	pain_overlay_pref_level = sanitize_integer(pain_overlay_pref_level, PAIN_OVERLAY_BLURRY, PAIN_OVERLAY_LEGACY, PAIN_OVERLAY_BLURRY)
	flash_overlay_pref = sanitize_integer(flash_overlay_pref, FLASH_OVERLAY_WHITE, FLASH_OVERLAY_DARK)
	crit_overlay_pref = sanitize_integer(crit_overlay_pref, CRIT_OVERLAY_WHITE, CRIT_OVERLAY_DARK)
	window_skin = sanitize_integer(window_skin, 0, SHORT_REAL_LIMIT, initial(window_skin))
	ghost_vision_pref = sanitize_inlist(ghost_vision_pref, list(GHOST_VISION_LEVEL_NO_NVG, GHOST_VISION_LEVEL_MID_NVG, GHOST_VISION_LEVEL_FULL_NVG), GHOST_VISION_LEVEL_MID_NVG)
	ghost_orbit = sanitize_inlist(ghost_orbit, GLOB.ghost_orbits, initial(ghost_orbit))
	auto_observe = sanitize_integer(auto_observe, 0, 1, 1)
	playtime_perks   = sanitize_integer(playtime_perks, 0, 1, 1)
	xeno_vision_level_pref = sanitize_inlist(xeno_vision_level_pref, list(XENO_VISION_LEVEL_NO_NVG, XENO_VISION_LEVEL_MID_NVG, XENO_VISION_LEVEL_FULL_NVG), XENO_VISION_LEVEL_MID_NVG)
	hear_vox = sanitize_integer(hear_vox, FALSE, TRUE, TRUE)
	hide_statusbar = sanitize_integer(hide_statusbar, FALSE, TRUE, FALSE)
	no_radials_preference = sanitize_integer(no_radials_preference, FALSE, TRUE, FALSE)
	no_radial_labels_preference = sanitize_integer(no_radial_labels_preference, FALSE, TRUE, FALSE)
	auto_fit_viewport = sanitize_integer(auto_fit_viewport, FALSE, TRUE, TRUE)
	adaptive_zoom = sanitize_integer(adaptive_zoom, 0, 2, 0)
	tooltips = sanitize_integer(tooltips, FALSE, TRUE, TRUE)

	synthetic_name = synthetic_name ? sanitize_text(synthetic_name, initial(synthetic_name)) : initial(synthetic_name)
	synthetic_type = sanitize_inlist(synthetic_type, PLAYER_SYNTHS, initial(synthetic_type))
	predator_name = predator_name ? sanitize_text(predator_name, initial(predator_name)) : initial(predator_name)
	predator_gender = sanitize_text(predator_gender, initial(predator_gender))
	predator_age = sanitize_integer(predator_age, 100, 10000, initial(predator_age))
	predator_use_legacy = sanitize_inlist(predator_use_legacy, PRED_LEGACIES, initial(predator_use_legacy))
	predator_translator_type = sanitize_inlist(predator_translator_type, PRED_TRANSLATORS, initial(predator_translator_type))
	predator_mask_type = sanitize_integer(predator_mask_type,1,1000000,initial(predator_mask_type))
	predator_armor_type = sanitize_integer(predator_armor_type,1,1000000,initial(predator_armor_type))
	predator_boot_type = sanitize_integer(predator_boot_type,1,1000000,initial(predator_boot_type))
	predator_mask_material = sanitize_inlist(predator_mask_material, PRED_MATERIALS, initial(predator_mask_material))
	predator_armor_material = sanitize_inlist(predator_armor_material, PRED_MATERIALS, initial(predator_armor_material))
	predator_greave_material = sanitize_inlist(predator_greave_material, PRED_MATERIALS, initial(predator_greave_material))
	predator_caster_material = sanitize_inlist(predator_caster_material, PRED_MATERIALS + "retro", initial(predator_caster_material))
	predator_cape_type = sanitize_inlist(predator_cape_type, GLOB.all_yautja_capes + "None", initial(predator_cape_type))
	predator_cape_color = sanitize_hexcolor(predator_cape_color, initial(predator_cape_color))
	predator_h_style = sanitize_inlist(predator_h_style, GLOB.yautja_hair_styles_list, initial(predator_h_style))
	predator_skin_color = sanitize_inlist(predator_skin_color, PRED_SKIN_COLOR, initial(predator_skin_color))
	predator_flavor_text = predator_flavor_text ? sanitize_text(predator_flavor_text, initial(predator_flavor_text)) : initial(predator_flavor_text)
	commander_status = sanitize_inlist(commander_status, GLOB.whitelist_hierarchy, initial(commander_status))
	commander_sidearm   = sanitize_inlist(commander_sidearm, (CO_GUNS + COUNCIL_CO_GUNS), initial(commander_sidearm))
	affiliation = sanitize_inlist(affiliation, FACTION_ALLEGIANCE_USCM_COMMANDER, initial(affiliation))
	yautja_status = sanitize_inlist(yautja_status, GLOB.whitelist_hierarchy + list("Elder"), initial(yautja_status))
	synth_status = sanitize_inlist(synth_status, GLOB.whitelist_hierarchy, initial(synth_status))

	window_scale = sanitize_integer(window_scale, FALSE, TRUE, initial(window_scale))
	tgui_lock = sanitize_integer(tgui_lock, FALSE, TRUE, initial(tgui_lock))
	tgui_fancy = sanitize_integer(tgui_fancy, FALSE, TRUE, initial(tgui_fancy))

	key_bindings = sanitize_keybindings(key_bindings)
	remembered_key_bindings = sanitize_islist(remembered_key_bindings, null)
	hotkeys = sanitize_integer(hotkeys, FALSE, TRUE, TRUE)
	custom_cursors = sanitize_integer(custom_cursors, FALSE, TRUE, TRUE)
	pref_special_job_options = sanitize_islist(pref_special_job_options, list())
	pref_job_slots = sanitize_islist(pref_job_slots, list())
	vars["fps"] = fps

	check_keybindings()
	S["key_bindings"] << key_bindings

	if(remembered_key_bindings)
		for(var/i in GLOB.keybindings_by_name)
			if(!(i in remembered_key_bindings))
				var/datum/keybinding/instance = GLOB.keybindings_by_name[i]
				// Classic
				if(LAZYLEN(instance.classic_keys))
					for(var/bound_key in instance.classic_keys)
						LAZYADD(key_bindings[bound_key], list(instance.name))

				// Hotkey
				if(LAZYLEN(instance.hotkey_keys))
					for(var/bound_key in instance.hotkey_keys)
						LAZYADD(key_bindings[bound_key], list(instance.name))

	S["remembered_key_bindings"] << GLOB.keybindings_by_name

	S.Unlock()

	if(toggles_chat & SHOW_TYPING)
		owner.typing_indicators = FALSE
	else
		owner.typing_indicators = TRUE

	if(!observer_huds)
		observer_huds = list("Medical HUD" = FALSE, "Security HUD" = FALSE, "Squad HUD" = FALSE, "Xeno Status HUD" = FALSE)

	return 1

/datum/preferences/proc/save_preferences()
	if(!path)
		return FALSE
	var/savefile/S = new /savefile(path)
	if(!S)
		return FALSE
	if(!S.Lock())
		to_chat(owner, SPAN_BOLDWARNING("Failed to save your preferences file - it may be in use by another process. Please try again."))
		return FALSE
	S.cd = "/"

	S["version"] << savefile_version

	//general preferences
	S["ooccolor"] << ooccolor
	S["lastchangelog"] << lastchangelog
	S["UI_style"] << UI_style
	S["UI_style_color"] << UI_style_color
	S["UI_style_alpha"] << UI_style_alpha
	S["tgui_say"] << tgui_say
	S["item_animation_pref_level"] << item_animation_pref_level
	S["pain_overlay_pref_level"] << pain_overlay_pref_level
	S["flash_overlay_pref"] << flash_overlay_pref
	S["crit_overlay_pref"] << crit_overlay_pref
	S["stylesheet"] << stylesheet
	S["be_special"] << be_special
	S["default_slot"] << default_slot
	S["toggles_chat"] << toggles_chat
	S["chat_display_preferences"] << chat_display_preferences
	S["toggles_ghost"] << toggles_ghost
	S["toggles_langchat"] << toggles_langchat
	S["toggles_sound"] << toggles_sound
	S["toggle_prefs"] << toggle_prefs
	S["xeno_ability_click_mode"] << xeno_ability_click_mode
	S["dual_wield_pref"] << dual_wield_pref
	S["toggles_flashing"] << toggles_flashing
	S["toggles_ert"] << toggles_ert
	S["toggles_admin"] << toggles_admin
	S["window_skin"] << window_skin
	S["fps"] << fps
	S["ghost_vision_pref"] << ghost_vision_pref
	S["ghost_orbit"] << ghost_orbit
	S["auto_observe"] << auto_observe

	S["human_name_ban"] << human_name_ban

	S["xeno_prefix"] << xeno_prefix
	S["xeno_postfix"] << xeno_postfix
	S["xeno_name_ban"] << xeno_name_ban
	S["xeno_vision_level_pref"] << xeno_vision_level_pref
	S["playtime_perks"] << playtime_perks

	S["view_controller"] << View_MC
	S["observer_huds"] << observer_huds
	S["pref_special_job_options"] << pref_special_job_options
	S["pref_job_slots"] << pref_job_slots

	S["synth_name"] << synthetic_name
	S["synth_type"] << synthetic_type
	S["pred_name"] << predator_name
	S["pred_gender"] << predator_gender
	S["pred_age"] << predator_age
	S["pred_use_legacy"] << predator_use_legacy
	S["pred_trans_type"] << predator_translator_type
	S["pred_mask_type"] << predator_mask_type
	S["pred_armor_type"] << predator_armor_type
	S["pred_boot_type"] << predator_boot_type
	S["pred_mask_mat"] << predator_mask_material
	S["pred_armor_mat"] << predator_armor_material
	S["pred_greave_mat"] << predator_greave_material
	S["pred_caster_mat"] << predator_caster_material
	S["pred_cape_type"] << predator_cape_type
	S["pred_cape_color"] << predator_cape_color
	S["pred_h_style"] << predator_h_style
	S["pred_skin_color"] << predator_skin_color
	S["pred_flavor_text"] << predator_flavor_text

	S["commander_status"] << commander_status
	S["co_sidearm"] << commander_sidearm
	S["co_affiliation"] << affiliation
	S["yautja_status"] << yautja_status
	S["synth_status"] << synth_status


	S["lang_chat_disabled"] << lang_chat_disabled
	S["show_permission_errors"] << show_permission_errors
	S["key_bindings"] << key_bindings
	S["hotkeys"] << hotkeys

	S["autofit_viewport"] << auto_fit_viewport
	S["adaptive_zoom"] << adaptive_zoom

	S["hear_vox"] << hear_vox

	S["hide_statusbar"] << hide_statusbar
	S["no_radials_preference"] << no_radials_preference
	S["no_radial_labels_preference"] << no_radial_labels_preference
	S["custom_cursors"] << custom_cursors

	S["tgui_fancy"] << tgui_fancy
	S["tgui_lock"] << tgui_lock
	S["window_scale"] << window_scale

	S.Unlock()

	return TRUE

/datum/preferences/proc/load_character(slot)
	if(!path)
		return FALSE

	if(!fexists(path))
		return FALSE

	var/savefile/S = new /savefile(path)
	if(!S)
		return FALSE

	if(!S.Lock())
		to_chat(owner, SPAN_BOLDWARNING("Failed to load your character slot - it may be in use by another process. Please try again."))
		return FALSE

	S.cd = "/"

	if(!slot)
		slot = default_slot
	slot = sanitize_integer(slot, 1, MAX_SAVE_SLOTS, initial(default_slot))
	if(slot != default_slot)
		default_slot = slot
		S["default_slot"] << slot
	S.cd = "/character[slot]"

	//Character
	S["OOC_Notes"] >> metadata
	S["real_name"] >> real_name
	S["slot_label"] >> slot_label
	S["name_is_always_random"] >> be_random_name
	S["body_is_always_random"] >> be_random_body
	S["gender"] >> gender
	S["age"] >> age
	S["ethnicity"] >> ethnicity
	S["skin_color"] >> skin_color
	S["body_type"] >> body_type
	S["body_size"] >> body_size
	S["language"] >> language
	S["spawnpoint"] >> spawnpoint

	//colors to be consolidated into hex strings (requires some work with dna code)
	S["hair_red"] >> r_hair
	S["hair_green"] >> g_hair
	S["hair_blue"] >> b_hair
	S["grad_red"] >> r_gradient
	S["grad_green"] >> g_gradient
	S["grad_blue"] >> b_gradient
	S["facial_red"] >> r_facial
	S["facial_green"] >> g_facial
	S["facial_blue"] >> b_facial
	S["skin_red"] >> r_skin
	S["skin_green"] >> g_skin
	S["skin_blue"] >> b_skin
	S["hair_style_name"] >> h_style
	S["hair_gradient_name"] >> grad_style
	S["facial_style_name"] >> f_style
	S["eyes_red"] >> r_eyes
	S["eyes_green"] >> g_eyes
	S["eyes_blue"] >> b_eyes
	S["underwear"] >> underwear
	S["undershirt"] >> undershirt
	S["backbag"] >> backbag
	//S["b_type"] >> b_type

	//Jobs
	S["alternate_option"] >> alternate_option
	S["job_preference_list"] >> job_preference_list

	//Flavour Text
	S["flavor_texts_general"] >> flavor_texts["general"]
	S["flavor_texts_head"] >> flavor_texts["head"]
	S["flavor_texts_face"] >> flavor_texts["face"]
	S["flavor_texts_eyes"] >> flavor_texts["eyes"]
	S["flavor_texts_torso"] >> flavor_texts["torso"]
	S["flavor_texts_arms"] >> flavor_texts["arms"]
	S["flavor_texts_hands"] >> flavor_texts["hands"]
	S["flavor_texts_legs"] >> flavor_texts["legs"]
	S["flavor_texts_feet"] >> flavor_texts["feet"]
	S["flavor_texts_helmet"] >> flavor_texts["helmet"]
	S["flavor_texts_armor"] >> flavor_texts["armor"]


	//Miscellaneous
	S["med_record"] >> med_record
	S["sec_record"] >> sec_record
	S["gen_record"] >> gen_record
	S["be_special"] >> be_special
	S["organ_data"] >> organ_data
	S["gear"] >> gear
	S["origin"] >> origin
	S["faction"] >> faction
	S["religion"] >> religion
	S["traits"] >> traits

	S["preferred_squad"] >> preferred_squad
	S["preferred_armor"] >> preferred_armor
	S["weyland_yutani_relation"] >> weyland_yutani_relation
	//S["skin_style"] >> skin_style

	S["uplinklocation"] >> uplinklocation
	S["exploit_record"] >> exploit_record

	var/tutorial_string = ""
	S["completed_tutorials"] >> tutorial_string
	tutorial_savestring_to_list(tutorial_string)

	S["ds_camo"] >> dropship_camo
	S["plat_name"] >> platoon_name
	S["ds_name"] >> dropship_name

	S["personal_weapon"] >> personal_weapon

	S.Unlock()

	//Sanitize
	metadata = sanitize_text(metadata, initial(metadata))
	real_name = reject_bad_name(real_name)

	if(isnull(language)) language = "None"
	if(isnull(spawnpoint)) spawnpoint = "Arrivals Shuttle"
	if(isnull(weyland_yutani_relation)) weyland_yutani_relation = initial(weyland_yutani_relation)
	if(!real_name) real_name = random_name(gender)
	be_random_name = sanitize_integer(be_random_name, 0, 1, initial(be_random_name))
	be_random_body = sanitize_integer(be_random_body, 0, 1, initial(be_random_body))
	gender = sanitize_gender(gender)
	age = sanitize_integer(age, AGE_MIN, AGE_MAX, initial(age))
	skin_color = sanitize_skin_color(skin_color)
	body_type = sanitize_body_type(body_type)
	body_size = sanitize_body_size(body_size)
	r_hair = sanitize_integer(r_hair, 0, 255, initial(r_hair))
	g_hair = sanitize_integer(g_hair, 0, 255, initial(g_hair))
	b_hair = sanitize_integer(b_hair, 0, 255, initial(b_hair))
	r_facial = sanitize_integer(r_facial, 0, 255, initial(r_facial))
	g_facial = sanitize_integer(g_facial, 0, 255, initial(g_facial))
	b_facial = sanitize_integer(b_facial, 0, 255, initial(b_facial))
	r_skin = sanitize_integer(r_skin, 0, 255, initial(r_skin))
	g_skin = sanitize_integer(g_skin, 0, 255, initial(g_skin))
	b_skin = sanitize_integer(b_skin, 0, 255, initial(b_skin))
	h_style = sanitize_inlist(h_style, GLOB.hair_styles_list, initial(h_style))
	r_gradient = sanitize_integer(r_gradient, 0, 255, initial(r_gradient))
	g_gradient = sanitize_integer(g_gradient, 0, 255, initial(g_gradient))
	b_gradient = sanitize_integer(b_gradient, 0, 255, initial(b_gradient))
	grad_style = sanitize_inlist(grad_style, GLOB.hair_gradient_list, initial(grad_style))
	var/datum/sprite_accessory/HS = GLOB.hair_styles_list[h_style]
	if(!HS.selectable) // delete this
		h_style = random_hair_style(gender, species)
		save_character()
	f_style = sanitize_inlist(f_style, GLOB.facial_hair_styles_list, initial(f_style))
	var/datum/sprite_accessory/FS = GLOB.facial_hair_styles_list[f_style]
	if(!FS.selectable) // delete this
		f_style = random_facial_hair_style(gender, species)
		save_character()
	r_eyes = sanitize_integer(r_eyes, 0, 255, initial(r_eyes))
	g_eyes = sanitize_integer(g_eyes, 0, 255, initial(g_eyes))
	b_eyes = sanitize_integer(b_eyes, 0, 255, initial(b_eyes))
	underwear = sanitize_inlist(underwear, gender == MALE ? GLOB.underwear_m : GLOB.underwear_f, initial(underwear))
	undershirt = sanitize_inlist(undershirt, gender == MALE ? GLOB.undershirt_m : GLOB.undershirt_f, initial(undershirt))
	backbag = sanitize_integer(backbag, 1, length(GLOB.backbaglist), initial(backbag))
	preferred_armor = sanitize_inlist(preferred_armor, GLOB.armor_style_list, "Random")
	//b_type = sanitize_text(b_type, initial(b_type))

	platoon_name = platoon_name ? sanitize_text(platoon_name, initial(platoon_name)) : "Sun Riders"
	dropship_camo = sanitize_inlist(dropship_camo, GLOB.dropship_camos, initial(dropship_camo))
	dropship_name = dropship_name ? sanitize_text(dropship_name, initial(dropship_name)) : "Midway"

	personal_weapon = sanitize_inlist(personal_weapon, GLOB.personal_weapons_list+"None", initial(personal_weapon))

	alternate_option = sanitize_integer(alternate_option, 0, 2, initial(alternate_option))
	if(!job_preference_list)
		ResetJobs()
	else
		for(var/job in job_preference_list)
			job_preference_list[job] = sanitize_integer(job_preference_list[job], 0, 4, initial(job_preference_list[job]))

	if(!organ_data)
		organ_data = list()

	gear = sanitize_list(gear)

	traits = sanitize_list(traits)
	read_traits = FALSE
	trait_points = initial(trait_points)
	close_browser(owner, "character_traits")

	if(!origin) origin = ORIGIN_USCM
	if(!faction)  faction =  "None"
	if(!religion) religion = RELIGION_AGNOSTICISM
	if(!preferred_squad) preferred_squad = "None"

	return 1

/datum/preferences/proc/save_character()
	if(!path)
		return FALSE
	var/savefile/S = new /savefile(path)
	if(!S)
		return FALSE

	if(!S.Lock())
		to_chat(owner, SPAN_BOLDWARNING("Failed to save your character slot - it may be in use by another process. Please try again."))
		return FALSE

	S.cd = "/character[default_slot]"

	//Character
	S["OOC_Notes"] << metadata
	S["real_name"] << real_name
	S["slot_label"] << slot_label
	S["name_is_always_random"] << be_random_name
	S["body_is_always_random"] << be_random_body
	S["gender"] << gender
	S["age"] << age
	S["ethnicity"] << ethnicity
	S["skin_color"] << skin_color
	S["body_type"] << body_type
	S["body_size"] << body_size
	S["language"] << language
	S["hair_red"] << r_hair
	S["hair_green"] << g_hair
	S["hair_blue"] << b_hair
	S["grad_red"] << r_gradient
	S["grad_green"] << g_gradient
	S["grad_blue"] << b_gradient
	S["facial_red"] << r_facial
	S["facial_green"] << g_facial
	S["facial_blue"] << b_facial
	S["skin_red"] << r_skin
	S["skin_green"] << g_skin
	S["skin_blue"] << b_skin
	S["hair_style_name"] << h_style
	S["hair_gradient_name"] << grad_style
	S["facial_style_name"] << f_style
	S["eyes_red"] << r_eyes
	S["eyes_green"] << g_eyes
	S["eyes_blue"] << b_eyes
	S["underwear"] << underwear
	S["undershirt"] << undershirt
	S["backbag"] << backbag
	//S["b_type"] << b_type
	S["spawnpoint"] << spawnpoint

	//Jobs
	S["alternate_option"] << alternate_option
	S["job_preference_list"] << job_preference_list

	//Flavour Text
	S["flavor_texts_general"] << flavor_texts["general"]
	S["flavor_texts_head"] << flavor_texts["head"]
	S["flavor_texts_face"] << flavor_texts["face"]
	S["flavor_texts_eyes"] << flavor_texts["eyes"]
	S["flavor_texts_torso"] << flavor_texts["torso"]
	S["flavor_texts_arms"] << flavor_texts["arms"]
	S["flavor_texts_hands"] << flavor_texts["hands"]
	S["flavor_texts_legs"] << flavor_texts["legs"]
	S["flavor_texts_feet"] << flavor_texts["feet"]
	S["flavor_texts_helmet"] << flavor_texts["helmet"]
	S["flavor_texts_armor"] << flavor_texts["armor"]

	//Miscellaneous
	S["med_record"] << med_record
	S["sec_record"] << sec_record
	S["gen_record"] << gen_record
	S["be_special"] << be_special
	S["organ_data"] << organ_data
	S["gear"] << gear
	S["origin"] << origin
	S["faction"] << faction
	S["religion"] << religion
	S["traits"] << traits

	S["weyland_yutani_relation"] << weyland_yutani_relation
	S["preferred_squad"] << preferred_squad
	S["preferred_armor"] << preferred_armor
	//S["skin_style"] << skin_style

	S["uplinklocation"] << uplinklocation
	S["exploit_record"] << exploit_record

	S["completed_tutorials"] << tutorial_list_to_savestring()

	S["ds_camo"] << dropship_camo
	S["plat_name"] << platoon_name
	S["ds_name"] << dropship_name

	S["personal_weapon"] << personal_weapon

	S.Unlock()

	return TRUE

/// checks through keybindings for outdated unbound keys and updates them
/datum/preferences/proc/check_keybindings()
	if(!owner)
		return
	var/list/user_binds = list()
	for(var/key in key_bindings)
		for(var/kb_name in key_bindings[key])
			user_binds[kb_name] += list(key)
	var/list/notadded = list()
	for(var/name in GLOB.keybindings_by_name)
		var/datum/keybinding/kb = GLOB.keybindings_by_name[name]
		if(length(user_binds[kb.name]))
			continue // key is unbound and or bound to something
		var/addedbind = FALSE
		if(hotkeys)
			for(var/hotkeytobind in kb.hotkey_keys)
				if(!length(key_bindings[hotkeytobind]) || hotkeytobind == "Unbound") //Only bind to the key if nothing else is bound expect for Unbound
					LAZYADD(key_bindings[hotkeytobind], kb.name)
					addedbind = TRUE
		else
			for(var/classickeytobind in kb.classic_keys)
				if(!length(key_bindings[classickeytobind]) || classickeytobind == "Unbound") //Only bind to the key if nothing else is bound expect for Unbound
					LAZYADD(key_bindings[classickeytobind], kb.name)
					addedbind = TRUE
		if(!addedbind)
			notadded += kb

	if(length(notadded))
		addtimer(CALLBACK(src, PROC_REF(announce_conflict), notadded), 5 SECONDS)

/datum/preferences/proc/announce_conflict(list/notadded)
	to_chat(owner, SPAN_ALERTWARNING("<u>Keybinding Conflict</u>"))
	to_chat(owner, SPAN_ALERTWARNING("There are new <a href='byond://?_src_=prefs;preference=viewmacros'>keybindings</a> that default to keys you've already bound. The new ones will be unbound."))
	for(var/datum/keybinding/conflicted as anything in notadded)
		to_chat(owner, SPAN_DANGER("[conflicted.category]: [conflicted.full_name] needs updating"))

		if(hotkeys)
			for(var/entry in conflicted.hotkey_keys)
				LAZYREMOVE(key_bindings[entry], conflicted.name)
		else
			for(var/entry in conflicted.classic_keys)
				LAZYREMOVE(key_bindings[entry], conflicted.name)

		LAZYADD(key_bindings["Unbound"], conflicted.name) // set it to unbound to prevent this from opening up again in the future

#undef SAVEFILE_VERSION_MAX
#undef SAVEFILE_VERSION_MIN
