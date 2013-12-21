@feedbackAdded = false

# Add the user feedback feature to the page.
feedback = ->
  # log.trace()

  # Only load and configure the feedback widget once.
  return if @feedbackAdded

  # Create a script element to load the UserVoice widget.
  uv       = document.createElement 'script'
  uv.async = 'async'
  uv.src   = "https://widget.uservoice.com/akwF2Qs6Se6qr848MmMA.js"
  # Insert the script element into the DOM.
  script = document.getElementsByTagName('script')[0]
  script.parentNode.insertBefore uv, script

  # Configure the widget as it's loading.
  UserVoice = window.UserVoice or= []
  UserVoice.push [
    'showTab'
    'classic_widget'
    {
      mode: 'full',
      primary_color: '#cc6d00',
      link_color: '#007dbf',
      default_mode: 'feedback',
      forum_id: 191718,
      topic_id: 37728,
      support_tab_name: 'Support',
      feedback_tab_name: 'Feedback',
      tab_label: 'Talk to us!',
      tab_color: '#cc6d00',
      tab_position: 'bottom-right',
      tab_inverted: true
    }
  ]

  # Ensure that the widget isn't loaded again.
  @feedbackAdded = yes

feedback()


# <!-- UserVoice JavaScript SDK (only needed once on a page) -->
# <script>(function(){var uv=document.createElement('script');uv.type='text/javascript';uv.async=true;uv.src='//widget.uservoice.com/akwF2Qs6Se6qr848MmMA.js';var s=document.getElementsByTagName('script')[0];s.parentNode.insertBefore(uv,s)})()</script>

# <!-- A tab to launch the Classic Widget -->
# <script>
# UserVoice = window.UserVoice || [];
# UserVoice.push(['showTab', 'classic_widget', {
#   mode: 'full',
#   primary_color: '#cc6d00',
#   link_color: '#007dbf',
#   default_mode: 'feedback',
#   forum_id: 191718,
#   topic_id: 37728,
#   support_tab_name: 'Support',
#   feedback_tab_name: 'Feedback',
#   tab_label: 'Talk to us!',
#   tab_color: '#cc6d00',
#   tab_position: 'top-left',
#   tab_inverted: true
# }]);
# </script>