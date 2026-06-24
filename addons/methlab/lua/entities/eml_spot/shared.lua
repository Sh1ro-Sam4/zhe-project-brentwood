ENT.Base = "base_gmodentity"
ENT.Type = "anim"

ENT.PrintName       = "Универсальный котелок"
ENT.Category        = "RP"
ENT.Spawnable       = true
ENT.AdminSpawnable  = true

POT_RECIPES = {
    ["meth"] = {
        name = "Мет",
        result = "eml_meth",
        time = 30,
        ingri = {
            ["eml_redp"] = {name = "Красный фосфор", amount = 1},
            ["eml_ciodine"] = {name = "Йод", amount = 1},
            ["eml_salt"] = {name = "Соль", amount = 1}
        }
    },
    ["bread"] = {
        name = "Хлеб",
        result = "bread",
        time = 60,
        ingri = {
            ["water"] = {name = "Вода", amount = 1},
            ["wheat"] = {name = "Пшеница", amount = 3}
        }
    },
    ["chips"] = {
        name = "Чипсы",
        result = "chips",
        time = 45,
        ingri = {
            ["potato"] = {name = "Сырая картошка", amount = 3},
            ["oil"] = {name = "Масло", amount = 1}
        }
    },
    ["coffe"] = {
        name = "Кофе",
        result = "coffe",
        time = 30,
        ingri = {
            ["water"] = {name = "Вода", amount = 1},
            ["coffe_seed"] = {name = "Кофейные зерна", amount = 2}
        }
    },
    ["pancake"] = {
        name = "Блины",
        result = "pancake",
        time = 70,
        ingri = {
            ["milk"] = {name = "Молоко", amount = 1},
            ["wheat"] = {name = "Пшеница", amount = 2},
            ["egg"] = {name = "Яйцо", amount = 1},
            ["oil"] = {name = "Масло", amount = 1}
        }
    },
    ["pie"] = {
        name = "Яблочный пирог",
        result = "pie",
        time = 90, -- Пирог сытный (45)
        ingri = {
            ["wheat"] = {name = "Пшеница", amount = 2},
            ["apple"] = {name = "Яблоко", amount = 3},
            ["egg"] = {name = "Яйцо", amount = 1},
            ["milk"] = {name = "Молоко", amount = 1}
        }
    },
    ["pizza"] = {
        name = "Пицца",
        result = "pizza",
        time = 120, -- Пицца очень сытная (65)
        ingri = {
            ["wheat"] = {name = "Пшеница", amount = 3},
            ["water"] = {name = "Вода", amount = 1},
            ["meat"] = {name = "Сырое мясо", amount = 2},
            ["cheese"] = {name = "Сыр", amount = 2}
        }
    },
    ["conserva"] = {
        name = "Мясная консерва",
        result = "conserva",
        time = 150, -- Самая питательная еда (75), долго готовится
        ingri = {
            ["meat"] = {name = "Сырое мясо", amount = 4},
            ["onion"] = {name = "Лук", amount = 2},
            ["oil"] = {name = "Масло", amount = 1}
        }
    },
    ["ration"] = {
        name = "Сух. Паек",
        result = "ration",
        time = 90, -- (40 сытости)
        ingri = {
            ["meat"] = {name = "Сырое мясо", amount = 2},
            ["cabbage"] = {name = "Капуста", amount = 2},
            ["potato"] = {name = "Сырая картошка", amount = 2},
            ["onion"] = {name = "Лук", amount = 1}
        }
    }
}