--I moved everything  to one file.

-- Drawing 3D2D things distance.
EML_DrawDistance = 300;

-- Stove consumption on heat amount.
EML_Stove_Consumption = 1;
-- Stove heat amount.
EML_Stove_Heat = 1;
-- Amount of gas inside.
EML_Stove_Storage = 600;
-- Can grab with gravity gun?
EML_Stove_GravityGun = true;
-- 0 - Can't be exploded/destroyed; 1 - Can be destroyed without explosion; 2 - Explodes after taking amount of damage.
EML_Stove_ExplosionType = 2;
-- Stove health if type 1 or 2.
EML_Stove_Health = 100;
-- Stove explosion damage if type 2.
EML_Stove_ExplosionDamage = 70;
-- Stove smoke color.
EML_Stove_SmokeColor_R = 100;
EML_Stove_SmokeColor_G = 100;
EML_Stove_SmokeColor_B = 0;
-- Stove indicator color.
EML_Stove_IndicatorColor = Color(255, 222, 0, 255);

--Красний фосфор
-- Стандартное время приготовления красного фосфора.
EML_Pot_StartTime = 60; --60
-- Сколько времени прибавится если добавить 1 Сольную кислоту.
EML_Pot_OnAdd_MuriaticAcid = 8;
-- Сколько времени прибавится если добавить 1 Серу.
EML_Pot_OnAdd_LiquidSulfur = 8;
-- Сколько времени прибавится если добавить 1 Воду. 
EML_Pot_OnAdd_Water = 8;
-- Change to false if you won't water/iodine/acid/sulfur disappear on empty.
EML_Pot_DestroyEmpty = true;


--Мет
-- Стандартное время приготовления мета.
EML_SpecialPot_StartTime = 120; 
-- Сколько времени прибавится если добавить 1 красный фосфор.
EML_SpecialPot_OnAdd_RedPhosphorus = 12;
-- Сколько времени прибавится если добавить 1 йод.
EML_SpecialPot_OnAdd_CrystallizedIodine = 10;
-- Сколько времени прибавится если добавить 1 соль.
EML_SpecialPot_OnAdd_Salt = 8;
-- Change to false if you won't Red Phosphorus/Crystallized Iodine disappear on empty.
EML_SpecialPot_DestroyEmpty = true;


-- Стандартное количество сери
EML_Sulfur_Amount = 4;
EML_Sulfur_Color = Color(243, 213, 19, 255);
-- Default Muriatic Acid amount.
EML_MuriaticAcid_Amount = 6;
EML_MuriaticAcid_Color = Color(160, 221, 99, 255);
-- Стандартное количество Жидкого йода
EML_Iodine_Amount = 2;
EML_Iodine_Color = Color(150, 80, 60, 255);
-- Стандартное количество воды
EML_Water_Amount = 5;
EML_Water_Color = Color(133, 202, 219, 255);
-- Стандартное количество Соли
EML_Salt_Amount = 5;
EML_Salt_Color = Color(133, 202, 219, 255);
-- Цвет цифры которая указывает на оставшийся количество продукта
EML_Pathos_Color = Color(90, 255, 0, 220);

-- Цена мета за один кристал (1500/lbs)
EML_Meth_ValueModifier = 20;
-- Meth addicted person (I don't like NPCs at all).
EML_Meth_UseSalesman = true;
-- Подать игрока в розыск если он продал мет.
EML_Meth_MakeWanted = true;

-- Type 'methbuyer_setpos <name>' to add NPC on map (at your target position and faces to you).
-- Type 'methbuyer_remove <name>' to remove NPC from map.

-- Use text above salesman's head?
EML_Meth_SalesmanText = true;
-- Salesman name.
EML_Meth_Salesman_Name = "Meth Addict";
-- Salesman name color.
EML_Meth_Salesman_Name_Color = Color(25, 220, 60, 260);
-- Комментируемые фразы, в чат если у игрока нет мета.
EML_Meth_Salesman_NoMeth = {
	"Go away! And don't come back without some ROCK!",
	"Are you an idiot? Where's my meth?!",
	"Are you trying to trick me?",
	};
-- Комментируемые фразы, если у игрока нет мета.
EML_Meth_Salesman_NoMeth_Sound = {
	"vo/npc/male01/gethellout.wav",
	"vo/npc/male01/no02.wav",
	"vo/npc/male01/no01.wav",
	"vo/npc/male01/ohno.wav"	
	};
-- .
EML_Meth_Salesman_GotMeth = {
	"This is some clear crystal!",
	"Time for some fun!",
	"I've had better...",
	"I hope this stuff doesn't kill me!"
	};	
-- Комментируемые фразы, если у игрока есть мет.
EML_Meth_Salesman_GotMeth_Sound = {
	"vo/npc/male01/yeah02.wav",
	"vo/npc/male01/finally.wav",
	"vo/npc/male01/oneforme.wav",
	};

-- It starts on 0%.
EML_Jar_StartProgress = 4;
-- Minimal speed on shaking. (25 is ok)
EML_Jar_MinShake = 25;
-- Minimal speed on shaking. (1000 is ok)
EML_Jar_MaxShake = 500;
-- Progress on correct shaking.
EML_Jar_CorrectShake = 6;
-- Progress on correct shaking.
EML_Jar_WrongShake = 2;
-- Change to false if you won't acid/iodine/water disappear on empty.
EML_Jar_DestroyEmpty = true;


-- Default gas amount in gas canister.
EML_Gas_Amount = 2500;
-- 0 - Can't be exploded/destroyed; 1 - Can be destroyed without explosion; 2 - Explodes instantly.
EML_Gas_ExplosionType = 1;
-- Removes when out of gas.
EML_Gas_Remove = true;

EML_OC_Color = Color(90, 255, 0, 220);