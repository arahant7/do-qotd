from datetime import datetime

def human_friendly_time(ts):
    now = datetime.utcnow()
    td = ts - now
    total_secs = td.days * (24 * 60 * 60) + td.seconds
    #python negative division is weird. See https://stackoverflow.com/q/5535206/354448
    #whatever happened to the principal of least surprise
    tabs = abs(total_secs)
    pos = True if total_secs >= 0 else False
    
    days = tabs // (24*60*60)
        
    res = None
    if days > 1:
        res =  "{} days".format(days)
    elif days == 1:
        res =  "1 day"
    if res:
        if not pos:
            res = res + " ago"
        return res
        
    daysfrac = tabs - (days * 24*60*60)
    hrs = daysfrac // (60 * 60)
        
    hrsfrac = daysfrac - (hrs * 60*60)
    mins = hrsfrac // 60
    
    hswitch = {
        1: "1 hour",
        0: ""
    }
    h = hswitch.get(hrs, "{} hours".format(hrs))
    mswitch = {
        1: "1 minute",
        0: ""
    }
    m = mswitch.get(mins, "{} minutes".format(mins))
    
    if not h and not m:
        res = "a few seconds"
    else:
        res = h + " " + m
        
    if not pos:
        res = res + " ago"
        
    return res.strip() 

