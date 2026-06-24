shizlib.imgCache = shizlib.imgCache or {}
shizlib.Achievements = shizlib.Achievements or {}
shizlib.Achievements.CFG = {
    ['#f4_open'] = {
        name = 'Что-то новое..',
        description = [[
            Нажать F4
        ]],
        icon = 'kasanov/misc/achievement.png',
    },
    ['#death'] = {
        name = 'В первый раз, да?',
        description = [[
            Умереть 1 раз
        ]],
        icon = 'kasanov/misc/achievement.png',
    },
    ['#kill'] = {
        name = 'Первая "Сотня"',
        description = [[
            Убейте 100 игроков
        ]],
        icon = 'kasanov/misc/achievement.png',
        needToGet = 100,
    },
    ['#monster'] = {
        name = 'Чудовище..',
        description = [[
            Убейте 1000 игроков
        ]],
        secret = true,
        icon = 'kasanov/misc/achievement.png',
        needToGet = 1000,
    },
    ['#accessory'] = {
        name = 'Я красивый?',
        description = [[
            Воспользуйтесь любым косметическим предметом
        ]],
        icon = 'kasanov/misc/achievement.png',
    },
    ['#craft'] = {
        name = 'Великий инженер',
        description = [[
            Скрафтить любой предмет
        ]],
        icon = 'kasanov/misc/achievement.png',
    },
    ['#admin_ctp'] = {
        name = 'Ого! Куда это я?',
        description = [[
            Админ тп!
        ]],
        secret = true,
        icon = 'kasanov/misc/achievement.png',
    },
    ['#dev'] = {
        name = '#dev',
        description = [[
            Получить Куб Разработчика
        ]],
        secret = true,
        icon = 'kasanov/misc/achievement.png',
    },
    ['#looting'] = {
        name = 'Искатель',
        description = [[
            Найти предмет в мусорке
        ]],
        icon = 'kasanov/misc/achievement.png',
    },
    ['#thxCommand'] = {
        name = 'Ой, спасибочки!',
        description = [[
            Поблагодарить игрока за Глобальный Буст
        ]],
        icon = 'kasanov/misc/achievement.png',
    },
    ['#kasanov'] = {
        name = 'Тебя обвели как лоха',
        description = [[
            Попытаться кликнуть на создателя в табе
        ]],
        secret = true,
        icon = 'kasanov/misc/achievement.png',
    },
    ['#clearCurse'] = {
        name = 'Камень очищения или же нет?',
        description = [[
            Использовать "Осколок Мироздания"
        ]],
        secret = true,
        icon = 'kasanov/misc/achievement.png',
    },

    /*
        СУПЕР ДОСТИЖЕНИЯ
    */
    ['#secret_founder'] = {
        name = 'Кладоискатель',
        description = [[
            ДА! Я нашел их все!
        ]],
        secret = true,
        icon = 'kasanov/misc/achievement.png',
    },
}