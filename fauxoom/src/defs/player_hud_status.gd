class_name PlayerHudStatus

# primary status
var health:int = 100
var energy:int = 100
var yawDegrees:float = 0
var currentAmmo:int = 0
var currentLoaded:int = 0
var currentLoadedMax:int = 0
var hasInteractionTarget:bool = false
var isNearWall:bool = false
var weaponChargeMode:int = 0
var swayScale:float = 0
var swayTime:float = 0
var slimeOverlapPercentage:float = 0.0

var hyperLevel:int = 0
var hyperTime:float = 0.0
var hyperSecondsRemaining:float = 0.0

var targetHealth:float = -1
var targetVulnerable:bool = false
var targetInvulnerable:bool = false

# inventory
var bullets:int = 0
var shells:int = 0
var rockets:int = 0
var plasma:int = 0
var fuel:int = 0

var bulletsPercentage:float = 0.0
var shellsPercentage:float = 0.0
var rocketsPercentage:float = 0.0
var plasmaPercentage:float = 0.0
var fuelPercentage:float = 0.0

# resources
var rage:int = 0
var bonus:int = 0
var chainsawRevs:float = 0.0

var hasPistol:bool = false
var hasSuperShotgun:bool = false
var hasRocketLauncher:bool = false
var hasRailgun:bool = false
var hasFlameThrower:bool = false

# cheats
var godMode:bool = false
