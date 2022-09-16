# Diesel-Safe
Safe System For QB-Core Fivem FrameWork

[[ BE CAREFULL SCRIPT ISN't 100% Tested But If There Is Any Peoblem With It Just Open Issue Or Contact Me In My Discord Server https://discord.gg/My2BvpRb57 ]] 

System For Createing Safes With Password On Any Locations Using Coords So Be Carefull When You Use It in Apartment System That Utilize Multi Dimension But Same Coords

For My Script To Work Properly You Will Need The Following : 
1- QBCore Framework
2- QB-Target
3- QB-Inventory

*** Installation ***

First You Have To Configure Config File By Adding The name Of Your Safes Item And Each Item How Much Slot And Weight You Need
Eg: 
```lua
Config.Safes = {
    [1] = {
        name = 'safe1', -- item name that must be registered as usable item 
        weight = 50000, -- max weight of the stash of this item
        slots = 50, --slots of the stash of this item 
        model = 'prop_ld_int_safe_01', -- model of the object that will be created
        hash = `prop_ld_int_safe_01`, --model hash of the model
        type = 1 -- type of the safe which has to be unique better to be same as the index
    },

    [2] = {
        name = 'safe2',
        weight = 100000,
        slots = 50,
        model = 'p_v_43_safe_s', 
        hash = `p_v_43_safe_s`,
        type = 2
    }
}
```

Then You have to import the SQl File 
Then Run The Script In Your Server And Have Fun With it 
