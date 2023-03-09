![logo](logo.png)

# Nodot3D
**A 3D video game helper library for Godot 4**

## What is Nodot3D?

Nodot is a 3D video game oriented collection of nodes, autoload scripts and scenes for Godot 4. The goal is to provide a set of tools that can be used to rapidly create a wide variety of games.

---

## Scenes

### UI

#### Menus

- MenuContainer - A container for menus
- MainMenu - A generic main menu
- OptionsMenu - An options menu with general purpose options
- MultiplayerMenu - A menu for multiplayer options
- MultiplayerServerBrowser - A menu for a multiplayer server browser
- MultiplayerLobbyMenu - A menu for multiplayer lobbies
- PauseMenu - A pause menu with basic options

#### Interfaces

- Inventory - An interface for inventory management
- TechTree - An interface for a tech tree
- QuestLog - An interface for a quest log
- QuestProgress - An interface for quest progress
- Chat - A simple interface for multiplayer chat
- MiniMap - A simple interface for a mini map
- LoadingScreen - A loading screen for scenes

### Characters

#### First Person

- FirstPersonCharacter - A node to create a first person character
- FirstPersonKeyboardInput - A node to handle first person keyboard input
- FirstPersonJoypadInput - A node to handle first person joypac input
- FirstPersonMouseInput - A node to handle first person mouse input
- FirstPersonViewport - A node to create a first person viewport to support hands/items and UI

#### Third Person

- ThirdPersonCharacter - A node to create a third person character
- ThirdPersonKeyboardInput - A node to handle third person keyboard input
- ThirdPersonJoypadInput - A node to handle third person joypac input
- ThirdPersonMouseInput - A node to handle third person mouse input
  
### Vehicles

- Vehicle - A node to create a vehicle
- VehicleCamera - A node to add a vehicle camera
- VehicleKeyboardInput - A node to handle generic vehicle keyboard input
- VehicleJoypadInput - A node to handle generic vehicle joypad input
- VehicleMouseInput - A node to handle generic vehicle mouse input

#### Bike

- Bike - A node to create a bike
- BikeKeyboardInput - A node to handle bike keyboard input
- BikeJoypadInput - A node to handle bike joypad input
- BikeMouseInput - A node to handle bike mouse input

#### Car

- Car - A node to create a car
- CarKeyboardInput - A node to handle car keyboard input
- CarJoypadInput - A node to handle car joypad input
- CarMouseInput - A node to handle car mouse input

#### Boat

- Boat - A node to create a boat
- BoatKeyboardInput - A node to handle boat keyboard input
- BoatJoypadInput - A node to handle boat joypad input
- BoatMouseInput - A node to handle boat mouse input

#### Airplane

- Airplane - A node to create an airplane
- AirplaneKeyboardInput - A node to handle airplane keyboard input
- AirplaneJoypadInput - A node to handle airplane joypad input
- AirplaneMouseInput - A node to handle airplane mouse input

#### Spaceship

- Spaceship - A node to create a spaceship
- SpaceshipKeyboardInput - A node to handle spaceship keyboard input
- SpaceshipJoypadInput - A node to handle spaceship joypad input
- SpaceshipMouseInput - A node to handle spaceship mouse input

### AI

- LineOfSight - A line of sight to detect nodes in line of sight
- ViewCone - A view cone to detect nodes in line of sight within the limits of the cone

### Targetting

- HitScan - Simulate a fast object being fired at a target
- Projectile - Simulate a slow moving object being fired at a target
- HomingProjectile - Simulate a slow moving object that homes in on a target

### Damage

- Damagable - A node to apply damage
- Explosion - An explosion area damage with line of sight
- DamageArea - Interval based area damage

### Effects

- ImpactDecal - For adding bullet holes/blood splashes etc to surfaces
- CanvasAttachment - A CanvasContainer that follows a 3D node
- HealthBar - A node to display a health bar
- ObjectOutliner - A node to outline objects
- MuzzleFlash - A node to create a light flash and temporary effect such as a muzzle flash

#### Weather

- RainEffect - A node to create rain effects
- WindEffect - A node to create wind effects
- SnowEffect - A node to create snow effects
- FogEffect - A node to create fog effects

### Environment

#### Elements

- Fire - A node to create fire
- Water - A node to create water

### Interactive

- Breakable - A node to create breakable objects
- ShrapnelEmitter - A node to create a shrapnel emitter (e.g. glass shards)
- Button3D - A node to create an interactive 3D button

### First Person

- FPSItem - A node to create a first person item (i.e gun, hammer etc)
- FPSIronSight - A node to position an ironsight camera
- FPSLaunchPosition - A node to position the point at which a projectile is launched
- FPSLeftHand - A node to attach a left hand to the weapon
- FPSRightHand - A node to attach a right hand to the weapon
- FPSArms - A node to attach hands to the weapon

### Sound

- SFXPlayer - A node to play sound effects
- MusicPlayer - A node to play music
- FootStepSounds - A node to manage and play footstep sounds
- EngineSound - A node to manage and play motor engine sounds

## Autoload Scripts

- SaveManager - A node to save and load game data
- PlayerManager - A node to manage player data
- WindowManager - A node to manage the game window
- NetworkManager - A simple network manager for multiplayer games
- SceneManager - A node to manage scene loading