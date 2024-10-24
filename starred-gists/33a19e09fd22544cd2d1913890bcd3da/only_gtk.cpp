#include <gtk/gtk.h>

int show_popup(GtkWidget *widget, GdkEvent *event)
{

  const gint RIGHT_CLICK = 3;

  if (event->type == GDK_BUTTON_PRESS)
  {

      GdkEventButton *bevent = (GdkEventButton *) event;
      if (bevent->button == RIGHT_CLICK)
      {
          gtk_menu_popup(GTK_MENU(widget), NULL, NULL, NULL, NULL,
              bevent->button, bevent->time);
      }

      return TRUE;
  }

  return FALSE;
}

int main(int argc, char *argv[])
{

    gtk_init(&argc, &argv);

    GtkWidget *window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
    gtk_window_set_position(GTK_WINDOW(window), GTK_WIN_POS_CENTER);
    gtk_window_set_default_size(GTK_WINDOW(window), 300, 200);
    gtk_window_set_title(GTK_WINDOW(window), "Popup menu");

    GtkWidget *ebox = gtk_event_box_new();
    gtk_container_add(GTK_CONTAINER(window), ebox);

    GtkWidget *pmenu = gtk_menu_new();

    GtkWidget *hideMi = gtk_menu_item_new_with_label("Minimize");
    gtk_widget_show(hideMi);
    gtk_menu_shell_append(GTK_MENU_SHELL(pmenu), hideMi);

    GtkWidget *quitMi = gtk_menu_item_new_with_label("Quit");
    gtk_widget_show(quitMi);
    gtk_menu_shell_append(GTK_MENU_SHELL(pmenu), quitMi);


    g_signal_connect_swapped(G_OBJECT(ebox), "button-press-event",
      G_CALLBACK(show_popup), pmenu);

    gtk_widget_show_all(window);


    // note, you can uncomment the below function to make it display the popup without going through the mouse event
    // gtk_menu_popup (GTK_MENU (pmenu),
    //                       NULL, NULL, NULL, NULL,
    //                       1, gtk_get_current_event_time());

    while (true)
    {
        while (gtk_events_pending())
        {
          gtk_main_iteration();
        }
    }

    return 0;
}
