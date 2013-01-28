Time =
  hoursAgo: (date_str) ->
    time = date_str.getTime()
    # 60
    # 60*2
    # 60*60, 60
    # 60*60*2
    # 60*60*24, 60*60
    # 60*60*24*2
    # 60*60*24*7, 60*60*24
    # 60*60*24*7*4*2
    # 60*60*24*7*4, 60*60*24*7
    # 60*60*24*7*4*2
    # 60*60*24*7*4*12, 60*60*24*7*4
    # 60*60*24*7*4*12*2
    # 60*60*24*7*4*12*100, 60*60*24*7*4*12
    # 60*60*24*7*4*12*100*2
    time_formats = [
      [60, "just now", "just now"],
      [120, "1 minute ago", "1 minute from now"],
      [3600, "minutes", 60],
      [7200, "1 hour ago", "1 hour from now"],
      [86400, "hours", 3600],
      [172800, "yesterday", "tomorrow"],
      [604800, "days", 86400],
      [1209600, "last week", "next week"],
      [2419200, "weeks", 604800],
      [4838400, "last month", "next month"],
      [29030400, "months", 2419200],
      [58060800, "last year", "next year"],
      [2903040000, "years", 29030400],
      [5806080000, "last century", "next century"],
      [58060800000, "centuries", 2903040000]
    ] # 60*60*24*7*4*12*100*20, 60*60*24*7*4*12*100
    
    seconds = (new Date - new Date(time)) / 1000
    token = "ago"
    list_choice = 1
    if seconds < 0
      seconds = Math.abs(seconds)
      token = "from now"
      list_choice = 2
    i = 0
    format = undefined
    while format = time_formats[i++]
      if seconds < format[0]
        if typeof format[2] is "string"
          return format[list_choice]
        else
          return Math.floor(seconds / format[2]) + " " + format[1] + " " + token
    time

  toDateFromAspNet: (str) ->
    dte = eval("new " + str.replace(/\//g, "") + ";")
    dte.setMinutes dte.getMinutes() - dte.getTimezoneOffset()
    dte

module.exports = Time
