@checkFooter = () ->
  if Cookies.get('hidefooter') == 'true'
    hideFooter()

@hideFooter = () ->
  $('footer .cookies').hide()
  Cookies.set 'hidefooter', 'true', { expires: 356 }


$(document).ready ->
  checkFooter()
