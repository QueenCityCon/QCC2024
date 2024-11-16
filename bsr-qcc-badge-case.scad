$fn=120;

ct = 1.2; // Case Thickness
ct2 = ct * 2;

pcb_x = 76.2 + ct + 0.3;
pcb_y = 127.0 + ct + 0.6;
pcb_z = 1.75 + ct + 0.6;
pcb_r = 4.0;

pcb_support_loc_x = 30.0;
pcb_support_loc_y = 82.5;
pcb_support_length = 15.0;

batt_x = 60;
batt_y = 35;
batt_z = 18;
batt_corner_d = 6.0;
batt_edge_offset = 4.81;

batt_cable_cutout_x = 6.445;
batt_cable_cutout_y = 26.0;

slot_x = 25.0;
slot_y = 8.0;
slot_y_offset = 5.08 - (slot_y / 2);

hole_d = 3.175;


module pcb_face() {
    hull() {
        cube([pcb_x, pcb_y, 0.0001]);
        translate([ct, ct, pcb_z / 1.25]) {
            cube([pcb_x - ct2, pcb_y - ct2, 0.0001]);
        }
    }
}

module pcb_face2() {
    hull() {
        cube([pcb_x + ct, pcb_y + ct, 0.0001]);
        translate([ct2, ct2, pcb_z / 2]) {
            cube([pcb_x - (ct * 3), pcb_y - (ct * 3), 0.0001]);
        }
    }
}

module pcb() {
    translate([pcb_r, pcb_r, 0]) {
        hull() {
            cylinder(h = pcb_z, r = pcb_r);
            translate([pcb_x - (pcb_r * 2), 0, 0]) {
                cylinder(h = pcb_z, r = pcb_r);
            }
            translate([0, pcb_y - (pcb_r * 2), 0]) {
                cylinder(h = pcb_z, r = pcb_r);
                translate([pcb_x - (pcb_r * 2), 0, 0]) {
                    cylinder(h = pcb_z, r = pcb_r);
                }
            }
        }    
    }
}

module lanyard_slot() {
    hull() {
        translate([0, slot_y / 2, -pcb_z]) {
            cube([slot_x, slot_y, pcb_z * 6]);
            translate([slot_y / 2, 0, 0]) {
                cylinder(h = pcb_z * 6, d = slot_y);
                translate([slot_x - slot_y, 0, 0]) {
                    cylinder(h = pcb_z * 6, d = slot_y);
                }
            }
        }
    }
}

module battery_holder() {
    translate([0, batt_corner_d / 2, batt_z - (batt_corner_d / 2)]) {
        rotate([0,90,0]){
            hull() {
                cylinder(h = batt_x, d = batt_corner_d);
                translate([0, batt_y - batt_corner_d, 0]) {
                    cylinder(h = batt_x, d = batt_corner_d);
                    translate([batt_z - (batt_corner_d * 1.5), batt_corner_d / -2, 0]) {
                        cube([batt_corner_d, batt_corner_d, batt_x]);
                    }
                }
                translate([batt_z - (batt_corner_d * 1.5), batt_corner_d / -2, 0]) {
                    cube([batt_corner_d, batt_corner_d, batt_x]);
                }
            }
        }
    }
}

module badge_cutout() {
    union() {
        translate([batt_edge_offset / 2, batt_edge_offset / 2, pcb_z / 2]) {
            resize([pcb_x - batt_edge_offset, pcb_y - batt_edge_offset, pcb_z]) {
                pcb();
            }
        }
        translate([(pcb_x / 2) - (batt_x / 2), batt_edge_offset - ct, pcb_z - 0.0001]) {
            battery_holder();
            // Last-minute change request to add USB cable relief cutout    
            translate([batt_x, (batt_y - batt_cable_cutout_y) / 2, 0]) {
                cube([batt_cable_cutout_x, batt_cable_cutout_y, batt_z]);
            }
        }
        translate([(pcb_x / 2) - (slot_x / 2), pcb_y - slot_y, 0]) {
            lanyard_slot();
        }
        translate([0, pcb_y, pcb_z / 1.5]) {
            rotate([180, 0, 0]) {
                pcb_face();
            }
        }
        // Adding corner cutout posts here. Sorry I'm lazy. :(
        translate([0, 0, -pcb_z]) {
            cylinder(h = pcb_z * 6, r = pcb_r);
            translate([pcb_x, 0, 0]) {
                cylinder(h = pcb_z * 6, r = pcb_r);
            }
            translate([0, pcb_y, 0]) {
                cylinder(h = pcb_z * 6, r = pcb_r);
                translate([pcb_x, 0, 0]) {
                    cylinder(h = pcb_z * 6, r = pcb_r);
                }
            }
        }
    }
}

module badge_shell() {
    difference() {
        union() {
            resize([pcb_x + ct2, pcb_y + ct2, pcb_z + (ct * 3.8) + 0.4]) {
                pcb();
            }
        }
        union() {
            translate([((pcb_x + ct2) / 2) - ((batt_x + ct2) / 2), batt_edge_offset - ct, pcb_z + ct2 - 0.0001]) {
                resize([batt_x + ct2, batt_y + ct2, batt_z + ct]) {
                    battery_holder();
                }
            }
        }
    }
}


module main() {
    union() {
        difference() {
            union() {
                difference() {
                    translate([0, 0, -ct]) {
                        badge_shell();
                        
                        // expansion of badge shell to improve layer adhesion and durability
                        translate([pcb_r, -ct, 0]) {
                            cube([(pcb_x + ct2) - (pcb_r * 2), ct, pcb_z + (ct * 3.8) + 0.4]);
                        }
                        translate([pcb_r, pcb_y + ct2, 0]) {
                            cube([(pcb_x + ct2) - (pcb_r * 2), ct, pcb_z + (ct * 3.8) + 0.4]);
                        }
                        translate([-ct, pcb_r, 0]) {
                            cube([ct, (pcb_y + ct2) - (pcb_r * 2), pcb_z + (ct * 3.8) + 0.4]);
                        }
                        translate([pcb_x + ct2, pcb_r, 0]) {
                            cube([ct, (pcb_y + ct2) - (pcb_r * 2), pcb_z + (ct * 3.8) + 0.4]);
                        }
                    }
                    union() {
                        translate([ct, ct, 0]) {
                            badge_cutout();
                        }
                        translate([ct / 2, ct / 2, -pcb_z / 2.4]) {
                            pcb_face2();
                        }
                    }
                }
                // add PCB support post
                translate([pcb_support_loc_x - (pcb_r / 2), (pcb_support_loc_y + ct2) - (pcb_r / 2), (pcb_z / 2) + (ct * 0.75)]) {
                    hull() {
                        cylinder(h = pcb_z, d = batt_edge_offset);
                        translate([pcb_support_length - (batt_edge_offset / 2), 0, 0]) {
                            cylinder(h = pcb_z, d = batt_edge_offset);
                        }
                    }
                }
            }
            color("green") {
                translate([(pcb_x + ct2) / 2, (pcb_y + ct2) / 2, -0.6]) {
                    import("qcc-badge-block.stl");
                }
            }
        }
    }
}

main();