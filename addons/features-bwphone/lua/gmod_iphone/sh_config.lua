iPhoneOS = iPhoneOS or {}
iPhoneOS.Config = iPhoneOS.Config or {}

iPhoneOS.Config.PHONE_WIDTH = 340
iPhoneOS.Config.PHONE_HEIGHT = 700
iPhoneOS.Config.SCREEN_PADDING = 12
iPhoneOS.Config.SCREEN_W = iPhoneOS.Config.PHONE_WIDTH - (iPhoneOS.Config.SCREEN_PADDING * 2)
iPhoneOS.Config.SCREEN_H = iPhoneOS.Config.PHONE_HEIGHT - (iPhoneOS.Config.SCREEN_PADDING * 2)
iPhoneOS.Config.ICON_SIZE = 60

iPhoneOS.PhoneSounds = {
    Click = "UI/buttonclick.wav",           
    Rollover = "UI/buttonrollover.wav",     
    Notification = "bobby/sms_notification.wav",     
    Ringtone = "garrysmod/save_load1.wav",  
    RingtoneDuration = 2,                   
    DialTone = "phone/gudok.wav",         
    DialToneDuration = 3,                 
    Camera = "npc/scanner/scanner_photo1.wav", 
    SendSMS = "phone/smsnotification.wav",   
    Error = "buttons/button10.wav",
    Win = "ui/freeze_cam.wav"
}

iPhoneOS.Themes = {
    { name = "Dark Pink (Glock)", bg = Color(20, 20, 22), bg2 = Color(30, 30, 33), text = color_white, subText = Color(160, 160, 165), accent = Color(224, 64, 101), bubbleRecv = Color(40, 40, 45), line = Color(50, 50, 55) }
}

iPhoneOS.presetRadios = {
    {name = "181.fm Power (Top 40)", url = "http://listen.181fm.com/181-power_128k.mp3"},
    {name = "181.fm The Beat (HipHop)", url = "http://listen.181fm.com/181-beat_128k.mp3"},
    {name = "181.fm The Eagle (Rock)", url = "http://listen.181fm.com/181-eagle_128k.mp3"},
    {name = "Kickin Country", url = "http://listen.181fm.com/181-kickincountry_128k.mp3"}
}

function iPhoneOS.GetTheme() 
    return iPhoneOS.Themes[iPhoneOS.PhoneData and iPhoneOS.PhoneData.ThemeIdx or 1] or iPhoneOS.Themes[1] 
end

-- Алиасы для удобства (app файлы используют iPhoneOS.SCREEN_W и т.д.)
iPhoneOS.PHONE_WIDTH = iPhoneOS.Config.PHONE_WIDTH
iPhoneOS.PHONE_HEIGHT = iPhoneOS.Config.PHONE_HEIGHT
iPhoneOS.SCREEN_PADDING = iPhoneOS.Config.SCREEN_PADDING
iPhoneOS.SCREEN_W = iPhoneOS.Config.SCREEN_W
iPhoneOS.SCREEN_H = iPhoneOS.Config.SCREEN_H
iPhoneOS.ICON_SIZE = iPhoneOS.Config.ICON_SIZE
