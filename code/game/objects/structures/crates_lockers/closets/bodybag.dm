
/obj/structure/closet/body_bag
	name = "body bag"
	desc = "A plastic bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag"
	density = FALSE
	mob_storage_capacity = 2
	open_sound = 'sound/items/zip.ogg'
	close_sound = 'sound/items/zip.ogg'
	integrity_failure = 0
	material_drop = /obj/item/stack/sheet/cloth
	delivery_icon = null //unwrappable
	anchorable = FALSE
	drag_delay = 0.05 SECONDS
	var/foldedbag_path = /obj/item/bodybag
	var/tagged = 0 // so closet code knows to put the tag overlay back

/obj/structure/closet/body_bag/attackby(obj/item/I, mob/user, params)
	if (istype(I, /obj/item/pen) || istype(I, /obj/item/toy/crayon))
		if(!user.is_literate())
			to_chat(user, SPAN_NOTICE("You scribble illegibly on [src]!"))
			return
		var/t = stripped_input(user, "What would you like the label to be?", name, null, 53)
		if(user.get_active_held_item() != I)
			return
		if(!user.canUseTopic(src, BE_CLOSE))
			return
		if(t)
			name = "body bag - [t]"
			tagged = 1
			update_icon()
		else
			name = "body bag"
		return
	else if(istype(I, /obj/item/wirecutters))
		to_chat(user, SPAN_NOTICE("You cut the tag off [src]."))
		name = "body bag"
		tagged = 0
		update_icon()

/obj/structure/closet/body_bag/update_overlays()
	. = ..()
	if (tagged)
		. += "bodybag_label"

/obj/structure/closet/body_bag/close()
	if(..())
		density = FALSE
		return 1
	return 0

/obj/structure/closet/body_bag/handle_lock_addition()
	return

/obj/structure/closet/body_bag/handle_lock_removal()
	return

/obj/structure/closet/body_bag/MouseDrop(over_object, src_location, over_location)
	. = ..()
	if(over_object == usr && Adjacent(usr) && (in_range(src, usr) || usr.contents.Find(src)))
		if(!ishuman(usr))
			return 0
		if(opened)
			return 0
		if(contents.len)
			return 0
		visible_message(SPAN_NOTICE("[usr] folds up [src]."))
		var/obj/item/bodybag/B = new foldedbag_path(get_turf(src))
		usr.put_in_hands(B)
		qdel(src)


/obj/structure/closet/body_bag/bluespace
	name = "bluespace body bag"
	desc = "A bluespace body bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bluebodybag"
	foldedbag_path = /obj/item/bodybag/bluespace
	mob_storage_capacity = 15
	max_mob_size = MOB_SIZE_LARGE

/obj/structure/closet/body_bag/bluespace/MouseDrop(over_object, src_location, over_location)
	. = ..()
	if(over_object == usr && Adjacent(usr) && (in_range(src, usr) || usr.contents.Find(src)))
		if(!ishuman(usr))
			return 0
		if(opened)
			return 0
		if(contents.len >= mob_storage_capacity / 2)
			to_chat(usr, SPAN_WARNING("There are too many things inside of [src] to fold it up!"))
			return 0
		for(var/obj/item/bodybag/bluespace/B in src)
			to_chat(usr, SPAN_WARNING("You can't recursively fold bluespace body bags!") )
			return 0
		visible_message(SPAN_NOTICE("[usr] folds up [src]."))
		var/obj/item/bodybag/B = new foldedbag_path(get_turf(src))
		usr.put_in_hands(B)
		for(var/atom/movable/A in contents)
			A.forceMove(B)
			if(isliving(A))
				to_chat(A, "<span class='userdanger'>You're suddenly forced into a tiny, compressed space!</span>")
		qdel(src)

/obj/structure/closet/body_bag/containment
	name = "containment body bag"
	desc = "A folded heavy body bag designed for the storage and transportation of cadavers with heavy radiation."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "radbodybag"
	mob_storage_capacity = 1
	foldedbag_path = /obj/item/bodybag/containment
	rad_flags = RAD_PROTECT_CONTENTS | RAD_NO_CONTAMINATE
