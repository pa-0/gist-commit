import wnck
import gtk
import time

if __name__ == '__main__':
  screen = wnck.screen_get_default()
  screen.force_update()
  while True:
    while gtk.events_pending():
      gtk.main_iteration()
    time.sleep(0.5)
    print screen.get_active_window().get_name()
