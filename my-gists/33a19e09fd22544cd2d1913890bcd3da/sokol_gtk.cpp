#define SOKOL_IMPL
#include "sokol_app.h"

// static void my_gtk_realize(GtkWidget* widget, gpointer user)
// {
//     printf("my_gtk_realize\n");
//     gtk_widget_set_window(widget, (GdkWindow*)user);
// }

static void init_func(void)
{
    printf("init_func\n");

    // get X Window from sokol_app
    // Window x11_win = _sapp.x11.window;

    // GdkDisplay* gd = gdk_display_get_default();
    // Display* d = GDK_DISPLAY_XDISPLAY(gd);
    // XMapRaised(d, x11_win);

    // GdkWindow* gw = gdk_x11_window_foreign_new_for_display(gd, x11_win);
    // GtkWidget* gtk = gtk_widget_new(GTK_TYPE_WINDOW, NULL);
    // g_signal_connect(gtk, "realize", G_CALLBACK(my_gtk_realize), gw);
    // gtk_widget_set_has_window(gtk, TRUE);
    // gtk_widget_realize(gtk);

    // gtk_widget_show_all(gtk);
}

static void frame_func(void)
{
    // process gtk events
    while (gtk_events_pending())
    {
        gtk_main_iteration();
    }
}

static void cleanup_func(void)
{
    printf("cleanup_func\n");
}

static void event_func(const sapp_event* e)
{
    if (e->type == SAPP_EVENTTYPE_MOUSE_DOWN &&
        e->mouse_button == SAPP_MOUSEBUTTON_RIGHT)
    {
        printf("right mouse down!\n");

        if (!gtk_init_check(NULL, NULL))
        {
            printf("gtk_init_check failed!\n");
            return;
        }

        GtkWidget *menu_gtk = gtk_menu_new ();

        GtkWidget *hide = gtk_menu_item_new_with_label("Minimize");
        gtk_widget_show(hide);
        gtk_menu_shell_append(GTK_MENU_SHELL(menu_gtk), hide);

        GtkWidget *quit = gtk_menu_item_new_with_label("Quit");
        gtk_widget_show(quit);
        gtk_menu_shell_append(GTK_MENU_SHELL(menu_gtk), quit);

        gtk_widget_show(menu_gtk);

        // note, below function is deprecated but should work
        gtk_menu_popup(GTK_MENU(menu_gtk),
                       NULL, NULL, NULL, NULL,
                       0, gtk_get_current_event_time());

        printf("trying to do popup\n");
    }
}

sapp_desc sokol_main(int argc, char* argv[])
{
    printf("sokol_main\n");

    gtk_init(&argc, &argv);

    sapp_desc desc = {};
    desc.window_title = "sokol + gtk";
    desc.width = 640;
    desc.height = 480;
    desc.high_dpi = true;
    desc.init_cb = init_func;
    desc.frame_cb = frame_func;
    desc.cleanup_cb = cleanup_func;
    desc.event_cb = event_func;
    return desc;
}
